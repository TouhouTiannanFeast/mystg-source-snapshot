$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$root=Join-Path $game 'mod\YuyukoStage3\root.lua'
$settings=Join-Path $game 'userdata\setting.json'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Running game preserved'}
$before=[IO.File]::ReadAllBytes($settings);$code=[IO.File]::ReadAllBytes($root)
try{
$probe=@'
local sounds=0;local ps=PlaySound
PlaySound=function(n,...)if n=='tan00'then sounds=sounds+1 end;return ps(n,...)end
local render=RenderFunc;local captured={}
RenderFunc=function()
 if Le03 and Le03.tick>=3655 and not captured.done then
  Y3BackgroundPlayer.advance(lstg.tmpvar.bg.playback,6500)
 end
 render()
 if Le03 and Le03.tick then
  for _,t in ipairs({2850,3250,3650})do
   if Le03.tick>=t and not captured[t]then
    captured[t]=true;lstg.Snapshot('userdata/snapshot/presentation11-'..t..'.jpg')
   end
  end
  if Le03.tick>=3655 and not captured.done then
   captured.done=true
   lstg.Snapshot('userdata/snapshot/presentation11-fog.jpg')
   assert(sounds>0,'No emission sound callback');print('PRESENTATION11 PASS sounds='..sounds)
   stage.QuitGame()
  end
 end
end
local frame=DoFrame;DoFrame=function(...)for i=1,4 do frame(...)end end
'@
[IO.File]::AppendAllText($root,"`n"+$probe,[Text.UTF8Encoding]::new($false))
$args="setting.mod='YuyukoStage3';setting.y3_full=true;setting.y3_entry='road-2700';setting.y3_practice='all';setting.y3_invincible=true;setting.y3_test=false;setting.windowed=true;start_game=true"
$p=Start-Process (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args+'"') -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(45000)){throw 'Probe timeout, process retained'}
Copy-Item (Join-Path $game 'engine.log') 'G:\MySTG\work\logs\yuyuko3\presentation11-native.log'
$log=Get-Content 'G:\MySTG\work\logs\yuyuko3\presentation11-native.log' -Raw
if($p.ExitCode-ne0 -or $log-notmatch'PRESENTATION11 PASS'){throw 'Probe failed; see presentation11-native.log'}
Get-ChildItem (Join-Path $game 'userdata\snapshot\presentation11-*.jpg') | Copy-Item -Destination 'G:\MySTG\work\logs\yuyuko3'
'PASS waves25..27, background shader compilation and emission sound callbacks'
}finally{[IO.File]::WriteAllBytes($root,$code);[IO.File]::WriteAllBytes($settings,$before)}

