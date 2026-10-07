@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\LaunchProduct.ps1" -Mode RC1
if errorlevel 1 pause
