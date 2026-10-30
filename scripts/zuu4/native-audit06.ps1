param([ValidateSet('stone','non2','spell1')][string]$Practice='stone',[switch]$SampleTransitions)
$ErrorActionPreference='Stop'
$auditGame='G:\MySTG\aex-0.8.22\game'
$auditRoot='G:\MySTG\work\logs\zuu4'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it before the scoped probe.'}
$auditSetting=Join-Path $auditGame 'userdata\setting.json'
$auditBytes=[IO.File]::ReadAllBytes($auditSetting)
$auditFrames=if($SampleTransitions){1200}elseif($Practice-eq'stone'){7201}else{500}
try{
 $auditArgs="setting.mod='MySTG'; setting.th08_autostart=true; setting.th08_autotest=false; setting.th08_practice='zuu-$Practice'; setting.zuu4_test=true; setting.zuu4_test_frames=$auditFrames; setting.zuu4_snapshot_frame=900; setting.zuu4_test_fast=true; setting.zuu4_test_progress=false; setting.zuu4_snapshot_points={60,90,150,210,270,330,400}; setting.windowed=true; start_game=true"
 if($SampleTransitions){$auditArgs+='; setting.zuu4_test_progress=true; setting.zuu4_snapshot_frame=120; setting.zuu4_snapshot_points={180,300,450,700,1000}'}
 $auditProcess=Start-Process -FilePath (Join-Path $auditGame 'LuaSTGSub.exe') -WorkingDirectory $auditGame -ArgumentList ('"'+$auditArgs+'"') -WindowStyle Hidden -PassThru
 $auditDeadline=(Get-Date).AddSeconds(65)
 while(-not $auditProcess.WaitForExit(1000)){
  if((Get-Date)-gt$auditDeadline){throw 'Scoped probe timed out; process retained.'}
 }
 $auditSuffix=if($SampleTransitions){'-layers'}else{''}
 $auditLog=Join-Path $auditRoot "native-$Practice$auditSuffix-audit06.log"
 Copy-Item -LiteralPath (Join-Path $auditGame 'engine.log') -Destination $auditLog
 $auditText=Get-Content -LiteralPath $auditLog -Raw
 if($auditProcess.ExitCode-ne 0 -or $auditText-notmatch'ZUU4 END ' -or $auditText-notmatch'TH08 COMPLETE' -or $auditText-match'\[luajit\].*(FrameFunc|RenderFunc).*(error|出错)'){throw 'Scoped native check failed; inspect saved log.'}
 if($Practice-eq'stone'){
  foreach($auditPhase in 0..3){if($auditText-notmatch"ZUU4 SNAPSHOT userdata/snapshot/zuu4-stone-$auditPhase.jpg"){throw 'A Stone phase capture is missing.'}}
 }
 foreach($auditMatch in [regex]::Matches($auditText,'ZUU4 (?:SNAPSHOT|AUDITSHOT) (userdata/snapshot/[^\r\n]+\.jpg)')){
  Copy-Item -LiteralPath (Join-Path $auditGame $auditMatch.Groups[1].Value) -Destination $auditRoot
 }
 Write-Output "PASS scoped native $Practice, frames=$auditFrames, capture/render and clean exit."
}finally{[IO.File]::WriteAllBytes($auditSetting,$auditBytes)}
