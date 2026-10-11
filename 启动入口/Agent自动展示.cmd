@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\tools\LaunchStable.ps1" -Mode Agent
if errorlevel 1 pause
