param([string]$Entry='', [string]$PreviewPath='', [switch]$NoInvincible, [switch]$AnchorOriginal)
$ErrorActionPreference='Stop'
$practiceRoot=Join-Path $PSScriptRoot 'aex-0.8.22\game'
$practiceEntries=Get-Content (Join-Path $practiceRoot 'mod\Stage12Normal\practice-entries.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $Entry){
 Add-Type -AssemblyName System.Windows.Forms
 Add-Type -AssemblyName System.Drawing
 [Windows.Forms.Application]::EnableVisualStyles()
 $practiceForm=New-Object Windows.Forms.Form
 $practiceForm.Text='两面起点选择';$practiceForm.ClientSize=New-Object Drawing.Size(540,475)
 $practiceForm.StartPosition='CenterScreen';$practiceForm.FormBorderStyle='FixedDialog';$practiceForm.MaximizeBox=$false
 $practiceForm.Font=New-Object Drawing.Font('Microsoft YaHei UI',10)
 $practiceLabel=New-Object Windows.Forms.Label
 $practiceLabel.Text='选择起点，随后继续后面的道中、Boss及下一面。';$practiceLabel.SetBounds(15,12,510,28)
 $practiceList=New-Object Windows.Forms.ListBox
 $practiceList.SetBounds(15,45,510,340);$practiceList.DisplayMember='label'
 foreach($practiceRow in $practiceEntries){[void]$practiceList.Items.Add([string]$practiceRow.label)}
 $practiceList.SelectedIndex=0
 $practiceHint=New-Object Windows.Forms.Label
 $practiceHint.Text='修改数据后请关闭游戏，再从此窗口启动。';$practiceHint.SetBounds(15,390,510,28)
 $practiceStart=New-Object Windows.Forms.Button
 $practiceStart.Text='从此处开始';$practiceStart.SetBounds(385,428,140,34)
 $practiceInvincible=New-Object Windows.Forms.CheckBox
 $practiceInvincible.Text='无敌（碰撞不扣残机、不消弹）';$practiceInvincible.SetBounds(15,428,360,30);$practiceInvincible.Checked=(-not $NoInvincible)
 $practiceStart.DialogResult=[Windows.Forms.DialogResult]::OK
 $practiceForm.Controls.AddRange(@($practiceLabel,$practiceList,$practiceHint,$practiceInvincible,$practiceStart));$practiceForm.AcceptButton=$practiceStart
 if($PreviewPath){
  $practiceForm.Show();$practiceForm.Refresh()
  $practiceBitmap=New-Object Drawing.Bitmap($practiceForm.Width,$practiceForm.Height)
  $practiceForm.DrawToBitmap($practiceBitmap, (New-Object Drawing.Rectangle(0,0,$practiceForm.Width,$practiceForm.Height)))
  $practiceBitmap.Save($PreviewPath,[Drawing.Imaging.ImageFormat]::Png)
  $practiceBitmap.Dispose();$practiceForm.Dispose();return
 }
 if($practiceForm.ShowDialog() -ne [Windows.Forms.DialogResult]::OK){return}
 $Entry=$practiceEntries[$practiceList.SelectedIndex].id;$NoInvincible=(-not $practiceInvincible.Checked);$practiceForm.Dispose()
}
if($Entry -notin $practiceEntries.id){throw "Unknown entry: $Entry"}
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw '请先关闭当前 LuaSTG 游戏窗口，再启动新的阶段。'}
$practiceImmune=if($NoInvincible){'false'}else{'true'}
$practiceOriginal=if($AnchorOriginal){'true'}else{'false'}
$practiceArgs="setting.mod='Stage12Normal';setting.stage12_entry='$Entry';setting.stage12_invincible=$practiceImmune;setting.stage12_anchor_original=$practiceOriginal;setting.windowed=true;start_game=true"
Start-Process -FilePath (Join-Path $practiceRoot 'LuaSTGSub.exe') -WorkingDirectory $practiceRoot -ArgumentList ('"'+$practiceArgs+'"') -WindowStyle Normal
