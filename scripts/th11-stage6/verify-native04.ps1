param([ValidateSet('chains','boss')][string]$Scene='boss')
$ErrorActionPreference='Stop'
$fix04Game='G:\MySTG\aex-0.8.22\game';$fix04Log='G:\MySTG\work\logs\th11-stage6\change04'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$fix04Settings=Join-Path $fix04Game 'userdata\setting.json';$fix04Bytes=[IO.File]::ReadAllBytes($fix04Settings)
$fix04Point=if($Scene -eq 'chains'){590}else{3100};$fix04Frames=if($Scene -eq 'chains'){360}else{720}
try {
 $fix04Args="setting.mod='TH11Stage6Normal';setting.th11s6_test=true;setting.th11s6_test_frames=$fix04Frames;setting.th11s6_checkpoint=$fix04Point;setting.th11s6_change04=true;setting.windowed=true;start_game=true"
 $fix04Process=Start-Process (Join-Path $fix04Game 'LuaSTGSub.exe') -WorkingDirectory $fix04Game -ArgumentList ('"'+$fix04Args+'"') -WindowStyle Hidden -PassThru
 $fix04Exited=$fix04Process.WaitForExit(45000)
 Copy-Item (Join-Path $fix04Game 'engine.log') (Join-Path $fix04Log "native-$Scene.log")
 if(-not $fix04Exited){Stop-Process -Id $fix04Process.Id;throw 'Bounded probe timeout; log preserved.'}
 $fix04Text=Get-Content (Join-Path $fix04Log "native-$Scene.log") -Raw
 $fix04Marker=if($Scene -eq 'chains'){'TH11S6 CHAINS04 PASS'}else{'TH11S6 BOSS04 PASS'}
 if($fix04Process.ExitCode -ne 0 -or $fix04Text -notmatch $fix04Marker -or $fix04Text -notmatch 'TH11S6 PASS tick='){throw 'Scoped native probe failed; see log.'}
 Get-ChildItem (Join-Path $fix04Game 'userdata\snapshot\th11s6-change04-*.jpg') | Copy-Item -Destination $fix04Log
 Write-Output "PASS bounded native $Scene"
}finally{
 if($fix04Process -and -not $fix04Process.HasExited){Stop-Process -Id $fix04Process.Id}
 [IO.File]::WriteAllBytes($fix04Settings,$fix04Bytes)
}
