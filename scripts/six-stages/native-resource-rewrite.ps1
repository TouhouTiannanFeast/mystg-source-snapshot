param([ValidateSet('opening','anchor','stage2','marisa','horou','nina')][string]$Mode='opening')
$ErrorActionPreference='Stop'
$resourceGame='G:\MySTG\aex-0.8.22\game'
$resourceLogs='G:\MySTG\work\logs\six-stages\resources-20261111'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$resourceState=@{}
foreach($name in @('userdata\setting.json','userdata\save\SixStageCampaign\User.json')){
 $path=Join-Path $resourceGame $name;$resourceState[$path]=[IO.File]::ReadAllBytes($path)
}
$resourceStage=if($Mode-in@('opening','anchor')){1}elseif($Mode-eq'stage2'){2}elseif($Mode-eq'marisa'){4}elseif($Mode-eq'horou'){5}else{6}
$resourceEntry=if($Mode-eq'opening'){'full'}elseif($Mode-eq'anchor'){'s1-scale'}elseif($Mode-eq'stage2'){'s2-mz2'}elseif($Mode-eq'nina'){'non3'}else{'final'}
try{
 $resourceArgs="setting.mod='SixStageCampaign';setting.six_stage=$resourceStage;setting.six_entry='$resourceEntry';setting.six_direct=true;setting.six_probe=false;setting.six_combat_probe=nil;setting.six_resource_probe='$Mode';setting.six_invincible=true;setting.six_speed=8;setting.windowed=true;start_game=true"
 $resourceProcess=Start-Process -FilePath (Join-Path $resourceGame 'LuaSTGSub.exe') -WorkingDirectory $resourceGame -ArgumentList ('"'+$resourceArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Bounded native $Mode process $($resourceProcess.Id)"
 if(-not$resourceProcess.WaitForExit(30000)){Stop-Process -Id $resourceProcess.Id;throw 'Native deadline exceeded.'}
 $resourceLog=Join-Path $resourceLogs "native-$Mode.log"
 Copy-Item (Join-Path $resourceGame 'engine.log') $resourceLog
 $resourceText=Get-Content $resourceLog -Raw
 if($resourceProcess.ExitCode-ne0-or$resourceText-match 'stack traceback'-or$resourceText-notmatch "RESOURCE NATIVE PASS $Mode"){throw "Native check failed: $resourceLog"}
 Copy-Item (Join-Path $resourceGame "userdata\snapshot\resources-$Mode.jpg") $resourceLogs
 Write-Output "PASS $resourceLog"
}finally{
 if($resourceProcess-and-not$resourceProcess.HasExited){Stop-Process -Id $resourceProcess.Id}
 Copy-Item (Join-Path $resourceGame 'engine.log') (Join-Path $resourceLogs "native-$Mode.log")
 foreach($path in $resourceState.Keys){[IO.File]::WriteAllBytes($path,$resourceState[$path])}
}
