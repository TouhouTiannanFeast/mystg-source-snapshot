$ErrorActionPreference='Stop'
$replayGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
$replayFile=Join-Path $replayGame 'userdata\replay\Stage2Full\slot1.rep'
if (!(Test-Path -LiteralPath $replayFile)) { throw 'Stage2Full slot1.rep not found.' }
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$replayArgs="setting.mod='Stage2Full'; setting.windowed=true; setting.stage2_replay='userdata/replay/Stage2Full/slot1.rep'; start_game=true"
Start-Process -FilePath (Join-Path $replayGame 'LuaSTGSub.exe') -WorkingDirectory $replayGame -ArgumentList ('"'+$replayArgs+'"') -WindowStyle Hidden
