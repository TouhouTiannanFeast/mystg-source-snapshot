$ErrorActionPreference='Stop'
$flareGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$flareArgs="setting.mod='RoyalFlareOrbit'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $flareGame 'LuaSTGSub.exe') -WorkingDirectory $flareGame -ArgumentList ('"'+$flareArgs+'"') -WindowStyle Normal
