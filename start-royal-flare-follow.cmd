@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-royal-flare-follow.ps1"
if errorlevel 1 pause
