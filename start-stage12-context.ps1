$ErrorActionPreference='Stop'
$stage12Game=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close the running LuaSTG game first.'}
$stage12Args="setting.mod='Stage12Normal'; setting.stage12_context_only=true; setting.th14_practice='context'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $stage12Game 'LuaSTGSub.exe') -WorkingDirectory $stage12Game -ArgumentList ('"'+$stage12Args+'"') -WindowStyle Normal
