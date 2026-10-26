@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0start-stage5-practice.ps1" %*
if errorlevel 1 pause
