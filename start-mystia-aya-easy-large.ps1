$ErrorActionPreference='Stop'
$mystiaGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$mystiaArgs="setting.mod='MystiaAyaNon3EasyLarge'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $mystiaGame 'LuaSTGSub.exe') -WorkingDirectory $mystiaGame -ArgumentList ('"'+$mystiaArgs+'"') -WindowStyle Normal
