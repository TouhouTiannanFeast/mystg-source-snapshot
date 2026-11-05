param([string]$Phase='all',[int]$Frames=1100)
$ErrorActionPreference='Stop'
$seigaGame='G:\MySTG\aex-0.8.22\game'
$seigaLogs='G:\MySTG\work\logs\th13-seiga4'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$seigaSetting=Join-Path $seigaGame 'userdata\setting.json'
$seigaBytes=[IO.File]::ReadAllBytes($seigaSetting)
$seigaPlugins=Join-Path $seigaGame 'plugins\plugins.json'
$seigaPluginBytes=[IO.File]::ReadAllBytes($seigaPlugins)
try{
 $seigaArgs="setting.mod='TH13Seiga4'; setting.seiga_test=true; setting.seiga_phase='$Phase'; setting.seiga_test_frames=$Frames; setting.windowed=true; start_game=true"
 $seigaProcess=Start-Process -FilePath (Join-Path $seigaGame 'LuaSTGSub.exe') -WorkingDirectory $seigaGame -ArgumentList ('"'+$seigaArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $seigaProcess.WaitForExit(120000)){
  Stop-Process -Id $seigaProcess.Id
  Copy-Item (Join-Path $seigaGame 'engine.log') (Join-Path $seigaLogs "native-$Phase-timeout.log")
  throw 'Bounded native probe exceeded120seconds; stopped only test process.'
 }
 $seigaLog=Join-Path $seigaLogs "native-$Phase.log"
 Copy-Item (Join-Path $seigaGame 'engine.log') $seigaLog
 $seigaText=Get-Content $seigaLog -Raw
 foreach($seigaMatch in [regex]::Matches($seigaText,'SEIGA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){
  Copy-Item (Join-Path $seigaGame $seigaMatch.Groups[1].Value) $seigaLogs
 }
 if($seigaProcess.ExitCode -ne 0 -or $seigaText -notmatch 'SEIGA COMPLETE'){throw "Native failure; see $seigaLog"}
 $seigaExpected=if($Phase -eq 'all'){@('non1','spell1','non2','spell2')}else{@($Phase)}
 foreach($seigaID in $seigaExpected){
  if($seigaText -notmatch "SEIGA NATIVE PASS $seigaID " -or $seigaText -notmatch "SEIGA CLEANUP PASS $seigaID"){throw "Missing phase evidence $seigaID"}
 }
 Write-Output "PASS native $Phase, $Frames frames/phase, actual shooting/Yoshika/curves/cleanup/exit."
}finally{[IO.File]::WriteAllBytes($seigaSetting,$seigaBytes);[IO.File]::WriteAllBytes($seigaPlugins,$seigaPluginBytes)}
