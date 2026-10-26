@echo off
cd /d "%~dp0runtime\LuaSTG-Sub-v0.21.129"
if not exist LuaSTGSub.exe (
  echo LuaSTG engine is missing. See README.md.
  pause
  exit /b 1
)
LuaSTGSub.exe
