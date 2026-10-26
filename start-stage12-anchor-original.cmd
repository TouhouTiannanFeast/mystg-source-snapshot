@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0start-stage12-practice.ps1" -Entry s1-scale -AnchorOriginal
if errorlevel 1 pause
