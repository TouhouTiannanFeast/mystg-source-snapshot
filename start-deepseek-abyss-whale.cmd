@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-deepseek-abyss.ps1" -Phase 4
if errorlevel 1 pause

