$ErrorActionPreference='Stop'
$scene02Game='G:\MySTG\aex-0.8.22\game'
$scene02Log='G:\MySTG\work\logs\th11-stage6\change02'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$scene02Settings=Join-Path $scene02Game 'userdata\setting.json'
$scene02Bytes=[IO.File]::ReadAllBytes($scene02Settings)
try {
 $scene02Args="setting.mod='TH11Stage6Normal'; setting.th11s6_test=true; setting.th11s6_test_frames=600; setting.th11s6_checkpoint=0; setting.th11s6_change02=true; setting.windowed=true; start_game=true"
 $scene02Process=Start-Process (Join-Path $scene02Game 'LuaSTGSub.exe') -WorkingDirectory $scene02Game -ArgumentList ('"'+$scene02Args+'"') -WindowStyle Hidden -PassThru
 if(-not $scene02Process.WaitForExit(45000)){Stop-Process -Id $scene02Process.Id;throw 'Bounded scene/player probe timeout.'}
 Copy-Item (Join-Path $scene02Game 'engine.log') (Join-Path $scene02Log 'native.log')
 $scene02Text=Get-Content (Join-Path $scene02Log 'native.log') -Raw
 if($scene02Process.ExitCode -ne 0 -or $scene02Text -notmatch 'TH11S6 CHANGE02 PASS' -or $scene02Text -notmatch 'TH11S6 PASS tick=600'){throw 'Native scene/player probe failed; inspect preserved log.'}
 Get-ChildItem (Join-Path $scene02Game 'userdata\snapshot\th11s6-change02-*.jpg') | Copy-Item -Destination $scene02Log
 Write-Output 'PASS bounded600f native Extra camera/loop,reference shot/high/slow/Bomb/4P'
}finally{
 if($scene02Process -and -not $scene02Process.HasExited){Stop-Process -Id $scene02Process.Id}
 [IO.File]::WriteAllBytes($scene02Settings,$scene02Bytes)
}
