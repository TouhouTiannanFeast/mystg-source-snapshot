@echo off
setlocal
if not exist "%~dp0aex-0.8.22\game\mod\DeepSeekCoT\root.lua" exit /b 1
cd /d "%~dp0aex-0.8.22\game"
LuaSTGSub.exe "setting.mod='DeepSeekCoT'; setting.cot_test=false; setting.windowed=true; start_game=true"
if errorlevel 1 pause
