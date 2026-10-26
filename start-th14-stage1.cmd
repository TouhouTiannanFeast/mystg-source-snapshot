@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-th14-stage1.ps1"
if errorlevel 1 pause
