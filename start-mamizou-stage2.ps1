param([ValidateRange(0,5)][int]$Phase=0)
$ErrorActionPreference='Stop'
$mamizouGame=Join-Path $PSScriptRoot 'aex-0.8.22\game'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the running LuaSTG game first.' }
$mamizouArgs="setting.mod='MamizouStage2'; setting.windowed=true; start_game=true"
if ($Phase -gt 0) { $mamizouArgs+="; setting.mamizou_phase=$Phase" }
Start-Process -FilePath (Join-Path $mamizouGame 'LuaSTGSub.exe') -WorkingDirectory $mamizouGame -ArgumentList ('"'+$mamizouArgs+'"') -WindowStyle Hidden
