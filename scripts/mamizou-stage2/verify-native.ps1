param([ValidateSet('timeout','kill')][string]$Mode='kill',[ValidateRange(0,5)][int]$Phase=0)
$ErrorActionPreference='Stop'
$mzRoot='G:\MySTG';$mzSharedGame=Join-Path $mzRoot 'aex-0.8.22\game';$mzGame=$mzSharedGame
$mzLogs=Join-Path $mzRoot "work\logs\mamizou-stage2\$Mode-$Phase"
New-Item -ItemType Directory -Force $mzLogs | Out-Null
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Running game preserved; close it first.' }
$mzSettings=Join-Path $mzGame 'userdata\setting.json';$mzBytes=[IO.File]::ReadAllBytes($mzSettings)
$mzHashes=@{}
Get-ChildItem (Join-Path $mzSharedGame 'mod') -Recurse -File | Where-Object { $_.FullName -notlike '*\MamizouStage2\*' } | ForEach-Object { $mzHashes[$_.FullName]=(Get-FileHash -LiteralPath $_.FullName).Hash }
try {
 $mzArgs="setting.mod='MamizouStage2'; setting.mamizou_test='$Mode'; setting.windowed=true; start_game=true"
 if ($Phase -gt 0) { $mzArgs+="; setting.mamizou_phase=$Phase" }
 $mzProcess=Start-Process -FilePath (Join-Path $mzGame 'LuaSTGSub.exe') -WorkingDirectory $mzGame -ArgumentList ('"'+$mzArgs+'"') -WindowStyle Hidden -PassThru
 $mzSeconds=if ($Mode -eq 'kill') {100} elseif ($Phase -eq 0) {510} else {170}
 $mzDeadline=[DateTime]::UtcNow.AddSeconds($mzSeconds)
 while (-not $mzProcess.WaitForExit(1000)) { if ([DateTime]::UtcNow -gt $mzDeadline) { Stop-Process -Id $mzProcess.Id;throw 'Native deadline exceeded.' } }
 Copy-Item (Join-Path $mzGame 'engine.log') (Join-Path $mzLogs 'engine.log')
 $mzText=Get-Content (Join-Path $mzLogs 'engine.log') -Raw
 if ($mzProcess.ExitCode -ne 0 -or $mzText -notmatch 'MAMIZOU ALL CLEANUP PASS') { throw 'Native validation failed; inspect engine.log.' }
 $mzRows=@([regex]::Matches($mzText,'MAMIZOU PHASE CLEANUP (\d+) tick=(\d+) shots=(\d+) rings=(\d+) radius=(\d+) random=(\d+) kept=(\d+) removed=(\d+)'))
 $mzExpected=if ($Phase -eq 0) {5} else {1}
 if ($mzRows.Count -ne $mzExpected) { throw 'Missing phase cleanup.' }
 foreach ($mzFile in $mzHashes.Keys) { if ((Get-FileHash -LiteralPath $mzFile).Hash -ne $mzHashes[$mzFile]) { throw 'Protected mod changed.' } }
 foreach ($mzMatch in [regex]::Matches($mzText,'MAMIZOU SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $mzGame $mzMatch.Groups[1].Value) $mzLogs }
 $mzResults=@($mzRows | ForEach-Object { [ordered]@{phase=[int]$_.Groups[1].Value;tick=[int]$_.Groups[2].Value;shots=[int]$_.Groups[3].Value;rings=[int]$_.Groups[4].Value;radius_checks=[int]$_.Groups[5].Value;random_candidates=[int]$_.Groups[6].Value;random_kept=[int]$_.Groups[7].Value;random_removed=[int]$_.Groups[8].Value} })
 [ordered]@{mode=$Mode;practice_phase=$Phase;phases=$mzResults;exit_code=$mzProcess.ExitCode;protected_files=$mzHashes.Count;manual_playtest=$false} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $mzLogs 'result.json')
 $mzHashes | ConvertTo-Json | Set-Content (Join-Path $mzLogs 'protected-hashes.json')
 Write-Output "Mamizou $Mode-$Phase phase lifecycle, own-object cleanup and protected hashes PASS."
} finally {
 if ($mzProcess -and -not $mzProcess.HasExited) { Stop-Process -Id $mzProcess.Id }
 [IO.File]::WriteAllBytes($mzSettings,$mzBytes)
 if (Test-Path (Join-Path $mzGame 'engine.log')) { Copy-Item (Join-Path $mzGame 'engine.log') (Join-Path $mzLogs 'engine.log') }
}
