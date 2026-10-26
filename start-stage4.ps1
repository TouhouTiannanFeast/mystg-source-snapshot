param([ValidateSet('mid','boss','non1','milky','non2','stardust','non3','nondirectional','non4','master','earthlight','final')][string]$Practice)
$ErrorActionPreference='Stop'
$stage4GameRoot=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game before opening Stage 4.' }
$stage4Arg="setting.mod='MySTG'; setting.th08_autostart=true; setting.th08_autotest=false; setting.windowed=true; start_game=true"
if ($Practice) { $stage4Arg+="; setting.th08_practice='$Practice'" }
# A visible interactive game is the explicit purpose of this user launcher.
Start-Process -FilePath (Join-Path $stage4GameRoot 'LuaSTGSub.exe') -WorkingDirectory $stage4GameRoot -ArgumentList ('"'+$stage4Arg+'"') -WindowStyle Normal
