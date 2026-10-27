$ErrorActionPreference='Stop'
$fireGame='G:\MySTG\aex-0.8.22\game'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$fireSettings=Join-Path $fireGame 'userdata\setting.json'
$fireBytes=[IO.File]::ReadAllBytes($fireSettings)
try{
 $fireArgs="setting.mod='MySTG';setting.suwako5_autostart=true;setting.suwako5_practice='th10-non1';setting.th18_fire_test=true;setting.windowed=true;start_game=true"
 $fireProcess=Start-Process -FilePath (Join-Path $fireGame 'LuaSTGSub.exe') -WorkingDirectory $fireGame -ArgumentList ('"'+$fireArgs+'"') -WindowStyle Hidden -PassThru
 $fireLimit=(Get-Date).AddSeconds(35)
 while(-not $fireProcess.WaitForExit(1000)){if((Get-Date)-gt $fireLimit){throw 'Fire probe timeout; process preserved.'}}
 $fireLog='G:\MySTG\work\logs\fire15\native.log'
 Copy-Item (Join-Path $fireGame 'engine.log') $fireLog
 $fireText=Get-Content $fireLog -Raw
 $fireText -split "`r?`n" | Select-String 'FIRE15|ERROR'
 if($fireText -notmatch 'FIRE15 COMPLETE'){throw 'Fire probe failed.'}
}finally{[IO.File]::WriteAllBytes($fireSettings,$fireBytes)}
