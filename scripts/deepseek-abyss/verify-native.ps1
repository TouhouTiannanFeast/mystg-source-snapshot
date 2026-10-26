param([ValidateSet(0,1,2,3,4)][int]$Phase=0,[switch]$Probe)
$ErrorActionPreference='Stop'
$abyssGame='G:\MySTG\aex-0.8.22\game'
$abyssLogs="G:\MySTG\work\logs\deepseek-abyss\phase-$Phase"
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing LuaSTG game preserved; close it before verification.' }
New-Item -ItemType Directory -Force $abyssLogs | Out-Null
$abyssSettings=Join-Path $abyssGame 'userdata\setting.json'
$abyssBytes=[IO.File]::ReadAllBytes($abyssSettings)
$abyssHashes=@{}
foreach ($abyssFile in @('mod\MySTG\root.lua','mod\MySTG\stages\normal.lua','mod\DragonSneeze\root.lua')) { $abyssHashes[$abyssFile]=(Get-FileHash (Join-Path $abyssGame $abyssFile)).Hash }
try {
    $abyssArgs="setting.mod='DeepSeekAbyss'; setting.abyss_phase=$Phase; setting.abyss_test=true; setting.abyss_fast=true; setting.windowed=true; start_game=true"
    if ($Probe) { $abyssArgs+='; setting.abyss_probe=true' }
    $abyssProcess=Start-Process -FilePath (Join-Path $abyssGame 'LuaSTGSub.exe') -WorkingDirectory $abyssGame -ArgumentList ('"'+$abyssArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $abyssProcess.WaitForExit(45000)) {
        Copy-Item (Join-Path $abyssGame 'engine.log') (Join-Path $abyssLogs 'engine.log')
        throw "Native verification timed out; test process ID $($abyssProcess.Id) preserved for inspection."
    }
    Copy-Item (Join-Path $abyssGame 'engine.log') (Join-Path $abyssLogs 'engine.log')
    $abyssText=Get-Content (Join-Path $abyssLogs 'engine.log') -Raw
    if ($abyssProcess.ExitCode -ne 0 -or $abyssText -notmatch 'ABYSS GEOMETRY PASS' -or $abyssText -notmatch 'ABYSS COMPLETE' -or $abyssText -notmatch 'ABYSS STAGE CLEANUP live=0') { throw 'Native validation failed; inspect saved engine.log.' }
    $abyssExpected=if ($Phase -eq 0) {4} else {1}
    if ([regex]::Matches($abyssText,'ABYSS PHASE PASS').Count -ne $abyssExpected) { throw 'Missing phase completion assertion.' }
    if ($Probe -and $abyssText -notmatch 'ABYSS COMBAT PROBES PASS') { throw 'Combat probes did not finish.' }
    foreach ($abyssFile in $abyssHashes.Keys) { if ((Get-FileHash (Join-Path $abyssGame $abyssFile)).Hash -ne $abyssHashes[$abyssFile]) { throw "Original content changed: $abyssFile" } }
    foreach ($abyssMatch in [regex]::Matches($abyssText,'ABYSS SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $abyssGame $abyssMatch.Groups[1].Value) $abyssLogs }
    [ordered]@{phase=$Phase;exit_code=$abyssProcess.ExitCode;phase_checks=$abyssExpected;combat_probe=[bool]$Probe;original_hashes=$abyssHashes;fast_forward=4;manual_playtest=$false} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $abyssLogs 'result.json')
    Write-Output "ABYSS native phase=$Phase PASS; geometry, schedule, cleanup, original hashes verified."
} finally { [IO.File]::WriteAllBytes($abyssSettings,$abyssBytes) }
