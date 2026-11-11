$ErrorActionPreference='Stop'
$storyGame='G:\MySTG\aex-0.8.22\game';$storyLogs='G:\MySTG\work\logs\six-stages\dialogue1-20261111'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$storyState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $storyGame $name;$storyState[$path]=[IO.File]::ReadAllBytes($path)
}
try{
 $storyArgs="setting.mod='SixStageCampaign';setting.six_stage=1;setting.six_entry='full';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe=nil;setting.six_resource_probe=nil;setting.six_dialogue3_probe=nil;setting.six_story46_probe=nil;setting.six_story2_probe=nil;setting.six_story1_probe=true;setting.flare_test=nil;setting.six_invincible=true;setting.six_speed=8;setting.windowed=true;start_game=true"
 $storyProcess=Start-Process -FilePath (Join-Path $storyGame 'LuaSTGSub.exe') -WorkingDirectory $storyGame -ArgumentList ('"'+$storyArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded stage1 story process $($storyProcess.Id)"
 if(-not$storyProcess.WaitForExit(45000)){Stop-Process -Id $storyProcess.Id;throw 'Story probe deadline exceeded.'}
 $storyLog=Join-Path $storyLogs 'native.log';Copy-Item (Join-Path $storyGame 'engine.log') $storyLog
 $storyText=Get-Content $storyLog -Raw
 if($storyProcess.ExitCode-ne0-or$storyText-match 'stack traceback'-or$storyText-notmatch 'STORY1 NATIVE PASS'){throw "Native check failed: $storyLog"}
 Get-ChildItem (Join-Path $storyGame 'userdata\snapshot') -Filter 'story1-*.jpg' | Copy-Item -Destination $storyLogs
 Write-Output "PASS $storyLog"
}finally{
 if($storyProcess-and-not$storyProcess.HasExited){Stop-Process -Id $storyProcess.Id}
 Copy-Item (Join-Path $storyGame 'engine.log') (Join-Path $storyLogs 'native.log')
 foreach($path in $storyState.Keys){[IO.File]::WriteAllBytes($path,$storyState[$path])}
}
