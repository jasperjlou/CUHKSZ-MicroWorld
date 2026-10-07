@echo off
cd /d "%~dp0..\..\..\"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\..\tools\Launch.ps1" -AgentDemo
