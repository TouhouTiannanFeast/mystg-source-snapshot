param([ValidateSet('survival','ordinary','practice','spark','horou','road','hit','comet')][string]$Mode='survival')
$ErrorActionPreference='Stop'
$combatGame='G:\MySTG\aex-0.8.22\game'
$combatLogs='G:\MySTG\work\logs\six-stages\combat-20261111'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$combatState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $combatGame $name;$combatState[$path]=[IO.File]::ReadAllBytes($path)
}
$combatStage=if($Mode-in@('survival','hit')){3}elseif($Mode-in@('horou','road')){5}else{4}
$combatEntry=if($Mode-eq'comet'){'comet'}elseif($Mode-eq'survival'){'spell3'}elseif($Mode-eq'hit'){'non2'}elseif($Mode-eq'practice'){'stardust'}elseif($Mode-eq'ordinary'){'milky'}elseif($Mode-eq'road'){'full'}else{'final'}
$combatSpeed=if($Mode-eq'hit'){1}else{8}
try{
 $combatArgs="setting.mod='SixStageCampaign';setting.six_stage=$combatStage;setting.six_entry='$combatEntry';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe='$Mode';setting.six_invincible=true;setting.six_speed=$combatSpeed;setting.windowed=true;start_game=true"
 $combatArgs+=";setting.six_story1_probe=nil;setting.six_story2_probe=nil;setting.six_story46_probe=nil;setting.six_dialogue3_probe=nil;setting.six_resource_probe=nil"
 $combatProcess=Start-Process -FilePath (Join-Path $combatGame 'LuaSTGSub.exe') -WorkingDirectory $combatGame -ArgumentList ('"'+$combatArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded native $Mode process $($combatProcess.Id)"
 if(-not$combatProcess.WaitForExit(45000)){Stop-Process -Id $combatProcess.Id;throw 'Native deadline exceeded.'}
 $combatLog=Join-Path $combatLogs "native-$Mode.log"
 Copy-Item (Join-Path $combatGame 'engine.log') $combatLog
 $combatText=Get-Content $combatLog -Raw
 if($combatProcess.ExitCode-ne0 -or$combatText-match 'stack traceback' -or$combatText-notmatch "COMBAT NATIVE PASS $Mode"){throw "Native check failed: $combatLog"}
 Copy-Item (Join-Path $combatGame "userdata\snapshot\combat-$Mode.jpg") $combatLogs
 Write-Output "PASS $combatLog"
}finally{
 if($combatProcess-and-not$combatProcess.HasExited){Stop-Process -Id $combatProcess.Id}
 Copy-Item (Join-Path $combatGame 'engine.log') (Join-Path $combatLogs "native-$Mode.log")
 foreach($path in $combatState.Keys){[IO.File]::WriteAllBytes($path,$combatState[$path])}
}
