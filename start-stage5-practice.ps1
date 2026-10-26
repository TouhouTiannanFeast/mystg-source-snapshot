param([string]$Entry='', [Nullable[int]]$Seed, [string]$PreviewPath='')
$ErrorActionPreference='Stop'
$inspectRoot=$PSScriptRoot
$inspectRows=Get-Content (Join-Path $inspectRoot 'scripts\suwako5\practice-catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($Entry){
 if($Entry -notin $inspectRows.id){throw "Unknown phase: $Entry"}
 & (Join-Path $inspectRoot 'start-stage5.ps1') -Practice $Entry -Seed $Seed
 return
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$inspectForm=New-Object Windows.Forms.Form
$inspectForm.Text='五面 · 单张非符 / 符卡观察'
$inspectForm.ClientSize=New-Object Drawing.Size(760,620)
$inspectForm.StartPosition='CenterScreen'
$inspectForm.Font=New-Object Drawing.Font('Microsoft YaHei UI',10)
$inspectForm.FormBorderStyle='FixedDialog';$inspectForm.MaximizeBox=$false
$inspectIntro=New-Object Windows.Forms.Label
$inspectIntro.Text='选中一张后单独启动。关闭游戏后，可在此重试或换卡。'
$inspectIntro.SetBounds(16,12,728,28)
$inspectList=New-Object Windows.Forms.ListBox
$inspectList.SetBounds(16,45,728,360);$inspectList.DisplayMember='label'
foreach($inspectRow in $inspectRows){[void]$inspectList.Items.Add($inspectRow)}
$inspectInfo=New-Object Windows.Forms.Label
$inspectInfo.SetBounds(16,415,728,48)
$inspectSeedCheck=New-Object Windows.Forms.CheckBox
$inspectSeedCheck.Text='固定随机种子';$inspectSeedCheck.SetBounds(16,471,155,28)
$inspectSeedCheck.Checked=($null -ne $Seed)
$inspectSeedBox=New-Object Windows.Forms.NumericUpDown
$inspectSeedBox.SetBounds(180,471,170,28)
$inspectSeedBox.Minimum=1;$inspectSeedBox.Maximum=2147483646
$inspectSeedBox.Value=if($null -ne $Seed){[Math]::Max(1,[Math]::Min(2147483646,$Seed))}else{20261026}
$inspectNote=New-Object Windows.Forms.Label
$inspectNote.Text='血量、倒计时见游戏内显示。DS 弹幕随血量推进；射击可观察后段。'
$inspectNote.SetBounds(16,511,728,28)
$inspectStatus=New-Object Windows.Forms.Label
$inspectStatus.SetBounds(16,579,728,28);$inspectStatus.Text='就绪：仅启动选中项，不进入随机卡组。'
$inspectStart=New-Object Windows.Forms.Button
$inspectStart.Text='启动选中项 / 重试';$inspectStart.SetBounds(16,544,210,32)
$inspectLogs=New-Object Windows.Forms.Button
$inspectLogs.Text='打开游戏日志';$inspectLogs.SetBounds(240,544,165,32)
$inspectList.Add_SelectedIndexChanged({
 $inspectSelected=$inspectList.SelectedItem
 if($null -ne $inspectSelected){$inspectInfo.Text="编号：$($inspectSelected.id)    血量：$($inspectSelected.hp)    时限：$($inspectSelected.seconds) 秒`r`n单张结束后返回游戏菜单；此窗口保持打开。"}
})
$inspectStart.Add_Click({
 try{
  $inspectSelected=$inspectList.SelectedItem
  if($null -eq $inspectSelected){return}
  $inspectChosenSeed=$null
  if($inspectSeedCheck.Checked){$inspectChosenSeed=[int]$inspectSeedBox.Value}
  & (Join-Path $inspectRoot 'start-stage5.ps1') -Practice $inspectSelected.id -Seed $inspectChosenSeed
  $inspectStatus.Text="已启动：$($inspectSelected.id)。换卡前请关闭游戏。"
 }catch{
  $inspectStatus.Text='未启动：请先关闭正在运行的游戏。'
  [void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'启动失败')
 }
})
$inspectList.Add_DoubleClick({$inspectStart.PerformClick()})
$inspectLogs.Add_Click({
 $inspectLog=Join-Path $inspectRoot 'aex-0.8.22\game\engine.log'
 if(Test-Path -LiteralPath $inspectLog){Start-Process notepad.exe -ArgumentList ('"'+$inspectLog+'"')}
 else{[void][Windows.Forms.MessageBox]::Show('尚无游戏日志，请先启动一次。','游戏日志')}
})
$inspectForm.Controls.AddRange(@($inspectIntro,$inspectList,$inspectInfo,$inspectSeedCheck,$inspectSeedBox,$inspectNote,$inspectStart,$inspectLogs,$inspectStatus))
$inspectList.SelectedIndex=0;$inspectForm.AcceptButton=$inspectStart
if($PreviewPath){
 $inspectForm.Show();$inspectForm.Refresh()
 $inspectBitmap=New-Object Drawing.Bitmap($inspectForm.Width,$inspectForm.Height)
 $inspectForm.DrawToBitmap($inspectBitmap,(New-Object Drawing.Rectangle(0,0,$inspectForm.Width,$inspectForm.Height)))
 $inspectBitmap.Save($PreviewPath,[Drawing.Imaging.ImageFormat]::Png)
 $inspectBitmap.Dispose();$inspectForm.Dispose();return
}
[void]$inspectForm.ShowDialog()
$inspectForm.Dispose()
