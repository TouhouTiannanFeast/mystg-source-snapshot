param([string]$Practice,[Nullable[int]]$Seed)
$ErrorActionPreference='Stop'
$suwako5Game=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
if ($Practice -and $Practice -notmatch '^th10-(card(?:[1-6]|8|9|10)|non[1-68])$|^th125-[a-d]$|^th143-090[26]$') { throw 'Unknown Stage 5 practice id.' }
$suwako5Args="setting.mod='MySTG'; setting.suwako5_autostart=true; setting.windowed=true; start_game=true"
if ($Practice) { $suwako5Args+="; setting.suwako5_practice='$Practice'" }
if ($null -ne $Seed) { $suwako5Args+="; setting.suwako5_seed=$Seed" }
# Visible interactive game is the explicit purpose of this user launcher.
Start-Process -FilePath (Join-Path $suwako5Game 'LuaSTGSub.exe') -WorkingDirectory $suwako5Game -ArgumentList ('"'+$suwako5Args+'"') -WindowStyle Normal
