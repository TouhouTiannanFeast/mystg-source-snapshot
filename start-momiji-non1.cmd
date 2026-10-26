@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-momiji-non1.ps1"
if errorlevel 1 pause
