param([switch]$BeforeFix)
$ErrorActionPreference='Stop'
$collisionGame='G:\MySTG\aex-0.8.22\game'
$collisionLog='G:\MySTG\work\logs\stage5\collision09-'+$(if($BeforeFix){'before'}else{'after'})+'.log'
if(Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue){throw 'Existing game preserved; close it first.'}
$collisionSettings=Join-Path $collisionGame 'userdata\setting.json'
$collisionBytes=[IO.File]::ReadAllBytes($collisionSettings)
try{
 $collisionArgs="setting.mod='MySTG'; setting.suwako5_autostart=true; setting.suwako5_seed=20261026; setting.th18_stage5_collision_test=true; setting.windowed=true; start_game=true"
 $collisionProcess=Start-Process -FilePath (Join-Path $collisionGame 'LuaSTGSub.exe') -WorkingDirectory $collisionGame -ArgumentList ('"'+$collisionArgs+'"') -WindowStyle Hidden -PassThru
 $collisionLimit=(Get-Date).AddSeconds(35)
 while(-not $collisionProcess.WaitForExit(1000)){if((Get-Date)-gt $collisionLimit){throw 'Collision probe timeout; process preserved.'}}
 Copy-Item (Join-Path $collisionGame 'engine.log') $collisionLog
 $collisionText=Get-Content -LiteralPath $collisionLog -Raw
 $collisionText -split "`r?`n" | Select-String 'COLLISION09'
 if($BeforeFix){if($collisionText -notmatch 'COLLISION09 START native=false' -or $collisionText -notmatch 'COLLISION09 FAIL'){throw 'Expected disabled native collision was not reproduced.'}}
 elseif($collisionText -notmatch 'COLLISION09 PASS'){throw 'Real shot collision probe failed.'}
 Write-Output 'PASS bounded native collision verification'
}finally{[IO.File]::WriteAllBytes($collisionSettings,$collisionBytes)}
