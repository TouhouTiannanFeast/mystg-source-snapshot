param([ValidateSet('timeout','kill')][string]$Mode='timeout')
$ErrorActionPreference='Stop'
$mystiaRoot='G:\MySTG'
$mystiaGame=Join-Path $mystiaRoot 'aex-0.8.22\game'
$mystiaLogs=Join-Path $mystiaRoot ('work\logs\mystia-aya-normal-large\'+$Mode)
New-Item -ItemType Directory -Force $mystiaLogs | Out-Null
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing game preserved; close it first.' }
$mystiaSettings=Join-Path $mystiaGame 'userdata\setting.json'
$mystiaBytes=[IO.File]::ReadAllBytes($mystiaSettings)
$mystiaHashes=@{}
Get-ChildItem (Join-Path $mystiaGame 'mod') -Recurse -File | Where-Object { $_.FullName -notlike '*\MystiaAyaNon3NormalLarge\*' } | ForEach-Object { $mystiaHashes[$_.FullName]=(Get-FileHash -LiteralPath $_.FullName).Hash }
try {
    $mystiaArgs="setting.mod='MystiaAyaNon3NormalLarge'; setting.mystia_test='$Mode'; setting.windowed=true; start_game=true"
    $mystiaProcess=Start-Process -FilePath (Join-Path $mystiaGame 'LuaSTGSub.exe') -WorkingDirectory $mystiaGame -ArgumentList ('"'+$mystiaArgs+'"') -WindowStyle Hidden -PassThru
    $mystiaDeadline=[DateTime]::UtcNow.AddSeconds(95)
    while (-not $mystiaProcess.WaitForExit(1000)) {
        if ([DateTime]::UtcNow -gt $mystiaDeadline) { Stop-Process -Id $mystiaProcess.Id; throw 'Test exceeded deadline.' }
    }
    Copy-Item (Join-Path $mystiaGame 'engine.log') (Join-Path $mystiaLogs 'engine.log')
    $mystiaText=Get-Content (Join-Path $mystiaLogs 'engine.log') -Raw
    if ($mystiaProcess.ExitCode -ne 0 -or $mystiaText -notmatch 'MYSTIA CLEANUP PASS tick=(\d+) shots=(\d+) blue=(\d+) red=(\d+) center_checks=(\d+) moves=(\d+) move_frames=(\d+) moving_shots=(\d+)') { throw 'Native validation failed; inspect engine.log.' }
    $mystiaValues=@($Matches[1],$Matches[2],$Matches[3],$Matches[4],$Matches[5],$Matches[6],$Matches[7],$Matches[8]) | ForEach-Object { [int]$_ }
    if ($mystiaText -notmatch 'MYSTIA FIRST VOLLEY PASS blue=64 red=96 move_frames=40 moving_shots=40') { throw 'First volley check missing.' }
    if ($Mode -eq 'timeout' -and ($mystiaValues[1] -ne 2740 -or $mystiaValues[2] -ne 1096 -or $mystiaValues[3] -ne 1644 -or $mystiaValues[5] -ne 17 -or $mystiaValues[6] -ne 680)) { throw 'Full schedule count mismatch.' }
    if ($Mode -eq 'kill' -and ($mystiaValues[0] -lt 400 -or $mystiaValues[0] -gt 405)) { throw 'Kill lifecycle mismatch.' }
    if ($mystiaValues[4] -lt 10000) { throw 'Insufficient center trajectory coverage.' }
    foreach ($mystiaFile in $mystiaHashes.Keys) { if ((Get-FileHash -LiteralPath $mystiaFile).Hash -ne $mystiaHashes[$mystiaFile]) { throw 'Protected mod changed.' } }
    foreach ($mystiaMatch in [regex]::Matches($mystiaText,'MYSTIA SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $mystiaGame $mystiaMatch.Groups[1].Value) $mystiaLogs }
    [ordered]@{mode=$Mode;tick=$mystiaValues[0];shots=$mystiaValues[1];blue=$mystiaValues[2];red=$mystiaValues[3];center_checks=$mystiaValues[4];moves=$mystiaValues[5];move_frames=$mystiaValues[6];moving_shots=$mystiaValues[7];exit_code=$mystiaProcess.ExitCode;protected_files=$mystiaHashes.Count;manual_playtest=$false} | ConvertTo-Json | Set-Content (Join-Path $mystiaLogs 'result.json')
    $mystiaHashes | ConvertTo-Json | Set-Content (Join-Path $mystiaLogs 'protected-hashes.json')
    Write-Output "Mystia $Mode native schedule, center trajectory and cleanup PASS."
} finally {
    if ($mystiaProcess -and -not $mystiaProcess.HasExited) { Stop-Process -Id $mystiaProcess.Id }
    [IO.File]::WriteAllBytes($mystiaSettings,$mystiaBytes)
    if (Test-Path (Join-Path $mystiaGame 'engine.log')) { Copy-Item (Join-Path $mystiaGame 'engine.log') (Join-Path $mystiaLogs 'engine.log') }
}
