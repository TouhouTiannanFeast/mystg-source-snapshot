param([ValidateSet(4,6)][int]$Stage=4,[switch]$PortraitOnly)
$ErrorActionPreference='Stop'
$storyGame='G:\MySTG\aex-0.8.22\game'
$storyLogs='G:\MySTG\work\logs\six-stages\dialogue46-20261111'
$storyEntry=if($PortraitOnly){'boss'}else{'full'}
$storyPortrait=if($PortraitOnly){'true'}else{'nil'}
$storyLogName=if($PortraitOnly){"native-$Stage-portrait.log"}else{"native-$Stage.log"}
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$storyState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $storyGame $name;$storyState[$path]=[IO.File]::ReadAllBytes($path)
}
try{
 $storyArgs="setting.mod='SixStageCampaign';setting.six_stage=$Stage;setting.six_entry='$storyEntry';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe=nil;setting.six_resource_probe=nil;setting.six_dialogue3_probe=nil;setting.six_story1_probe=nil;setting.six_story2_probe=nil;setting.six_story46_probe=true;setting.six_story46_portrait_probe=$storyPortrait;setting.six_invincible=true;setting.six_speed=8;setting.windowed=true;start_game=true"
 $storyProcess=Start-Process -FilePath (Join-Path $storyGame 'LuaSTGSub.exe') -WorkingDirectory $storyGame -ArgumentList ('"'+$storyArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded stage$Stage story process $($storyProcess.Id)"
 if(-not$storyProcess.WaitForExit(55000)){Stop-Process -Id $storyProcess.Id;throw 'Story probe deadline exceeded.'}
 $storyLog=Join-Path $storyLogs $storyLogName
 Copy-Item (Join-Path $storyGame 'engine.log') $storyLog
 $storyText=Get-Content $storyLog -Raw
 if($storyProcess.ExitCode-ne0-or$storyText-match 'stack traceback'-or$storyText-notmatch 'STORY46 NATIVE PASS'){throw "Native check failed: $storyLog"}
 Get-ChildItem (Join-Path $storyGame 'userdata\snapshot') -Filter 'story46-*.jpg' | Copy-Item -Destination $storyLogs
 Write-Output "PASS $storyLog"
}finally{
 if($storyProcess-and-not$storyProcess.HasExited){Stop-Process -Id $storyProcess.Id}
 Copy-Item (Join-Path $storyGame 'engine.log') (Join-Path $storyLogs $storyLogName)
 foreach($path in $storyState.Keys){[IO.File]::WriteAllBytes($path,$storyState[$path])}
}
