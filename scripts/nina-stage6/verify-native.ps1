param([string]$Phase='non1',[int]$Frames=750,[string]$Tag='',[string]$Probe='',[switch]$RoadProbe,[int]$RoadCheckpoint=10500)
$ErrorActionPreference='Stop'
$ninaGame='G:\MySTG\aex-0.8.22\game'
$ninaLogs='G:\MySTG\work\logs\nina-stage6'
New-Item -ItemType Directory -Force $ninaLogs | Out-Null
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$ninaSetting=Join-Path $ninaGame 'userdata\setting.json'
$ninaBytes=[IO.File]::ReadAllBytes($ninaSetting)
$ninaPlugins=Join-Path $ninaGame 'plugins\plugins.json'
$ninaPluginBytes=[IO.File]::ReadAllBytes($ninaPlugins)
try{
 if($Phase -notin @('all','non1','spell1','non2','spell2','non3','spell3','non4','spell4','final','kanako') -or $Probe -notin @('','suwako')){throw 'Invalid target probe.'}
 $ninaArgs="setting.mod='NinaStage6Normal'; setting.nina_test=true; setting.nina_phase='$Phase'; setting.nina_probe='$Probe'; setting.nina_test_frames=$Frames; setting.windowed=true; start_game=true"
 if($RoadProbe){$ninaArgs+="; setting.nina_road_probe=true; setting.nina_road_checkpoint=$RoadCheckpoint"}
 $ninaProcess=Start-Process -FilePath (Join-Path $ninaGame 'LuaSTGSub.exe') -WorkingDirectory $ninaGame -ArgumentList ('"'+$ninaArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $ninaProcess.WaitForExit(120000)){Stop-Process -Id $ninaProcess.Id;throw 'Native probe exceeded120s.'}
 $ninaLog=Join-Path $ninaLogs "$($Tag)native-$Phase.log";Copy-Item (Join-Path $ninaGame 'engine.log') $ninaLog
 $ninaText=Get-Content $ninaLog -Raw
 foreach($ninaMatch in [regex]::Matches($ninaText,'NINA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){Copy-Item (Join-Path $ninaGame $ninaMatch.Groups[1].Value) (Join-Path $ninaLogs ($Tag+[IO.Path]::GetFileName($ninaMatch.Groups[1].Value)))}
 if($ninaProcess.ExitCode -ne 0 -or $ninaText -notmatch 'NINA COMPLETE'){throw "Native failure; see $ninaLog"}
 $ninaExpected=if($Phase -eq 'all'){@('non1','spell1','non2','spell2','non3','spell3','non4','spell4','final','kanako')}else{@($Phase)}
 foreach($ninaId in $ninaExpected){if($ninaText -notmatch "NINA NATIVE PASS $ninaId " -or $ninaText -notmatch "NINA CLEANUP $ninaId"){throw "Missing phase evidence $ninaId"}}
 if($RoadProbe){
  if($ninaText -notmatch 'NINA ROAD WAIT120' -or $ninaText -notmatch 'NINA LAUGH4 AFTER APPEAR'){throw 'Missing merged route/voice evidence'}
  if(([regex]::Matches($ninaText,'NINA ROAD VOICE 4 ')).Count -ne 1){throw 'Fourth laugh must play once'}
 }
 Write-Output "PASS native $Phase $Frames frames."
}finally{[IO.File]::WriteAllBytes($ninaSetting,$ninaBytes);[IO.File]::WriteAllBytes($ninaPlugins,$ninaPluginBytes)}
