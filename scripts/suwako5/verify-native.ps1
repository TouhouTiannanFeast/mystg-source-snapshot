param([switch]$Shoot,[switch]$Progress,[switch]$VisualBomb)
$ErrorActionPreference='Stop'
$suwako5Game='G:\MySTG\aex-0.8.22\game'
$suwako5Logs='G:\MySTG\work\logs\suwako5'
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing game preserved; close it first.' }
$suwako5Settings=Join-Path $suwako5Game 'userdata\setting.json'
$suwako5Bytes=[IO.File]::ReadAllBytes($suwako5Settings)
try {
 $suwako5Args="setting.mod='MySTG'; setting.suwako5_autostart=true; setting.suwako5_seed=20261026; setting.suwako5_test=true; setting.suwako5_test_frames=720; setting.suwako5_test_plan={'th10-non1','th10-card2','th125-d','th143-0902','th143-0906'}; setting.windowed=true; start_game=true"
 if ($Shoot) { $suwako5Args+="; setting.suwako5_test_shoot=true; setting.suwako5_test_frames=480; setting.suwako5_test_plan={'th10-card8','th10-card9','th125-a','th143-0906'}" }
 if ($Progress) { $suwako5Args+="; setting.suwako5_test_progress=true; setting.suwako5_test_plan={'th125-a','th125-b','th125-c','th125-d'}" }
 if ($VisualBomb) { $suwako5Args+="; setting.suwako5_test_progress=true; setting.suwako5_test_plan={'th125-d'}" }
 $suwako5Process=Start-Process -FilePath (Join-Path $suwako5Game 'LuaSTGSub.exe') -WorkingDirectory $suwako5Game -ArgumentList ('"'+$suwako5Args+'"') -WindowStyle Hidden -PassThru
 if (-not $suwako5Process.WaitForExit(90000)) { throw 'Bounded Stage 5 test timed out; process retained for inspection.' }
 $suwako5LogName=if ($VisualBomb) {'engine-bombvisual.log'} elseif ($Progress) {'engine-progress.log'} elseif ($Shoot) {'engine-shoot.log'} else {'engine.log'}
 Copy-Item (Join-Path $suwako5Game 'engine.log') (Join-Path $suwako5Logs $suwako5LogName)
 $suwako5Text=Get-Content (Join-Path $suwako5Logs $suwako5LogName) -Raw
 $suwako5Expected=if ($VisualBomb) {'SUWAKO5 COMPLETE phases=1'} elseif ($Shoot -or $Progress) {'SUWAKO5 COMPLETE phases=4'} else {'SUWAKO5 COMPLETE phases=5'}
 if ($suwako5Process.ExitCode -ne 0 -or $suwako5Text -notmatch $suwako5Expected) { throw 'Stage 5 native test failed; inspect log.' }
 foreach ($suwako5Match in [regex]::Matches($suwako5Text,'SUWAKO5 SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $suwako5Game $suwako5Match.Groups[1].Value) $suwako5Logs }
 Write-Output "PASS Stage 5 native host; $suwako5Expected; shoot=$Shoot; phase completion and cleanup."
} finally { [IO.File]::WriteAllBytes($suwako5Settings,$suwako5Bytes) }
