param([ValidateSet('timeout','kill','fire')][string]$Case='timeout',[switch]$VerifySaved)
$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$logs="G:\MySTG\work\logs\stage12\$Case"
if(-not $VerifySaved -and (Get-Process LuaSTGSub -ErrorAction SilentlyContinue)){throw 'Existing game preserved; close it first.'}
New-Item -ItemType Directory -Force $logs | Out-Null
$settings=Join-Path $game 'userdata\setting.json'
$saved=[IO.File]::ReadAllBytes($settings)
try {
 if(-not $VerifySaved){
 $args12="setting.mod='Stage12Normal'; setting.stage12_test=true; setting.windowed=true; start_game=true"
 if($Case -eq 'fire'){$args12+='; setting.stage12_fire=true; setting.stage12_reimu_b_test=true'}
 if($Case -eq 'kill'){$args12+='; setting.stage12_kill=true'}
 $process12=Start-Process -FilePath (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args12+'"') -WindowStyle Hidden -PassThru
 if(-not $process12.WaitForExit(180000)){throw 'Native test timeout; process preserved for diagnosis.'}
 Copy-Item (Join-Path $game 'engine.log') (Join-Path $logs 'engine.log')
 }
 $log=Get-Content (Join-Path $logs 'engine.log') -Raw
 if((-not $VerifySaved -and $process12.ExitCode -ne 0) -or $log -notmatch 'STAGE12 COMPLETE'){throw 'Native route did not complete; inspect saved engine.log'}
 if($log -notmatch 'TH14 COMPLETE frames=\d+ waves=186 phases=5 ended=5'){throw 'Stage one count mismatch'}
 $ordered=@('TH14 PHASE START momiji','TH14 PHASE START non1','TH14 PHASE START context','TH14 PHASE START non2','TH14 PHASE START scale','STAGE2 PHASE Opening','STAGE2 PHASE Mamizou','STAGE2 PHASE Complete')
 $position12=-1
 foreach($phase12 in $ordered){$next12=$log.IndexOf($phase12,$position12+1);if($next12 -lt 0){throw "Missing ordered phase: $phase12"};$position12=$next12}
 foreach($match12 in [regex]::Matches($log,'STAGE12 SNAPSHOT (userdata/snapshot/[^\r\n ]+\.jpg)')){Copy-Item (Join-Path $game $match12.Groups[1].Value) $logs}
 $momEnd=[regex]::Match($log,'TH14 PHASE END momiji frame=(\d+)')
 $post=[regex]::Match($log,'TH14 POST-MOMIJI WAVES START frame=(\d+)')
 if(-not $momEnd.Success -or -not $post.Success -or [int]$post.Groups[1].Value -lt [int]$momEnd.Groups[1].Value){throw 'Post-mid waves started before Momiji ended'}
 if($Case -eq 'fire'){
  foreach($phase12 in @('momiji','non1','non2','scale')){if($log -notmatch "STAGE12 REAL SHOT PASS $phase12 "){throw "Missing actual-shot check: $phase12"}}
  $contextStart=[regex]::Match($log,'TH14 PHASE START context frame=(\d+)')
  $contextEnd=[regex]::Match($log,'TH14 PHASE END context frame=(\d+)')
  if(-not $contextStart.Success -or -not $contextEnd.Success -or ([int]$contextEnd.Groups[1].Value-[int]$contextStart.Groups[1].Value) -ge 3000){throw 'Real shots failed to defeat short context card'}
 }
 Write-Output "Native $Case ordered two-stage route PASS"
}finally{[IO.File]::WriteAllBytes($settings,$saved)}

