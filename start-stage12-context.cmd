@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-stage12-context.ps1"
if errorlevel 1 pause
