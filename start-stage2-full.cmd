@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-stage2-full.ps1"
if errorlevel 1 pause
