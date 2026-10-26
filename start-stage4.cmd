@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-stage4.ps1"
if errorlevel 1 pause
