@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-stage12.ps1"
if errorlevel 1 pause
