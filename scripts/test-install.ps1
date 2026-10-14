#!/usr/bin/env pwsh
#Requires -Version 5.1
# Integration test for setup.ps1: install, backup, idempotency, and dry-run
# behaviors, isolated from the real HOME (mirrors scripts/test-install.sh).

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$setupScript = Join-Path $repoRoot 'setup.ps1'

$taskTestRoot = Join-Path $env:TEMP ('omochi-install-test-' + [Guid]::NewGuid().ToString('N'))
$fakeBin = Join-Path $taskTestRoot 'fake bin'
$callsLog = Join-Path $taskTestRoot 'calls.log'

function Fail([string]$Message) {
  [Console]::Error.WriteLine("error: $Message")
  exit 1
}

function Assert([bool]$Condition, [string]$Message) {
  if (-not $Condition) { Fail $Message }
}

if (Get-Command pwsh -ErrorAction SilentlyContinue) {
  $psExe = (Get-Command pwsh).Source
} else {
  $psExe = (Get-Command powershell).Source
}

# Run setup.ps1 in a child process with an isolated HOME and PATH. setup.ps1
# reads $HOME, which a child PowerShell resolves from the USERPROFILE env var.
function Invoke-Setup {
  param(
    [Parameter(Mandatory)][string]$TestHome,
    [string]$PathPrefix,
    [string]$PathOverride,
    [string]$RepoUrl,
    [switch]$DryRun
  )
  $savedUserProfile = $env:USERPROFILE
  $savedHome = $env:HOME
  $savedPath = $env:PATH
  $savedRepoUrl = $env:AI_SETUP_REPO_URL
  try {
    $env:USERPROFILE = $TestHome
    $env:HOME = $TestHome
    if ($PathOverride) {
      $env:PATH = $PathOverride
    } elseif ($PathPrefix) {
      $env:PATH = "$PathPrefix;$savedPath"
    }
    $env:AI_SETUP_REPO_URL = $RepoUrl
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setupScript)
    if ($DryRun) { $arguments += '-DryRun' }
    # Native stderr records must not terminate this script, so capture them
    # under Continue and restore Stop afterwards.
    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
      $output = & $psExe @arguments 2>&1
      $exitCode = $LASTEXITCODE
    } finally {
      $ErrorActionPreference = $previousEap
    }
    return @{ ExitCode = $exitCode; Output = ($output | Out-String) }
  } finally {
    $env:USERPROFILE = $savedUserProfile
    $env:HOME = $savedHome
    $env:PATH = $savedPath
    $env:AI_SETUP_REPO_URL = $savedRepoUrl
  }
}

try {
  # Fake tools shadow the real ones so a broken skip-check cannot install
  # anything; every invocation is logged.
  $env:OMOCHI_CALLS_LOG = $callsLog
  New-Item -ItemType Directory -Force -Path $fakeBin | Out-Null
  foreach ($tool in 'opencode', 'bun', 'rtk') {
    $lines = @('@echo off', 'echo %*>>"%OMOCHI_CALLS_LOG%"')
    if ($tool -eq 'opencode') { $lines += 'if "%1"=="--version" echo 2.0.1' }
    $lines += 'exit /b 0'
    Set-Content -Path (Join-Path $fakeBin "$tool.cmd") -Value ($lines -join "`r`n") -Encoding Ascii
  }
  foreach ($tool in 'npm', 'winget') {
    $lines = @('@echo off', "echo $tool %*>>`"%OMOCHI_CALLS_LOG%`"", 'exit /b 1')
    Set-Content -Path (Join-Path $fakeBin "$tool.cmd") -Value ($lines -join "`r`n") -Encoding Ascii
  }

  # Snapshot the working tree — not just HEAD — so setup.ps1 is exercised
  # against uncommitted changes too.
  $snapshot = Join-Path $taskTestRoot 'repo'
  New-Item -ItemType Directory -Force -Path $snapshot | Out-Null
  $tarball = Join-Path $taskTestRoot 'snapshot.tar'
  & tar -C $repoRoot --exclude=./.git -cf $tarball .
  Assert ($LASTEXITCODE -eq 0) 'snapshot tar failed'
  & tar -C $snapshot -xf $tarball
  Assert ($LASTEXITCODE -eq 0) 'snapshot extract failed'
  & git -C $snapshot init -q
  & git -C $snapshot add -A
  & git -C $snapshot -c user.email=test@example.com -c user.name=test commit -qm snapshot
  Assert ($LASTEXITCODE -eq 0) 'snapshot commit failed'
  $repoUrl = 'file:///' + ($snapshot -replace '\\', '/')

  $freshHome = Join-Path $taskTestRoot 'fresh home'
  New-Item -ItemType Directory -Force -Path $freshHome | Out-Null
  $result = Invoke-Setup -TestHome $freshHome -PathPrefix $fakeBin -RepoUrl $repoUrl
  Assert ($result.ExitCode -eq 0) "fresh install exited $($result.ExitCode): $($result.Output)"
  Assert (Test-Path -LiteralPath (Join-Path $freshHome 'omochi\.git')) 'installer did not clone the repository'
  $calls = @()
  if (Test-Path -LiteralPath $callsLog) { $calls = @(Get-Content -LiteralPath $callsLog | Where-Object { $_ }) }
  $unexpected = @($calls | Where-Object { $_ -notmatch '^--version' })
  Assert ($unexpected.Count -eq 0) "installer invoked tools that were already installed: $($unexpected -join '; ')"
  'ok: already-installed path skips installs and clones'

  $repoSkillCount = @(Get-ChildItem (Join-Path $repoRoot '.agents\skills') -Recurse -Filter 'SKILL.md').Count
  $installedSkillCount = @(Get-ChildItem (Join-Path $freshHome '.agents\skills') -Recurse -Filter 'SKILL.md').Count
  Assert ($installedSkillCount -eq $repoSkillCount) "installer installed $installedSkillCount skills, repository has $repoSkillCount"
  'ok: skills installed into ~/.agents/skills'

  Assert (Test-Path -LiteralPath (Join-Path $freshHome '.config\opencode\plugins\rtk.ts')) 'installer did not install the rtk plugin'
  $sourceHash = (Get-FileHash (Join-Path $repoRoot 'plugins\rtk.ts')).Hash
  $installedHash = (Get-FileHash (Join-Path $freshHome '.config\opencode\plugins\rtk.ts')).Hash
  Assert ($sourceHash -eq $installedHash) 'installed rtk plugin differs from the repository copy'
  $sourceHash = (Get-FileHash (Join-Path $repoRoot 'templates\global-AGENTS.md')).Hash
  $installedHash = (Get-FileHash (Join-Path $freshHome '.config\opencode\AGENTS.md')).Hash
  Assert ($sourceHash -eq $installedHash) 'installed global AGENTS.md differs from the template'
  Assert (Test-Path -LiteralPath (Join-Path $freshHome '.config\opencode\templates\project-docs\SPEC.md')) 'installer did not install the project-docs templates'
  'ok: plugin, global AGENTS.md, and templates installed'

  $idemHome = Join-Path $taskTestRoot 'idempotent home'
  New-Item -ItemType Directory -Force -Path $idemHome | Out-Null
  $first = Invoke-Setup -TestHome $idemHome -PathPrefix $fakeBin -RepoUrl $repoUrl
  Assert ($first.ExitCode -eq 0) "first idempotency run exited $($first.ExitCode): $($first.Output)"
  $second = Invoke-Setup -TestHome $idemHome -PathPrefix $fakeBin -RepoUrl $repoUrl
  Assert ($second.ExitCode -eq 0) "second idempotency run exited $($second.ExitCode): $($second.Output)"
  $count = @(Get-ChildItem (Join-Path $idemHome '.agents\skills') -Recurse -Filter 'SKILL.md').Count
  Assert ($count -eq $repoSkillCount) 're-running the installer changed the installed skill count'
  $agentsBackups = @(Get-ChildItem (Join-Path $idemHome '.config\opencode') -Filter 'AGENTS.md.bak-*' -ErrorAction SilentlyContinue)
  Assert ($agentsBackups.Count -eq 0) 're-running the installer backed up an unchanged AGENTS.md'
  'ok: re-running the installer keeps the skill set'

  $dirtyHome = Join-Path $taskTestRoot 'dirty home'
  New-Item -ItemType Directory -Force -Path (Join-Path $dirtyHome 'omochi'), (Join-Path $dirtyHome '.config\opencode') | Out-Null
  Set-Content -Path (Join-Path $dirtyHome 'omochi\marker.txt') -Value 'user data'
  Set-Content -Path (Join-Path $dirtyHome '.config\opencode\AGENTS.md') -Value 'local edit'
  $result = Invoke-Setup -TestHome $dirtyHome -PathPrefix $fakeBin -RepoUrl $repoUrl
  Assert ($result.ExitCode -eq 0) "dirty-home install exited $($result.ExitCode): $($result.Output)"

  $backups = @(Get-ChildItem -LiteralPath $dirtyHome -Directory -Filter 'omochi.bak-*')
  Assert ($backups.Count -eq 1) "expected one backup of existing ~/omochi, found $($backups.Count)"
  Assert ((Get-Content -LiteralPath (Join-Path $backups[0].FullName 'marker.txt') -Raw).Trim() -eq 'user data') 'backup did not preserve the existing ~/omochi content'
  Assert (Test-Path -LiteralPath (Join-Path $dirtyHome 'omochi\.git')) 'installer did not clone after backup'
  'ok: dirty ~/omochi is backed up then replaced'

  $agentsBackups = @(Get-ChildItem (Join-Path $dirtyHome '.config\opencode') -Filter 'AGENTS.md.bak-*')
  Assert ($agentsBackups.Count -eq 1) "expected one backup of a locally edited AGENTS.md, found $($agentsBackups.Count)"
  Assert ((Get-Content -LiteralPath $agentsBackups[0].FullName -Raw).Trim() -eq 'local edit') 'AGENTS.md backup did not preserve the local edit'
  $sourceHash = (Get-FileHash (Join-Path $repoRoot 'templates\global-AGENTS.md')).Hash
  $installedHash = (Get-FileHash (Join-Path $dirtyHome '.config\opencode\AGENTS.md')).Hash
  Assert ($sourceHash -eq $installedHash) 'AGENTS.md was not replaced with the template'
  'ok: a locally edited AGENTS.md is backed up then replaced'

  $dryHome = Join-Path $taskTestRoot 'dry home'
  New-Item -ItemType Directory -Force -Path $dryHome | Out-Null
  $result = Invoke-Setup -TestHome $dryHome -PathPrefix $fakeBin -RepoUrl $repoUrl -DryRun
  Assert ($result.ExitCode -eq 0) "dry run exited $($result.ExitCode): $($result.Output)"
  Assert (-not (Test-Path -LiteralPath (Join-Path $dryHome 'omochi'))) 'dry run created ~/omochi'
  Assert (-not (Test-Path -LiteralPath (Join-Path $dryHome '.agents'))) 'dry run created ~/.agents'
  Assert (-not (Test-Path -LiteralPath (Join-Path $dryHome '.config\opencode'))) 'dry run wrote to ~/.config/opencode'
  'ok: dry run changes nothing'

  $missingHome = Join-Path $taskTestRoot 'missing tools home'
  New-Item -ItemType Directory -Force -Path $missingHome | Out-Null
  $minimalPath = "$env:SystemRoot\System32;$env:SystemRoot"
  $result = Invoke-Setup -TestHome $missingHome -PathOverride $minimalPath -RepoUrl $repoUrl -DryRun
  Assert ($result.ExitCode -eq 0) "dry run with missing tools exited $($result.ExitCode): $($result.Output)"
  Assert (-not (Test-Path -LiteralPath (Join-Path $missingHome 'omochi'))) 'dry run with missing tools created ~/omochi'
  Assert ($result.Output -notmatch 'is not recognized') 'dry run produced a command-not-found error'
  Assert ($result.Output -match 'opencode-windows-(x64|arm64)') 'dry run did not preview the opencode download'
  Assert ($result.Output -match 'bun\.sh/install\.ps1') 'dry run did not preview the bun installer'
  Assert ($result.Output -match 'rtk-x86_64-pc-windows-msvc') 'dry run did not preview the rtk download'
  'ok: dry run with missing tools previews installs without running them'

  'installer integration test passed'
} finally {
  if ((Test-Path -LiteralPath $taskTestRoot) -and (Split-Path -Parent $taskTestRoot) -eq $env:TEMP) {
    Remove-Item -LiteralPath $taskTestRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
