param([switch]$Route,[switch]$Timeout,[switch]$Latter,[switch]$Scenery)
$ErrorActionPreference='Stop'
$stage5Game='G:\MySTG\aex-0.8.22\game'
$stage5Logs='G:\MySTG\work\logs\stage5'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$stage5Settings=Join-Path $stage5Game 'userdata\setting.json'
$stage5Bytes=[IO.File]::ReadAllBytes($stage5Settings)
try{
 $stage5Args="setting.mod='MySTG'; setting.suwako5_autostart=true; setting.suwako5_seed=20261026; setting.suwako5_test=true; setting.suwako5_test_frames=240; setting.suwako5_test_plan={'th10-non1'}; setting.suwako5_invincible=true; setting.windowed=true; start_game=true"
 if($Route){$stage5Args+="; setting.th18_stage5_test=true; setting.th18_stage5_test_midboss=700; setting.th18_stage5_test_snapshots={180,1600,3100,4300,4560,4940,5550,7400,8500}"}
 if($Scenery){$stage5Args+='; setting.th18_stage5_test_scenery=true'}
 if($Latter){$stage5Args+='; setting.th18_stage5_test_skip_front=true'}
 if($Timeout){$stage5Args+='; setting.th18_stage5_test_timeout=true; setting.th18_stage5_test_midboss=2100'}
 $stage5Process=Start-Process -FilePath (Join-Path $stage5Game 'LuaSTGSub.exe') -WorkingDirectory $stage5Game -ArgumentList ('"'+$stage5Args+'"') -WindowStyle Hidden -PassThru
 Write-Output ('Native PID='+$stage5Process.Id)
 $stage5Limit=(Get-Date).AddSeconds(260)
 while(-not $stage5Process.WaitForExit(1000)){if((Get-Date)-gt $stage5Limit){throw 'Native test timed out; process preserved for inspection.'}}
 $stage5Name=if($Scenery){'native-scenery'}elseif($Route -and $Timeout){'native-full-timeout'}elseif($Route){'native-route'}else{'native-model'}
 Copy-Item (Join-Path $stage5Game 'engine.log') (Join-Path $stage5Logs ($stage5Name+'.log'))
 $stage5Text=Get-Content (Join-Path $stage5Logs ($stage5Name+'.log')) -Raw
 if($stage5Text -notmatch 'SUWAKO5 COMPLETE phases=1'){throw 'Native stage did not complete; inspect log.'}
 foreach($stage5Match in [regex]::Matches($stage5Text,'(?:SUWAKO5|TH18S5) SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')){Copy-Item (Join-Path $stage5Game $stage5Match.Groups[1].Value) $stage5Logs}
 Write-Output "PASS $stage5Name"
}finally{[IO.File]::WriteAllBytes($stage5Settings,$stage5Bytes)}
