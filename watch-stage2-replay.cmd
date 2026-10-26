@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-stage2-replay.ps1"
if errorlevel 1 pause
