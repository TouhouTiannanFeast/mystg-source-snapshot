param([ValidateSet('background','encounter')][string]$Scene='encounter')
$ErrorActionPreference='Stop'
$fix03Game='G:\MySTG\aex-0.8.22\game';$fix03Log='G:\MySTG\work\logs\th11-stage6\change03'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$fix03Settings=Join-Path $fix03Game 'userdata\setting.json';$fix03Bytes=[IO.File]::ReadAllBytes($fix03Settings)
$fix03Point=if($Scene -eq 'background'){0}else{3100};$fix03Frames=if($Scene -eq 'background'){360}else{850}
try {
 $fix03Args="setting.mod='TH11Stage6Normal';setting.th11s6_test=true;setting.th11s6_test_frames=$fix03Frames;setting.th11s6_checkpoint=$fix03Point;setting.th11s6_change03=$($Scene -eq 'encounter' | ForEach-Object {$_.ToString().ToLower()});setting.windowed=true;start_game=true"
 $fix03Process=Start-Process (Join-Path $fix03Game 'LuaSTGSub.exe') -WorkingDirectory $fix03Game -ArgumentList ('"'+$fix03Args+'"') -WindowStyle Hidden -PassThru
 $fix03Exited=$fix03Process.WaitForExit(45000)
 Copy-Item (Join-Path $fix03Game 'engine.log') (Join-Path $fix03Log "native-$Scene.log")
 if(-not $fix03Exited){Stop-Process -Id $fix03Process.Id;throw 'Bounded probe timeout; log preserved.'}
 $fix03Text=Get-Content (Join-Path $fix03Log "native-$Scene.log") -Raw
 if($fix03Process.ExitCode -ne 0 -or $fix03Text -notmatch 'TH11S6 PASS tick='){throw 'Native probe failed.'}
 if($Scene -eq 'encounter' -and $fix03Text -notmatch 'TH11S6 CHANGE03 PASS'){throw 'Encounter/drop/crow checks did not complete.'}
 if($Scene -eq 'encounter'){
  Get-ChildItem (Join-Path $fix03Game 'userdata\snapshot\th11s6-change03-*.jpg') | Copy-Item -Destination $fix03Log
 }else{
  Get-ChildItem (Join-Path $fix03Game 'userdata\snapshot\th11s6-0-*.jpg') | ForEach-Object {Copy-Item $_.FullName (Join-Path $fix03Log ('bg-'+$_.Name))}
 }
 Write-Output "PASS bounded native $Scene"
}finally{
 if($fix03Process -and -not $fix03Process.HasExited){Stop-Process -Id $fix03Process.Id}
 [IO.File]::WriteAllBytes($fix03Settings,$fix03Bytes)
}
