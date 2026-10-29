param([ValidateSet('all','non1','spell3')][string]$Practice='all',[switch]$Shoot,[switch]$PlayerProbe)
$ErrorActionPreference='Stop'
$y3Game='G:\MySTG\aex-0.8.22\game'
$y3Logs='G:\MySTG\work\logs\yuyuko3'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close the running game first; it was preserved.'}
$y3Settings=Join-Path $y3Game 'userdata\setting.json'
$y3Before=[IO.File]::ReadAllBytes($y3Settings)
try{
 $y3Args="setting.mod='YuyukoStage3'; setting.y3_practice='$Practice'; setting.y3_test=true; setting.y3_test_frames=900; setting.y3_fast=true; setting.windowed=true; start_game=true"
 if($Shoot){$y3Args+='; setting.y3_test_shoot=true'}
 if($PlayerProbe){$y3Args+='; setting.y3_test_player=true'}
 $y3Process=Start-Process -FilePath (Join-Path $y3Game 'LuaSTGSub.exe') -WorkingDirectory $y3Game -ArgumentList ('"'+$y3Args+'"') -WindowStyle Hidden -PassThru
 $y3Deadline=(Get-Date).AddSeconds(70)
 while(-not $y3Process.WaitForExit(1000)){if((Get-Date)-gt$y3Deadline){throw 'Probe timed out; process retained for inspection.'}}
 $y3File=if($PlayerProbe){'player02-native.log'}elseif($Shoot){'native-shoot.log'}else{"native-$Practice.log"}
 Copy-Item -LiteralPath (Join-Path $y3Game 'engine.log') -Destination (Join-Path $y3Logs $y3File)
 $y3Text=Get-Content -LiteralPath (Join-Path $y3Logs $y3File) -Raw
 $y3Expected=if($Practice-eq'all'){6}else{1}
 if($y3Process.ExitCode-ne 0 -or ([regex]::Matches($y3Text,'Y3 END ')).Count-ne$y3Expected -or $y3Text-notmatch"Y3 COMPLETE phases=$y3Expected"){throw "Native probe failed; inspect $y3File."}
 if($PlayerProbe-and$y3Text-notmatch'Y3 PLAYER PIERCE PASS'){throw 'Player piercing check did not pass.'}
 $y3Phases=if($Practice-eq'all'){@('non1','spell1','non2','spell2','non3','spell3')}else{@($Practice)}
 foreach($y3Phase in $y3Phases){
  Copy-Item -LiteralPath (Join-Path $y3Game "userdata\snapshot\yuyuko3-$y3Phase.jpg") -Destination $y3Logs
 }
 Write-Output "PASS native $Practice phases=$y3Expected, 900 frames each, phase cleanup, captures and normal exit."
}finally{[IO.File]::WriteAllBytes($y3Settings,$y3Before)}
