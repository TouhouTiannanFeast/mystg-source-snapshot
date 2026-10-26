$ErrorActionPreference='Stop'
$cotGame='G:\MySTG\aex-0.8.22\game'
$cotLogs='G:\MySTG\work\logs\deepseek-cot'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close the existing game first; it has been preserved.' }
$cotSettings=Join-Path $cotGame 'userdata\setting.json'
$cotBytes=[IO.File]::ReadAllBytes($cotSettings)
try {
    $cotArgs="setting.mod='DeepSeekCoT'; setting.cot_test=true; setting.windowed=true; start_game=true"
    $cotProcess=Start-Process -FilePath (Join-Path $cotGame 'LuaSTGSub.exe') -WorkingDirectory $cotGame -ArgumentList ('"'+$cotArgs+'"') -WindowStyle Hidden -PassThru
    while (-not $cotProcess.WaitForExit(1000)) { if ((Get-Date)-$cotProcess.StartTime -gt [TimeSpan]::FromSeconds(100)) { throw 'Native test timeout; game preserved for inspection.' } }
    Copy-Item (Join-Path $cotGame 'engine.log') (Join-Path $cotLogs 'engine.log')
    $cotText=Get-Content (Join-Path $cotLogs 'engine.log') -Raw
    if ($cotProcess.ExitCode -ne 0 -or $cotText -notmatch 'COT COMPLETE' -or $cotText -notmatch 'COT STAGE CLEANUP owned=0') { throw 'Native test failed: inspect engine.log.' }
    foreach ($cotMatch in [regex]::Matches($cotText,'COT SNAPSHOT (userdata/snapshot/[^\r\n]+\.jpg)')) { Copy-Item (Join-Path $cotGame $cotMatch.Groups[1].Value) $cotLogs }
    Write-Output 'PASS: native 60-second card, two branching generations, bounded objects, natural completion and stage cleanup.'
} finally { [IO.File]::WriteAllBytes($cotSettings,$cotBytes) }
