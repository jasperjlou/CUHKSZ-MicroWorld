@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\LaunchProduct.ps1" -Mode Agent
if errorlevel 1 pause
