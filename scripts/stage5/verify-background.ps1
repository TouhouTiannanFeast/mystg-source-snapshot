param([switch]$Valley)
$ErrorActionPreference='Stop'
$bg11Game='G:\MySTG\aex-0.8.22\game'
$bg11Logs='G:\MySTG\work\logs\stage5'
$bg11Tag=if($Valley){'BG12'}else{'BG11'}
$bg11LogName=if($Valley){'bg12-native.log'}else{'bg11-native.log'}
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$bg11Settings=Join-Path $bg11Game 'userdata\setting.json'
$bg11Bytes=[IO.File]::ReadAllBytes($bg11Settings)
try{
 $bg11Args="setting.mod='MySTG';setting.suwako5_autostart=true;setting.suwako5_test_plan={'th10-non1'};setting.th18_stage5_background_test=true;setting.windowed=true;start_game=true"
 if($Valley){$bg11Args+=';setting.th18_stage5_background_valley_test=true'}
 $bg11Process=Start-Process -FilePath (Join-Path $bg11Game 'LuaSTGSub.exe') -WorkingDirectory $bg11Game -ArgumentList ('"'+$bg11Args+'"') -WindowStyle Hidden -PassThru
 $bg11Limit=(Get-Date).AddSeconds(45)
 while(-not $bg11Process.WaitForExit(1000)){if((Get-Date)-gt $bg11Limit){throw 'Background fixture timed out; process preserved.'}}
 Copy-Item (Join-Path $bg11Game 'engine.log') (Join-Path $bg11Logs $bg11LogName)
 $bg11Text=Get-Content (Join-Path $bg11Logs $bg11LogName) -Raw
 if($bg11Text -notmatch ($bg11Tag+' COMPLETE')){throw 'Background fixture did not complete.'}
 foreach($bg11Match in [regex]::Matches($bg11Text,($bg11Tag+' SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)'))){Copy-Item (Join-Path $bg11Game $bg11Match.Groups[1].Value) $bg11Logs}
 $bg11Text -split "`r?`n" | Select-String ($bg11Tag+' STATE|'+$bg11Tag+' COMPLETE|'+$bg11Tag+' MIDBOSS')
 if($Valley){Write-Output 'PASS background-only midboss gate/entry/bright valley captures'}else{Write-Output 'PASS background-only native fixture; all scene epochs and boss interrupt'}
}finally{[IO.File]::WriteAllBytes($bg11Settings,$bg11Bytes)}
