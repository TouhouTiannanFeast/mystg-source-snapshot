param([ValidateSet('full','non1','spell3')][string]$Entry='full')
$ErrorActionPreference='Stop'
$dialogGame='G:\MySTG\aex-0.8.22\game'
$dialogLogs='G:\MySTG\work\logs\six-stages\dialogue3-20261111'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$dialogState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $dialogGame $name;$dialogState[$path]=[IO.File]::ReadAllBytes($path)
}
try{
 $dialogArgs="setting.mod='SixStageCampaign';setting.six_stage=3;setting.six_entry='$Entry';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe=nil;setting.six_resource_probe=nil;setting.six_dialogue3_probe=true;setting.six_invincible=true;setting.six_speed=8;setting.windowed=true;start_game=true"
 $dialogProcess=Start-Process -FilePath (Join-Path $dialogGame 'LuaSTGSub.exe') -WorkingDirectory $dialogGame -ArgumentList ('"'+$dialogArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded dialogue process $($dialogProcess.Id)"
 if(-not$dialogProcess.WaitForExit(45000)){Stop-Process -Id $dialogProcess.Id;throw 'Dialogue probe deadline exceeded.'}
 $dialogLog=Join-Path $dialogLogs "native-$Entry.log"
 Copy-Item (Join-Path $dialogGame 'engine.log') $dialogLog
 $dialogText=Get-Content $dialogLog -Raw
 if($dialogProcess.ExitCode-ne0-or$dialogText-match 'stack traceback'-or$dialogText-notmatch 'DIALOGUE3 NATIVE PASS'){throw "Native check failed: $dialogLog"}
 Get-ChildItem (Join-Path $dialogGame 'userdata\snapshot') -Filter 'dialogue3-*.jpg' | Copy-Item -Destination $dialogLogs
 Write-Output "PASS $dialogLog"
}finally{
 if($dialogProcess-and-not$dialogProcess.HasExited){Stop-Process -Id $dialogProcess.Id}
 Copy-Item (Join-Path $dialogGame 'engine.log') (Join-Path $dialogLogs "native-$Entry.log")
 foreach($path in $dialogState.Keys){[IO.File]::WriteAllBytes($path,$dialogState[$path])}
}
