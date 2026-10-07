param(
    [switch]$Editor,
    [switch]$Test,
    [switch]$AgentDemo,
    [switch]$AgentBatch,
    [switch]$AgentQA,
    [switch]$FairyLake,
    [string]$GodotPath = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) {
    $localEngine = Join-Path $projectRoot '.tools\godot\Godot_v4.5.1-stable_win64.exe'
    if (Test-Path -LiteralPath $localEngine) {
        $GodotPath = $localEngine
    } else {
        $command = Get-Command godot.exe,godot4.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) { $GodotPath = $command.Source }
    }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath)) {
    throw '未找到 Godot 4。请在 Godot 编辑器中导入 project.godot，或通过 -GodotPath 指定程序位置。'
}
if ($Test -or $AgentBatch -or $AgentQA) {
    $consolePath = $GodotPath -replace '\.exe$', '_console.exe'
    if (Test-Path -LiteralPath $consolePath) { $GodotPath = $consolePath }
    $testMode = if ($AgentBatch) { '--agent-batch' } elseif ($AgentQA) { '--agent-qa' } else { '--qa' }
    $output = & $GodotPath --headless --path $projectRoot res://world/MainWorld.tscn --fixed-fps 60 --quit-after 1200000 -- $testMode 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }
    if ($exitCode -ne 0 -or ($output | Select-String 'SCRIPT ERROR:|ERROR:|QA FAIL:')) { exit 1 }
    exit 0
}
$arguments = @('--path', ('"' + $projectRoot + '"'))
if ($Editor) { $arguments += '--editor' } else { $arguments += 'res://world/MainWorld.tscn' }
if ($AgentDemo) { $arguments += @('--', '--agent-demo') }
if ($FairyLake) { $arguments += @('--', '--fairy-lake') }
# This is the user-requested interactive game/editor, not a background helper.
Start-Process -FilePath $GodotPath -ArgumentList $arguments -WorkingDirectory $projectRoot
