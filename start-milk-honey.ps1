$ErrorActionPreference='Stop'
$milkGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$milkArgs="setting.mod='MilkHoney'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $milkGame 'LuaSTGSub.exe') -WorkingDirectory $milkGame -ArgumentList ('"'+$milkArgs+'"') -WindowStyle Normal
