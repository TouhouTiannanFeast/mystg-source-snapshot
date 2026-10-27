param([ValidateSet('all','non1','spell1','non2','spell2','non3','stone','final')][string]$Practice='all',[switch]$Shoot)
$ErrorActionPreference='Stop'
$zuuGame='G:\MySTG\aex-0.8.22\game'
$zuuLogRoot='G:\MySTG\work\logs\zuu4'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing interactive game preserved; close it first.'}
$zuuSetting=Join-Path $zuuGame 'userdata\setting.json'
$zuuBytes=[IO.File]::ReadAllBytes($zuuSetting)
try{
 $zuuArgs="setting.mod='MySTG'; setting.th08_autostart=true; setting.th08_autotest=false; setting.th08_practice='zuu-$Practice'; setting.zuu4_test=true; setting.zuu4_test_frames=1200; setting.zuu4_snapshot_frame=900; setting.zuu4_test_progress=true; setting.zuu4_test_fast=true; setting.windowed=true; start_game=true"
 if($Shoot){$zuuArgs+='; setting.zuu4_test_shoot=true'}
 $zuuProcess=Start-Process -FilePath (Join-Path $zuuGame 'LuaSTGSub.exe') -WorkingDirectory $zuuGame -ArgumentList ('"'+$zuuArgs+'"') -WindowStyle Hidden -PassThru
 $zuuDeadline=(Get-Date).AddSeconds(70)
 while(-not $zuuProcess.WaitForExit(1000)){if((Get-Date)-gt$zuuDeadline){throw 'Zuu4 probe timed out; process retained.'}}
 $zuuSuffix=if($Shoot){'-shoot'}else{''}
 $zuuLog=Join-Path $zuuLogRoot "native-$Practice$zuuSuffix.log"
 Copy-Item (Join-Path $zuuGame 'engine.log') $zuuLog
 $zuuText=Get-Content -LiteralPath $zuuLog -Raw
 $zuuExpected=if($Practice-eq'all'){7}else{1}
 if($zuuProcess.ExitCode-ne 0 -or ([regex]::Matches($zuuText,'ZUU4 END ')).Count-ne$zuuExpected -or $zuuText-notmatch'TH08 COMPLETE'){throw 'Zuu4 native probe failed; inspect saved log.'}
 foreach($zuuMatch in [regex]::Matches($zuuText,'ZUU4 SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){Copy-Item (Join-Path $zuuGame $zuuMatch.Groups[1].Value) $zuuLogRoot}
 Write-Output "PASS native $Practice phases=$zuuExpected with source bullets, native collision and cleanup."
}finally{[IO.File]::WriteAllBytes($zuuSetting,$zuuBytes)}
