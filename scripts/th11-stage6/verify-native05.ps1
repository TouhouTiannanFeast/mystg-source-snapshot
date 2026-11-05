$ErrorActionPreference='Stop'
$gate05Game='G:\MySTG\aex-0.8.22\game';$gate05Log='G:\MySTG\work\logs\th11-stage6\change05'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$gate05Settings=Join-Path $gate05Game 'userdata\setting.json';$gate05Bytes=[IO.File]::ReadAllBytes($gate05Settings)
try {
 $gate05Args="setting.mod='TH11Stage6Normal';setting.th11s6_test=true;setting.th11s6_test_frames=700;setting.th11s6_checkpoint=3100;setting.th11s6_change05=true;setting.windowed=true;start_game=true"
 $gate05Process=Start-Process (Join-Path $gate05Game 'LuaSTGSub.exe') -WorkingDirectory $gate05Game -ArgumentList ('"'+$gate05Args+'"') -WindowStyle Hidden -PassThru
 $gate05Exited=$gate05Process.WaitForExit(40000)
 Copy-Item (Join-Path $gate05Game 'engine.log') (Join-Path $gate05Log 'native.log')
 if(-not $gate05Exited){Stop-Process -Id $gate05Process.Id;throw 'Bounded probe timeout; log preserved.'}
 $gate05Text=Get-Content (Join-Path $gate05Log 'native.log') -Raw
 if($gate05Process.ExitCode -ne 0 -or $gate05Text -notmatch 'TH11S6 GATE05 PASS' -or $gate05Text -notmatch 'TH11S6 FROG05 PASS' -or $gate05Text -notmatch 'TH11S6 PASS tick='){throw 'Scoped gate/frog probe failed; see log.'}
 Copy-Item (Join-Path $gate05Game 'userdata\snapshot\th11s6-change05-frog.jpg') -Destination $gate05Log
 Write-Output 'PASS bounded native gate and new frog render'
}finally{
 if($gate05Process -and -not $gate05Process.HasExited){Stop-Process -Id $gate05Process.Id}
 [IO.File]::WriteAllBytes($gate05Settings,$gate05Bytes)
}
