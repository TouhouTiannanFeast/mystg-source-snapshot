param([string]$Phase='all',[string]$Branch='',[string]$SSGMode='full')
$ErrorActionPreference='Stop'
$marisaGame='G:\MySTG\aex-0.8.22\game'
$marisaLogs='G:\MySTG\work\logs\marisa-mixed'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$marisaSetting=Join-Path $marisaGame 'userdata\setting.json'
$marisaBytes=[IO.File]::ReadAllBytes($marisaSetting)
try{
 $marisaArgs="setting.mod='MarisaMixed'; setting.marisa_road=false; setting.marisa_road_test=false; setting.marisa_phase='$Phase'; setting.marisa_test=true; setting.marisa_invincible=true; setting.windowed=true; start_game=true"
 if($Branch){$marisaArgs+="; setting.marisa_test_branch='$Branch'"}
 $marisaArgs+="; setting.marisa_ssg_mode='$SSGMode'"
 $marisaProcess=Start-Process -FilePath (Join-Path $marisaGame 'LuaSTGSub.exe') -WorkingDirectory $marisaGame -ArgumentList ('"'+$marisaArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $marisaProcess.WaitForExit(90000)){Stop-Process -Id $marisaProcess.Id;throw 'Bounded native probe timed out; stopped only owned process.'}
 $marisaLog=Join-Path $marisaLogs "native-$Phase.log"
 Copy-Item (Join-Path $marisaGame 'engine.log') $marisaLog
 $marisaText=Get-Content $marisaLog -Raw
 foreach($marisaMatch in [regex]::Matches($marisaText,'MARISA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){Copy-Item (Join-Path $marisaGame $marisaMatch.Groups[1].Value) $marisaLogs}
 if($marisaProcess.ExitCode -ne 0 -or $marisaText -notmatch 'MARISA COMPLETE' -or $marisaText -match 'MARISA (FRAME|RENDER) ERROR'){throw "Native probe failed; see $marisaLog"}
 $marisaPhases=if($Phase -eq 'all'){@('ssg','stardust','non1','milky','non3','comet','final')}elseif($Phase -eq 'fix02'){@('ssg','stardust','final')}else{@($Phase)}
 foreach($marisaID in $marisaPhases){if($marisaText -notmatch "MARISA CHECKPOINT $marisaID " -or $marisaText -notmatch "MARISA END $marisaID"){throw "Missing checkpoint/cleanup $marisaID"}}
 Write-Output "PASS bounded native $Phase phase order/render/cleanup/exit"
}finally{[IO.File]::WriteAllBytes($marisaSetting,$marisaBytes)}
