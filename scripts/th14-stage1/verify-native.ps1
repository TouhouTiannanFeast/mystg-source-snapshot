param([ValidateSet('timeout','kill','tail','scale')][string]$Case='timeout')
$ErrorActionPreference='Stop'
$stageRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$stageGameRoot=Join-Path $stageRoot 'aex-0.8.22\game'
$stageLogRoot=Join-Path $stageRoot "work\logs\th14-stage1\$Case"
if (Get-Process -Name LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing LuaSTG game preserved; close it first.' }
New-Item -ItemType Directory -Path $stageLogRoot -Force | Out-Null
$stageSettingPath=Join-Path $stageGameRoot 'userdata\setting.json'
$stageSettingBytes=[IO.File]::ReadAllBytes($stageSettingPath)
$stageEngineLog=Join-Path $stageGameRoot 'engine.log'
if (Test-Path -LiteralPath $stageEngineLog) { Copy-Item -LiteralPath $stageEngineLog -Destination (Join-Path $stageLogRoot 'engine-before.log') }
$stageOriginalPaths=@('mod\MySTG\root.lua','mod\MySTG\stages\normal.lua')
$stageOriginalHashes=@{}
foreach ($stagePath in $stageOriginalPaths) { $stageOriginalHashes[$stagePath]=(Get-FileHash -LiteralPath (Join-Path $stageGameRoot $stagePath)).Hash }
$stageArg="setting.mod='TH14Stage1Normal'; setting.th14_autostart=true; setting.th14_autotest=true; setting.th14_fast=true; setting.windowed=true; start_game=true"
if ($Case -eq 'kill') { $stageArg+='; setting.th14_killtest=true' }
if ($Case -in @('tail','scale')) { $stageArg+="; setting.th14_practice='$Case'" }
$stageExit=$null
try {
    $stageProcess=Start-Process -FilePath (Join-Path $stageGameRoot 'LuaSTGSub.exe') -WorkingDirectory $stageGameRoot -ArgumentList ('"'+$stageArg+'"') -WindowStyle Hidden -PassThru
    if (-not $stageProcess.WaitForExit(180000)) { throw 'Native verification timeout; preserve the running game for inspection.' }
    $stageExit=$stageProcess.ExitCode
    Copy-Item -LiteralPath $stageEngineLog -Destination (Join-Path $stageLogRoot 'engine.log')
    $stageText=Get-Content -LiteralPath $stageEngineLog -Raw
    $stageComplete=[regex]::Match($stageText,'TH14 COMPLETE frames=(\d+) waves=(\d+) phases=(\d+) ended=(\d+) bullets=(\d+)')
    if (-not $stageComplete.Success) { throw 'Stage did not complete; inspect the saved native log.' }
    $stageExpected=if ($Case -in @('tail','scale')) { 1 } else { 5 }
    if ([int]$stageComplete.Groups[3].Value -ne $stageExpected -or [int]$stageComplete.Groups[4].Value -ne $stageExpected) { throw 'Missing phase start/end.' }
    if ($Case -in @('timeout','kill') -and [int]$stageComplete.Groups[2].Value -ne 186) { throw 'Stage wave count differs from the source schedule.' }
    foreach ($stagePath in $stageOriginalPaths) {
        if ((Get-FileHash -LiteralPath (Join-Path $stageGameRoot $stagePath)).Hash -ne $stageOriginalHashes[$stagePath]) { throw "Original encounter changed: $stagePath" }
    }
    foreach ($stageMatch in [regex]::Matches($stageText,'TH14 SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) {
        $stageSnapshot=Join-Path $stageGameRoot $stageMatch.Groups[1].Value
        Copy-Item -LiteralPath $stageSnapshot -Destination $stageLogRoot
    }
    if ($stageExit -ne 0) { throw "Native engine exit code: $stageExit" }
    [ordered]@{case=$Case;exit_code=$stageExit;frames=[int]$stageComplete.Groups[1].Value;waves=[int]$stageComplete.Groups[2].Value;phases=[int]$stageComplete.Groups[3].Value;ended=[int]$stageComplete.Groups[4].Value;bullets=[int]$stageComplete.Groups[5].Value;original_hashes=$stageOriginalHashes;fast_forward=8;manual_playtest=$false} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $stageLogRoot 'result.json') -Encoding UTF8
    Write-Output $stageComplete.Value
} finally {
    [IO.File]::WriteAllBytes($stageSettingPath,$stageSettingBytes)
}
