$ErrorActionPreference='Stop'
$momijiGame='G:\MySTG\aex-0.8.22\game'
$momijiLog='G:\MySTG\work\logs\momiji-non1'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close running game first.' }
$momijiSettings=Join-Path $momijiGame 'userdata\setting.json'
$momijiBytes=[IO.File]::ReadAllBytes($momijiSettings)
try {
    $momijiArgs="setting.mod='MomijiNon1'; setting.momiji_test='kill'; setting.windowed=true; start_game=true"
    $momijiProcess=Start-Process (Join-Path $momijiGame 'LuaSTGSub.exe') -WorkingDirectory $momijiGame -ArgumentList ('"'+$momijiArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $momijiProcess.WaitForExit(45000)) { Stop-Process -Id $momijiProcess.Id;throw 'Native test timeout.' }
    Copy-Item (Join-Path $momijiGame 'engine.log') (Join-Path $momijiLog 'native.log')
    $momijiText=Get-Content (Join-Path $momijiLog 'native.log') -Raw
    if ($momijiProcess.ExitCode -ne 0 -or $momijiText -notmatch 'MOMIJI CLEANUP PASS tick=900 gun=344 scale=432 rounds=2 bounces=0') { throw 'Native checks failed; inspect native.log.' }
    Copy-Item (Join-Path $momijiGame 'userdata\snapshot\momiji-non1-*.jpg') $momijiLog
    Write-Output 'PASS: native straight-flight assertions, per-wave reverse aim, 344 gun/432 scale shots, two round hooks, defeat cleanup.'
} finally {
    if ($momijiProcess -and -not $momijiProcess.HasExited) { Stop-Process -Id $momijiProcess.Id }
    [IO.File]::WriteAllBytes($momijiSettings,$momijiBytes)
}
