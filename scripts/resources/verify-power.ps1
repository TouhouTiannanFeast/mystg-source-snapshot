$ErrorActionPreference='Stop'
$power14Game='G:\MySTG\aex-0.8.22\game'
$power14Logs='G:\MySTG\work\logs\resources'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$power14Settings=Join-Path $power14Game 'userdata\setting.json'
$power14Bytes=[IO.File]::ReadAllBytes($power14Settings)
try{
 $power14Args="setting.mod='MySTG';setting.suwako5_autostart=true;setting.suwako5_practice='th10-non1';setting.resources_power_test=true;setting.windowed=true;start_game=true"
 $power14Process=Start-Process -FilePath (Join-Path $power14Game 'LuaSTGSub.exe') -WorkingDirectory $power14Game -ArgumentList ('"'+$power14Args+'"') -WindowStyle Hidden -PassThru
 $power14Limit=(Get-Date).AddSeconds(30)
 while(-not $power14Process.WaitForExit(1000)){if((Get-Date)-gt $power14Limit){throw 'Power probe timeout; process preserved.'}}
 Copy-Item (Join-Path $power14Game 'engine.log') (Join-Path $power14Logs 'power14-native.log')
 $power14Text=Get-Content (Join-Path $power14Logs 'power14-native.log') -Raw
 if($power14Text -notmatch 'POWER14 COMPLETE'){throw 'Power probe failed.'}
 Copy-Item (Join-Path $power14Game 'userdata\snapshot\power14-hud.jpg') $power14Logs
 $power14Text -split "`r?`n" | Select-String 'POWER14'
 Write-Output 'PASS native fixed power400 and HUD capture'
}finally{[IO.File]::WriteAllBytes($power14Settings,$power14Bytes)}
