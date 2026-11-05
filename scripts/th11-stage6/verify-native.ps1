param([ValidateSet(0,1000,3100,4150,4750,5270,6510)][int]$Checkpoint=0,[switch]$EarlyClear,[switch]$KillBoss)
$ErrorActionPreference='Stop'
$th11s6Game='G:\MySTG\aex-0.8.22\game'
$th11s6Log='G:\MySTG\work\logs\th11-stage6'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$th11s6Settings=Join-Path $th11s6Game 'userdata\setting.json'
$th11s6Bytes=[IO.File]::ReadAllBytes($th11s6Settings)
try {
 $th11s6Args="setting.mod='TH11Stage6Normal'; setting.th11s6_test=true; setting.th11s6_test_frames=360; setting.th11s6_checkpoint=$Checkpoint; setting.th11s6_test_earlyclear=$($EarlyClear.IsPresent.ToString().ToLower()); setting.th11s6_test_killboss=$($KillBoss.IsPresent.ToString().ToLower()); setting.windowed=true; start_game=true"
 $th11s6Process=Start-Process (Join-Path $th11s6Game 'LuaSTGSub.exe') -WorkingDirectory $th11s6Game -ArgumentList ('"'+$th11s6Args+'"') -WindowStyle Hidden -PassThru
 if(-not $th11s6Process.WaitForExit(45000)){Stop-Process -Id $th11s6Process.Id;throw 'Bounded native probe timeout.'}
 Copy-Item (Join-Path $th11s6Game 'engine.log') (Join-Path $th11s6Log "native-$Checkpoint.log")
 $th11s6Text=Get-Content (Join-Path $th11s6Log "native-$Checkpoint.log") -Raw
 if($th11s6Process.ExitCode -ne 0 -or $th11s6Text -notmatch 'TH11S6 PASS tick='){throw 'Native probe failed; inspect preserved log.'}
 Get-ChildItem (Join-Path $th11s6Game "userdata\snapshot\th11s6-$Checkpoint-*.jpg") -ErrorAction SilentlyContinue | Copy-Item -Destination $th11s6Log
 Write-Output "PASS bounded native checkpoint $Checkpoint"
}finally{
 if($th11s6Process -and -not $th11s6Process.HasExited){Stop-Process -Id $th11s6Process.Id}
 [IO.File]::WriteAllBytes($th11s6Settings,$th11s6Bytes)
}
