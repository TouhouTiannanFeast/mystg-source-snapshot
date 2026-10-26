$ErrorActionPreference='Stop'
$momijiGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$momijiArgs="setting.mod='MomijiNon1'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $momijiGame 'LuaSTGSub.exe') -WorkingDirectory $momijiGame -ArgumentList ('"'+$momijiArgs+'"') -WindowStyle Normal
