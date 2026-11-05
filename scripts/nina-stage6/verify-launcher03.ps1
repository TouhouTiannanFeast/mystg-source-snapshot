$ErrorActionPreference='Stop'
$ninaSource='G:\MySTG\start-nina-stage6.ps1'
$ninaTokens=$null;$ninaErrors=$null
$ninaAst=[Management.Automation.Language.Parser]::ParseFile($ninaSource,[ref]$ninaTokens,[ref]$ninaErrors)
if($ninaErrors){throw $ninaErrors}
$ninaFunction=$ninaAst.Find({param($ninaNode) $ninaNode -is [Management.Automation.Language.FunctionDefinitionAst] -and $ninaNode.Name -eq 'Select-NinaStage'},$true).Extent.Text
$ninaHook=@'
 $ninaPreviewTimer=New-Object Windows.Forms.Timer
 $ninaPreviewTimer.Interval=500
 $ninaPreviewTimer.add_Tick({
  $ninaPreviewTimer.Stop();$ninaChoice.SelectedIndex=6;$ninaGod.Checked=$true
  if($ninaChoice.Items.Count -ne 13){throw 'Expected full/road/Boss plus ten phases'}
  if($ninaForm.Controls.Count -ne 5){throw 'Unexpected extra launcher controls'}
  foreach($ninaControl in $ninaForm.Controls){if($ninaControl.Text -like '*素材*'){throw 'Gallery entry remained'}}
  $ninaBitmap=New-Object Drawing.Bitmap($ninaForm.Width,$ninaForm.Height)
  $ninaForm.DrawToBitmap($ninaBitmap,(New-Object Drawing.Rectangle(0,0,$ninaForm.Width,$ninaForm.Height)))
  $ninaBitmap.Save('G:\MySTG\work\logs\nina-stage6\merge17-launcher.png');$ninaBitmap.Dispose()
  $ninaForm.DialogResult='OK'
 })
 $ninaForm.add_Shown({$ninaPreviewTimer.Start()})
 $ninaAnswer=$ninaForm.ShowDialog()
'@
$ninaFunction=$ninaFunction.Replace('$ninaAnswer=$ninaForm.ShowDialog()',$ninaHook)
Invoke-Expression $ninaFunction
$Practice='all';$Invincible=$false
$ninaResult=Select-NinaStage
if(-not $ninaResult.Accepted -or $ninaResult.Phase -ne 'spell2' -or -not $ninaResult.God){throw 'Selection transfer failed'}
'PASS actual selector form: full/road/Boss+10 phases, selected spell2 + invincible; screenshot saved; no game launched'
