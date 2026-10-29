$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$logs='G:\MySTG\work\logs\yuyuko3'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close the running game first; preserved.'}
$settings=Join-Path $game 'userdata\setting.json'
$before=[IO.File]::ReadAllBytes($settings)
try{
 foreach($phase in @('non1','spell1')){
  $args="setting.mod='YuyukoStage3';setting.y3_full=false;setting.y3_practice='$phase';setting.y3_test=true;setting.y3_test_frames=650;setting.y3_fast=true;setting.windowed=true;start_game=true"
  $p=Start-Process (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args+'"') -WindowStyle Hidden -PassThru
  if(-not $p.WaitForExit(45000)){throw 'Probe timed out; process retained.'}
  Copy-Item (Join-Path $game 'engine.log') (Join-Path $logs "background10-$phase.log")
  $log=Get-Content (Join-Path $logs "background10-$phase.log") -Raw
  if($p.ExitCode-ne 0 -or $log-notmatch'Y3 COMPLETE phases=1' -or $log-notmatch'Y3 BACKGROUND TH16 stage4'){throw "Probe failed: $phase"}
  Copy-Item (Join-Path $game "userdata\snapshot\yuyuko3-$phase.jpg") (Join-Path $logs "background10-$phase.jpg")
  Write-Output "PASS background native $phase"
 }
}finally{[IO.File]::WriteAllBytes($settings,$before)}
