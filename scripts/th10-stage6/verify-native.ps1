param([ValidateSet(0,1320,2410,3300)][int]$Checkpoint=0)
$ErrorActionPreference='Stop'
$th10s6Game='G:\MySTG\aex-0.8.22\game'
$th10s6Log='G:\MySTG\work\logs\th10-stage6'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$th10s6Settings=Join-Path $th10s6Game 'userdata\setting.json'
$th10s6Bytes=[IO.File]::ReadAllBytes($th10s6Settings)
try {
 $th10s6Args="setting.mod='TH10Stage6Normal'; setting.th10s6_test=true; setting.th10s6_test_frames=360; setting.th10s6_checkpoint=$Checkpoint; setting.windowed=true; start_game=true"
 $th10s6Process=Start-Process (Join-Path $th10s6Game 'LuaSTGSub.exe') -WorkingDirectory $th10s6Game -ArgumentList ('"'+$th10s6Args+'"') -WindowStyle Hidden -PassThru
 if(-not $th10s6Process.WaitForExit(45000)){Stop-Process -Id $th10s6Process.Id;throw 'Bounded native probe timeout.'}
 Copy-Item (Join-Path $th10s6Game 'engine.log') (Join-Path $th10s6Log "native-$Checkpoint.log")
 $th10s6Text=Get-Content (Join-Path $th10s6Log "native-$Checkpoint.log") -Raw
 if($th10s6Process.ExitCode -ne 0 -or $th10s6Text -notmatch 'TH10S6 PASS tick=\d+ spawns=\d+ shots=\d+ kills=\d+ culls=\d+ drops=\d+ sounds=\d+'){throw 'Native probe failed; inspect preserved log.'}
 Get-ChildItem (Join-Path $th10s6Game "userdata\snapshot\th10s6-$Checkpoint-*.jpg") | Copy-Item -Destination $th10s6Log
 Write-Output "PASS bounded native checkpoint $Checkpoint"
}finally{
 if($th10s6Process -and -not $th10s6Process.HasExited){Stop-Process -Id $th10s6Process.Id}
 [IO.File]::WriteAllBytes($th10s6Settings,$th10s6Bytes)
}
