@echo off
cd /d "%~dp0aex-0.8.22\game"
if not exist LuaSTGSub.exe (
  echo LuaSTG AEX+ is missing. See README.md.
  pause
  exit /b 1
)
LuaSTGSub.exe
