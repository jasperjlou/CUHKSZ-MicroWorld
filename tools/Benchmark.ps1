param(
    [switch]$UI,
    [ValidateSet('mock','openai_compatible')][string]$Provider = 'mock',
    [ValidateSet('all','Reactive','History','PlanHistory')][string]$Condition = 'all',
    [string]$Tasks = 'all',
    [ValidateRange(1,100)][int]$Episodes = 1,
    [ValidateRange(1,100)][int]$MaxSteps = 40,
    [string]$GodotPath = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) { $GodotPath = Join-Path $projectRoot '.tools\godot\Godot_v4.5.1-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw '未找到 Godot，请用 -GodotPath 指定引擎。' }
if ($UI) {
    Start-Process -FilePath $GodotPath -ArgumentList @('--path',('"' + $projectRoot + '"'),'--','--benchmark-ui') -WorkingDirectory $projectRoot
    exit 0
}
$consolePath = $GodotPath -replace '\.exe$', '_console.exe'
if (Test-Path -LiteralPath $consolePath) { $GodotPath = $consolePath }
# Secrets are inherited from environment variables only, never command arguments.
$output = & $GodotPath --headless --path $projectRoot --fixed-fps 60 -- --benchmark "--provider=$Provider" "--condition=$Condition" "--tasks=$Tasks" "--episodes=$Episodes" "--max-steps=$MaxSteps" 2>&1
$exitCode = $LASTEXITCODE
$output | ForEach-Object { Write-Host $_ }
if ($exitCode -ne 0 -or ($output | Select-String 'SCRIPT ERROR:|ERROR:')) { exit 1 }
exit 0
