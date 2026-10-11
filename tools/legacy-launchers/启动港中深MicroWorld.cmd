@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\tools\LaunchProduct.ps1" -Mode Menu
if errorlevel 1 pause
