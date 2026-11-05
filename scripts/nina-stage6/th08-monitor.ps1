Add-Type -AssemblyName System.Windows.Forms,System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CAP {
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left,Top,Right,Bottom; }
}
"@
$dir='G:\MySTG\work\nina-stage6\th08\cap'
$log=Join-Path $dir 'monitor.log'
$end=(Get-Date).AddSeconds(300); $i=0
$sw=[Diagnostics.Stopwatch]::StartNew()
while((Get-Date) -lt $end){
  $p=Get-Process th08 -ErrorAction SilentlyContinue | Select-Object -First 1
  if($p -and $p.MainWindowHandle -ne 0){
    $h=$p.MainWindowHandle
    $r=New-Object CAP+RECT; [CAP]::GetWindowRect($h,[ref]$r) | Out-Null
    $w=$r.Right-$r.Left; $hh=$r.Bottom-$r.Top
    if($w -gt 50 -and $hh -gt 50){
      try{
        $bmp=New-Object System.Drawing.Bitmap $w,$hh
        $g=[System.Drawing.Graphics]::FromImage($bmp)
        $g.CopyFromScreen((New-Object System.Drawing.Point $r.Left,$r.Top),[System.Drawing.Point]::Empty,(New-Object System.Drawing.Size $w,$hh))
        $bmp.Save((Join-Path $dir ('f{0:d4}.png' -f $i)),[System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
      }catch{}
    }
    if($i -eq 0 -or $i % 20 -eq 0){ "{0:0.0} rect={1},{2},{3},{4} fg={5} title={6}" -f $sw.Elapsed.TotalSeconds,$r.Left,$r.Top,$r.Right,$r.Bottom,[CAP]::GetForegroundWindow(),$p.MainWindowTitle | Add-Content $log }
  } else {
    if($i -eq 0 -or $i % 20 -eq 0){ "{0:0.0} no th08" -f $sw.Elapsed.TotalSeconds | Add-Content $log }
  }
  $i++
  Start-Sleep -Milliseconds 500
}
"done frames=$i" | Add-Content $log
