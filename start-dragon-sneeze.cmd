@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-dragon-sneeze.ps1"
if errorlevel 1 pause
