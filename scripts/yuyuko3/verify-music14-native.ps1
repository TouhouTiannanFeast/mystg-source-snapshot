$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$root=Join-Path $game 'mod\YuyukoStage3\root.lua'
$settings=Join-Path $game 'userdata\setting.json'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Running game preserved'}
$before=[IO.File]::ReadAllBytes($settings);$code=[IO.File]::ReadAllBytes($root)
try{
$probe=@'
Y3Road.run=function()
 assert(GetMusicState('y3.music.road')=='playing','Road music not playing')
 assert(GetMusicState('y3.music.boss')=='stopped','Boss playing during road')
 task.Wait(10)
 print('MUSIC14 ROAD PASS')
end
local frame=FrameFunc;local checked=false
FrameFunc=function()
 local result=frame()
 if Y3Host.current and Y3.tick>=30 and not checked then
  checked=true
  assert(GetMusicState('y3.music.boss')=='playing','Boss music not playing')
  assert(GetMusicState('y3.music.road')=='stopped','Road music not stopped')
  ext.pausemenu:PauseSound();assert(GetMusicState('y3.music.boss')=='paused')
  ext.pausemenu:ResumeSound();assert(GetMusicState('y3.music.boss')=='playing')
  print('MUSIC14 BOSS SWITCH PAUSE RESUME PASS');stage.QuitGame()
 end
 return result
end
'@
[IO.File]::AppendAllText($root,"`n"+$probe,[Text.UTF8Encoding]::new($false))
$args="setting.mod='YuyukoStage3';setting.y3_full=true;setting.y3_entry='full';setting.y3_practice='non1';setting.y3_invincible=true;setting.y3_test=false;setting.windowed=true;start_game=true"
$p=Start-Process (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args+'"') -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(30000)){throw 'Probe timeout, process retained'}
Copy-Item (Join-Path $game 'engine.log') 'G:\MySTG\work\logs\yuyuko3\music14-native.log'
$log=Get-Content 'G:\MySTG\work\logs\yuyuko3\music14-native.log' -Raw
if($p.ExitCode-ne0 -or $log-notmatch'MUSIC14 ROAD PASS' -or $log-notmatch'MUSIC14 BOSS SWITCH PAUSE RESUME PASS'){throw 'Probe failed; see music14-native.log'}
'PASS native music decode, road->boss playback states, pause/resume'
}finally{[IO.File]::WriteAllBytes($root,$code);[IO.File]::WriteAllBytes($settings,$before)}
