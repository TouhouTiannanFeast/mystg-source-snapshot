param([ValidateSet('tail','scale','mid','non1','non2')][string]$Practice)
$ErrorActionPreference='Stop'
$stageGameRoot=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the existing LuaSTG window before starting this stage.' }
$stageLaunchArg="setting.mod='TH14Stage1Normal'; setting.th14_autostart=true; setting.th14_autotest=false; setting.windowed=true; start_game=true"
if ($Practice) { $stageLaunchArg+="; setting.th14_practice='$Practice'" }
# Visible interactive game is the explicit purpose of this user-operated launcher.
Start-Process -FilePath (Join-Path $stageGameRoot 'LuaSTGSub.exe') -WorkingDirectory $stageGameRoot -ArgumentList ('"'+$stageLaunchArg+'"') -WindowStyle Normal
