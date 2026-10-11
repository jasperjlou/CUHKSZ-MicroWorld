param([ValidateSet('Human','Agent')][string]$Mode='Human')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
$release=Get-Content -LiteralPath (Join-Path $projectRoot 'releases/latest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$executable=Join-Path $projectRoot $release.local_executable
if (-not (Test-Path -LiteralPath $executable)) {
    throw '未找到本地稳定版。请下载 GitHub Release 的 Windows 包；开发运行可使用 tools/LaunchProduct.ps1。'
}
$modeArgument=if ($Mode -eq 'Agent') { '--agent-demo' } else { '--human' }
# The user selected an interactive product entrance.
Start-Process -FilePath $executable -ArgumentList @('--',$modeArgument) -WorkingDirectory (Split-Path -Parent $executable)
