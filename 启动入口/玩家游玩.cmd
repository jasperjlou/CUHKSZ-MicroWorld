@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\tools\LaunchStable.ps1" -Mode Human
if errorlevel 1 pause
