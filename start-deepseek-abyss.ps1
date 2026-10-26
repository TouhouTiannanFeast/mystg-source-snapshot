param([ValidateSet(0,1,2,3,4)][int]$Phase=0)
$ErrorActionPreference='Stop'
$abyssGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$abyssArgs="setting.mod='DeepSeekAbyss'; setting.abyss_phase=$Phase; setting.abyss_test=false; setting.abyss_fast=false; setting.abyss_probe=false; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $abyssGame 'LuaSTGSub.exe') -WorkingDirectory $abyssGame -ArgumentList ('"'+$abyssArgs+'"') -WindowStyle Normal
