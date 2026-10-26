$ErrorActionPreference='Stop'
$stageTwoGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$stageTwoArgs="setting.mod='Stage2Full'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $stageTwoGame 'LuaSTGSub.exe') -WorkingDirectory $stageTwoGame -ArgumentList ('"'+$stageTwoArgs+'"') -WindowStyle Hidden
