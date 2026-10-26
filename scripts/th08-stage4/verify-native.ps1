param([ValidateSet('timeout','kill','boss','master','final','earthlight')][string]$Case='timeout')
$ErrorActionPreference='Stop'
$stageRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$stageGameRoot=Join-Path $stageRoot 'aex-0.8.22\game'
$stageLogRoot=Join-Path $stageRoot "work\logs\th08-stage4\$Case"
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing LuaSTG game preserved; close it first.' }
New-Item -ItemType Directory -Path $stageLogRoot -Force | Out-Null
$stageSettingPath=Join-Path $stageGameRoot 'userdata\setting.json'
$stageSettingBytes=[IO.File]::ReadAllBytes($stageSettingPath)
$stageEngineLog=Join-Path $stageGameRoot 'engine.log'
if (Test-Path -LiteralPath $stageEngineLog) { Copy-Item -LiteralPath $stageEngineLog -Destination (Join-Path $stageLogRoot 'engine-before.log') }
$stageOriginalPaths=@('mod\MySTG\stages\normal.lua','mod\TH14Stage1Normal\root.lua')
$stageOriginalHashes=@{}
foreach ($stagePath in $stageOriginalPaths) { $stageOriginalHashes[$stagePath]=(Get-FileHash -LiteralPath (Join-Path $stageGameRoot $stagePath)).Hash }
$stageArg="setting.mod='MySTG'; setting.th08_autostart=true; setting.th08_autotest=true; setting.th08_fast=true; setting.windowed=true; start_game=true"
if ($Case -eq 'kill') { $stageArg+='; setting.th08_killtest=true' }
if ($Case -in @('boss','master','final','earthlight')) { $stageArg+="; setting.th08_practice='$Case'" }
try {
    $stageProcess=Start-Process -FilePath (Join-Path $stageGameRoot 'LuaSTGSub.exe') -WorkingDirectory $stageGameRoot -ArgumentList ('"'+$stageArg+'"') -WindowStyle Hidden -PassThru
    if (-not $stageProcess.WaitForExit(180000)) { throw 'Native verification timeout; running game preserved for inspection.' }
    Copy-Item -LiteralPath $stageEngineLog -Destination (Join-Path $stageLogRoot 'engine.log')
    $stageText=Get-Content -LiteralPath $stageEngineLog -Raw
    $stageComplete=[regex]::Match($stageText,'TH08 COMPLETE frames=(\d+) waves=(\d+) phases=(\d+) ended=(\d+) bullets=(\d+) beams=(\d+)')
    if (-not $stageComplete.Success) { throw 'Stage did not complete; inspect saved native log.' }
    $stageExpected=if ($Case -eq 'boss') { 5 } elseif ($Case -in @('master','final','earthlight')) { 1 } else { 9 }
    if ([int]$stageComplete.Groups[3].Value -ne $stageExpected -or [int]$stageComplete.Groups[4].Value -ne $stageExpected) { throw 'Missing phase start/end.' }
    if ($Case -in @('timeout','kill') -and [int]$stageComplete.Groups[2].Value -ne 241) { throw 'Enemy count differs from source schedule.' }
    if ([int]$stageComplete.Groups[6].Value -lt 1) { throw 'No native lasers emitted.' }
    foreach ($stagePath in $stageOriginalPaths) {
        if ((Get-FileHash -LiteralPath (Join-Path $stageGameRoot $stagePath)).Hash -ne $stageOriginalHashes[$stagePath]) { throw "Original content changed: $stagePath" }
    }
    foreach ($stageMatch in [regex]::Matches($stageText,'TH08 SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) {
        Copy-Item -LiteralPath (Join-Path $stageGameRoot $stageMatch.Groups[1].Value) -Destination $stageLogRoot
    }
    if ($stageProcess.ExitCode -ne 0) { throw "Native exit code: $($stageProcess.ExitCode)" }
    [ordered]@{case=$Case;exit_code=$stageProcess.ExitCode;frames=[int]$stageComplete.Groups[1].Value;waves=[int]$stageComplete.Groups[2].Value;phases=[int]$stageComplete.Groups[3].Value;ended=[int]$stageComplete.Groups[4].Value;bullets=[int]$stageComplete.Groups[5].Value;beams=[int]$stageComplete.Groups[6].Value;original_hashes=$stageOriginalHashes;fast_forward=8;manual_playtest=$false} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $stageLogRoot 'result.json') -Encoding UTF8
    Write-Output $stageComplete.Value
} finally {
    [IO.File]::WriteAllBytes($stageSettingPath,$stageSettingBytes)
}
