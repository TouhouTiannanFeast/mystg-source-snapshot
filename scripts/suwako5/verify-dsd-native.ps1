$ErrorActionPreference='Stop'
$dsdGame='G:\MySTG\aex-0.8.22\game'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$dsdSettings=Join-Path $dsdGame 'userdata\setting.json'
$dsdBytes=[IO.File]::ReadAllBytes($dsdSettings)
try{
 $dsdArgs="setting.mod='MySTG';setting.suwako5_autostart=true;setting.suwako5_practice='th125-d';setting.dsd_laser_test=true;setting.windowed=true;start_game=true"
 $dsdProcess=Start-Process (Join-Path $dsdGame 'LuaSTGSub.exe') -WorkingDirectory $dsdGame -ArgumentList ('"'+$dsdArgs+'"') -WindowStyle Hidden -PassThru
 $dsdLimit=(Get-Date).AddSeconds(30)
 while(-not $dsdProcess.WaitForExit(1000)){if((Get-Date)-gt $dsdLimit){throw 'Probe timeout; process preserved.'}}
 $dsdLog='G:\MySTG\work\logs\suwako5\dsd17-native.log'
 Copy-Item (Join-Path $dsdGame 'engine.log') $dsdLog
 $dsdText=Get-Content $dsdLog -Raw
 $dsdText -split "`r?`n"|Select-String DSD17
 if($dsdText -notmatch 'DSD17 PASS'){throw 'DS-d probe failed.'}
 foreach($dsdTick in @(65,85,115)){Copy-Item (Join-Path $dsdGame "userdata\snapshot\dsd17-$dsdTick.jpg") 'G:\MySTG\work\logs\suwako5'}
}finally{[IO.File]::WriteAllBytes($dsdSettings,$dsdBytes)}
