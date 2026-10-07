param([string]$GodotPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) {
    $localEngine = Join-Path $projectRoot '.tools\godot\Godot_v4.5.1-stable_win64.exe'
    if (Test-Path -LiteralPath $localEngine) { $GodotPath = $localEngine }
    else {
        $command = Get-Command godot.exe,godot4.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) { $GodotPath = $command.Source }
    }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath)) {
    throw 'Godot 4.5.1 not found. Supply -GodotPath, or run CampusMaster.tscn in the editor.'
}
# Explicit interactive world launch; RC1 default scene/configuration stays unchanged.
Start-Process -FilePath $GodotPath -ArgumentList @('--path', ('"' + $projectRoot + '"'), 'res://world/campus_master/CampusMaster.tscn') -WorkingDirectory $projectRoot
