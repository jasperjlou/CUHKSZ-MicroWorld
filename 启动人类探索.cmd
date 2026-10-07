@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\LaunchProduct.ps1" -Mode Human
if errorlevel 1 pause
