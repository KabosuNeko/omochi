#!/usr/bin/env pwsh
#Requires -Version 5.1
# omochi bootstrap (Windows): install opencode + bun + rtk, fetch this repo,
# and install the repo's skills, templates, global AGENTS.md, and rtk plugin.
# Model discovery, opencode.jsonc, and the rtk config are done by the
# AI-driven setup prompt — run it AFTER the manual steps below.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup.ps1 [-DryRun] [-Repo <url>]
#   pwsh -File setup.ps1 [-DryRun] [-Repo <url>]

[CmdletBinding()]
param(
  [switch]$DryRun,
  [string]$Repo
)

$ErrorActionPreference = 'Stop'

if ($Repo) {
  $RepoUrl = $Repo
} elseif ($env:AI_SETUP_REPO_URL) {
  $RepoUrl = $env:AI_SETUP_REPO_URL
} else {
  $RepoUrl = 'https://github.com/KabosuNeko/omochi'
}

function Test-Tool([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# winget/bun add themselves to the user PATH; pick that up mid-run.
function Update-SessionPath {
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:PATH = "$machine;$user"
}

function Add-UserPath([string]$Directory) {
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $parts = @($user -split ';' | Where-Object { $_ })
  if ($parts -contains $Directory) { return }
  $parts += $Directory
  [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
  Write-Host ">> Added to user PATH: $Directory"
}

# Run a mutating action, or print it when -DryRun is set.
function Invoke-Managed([string]$Preview, [scriptblock]$Action) {
  if ($DryRun) {
    Write-Host "+ $Preview"
  } else {
    & $Action
  }
}

# Download a zip and extract it into a directory that joins the user PATH.
function Install-ZipTool([string]$Url, [string]$Directory, [string]$ExeName) {
  Invoke-Managed "download $Url -> $Directory\$ExeName (+ user PATH)" {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    $archive = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName() + '.zip')
    Invoke-WebRequest -Uri $Url -OutFile $archive -UseBasicParsing
    Expand-Archive -LiteralPath $archive -DestinationPath $Directory -Force
    Remove-Item -LiteralPath $archive -Force
    Add-UserPath $Directory
    Update-SessionPath
  }
}

# Copy a directory tree in place. Stale entries are not pruned; files the repo
# no longer ships stay on the machine until removed by hand.
function Install-Tree([string]$Source, [string]$Destination) {
  if (-not $DryRun -and -not (Test-Path -LiteralPath $Source)) {
    Write-Warning "$Source is missing; nothing installed into $Destination"
    return
  }
  if ($DryRun) {
    Write-Host "+ copy $Source\* -> $Destination"
    return
  }
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  Copy-Item -Path (Join-Path $Source '*') -Destination $Destination -Recurse -Force
}

# Replace a single config file only when its contents differ, keeping a
# timestamped backup so a local edit is never overwritten silently.
function Install-File([string]$Source, [string]$Destination) {
  if (-not $DryRun -and -not (Test-Path -LiteralPath $Source)) {
    Write-Warning "$Source is missing; $Destination was not installed"
    return
  }
  if ($DryRun) {
    Write-Host "+ copy $Source -> $Destination"
    return
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
  if (Test-Path -LiteralPath $Destination) {
    $same = (Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash
    if ($same) { return }
    $backup = "$Destination.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $Destination -Destination $backup -Force
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host (">> replaced {0} (kept {1}; review with: git diff --no-index '{1}' '{0}')" -f $Destination, $backup)
    return
  }
  Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

if (-not $DryRun -and -not (Test-Tool 'git')) {
  throw 'git is required; install it first: winget install Git.Git'
}

if (-not (Test-Tool 'opencode')) {
  Write-Host '>> Installing opencode (OpenCode 2.0)...'
  if (Test-Tool 'npm') {
    Invoke-Managed 'npm install -g @opencode/cli' {
      npm install -g @opencode/cli
      if ($LASTEXITCODE -ne 0) { throw 'npm install failed' }
      Update-SessionPath
    }
  } else {
    # winget ships opencode 1.x, so the standalone 2.0 build is the fallback.
    if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
      $opencodeZip = 'https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-arm64.zip'
    } else {
      $opencodeZip = 'https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-x64.zip'
    }
    Install-ZipTool $opencodeZip (Join-Path $HOME '.opencode\bin') 'opencode.exe'
  }
}

if (Test-Tool 'opencode') {
  $versionLine = [string](@(& opencode --version 2>$null) | Select-Object -First 1)
  $match = [regex]::Match($versionLine, '^(\d+)\.')
  if ($match.Success -and [int]$match.Groups[1].Value -lt 2) {
    Write-Warning ("opencode {0} found, but omochi targets OpenCode 2.0+. Install it with: npm install -g @opencode/cli. If an older winget copy stays on PATH, remove it: winget uninstall SST.opencode" -f $versionLine)
  }
}

if (-not (Test-Tool 'bun')) {
  Write-Host '>> Installing bun (official installer)...'
  Invoke-Managed 'powershell -c "irm bun.sh/install.ps1 | iex"' {
    powershell -NoProfile -ExecutionPolicy Bypass -Command 'irm bun.sh/install.ps1 | iex'
    if ($LASTEXITCODE -ne 0) { throw 'bun install failed' }
    Update-SessionPath
  }
}

if (-not (Test-Tool 'rtk')) {
  if (Test-Tool 'winget') {
    Write-Host '>> Installing rtk (winget)...'
    Invoke-Managed 'winget install --id rtk-ai.rtk -e --accept-package-agreements --accept-source-agreements --disable-interactivity' {
      winget install --id rtk-ai.rtk -e --accept-package-agreements --accept-source-agreements --disable-interactivity
      if ($LASTEXITCODE -ne 0) { throw 'winget install rtk failed' }
      Update-SessionPath
    }
  } else {
    Write-Host '>> Installing rtk (prebuilt binary)...'
    Install-ZipTool 'https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-pc-windows-msvc.zip' (Join-Path $HOME '.local\bin') 'rtk.exe'
  }
}

$repoDir = Join-Path $HOME 'omochi'
if (Test-Path -LiteralPath (Join-Path $repoDir '.git')) {
  Write-Host '>> ~/omochi already installed, skipping clone'
} else {
  if (Test-Path -LiteralPath $repoDir) {
    $backup = "$repoDir.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host ">> Backing up existing ~/omochi -> $backup"
    Invoke-Managed "move $repoDir -> $backup" { Move-Item -LiteralPath $repoDir -Destination $backup -Force }
  }
  Write-Host '>> Cloning omochi into ~/omochi'
  Invoke-Managed "git clone --depth 1 $RepoUrl $repoDir" {
    git clone --depth 1 $RepoUrl $repoDir
    if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }
  }
}

$opencodeDir = Join-Path $HOME '.config\opencode'

Install-Tree (Join-Path $repoDir '.agents\skills') (Join-Path $HOME '.agents\skills')
Install-Tree (Join-Path $repoDir 'templates\project-docs') (Join-Path $opencodeDir 'templates\project-docs')
Install-File (Join-Path $repoDir 'templates\global-AGENTS.md') (Join-Path $opencodeDir 'AGENTS.md')
Install-File (Join-Path $repoDir 'plugins\rtk.ts') (Join-Path $opencodeDir 'plugins\rtk.ts')

Write-Host @'

Bootstrap done. Manual steps (interactive / secret, cannot be automated):

  1. opencode auth login            # select opencode-go (and OpenCode Zen for free models)
  2. (optional) setx OPENCODE_API_KEY "sk-..."   # env-based auth only; new terminal required
  3. opencode run "$(Get-Content $HOME\omochi\opencode-setup-prompt.md -Raw)"
                                    # AI-driven setup: discovers models, writes configs,
                                    # configures rtk, runs smoke tests

Installed from this repo: ~/.agents/skills, ~/.config/opencode/AGENTS.md,
~/.config/opencode/templates/project-docs, ~/.config/opencode/plugins/rtk.ts.
To update them:
  git -C $HOME\omochi pull; pwsh $HOME\omochi\setup.ps1
'@
