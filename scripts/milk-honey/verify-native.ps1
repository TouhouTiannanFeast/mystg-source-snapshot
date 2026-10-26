$ErrorActionPreference='Stop'
$milkGame='G:\MySTG\aex-0.8.22\game'
$milkLogs='G:\MySTG\work\logs\milk-honey'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing game preserved; close it first.' }
$milkSettings=Join-Path $milkGame 'userdata\setting.json'
$milkBytes=[IO.File]::ReadAllBytes($milkSettings)
try {
    $milkArgs="setting.mod='MilkHoney'; setting.milk_test=true; setting.windowed=true; start_game=true"
    $milkProcess=Start-Process -FilePath (Join-Path $milkGame 'LuaSTGSub.exe') -WorkingDirectory $milkGame -ArgumentList ('"'+$milkArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $milkProcess.WaitForExit(45000)) { throw 'Bounded test exceeded45seconds; process left for inspection.' }
    Copy-Item (Join-Path $milkGame 'engine.log') (Join-Path $milkLogs 'engine.log')
    $milkText=Get-Content (Join-Path $milkLogs 'engine.log') -Raw
    if ($milkProcess.ExitCode -ne 0 -or $milkText -notmatch 'MILK NATIVE PASS' -or $milkText -notmatch 'MILK CLEANUP PASS') { throw 'Native validation failed; inspect engine.log.' }
    foreach ($milkMatch in [regex]::Matches($milkText,'MILK SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $milkGame $milkMatch.Groups[1].Value) $milkLogs }
    Write-Output 'PASS native720frames, exact volley counts/movement schedule/integration/cleanup; three captures saved.'
} finally { [IO.File]::WriteAllBytes($milkSettings,$milkBytes) }
