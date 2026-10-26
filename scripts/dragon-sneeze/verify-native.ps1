$ErrorActionPreference='Stop'
$dragonRoot='G:\MySTG'
$dragonGame=Join-Path $dragonRoot 'aex-0.8.22\game'
$dragonLogs=Join-Path $dragonRoot 'work\logs\dragon-sneeze'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing game preserved; close it first.' }
$dragonSettings=Join-Path $dragonGame 'userdata\setting.json'
$dragonBytes=[IO.File]::ReadAllBytes($dragonSettings)
$dragonHashes=@{}
foreach ($dragonFile in @('mod\MySTG\root.lua','mod\MySTG\stages\normal.lua')) { $dragonHashes[$dragonFile]=(Get-FileHash (Join-Path $dragonGame $dragonFile)).Hash }
try {
    $dragonArgs="setting.mod='DragonSneeze'; setting.dragon_test=true; setting.windowed=true; start_game=true"
    $dragonProcess=Start-Process -FilePath (Join-Path $dragonGame 'LuaSTGSub.exe') -WorkingDirectory $dragonGame -ArgumentList ('"'+$dragonArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $dragonProcess.WaitForExit(60000)) { throw 'Native run exceeded 60 seconds; game left for inspection.' }
    Copy-Item (Join-Path $dragonGame 'engine.log') (Join-Path $dragonLogs 'engine.log')
    $dragonText=Get-Content (Join-Path $dragonLogs 'engine.log') -Raw
    if ($dragonProcess.ExitCode -ne 0 -or $dragonText -notmatch 'DRAGON FIRST CYCLE PASS' -or $dragonText -notmatch 'DRAGON CLEANUP PASS') { throw 'Native validation failed; inspect engine.log.' }
    foreach ($dragonFile in $dragonHashes.Keys) { if ((Get-FileHash (Join-Path $dragonGame $dragonFile)).Hash -ne $dragonHashes[$dragonFile]) { throw 'Original content changed.' } }
    foreach ($dragonMatch in [regex]::Matches($dragonText,'DRAGON SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $dragonGame $dragonMatch.Groups[1].Value) $dragonLogs }
    $dragonHashes | ConvertTo-Json | Set-Content (Join-Path $dragonLogs 'original-hashes.json')
    Write-Output 'Native first-cycle assertions, 45-second timeout and cleanup PASS; original content unchanged.'
} finally { [IO.File]::WriteAllBytes($dragonSettings,$dragonBytes) }
