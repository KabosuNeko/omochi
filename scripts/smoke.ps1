#!/usr/bin/env pwsh
#Requires -Version 5.1
# Smoke test: prove the opencode shell tool runs rtk-rewritten commands.
# Needs opencode + rtk installed, a logged-in provider, and network access, so
# it is not part of the CI gate. Override the model with OMOCHI_SMOKE_MODEL.

$ErrorActionPreference = 'Stop'

$commandUnderTest = 'git status --short .'
if ($env:OMOCHI_SMOKE_MODEL) {
  $model = $env:OMOCHI_SMOKE_MODEL
} else {
  $model = 'opencode/muse-spark-1.3-contributor-free'
}

function Fail([string]$Message) {
  [Console]::Error.WriteLine("error: $Message")
  exit 1
}

foreach ($tool in 'opencode', 'rtk') {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    Fail "$tool not found in PATH"
  }
}

$logLine = @(opencode debug paths | Where-Object { $_ -match '^\s*log\s' } | Select-Object -First 1)
if ($logLine.Count -eq 0) {
  Fail 'opencode log not found (opencode debug paths printed no log line)'
}
$logDir = ($logLine[0] -replace '^\s*log\s+', '').Trim()
$log = Join-Path $logDir 'opencode.log'
if (-not (Test-Path -LiteralPath $log)) {
  Fail "opencode log not found (resolved: $log)"
}

$before = @(Get-Content -LiteralPath $log).Count
& opencode run --auto -m $model "Call the bash tool (shell tool on Windows) with this command: $commandUnderTest  Then reply with just: DONE" | Out-Null

$newSpawns = @(Get-Content -LiteralPath $log | Select-Object -Skip $before | Where-Object { $_ -match 'spawning process' })
if ($newSpawns.Count -eq 0) {
  Fail 'no process was spawned; the model did not call the shell tool'
}

$expected = "rtk $commandUnderTest"
if (-not ($newSpawns | Where-Object { $_.Contains($expected) })) {
  [Console]::Error.WriteLine("error: command was not rewritten; expected $expected in the server log")
  $newSpawns | Select-Object -Last 3 | ForEach-Object { [Console]::Error.WriteLine($_) }
  exit 1
}

Write-Host "ok: rtk plugin rewrote the command to: $expected"
