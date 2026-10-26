$ErrorActionPreference='Stop'
$flareFollowGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$flareFollowArgs="setting.mod='RoyalFlareFollow'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $flareFollowGame 'LuaSTGSub.exe') -WorkingDirectory $flareFollowGame -ArgumentList ('"'+$flareFollowArgs+'"') -WindowStyle Normal
