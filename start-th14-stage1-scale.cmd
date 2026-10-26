@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-th14-stage1.ps1" -Practice scale
if errorlevel 1 pause
