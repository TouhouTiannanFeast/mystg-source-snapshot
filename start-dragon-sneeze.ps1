$ErrorActionPreference='Stop'
$dragonGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$dragonArgs="setting.mod='DragonSneeze'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $dragonGame 'LuaSTGSub.exe') -WorkingDirectory $dragonGame -ArgumentList ('"'+$dragonArgs+'"') -WindowStyle Normal
