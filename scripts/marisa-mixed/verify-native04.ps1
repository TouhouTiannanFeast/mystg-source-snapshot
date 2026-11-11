param([string[]]$Modes=@('A1','B6'))
$ErrorActionPreference='Stop'
$game04='G:\MySTG\aex-0.8.22\game'
$logs04='G:\MySTG\work\logs\marisa-mixed\change04'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$setting04=Join-Path $game04 'userdata\setting.json';$bytes04=[IO.File]::ReadAllBytes($setting04)
try{
 foreach($mode04 in $Modes){
  if($mode04 -notmatch '^(A[1-4]|B[1-6])$'){throw 'Unknown inspection mode'}
  $args04="setting.mod='MarisaMixed';setting.marisa_phase='ssg';setting.marisa_ssg_mode='$mode04';setting.marisa_test=true;setting.marisa_test_branch='inspect04';setting.marisa_invincible=true;setting.windowed=true;start_game=true"
  $process04=Start-Process -FilePath (Join-Path $game04 'LuaSTGSub.exe') -WorkingDirectory $game04 -ArgumentList ('"'+$args04+'"') -WindowStyle Hidden -PassThru
  if(-not $process04.WaitForExit(45000)){Stop-Process -Id $process04.Id;throw 'Bounded inspection timed out; owned process stopped.'}
  $log04=Join-Path $logs04 "native-$mode04.log";Copy-Item (Join-Path $game04 'engine.log') $log04
  $text04=Get-Content $log04 -Raw
  if($process04.ExitCode -ne 0 -or $text04 -notmatch "SSG INSPECT PASS $mode04 " -or $text04 -notmatch 'MARISA COMPLETE' -or $text04 -match 'MARISA (FRAME|RENDER) ERROR'){throw "Inspection $mode04 failed; see $log04"}
  foreach($match04 in [regex]::Matches($text04,'MARISA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){
   $snapshot04=Join-Path $game04 $match04.Groups[1].Value
   Copy-Item $snapshot04 (Join-Path $logs04 ($mode04+'-'+[IO.Path]::GetFileName($snapshot04)))
  }
  Write-Output "PASS native inspection $mode04 chosen helper only, visible ID/render/cleanup/exit"
 }
}finally{[IO.File]::WriteAllBytes($setting04,$bytes04)}
