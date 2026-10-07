@echo off
cd /d "%~dp0..\..\..\"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\..\tools\Benchmark.ps1" -Provider mock
pause
