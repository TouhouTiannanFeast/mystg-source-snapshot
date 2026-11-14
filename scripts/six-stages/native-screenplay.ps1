param([ValidateRange(1,6)][int]$Stage=1,[switch]$ShionPortraitOnly,[switch]$PatchouliPortraitOnly,[switch]$MystiaPortraitOnly)
$ErrorActionPreference='Stop'
$scriptGame='G:\MySTG\aex-0.8.22\game';$scriptLogs='G:\MySTG\work\logs\six-stages\screenplay-20261113'
if($ShionPortraitOnly){$scriptLogs='G:\MySTG\work\logs\six-stages\shion-portraits-20261113'}
if($PatchouliPortraitOnly){$scriptLogs='G:\MySTG\work\logs\six-stages\patchouli-portrait-20261113'}
if($MystiaPortraitOnly){$scriptLogs='G:\MySTG\work\logs\six-stages\mystia-portraits-20261113'}
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$scriptState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $scriptGame $name;$scriptState[$path]=[IO.File]::ReadAllBytes($path)
}
try{
 $scriptArgs="setting.mod='SixStageCampaign';setting.six_stage=$Stage;setting.six_entry='full';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe=nil;setting.six_resource_probe=nil;setting.six_dialogue3_probe=nil;setting.six_story1_probe=nil;setting.six_story2_probe=nil;setting.six_story2_patchouli_only=nil;setting.six_story46_probe=nil;setting.six_story46_portrait_probe=nil;setting.six_screenplay_probe=true;setting.six_invincible=true;setting.six_speed=8;setting.windowed=true;start_game=true"
 $scriptArgs+=";setting.six_shion_portrait_only="+$(if($ShionPortraitOnly){'true;setting.six_entry=''non1'''}else{'nil'})
 if($PatchouliPortraitOnly){$scriptArgs+=";setting.six_story2_patchouli_only=true;setting.six_entry='full'"}
 $scriptArgs+=";setting.six_mystia_portrait_only="+$(if($MystiaPortraitOnly){"true;setting.six_entry='s2-mystia'"}else{'nil'})
 $scriptProcess=Start-Process -FilePath (Join-Path $scriptGame 'LuaSTGSub.exe') -WorkingDirectory $scriptGame -ArgumentList ('"'+$scriptArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded screenplay Stage$Stage process $($scriptProcess.Id)"
 if(-not$scriptProcess.WaitForExit(58000)){Stop-Process -Id $scriptProcess.Id;throw "Stage$Stage screenplay deadline"}
 $scriptLog=Join-Path $scriptLogs "native-$Stage.log";Copy-Item (Join-Path $scriptGame 'engine.log') $scriptLog
 $scriptText=Get-Content $scriptLog -Raw
 if($scriptProcess.ExitCode-ne0-or$scriptText-match 'stack traceback'-or$scriptText-notmatch 'NATIVE PASS'){throw "Native check failed: $scriptLog"}
 Get-ChildItem (Join-Path $scriptGame 'userdata\snapshot') -Filter "screenplay-$Stage-*.jpg" | Copy-Item -Destination $scriptLogs
 if($ShionPortraitOnly){Copy-Item (Join-Path $scriptGame 'userdata\snapshot\shion-portrait-user08.jpg') (Join-Path $scriptLogs 'preview.jpg')}
 if($PatchouliPortraitOnly){Get-ChildItem (Join-Path $scriptGame 'userdata\snapshot') -Filter 'story2-s2hinapre-*.jpg' | Copy-Item -Destination $scriptLogs}
 if($MystiaPortraitOnly){Get-ChildItem (Join-Path $scriptGame 'userdata\snapshot') -Filter 'mystia-portrait-*.jpg' | Copy-Item -Destination $scriptLogs}
 Write-Output "PASS $scriptLog"
}finally{
 if($scriptProcess-and-not$scriptProcess.HasExited){Stop-Process -Id $scriptProcess.Id}
 Copy-Item (Join-Path $scriptGame 'engine.log') (Join-Path $scriptLogs "native-$Stage.log")
 foreach($path in $scriptState.Keys){[IO.File]::WriteAllBytes($path,$scriptState[$path])}
}
