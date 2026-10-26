param([ValidateSet('Orbit','Follow')][string]$Variant='Orbit')
$ErrorActionPreference='Stop'
$flareRoot='G:\MySTG'
$flareGame=Join-Path $flareRoot 'aex-0.8.22\game'
$flareLogs=Join-Path $flareRoot ('work\logs\royal-flare-v5\'+$Variant)
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Existing game preserved; close it first.' }
$flareSettings=Join-Path $flareGame 'userdata\setting.json'
$flareBytes=[IO.File]::ReadAllBytes($flareSettings)
$flareHashes=@{}
foreach ($flareFile in @('mod\MySTG\root.lua','mod\MySTG\stages\normal.lua','mod\DragonSneeze\root.lua','mod\DeepSeekAbyss\root.lua')) { $flareHashes[$flareFile]=(Get-FileHash (Join-Path $flareGame $flareFile)).Hash }
try {
    $flareMod=if ($Variant -eq 'Follow') {'RoyalFlareFollow'} else {'RoyalFlareOrbit'}
    $flareArgs="setting.mod='$flareMod'; setting.flare_test=true; setting.windowed=true; start_game=true"
    $flareProcess=Start-Process -FilePath (Join-Path $flareGame 'LuaSTGSub.exe') -WorkingDirectory $flareGame -ArgumentList ('"'+$flareArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $flareProcess.WaitForExit(60000)) {
        if (-not $flareProcess.WaitForExit(15000)) {
            Copy-Item (Join-Path $flareGame 'engine.log') (Join-Path $flareLogs 'engine.log')
            throw 'Native run exceeded 75 seconds; left for inspection.'
        }
    }
    Copy-Item (Join-Path $flareGame 'engine.log') (Join-Path $flareLogs 'engine.log')
    $flareText=Get-Content (Join-Path $flareLogs 'engine.log') -Raw
    if ($flareProcess.ExitCode -ne 0 -or $flareText -notmatch ('FLARE CLEANUP PASS variant='+$Variant+' shots=3256 trajectory_checks=(\d+) peak=(\d+) follow_distance=([\d.]+) follow_left=(\d+) follow_right=(\d+)')) { throw 'Native validation failed; inspect engine.log.' }
    $flareChecks=[int]$Matches[1]; $flarePeak=[int]$Matches[2]
    $flareDistance=[double]$Matches[3]; $flareLeft=[int]$Matches[4]; $flareRight=[int]$Matches[5]
    if ($flareDistance -ne 0 -or $flareLeft -ne 0 -or $flareRight -ne 0) { throw 'Stationary Boss translated fired bullets.' }
    if ($flareText -notmatch 'FLARE ARRIVAL PASS fraction=([\d.]+) x=([-\d.]+) y=([-\d.]+) pre_arrival_shots=0') { throw 'Opening move/arrival missing.' }
    $flareFraction=[double]$Matches[1]; $flareStopX=[double]$Matches[2]; $flareStopY=[double]$Matches[3]
    if ($flareFraction -lt (1/3) -or $flareFraction -gt (2/3) -or [math]::Abs($flareStopX) -gt (52/3+0.000001)) { throw 'Destination outside middle third.' }
    if ($flareText -notmatch 'FLARE STATIONARY PASS checks=(\d+)') { throw 'Stationary Boss validation missing.' }
    $flareStationaryChecks=[int]$Matches[1]
    if ($flareStationaryChecks -lt 2800) { throw 'Stationary coverage incomplete.' }
    if ($flareText -notmatch 'FLARE CENTER PASS checks=(\d+) layout=RoyalFlareTranslated') { throw 'Royal Flare center translation validation missing.' }
    $flareCenterChecks=[int]$Matches[1]
    if ($flareCenterChecks -lt 400) { throw 'Center coverage incomplete.' }
    if ($flareText -notmatch 'FLARE HEADING PASS tangent_checks=(\d+) bent_headings=(\d+)') { throw 'Native tangent heading validation missing.' }
    $flareHeadingChecks=[int]$Matches[1]; $flareBentHeadings=[int]$Matches[2]
    if ($flareHeadingChecks -lt 1000 -or $flareBentHeadings -ne 0) { throw 'Unexpected tangent heading coverage.' }
    foreach ($flareFile in $flareHashes.Keys) { if ((Get-FileHash (Join-Path $flareGame $flareFile)).Hash -ne $flareHashes[$flareFile]) { throw 'Original content changed.' } }
    foreach ($flareMatch in [regex]::Matches($flareText,'FLARE SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $flareGame $flareMatch.Groups[1].Value) $flareLogs }
    $flareHashes | ConvertTo-Json | Set-Content (Join-Path $flareLogs 'original-hashes.json')
    [ordered]@{variant=$Variant;emission_layout='RoyalFlareTranslated';center_checks=$flareCenterChecks;destination_fraction=$flareFraction;stop_x=$flareStopX;stop_y=$flareStopY;pre_arrival_shots=0;stationary_checks=$flareStationaryChecks;shots=3256;trajectory_checks=$flareChecks;tangent_checks=$flareHeadingChecks;bent_headings=$flareBentHeadings;peak_bullets=$flarePeak;follow_distance=$flareDistance;follow_left=$flareLeft;follow_right=$flareRight;exit_code=$flareProcess.ExitCode;manual_playtest=$false;protected_hashes=$flareHashes} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $flareLogs 'result.json')
    Write-Output "Native $Variant four-phase, trajectory, fireball rendering and natural cleanup PASS. Protected mods unchanged."
} finally { [IO.File]::WriteAllBytes($flareSettings,$flareBytes) }
