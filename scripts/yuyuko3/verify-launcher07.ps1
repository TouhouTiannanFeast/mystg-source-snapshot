$stage3Errors=$null;$stage3Tokens=$null
[void][System.Management.Automation.Language.Parser]::ParseFile('G:\MySTG\start-stage3.ps1',[ref]$stage3Tokens,[ref]$stage3Errors)
if($stage3Errors.Count){throw ($stage3Errors | Out-String)}
'PASS Windows PowerShell '+$PSVersionTable.PSVersion+' parse'
$stage3Code=[IO.File]::ReadAllText('G:\MySTG\start-stage3.ps1')
$stage3Code=$stage3Code.Replace('$PSScriptRoot',"'G:\MySTG'")
# Build the actual form, validate choices, then take its cancel path without showing it.
$stage3Code=$stage3Code.Replace("if(`$stage3Form.ShowDialog()-ne'OK')",'Write-Output ("PASS form built, entries="+$stage3Combo.Items.Count); if($stage3Combo.Items.Count-ne70){throw "Expected 70 choices"}; if($true)')
& ([scriptblock]::Create($stage3Code))
