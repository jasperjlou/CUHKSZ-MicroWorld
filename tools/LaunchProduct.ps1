param([ValidateSet('Menu','Human','Agent','RC1')][string]$Mode='Menu',[string]$GodotPath='')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) {
    $localEngine=Join-Path $projectRoot '.tools\godot\Godot_v4.5.1-stable_win64.exe'
    if (Test-Path -LiteralPath $localEngine) { $GodotPath=$localEngine }
    else { $engineCommand=Get-Command godot.exe,godot4.exe -ErrorAction SilentlyContinue | Select-Object -First 1; if ($engineCommand) { $GodotPath=$engineCommand.Source } }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath)) { throw '请安装 Godot 4.5.1，并在编辑器中导入 project.godot，或通过 -GodotPath 指定引擎。' }
$scene=if ($Mode -eq 'RC1') { 'res://world/MainWorld.tscn' } else { 'res://world/unified/UnifiedCampus.tscn' }
$productArgs=@('--path',('"'+$projectRoot+'"'),$scene)
if ($Mode -eq 'Human') { $productArgs+=@('--','--human') }
if ($Mode -eq 'Agent') { $productArgs+=@('--','--agent-demo') }
# Explicitly requested interactive product window.
Start-Process -FilePath $GodotPath -ArgumentList $productArgs -WorkingDirectory $projectRoot
