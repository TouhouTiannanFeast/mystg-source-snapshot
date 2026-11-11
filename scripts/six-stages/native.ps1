param([int]$Stage=1,[string]$Entry='full',[switch]$Probe,[switch]$Charge,[switch]$Items)
$ErrorActionPreference='Stop'
$sixGame='G:\MySTG\aex-0.8.22\game'
$sixLogs='G:\MySTG\work\logs\six-stages'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved.'}
$sixSettings=Join-Path $sixGame 'userdata\setting.json'
$sixBytes=[IO.File]::ReadAllBytes($sixSettings)
try{
 $sixArgs="setting.mod='SixStageCampaign'; setting.six_stage=$Stage; setting.six_entry='$Entry'; setting.six_invincible=true; setting.six_speed=8; setting.six_probe=$($Probe.IsPresent.ToString().ToLowerInvariant()); setting.windowed=true; start_game=true"
 $sixArgs+="; setting.six_probe_b3=$($Charge.IsPresent.ToString().ToLowerInvariant()); setting.six_items_probe=$($Items.IsPresent.ToString().ToLowerInvariant())"
 $sixProcess=Start-Process -FilePath (Join-Path $sixGame 'LuaSTGSub.exe') -WorkingDirectory $sixGame -ArgumentList ('"'+$sixArgs+'"') -WindowStyle Hidden -PassThru
 Write-Output "Native process $($sixProcess.Id)"
 if(-not$sixProcess.WaitForExit(55000)){Stop-Process -Id $sixProcess.Id;throw 'Bounded native check timed out.'}
 $sixLog=Join-Path $sixLogs "revision/native-$Stage-$Entry-$($Charge.IsPresent)-$($Items.IsPresent).log"
 Copy-Item (Join-Path $sixGame 'engine.log') $sixLog
 $sixText=Get-Content $sixLog -Raw
 if($sixProcess.ExitCode-ne0 -or $sixText-match 'SIX ERROR|stack traceback'){throw "Native failure: $sixLog"}
 if($Probe -and $sixText-notmatch 'SIX PROBE PASS'){throw "Missing completion: $sixLog"}
 Write-Output "PASS $sixLog"
}finally{
 if($sixProcess -and -not$sixProcess.HasExited){Stop-Process -Id $sixProcess.Id}
 Copy-Item (Join-Path $sixGame 'engine.log') (Join-Path $sixLogs "revision/native-$Stage-$Entry-$($Charge.IsPresent)-$($Items.IsPresent).log")
 [IO.File]::WriteAllBytes($sixSettings,$sixBytes)
}
