param([ValidateSet('mid','tail')][string]$Part='mid')
$ErrorActionPreference='Stop'
$marisaGame='G:\MySTG\aex-0.8.22\game'
$marisaLogs='G:\MySTG\work\logs\marisa-mixed\stage14'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$marisaSetting=Join-Path $marisaGame 'userdata\setting.json'
$marisaBytes=[IO.File]::ReadAllBytes($marisaSetting)
try{
 $marisaArgs="setting.mod='MarisaMixed'; setting.th18_stage5_test=false; setting.th18_stage5_collision_test=false; setting.th18_stage5_background_test=false; setting.th18_stage5_test_scenery=false; setting.marisa_road=true; setting.marisa_road_test='$Part'; setting.marisa_phase='all'; setting.marisa_ssg_mode='full'; setting.marisa_seed=20261106; setting.marisa_test=true; setting.marisa_test_branch=false; setting.marisa_invincible=true; setting.rs_test=false; setting.rs_hammer_test=false; setting.rs_practice='all'; setting.rs_seed=20261102; setting.rs_invincible=true; setting.windowed=true; start_game=true"
 $marisaProcess=Start-Process -FilePath (Join-Path $marisaGame 'LuaSTGSub.exe') -WorkingDirectory $marisaGame -ArgumentList ('"'+$marisaArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $marisaProcess.WaitForExit(90000)){Stop-Process -Id $marisaProcess.Id;throw 'Bounded integration check timed out; stopped only owned process.'}
 $marisaLog=Join-Path $marisaLogs "native-$Part.log"
 Copy-Item (Join-Path $marisaGame 'engine.log') $marisaLog
 $marisaText=Get-Content $marisaLog -Raw
 if($marisaText -match 'MARISA (FRAME|RENDER) ERROR' -or $marisaProcess.ExitCode -ne 0){throw "Integration failed: $marisaLog"}
 if($Part -eq 'mid'){
  if($marisaText -notmatch 'MARISA14 MID PASS' -or $marisaText -notmatch 'MARISA14 RABBIT COMPLETE cards=2'){throw "Rabbit did not complete: $marisaLog"}
 }else{
  foreach($mark in @('MARISA14 ROAD EMPTY','MARISA14 ENTRY GAP 120','MARISA14 MUSIC state=playing','MARISA14 OFFSCREEN ENTRY','MARISA COMPLETE ended=7')){if($marisaText -notmatch [regex]::Escape($mark)){throw "Missing $mark : $marisaLog"}}
  foreach($phase in @('ssg','stardust','non1','milky','non3','comet','final')){if($marisaText -notmatch "MARISA START $phase " -or $marisaText -notmatch "MARISA END $phase"){throw "Missing $phase : $marisaLog"}}
 }
 foreach($marisaMatch in [regex]::Matches($marisaText,'MARISA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){Copy-Item (Join-Path $marisaGame $marisaMatch.Groups[1].Value) $marisaLogs}
 Write-Output "PASS bounded stage14 $Part integration; settings restored"
}finally{if($marisaProcess -and -not $marisaProcess.HasExited){Stop-Process -Id $marisaProcess.Id};[IO.File]::WriteAllBytes($marisaSetting,$marisaBytes)}
