param([switch]$HammerOnly)
$ErrorActionPreference='Stop'
$rsGame='G:\MySTG\aex-0.8.22\game'
$rsLog='G:\MySTG\work\logs\ringo-seiran'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close the running game first.'}
$rsSettings=Join-Path $rsGame 'userdata\setting.json'
$rsBytes=[IO.File]::ReadAllBytes($rsSettings)
try {
 $rsArgs="setting.mod='RingoSeiran'; setting.rs_practice='all'; setting.rs_test=true; setting.rs_fast=true; setting.windowed=true; start_game=true"
 if($HammerOnly){$rsArgs+="; setting.rs_practice='spell'; setting.rs_hammer_test=true"}
 $rsProcess=Start-Process (Join-Path $rsGame 'LuaSTGSub.exe') -WorkingDirectory $rsGame -ArgumentList ('"'+$rsArgs+'"') -WindowStyle Hidden -PassThru
 if(-not $rsProcess.WaitForExit(45000)){Stop-Process -Id $rsProcess.Id;throw 'Native checkpoint timed out.'}
 $rsName=if($HammerOnly){'native-hammer.log'}else{'native.log'}
 Copy-Item (Join-Path $rsGame 'engine.log') (Join-Path $rsLog $rsName)
 $rsText=Get-Content (Join-Path $rsLog $rsName) -Raw
 $rsComplete=if($HammerOnly){'RS COMPLETE phases=1'}else{'RS COMPLETE phases=2'}
 if($rsProcess.ExitCode -ne 0 -or $rsText -notmatch $rsComplete -or $rsText -notmatch 'RS IMPACT t=359 locks=3 gun=108') {throw 'Native verification failed; inspect native log.'}
 if($HammerOnly -and $rsText -notmatch 'RS HAMMER COLLISION PASS'){throw 'Hammer collision check failed.'}
 if($HammerOnly -and ($rsText -notmatch 'RS BODY COLLISION PASS' -or $rsText -notmatch 'RS SHAKE PASS')){throw 'Body collision / screen shake check failed.'}
 if($rsText -notmatch 'RS PELLETS t=359 total=18' -or $rsText -notmatch 'RS STAR FLIGHT PASS'){throw 'Persistent star flight host check failed.'}
 Copy-Item (Join-Path $rsGame 'userdata\snapshot\ringo-seiran-*.jpg') $rsLog
 if($HammerOnly){Write-Output 'PASS: native3 impacts/108gun/18redrings; 6redrings between gun groups,continuous flight,fade24; body+hammer collisions,shake/reset,cleanup.'}
 else{Write-Output 'PASS: native nonspell timeout, spell3 impacts/108gun, cleanup, six named snapshots.'}
} finally {
 if($rsProcess -and -not $rsProcess.HasExited){Stop-Process -Id $rsProcess.Id}
 [IO.File]::WriteAllBytes($rsSettings,$rsBytes)
}
