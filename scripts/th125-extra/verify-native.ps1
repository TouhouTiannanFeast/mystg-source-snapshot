param([int[]]$Cards=@(2,7,8),[int]$Frames=780,[switch]$Interactions)
$ErrorActionPreference='Stop'
$dsGame='G:\MySTG\aex-0.8.22\game'
$dsLogs='G:\MySTG\work\logs\th125-extra'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$dsSetting=Join-Path $dsGame 'userdata\setting.json'
$dsBytes=[IO.File]::ReadAllBytes($dsSetting)
try{
 foreach($dsCard in $Cards){
  $dsSelection=if($dsCard -eq 0){'false'}else{"$dsCard"}
  $dsArgs="setting.mod='TH125Extra'; setting.ds_extra_test=true; setting.ds_extra_test_interactions=false; setting.ds_extra_card=$dsSelection; setting.ds_extra_test_frames=$Frames; setting.windowed=true; start_game=true"
  if($Interactions){$dsArgs+='; setting.ds_extra_test_interactions=true'}
  $dsProcess=Start-Process -FilePath (Join-Path $dsGame 'LuaSTGSub.exe') -WorkingDirectory $dsGame -ArgumentList ('"'+$dsArgs+'"') -WindowStyle Hidden -PassThru
  if(-not $dsProcess.WaitForExit(45000)){
   Stop-Process -Id $dsProcess.Id
   Copy-Item (Join-Path $dsGame 'engine.log') (Join-Path $dsLogs "native-ex$dsCard-timeout.log")
   throw "Bounded card $dsCard exceeded45seconds; stopped only test process."
  }
  $dsSuffix=if($Interactions){'-shoot'}else{''}
  $dsLog=Join-Path $dsLogs "native-ex$dsCard$dsSuffix.log"
  Copy-Item (Join-Path $dsGame 'engine.log') $dsLog
  $dsText=Get-Content $dsLog -Raw
  foreach($dsMatch in [regex]::Matches($dsText,'DS EXTRA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){
   Copy-Item (Join-Path $dsGame $dsMatch.Groups[1].Value) $dsLogs
  }
  if($dsProcess.ExitCode -ne 0 -or $dsText -notmatch 'DS EXTRA COMPLETE'){
   throw "Native Ex-$dsCard failed; see $dsLog"
  }
  $dsExpected=if($dsCard -eq 0){@(2,7,8)}else{@($dsCard)}
  foreach($dsID in $dsExpected){
   if($dsText -notmatch "DS EXTRA NATIVE PASS card=$dsID " -or $dsText -notmatch "DS EXTRA CLEANUP PASS card=$dsID"){throw "Missing phase evidence for Ex-$dsID"}
   if($Interactions -and $dsText -notmatch "DS EXTRA SHOOT PASS card=$dsID "){throw 'Missing shooting collision evidence.'}
  }
  Write-Output "PASS Ex-$dsCard native$Frames frames, source emissions/actors/render/phase cleanup/exit."
 }
}finally{[IO.File]::WriteAllBytes($dsSetting,$dsBytes)}
