$ErrorActionPreference='Stop'
$fullGame='G:\MySTG\aex-0.8.22\game'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close running game first; preserved.'}
$fullSetting=Join-Path $fullGame 'userdata\setting.json'
$fullBefore=[IO.File]::ReadAllBytes($fullSetting)
try{
 $fullArgs="setting.mod='YuyukoStage3'; setting.y3_full=true; setting.y3_entry='road-9500'; setting.y3_practice='all'; setting.y3_invincible=true; setting.y3_test=true; setting.y3_test_frames=60; setting.y3_fast=true; setting.windowed=true; start_game=true"
 $fullProcess=Start-Process -FilePath (Join-Path $fullGame 'LuaSTGSub.exe') -WorkingDirectory $fullGame -ArgumentList ('"'+$fullArgs+'"') -WindowStyle Hidden -PassThru
 $fullDeadline=(Get-Date).AddSeconds(70)
 while(-not $fullProcess.WaitForExit(1000)){if((Get-Date)-gt$fullDeadline){throw 'Native check timeout; process retained.'}}
 $fullLog='G:\MySTG\work\logs\yuyuko3\full06-native.log'
 Copy-Item (Join-Path $fullGame 'engine.log') $fullLog
 $fullText=Get-Content $fullLog -Raw
 if($fullProcess.ExitCode-ne0 -or $fullText-notmatch'STAGE3 ROAD CLEAN' -or $fullText-notmatch'Y3 COMPLETE phases=6'){throw 'Native seam failed; see full06-native.log'}
 foreach($fullId in @('non1','spell1','non2','spell2','non3','spell3')){if($fullText-notmatch("Y3 END "+$fullId+" ticks=60")){throw "Phase missing: $fullId"}}
 'PASS native last road wave -> cleanup -> all 6 boss phases (60 frames each) -> normal exit'
}finally{[IO.File]::WriteAllBytes($fullSetting,$fullBefore)}
