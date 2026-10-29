$ErrorActionPreference='Stop'
$sharedGame='G:\MySTG\aex-0.8.22\game'
$sharedPath=Join-Path $sharedGame 'userdata\setting.json'
$sharedBefore=[IO.File]::ReadAllBytes($sharedPath)
try{
 if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Running game preserved'}
 $sharedArgs="setting.mod='Le03Stage4Normal'; setting.le03_test=true; setting.le03_test_frames=360; setting.le03_invincible=true; setting.windowed=true; start_game=true"
 $sharedProcess=Start-Process -FilePath (Join-Path $sharedGame 'LuaSTGSub.exe') -WorkingDirectory $sharedGame -ArgumentList ('"'+$sharedArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $sharedProcess.WaitForExit(30000)){throw 'Native standalone smoke timed out; process preserved'}
 Copy-Item (Join-Path $sharedGame 'engine.log') 'G:\MySTG\work\logs\yuyuko3\shared09-standalone.log'
 $sharedText=Get-Content 'G:\MySTG\work\logs\yuyuko3\shared09-standalone.log' -Raw
 if($sharedProcess.ExitCode-ne0 -or $sharedText-notmatch'LE03 NORMAL ROAD TEST END ticks=360'){throw 'Standalone smoke incomplete'}
 'PASS original standalone road host: 360 frames, source assets loaded, normal exit'
}finally{[IO.File]::WriteAllBytes($sharedPath,$sharedBefore)}
