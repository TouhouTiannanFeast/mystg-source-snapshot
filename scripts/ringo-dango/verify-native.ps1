$ErrorActionPreference='Stop'
$dangoGame='G:\MySTG\aex-0.8.22\game'
$dangoLog='G:\MySTG\work\logs\ringo-dango'
if (Get-Process LuaSTGSub -ErrorAction SilentlyContinue) { throw 'Close running game first.' }
$dangoSettings=Join-Path $dangoGame 'userdata\setting.json'
$dangoBytes=[IO.File]::ReadAllBytes($dangoSettings)
try {
    $dangoArgs="setting.mod='RingoDango'; setting.dango_test=true; setting.windowed=true; start_game=true"
    $dangoProcess=Start-Process (Join-Path $dangoGame 'LuaSTGSub.exe') -WorkingDirectory $dangoGame -ArgumentList ('"'+$dangoArgs+'"') -WindowStyle Hidden -PassThru
    if (-not $dangoProcess.WaitForExit(45000)) { Stop-Process -Id $dangoProcess.Id;throw 'Native test timeout.' }
    Copy-Item (Join-Path $dangoGame 'engine.log') (Join-Path $dangoLog 'native.log')
    $dangoText=Get-Content (Join-Path $dangoLog 'native.log') -Raw
    if ($dangoProcess.ExitCode -ne 0 -or $dangoText -notmatch 'DANGO PASS tick=1100 rings=19 pellet=2660 mentos=9 influenced=\d+ bounces=\d+ cleanup=0') { throw 'Native checks failed; inspect native.log.' }
    Copy-Item (Join-Path $dangoGame 'userdata\snapshot\ringo-dango-*.jpg') $dangoLog
    Write-Output 'PASS: native source schedule, influence, bounce, boss defeat cleanup and bounded captures.'
} finally {
    if ($dangoProcess -and -not $dangoProcess.HasExited) { Stop-Process -Id $dangoProcess.Id }
    [IO.File]::WriteAllBytes($dangoSettings,$dangoBytes)
}
