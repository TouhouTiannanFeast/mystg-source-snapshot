$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$root=Join-Path $game 'mod\YuyukoStage3\root.lua'
$settings=Join-Path $game 'userdata\setting.json'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Running game preserved'}
$before=[IO.File]::ReadAllBytes($settings);$code=[IO.File]::ReadAllBytes($root)
try{
$probe=@'
player_lib.debug_data.keep_shooting=true
local keys=player_lib.system.updateKeyState
function player_lib.system:updateKeyState(...)local r=keys(self,...);self.player.__slow_flag=true;return r end
local frame=FrameFunc;local target;local missChecked=false;local done=false;local defeatedAt
FrameFunc=function()
 if target and target.active and IsValid(player)then player.x=math.max(-180,math.min(180,target.x-192))end
 local result=frame()
 if Le03 and Le03.tick>1100 and IsValid(player)then
  if not target then for _,e in ipairs(Le03.enemies)do if e.appear==1100 and e.active then target=e;break end end end
  if target and target.defeated and not defeatedAt then defeatedAt=Le03.tick end
  assert(lstg.var.power==400 and player.support==4,'Power/support not locked')
  if Le03.tick>=1160 and not missChecked then
   missChecked=true;item.PlayerMiss(player);assert(lstg.var.power==400 and player.support==4,'Miss reduced power')
   GetPower(-300);assert(lstg.var.power==400,'Power API unlocked')
  end
  if Le03.tick>=1490 and not done then
   done=true
   assert(defeatedAt and defeatedAt<1450,'First600HP enemy did not die before departure; damage='..Le03.counts.damage..' hp='..tostring(target and target.hp))
   print('HP17 PASS power='..lstg.var.power..' support='..player.support..' first600HP_defeated_at='..defeatedAt..' total_damage='..Le03.counts.damage)
  end
  if Le03.tick>=1495 then stage.QuitGame()end
 end
 return result
end
local render=RenderFunc
RenderFunc=function()render();if done then lstg.Snapshot('userdata/snapshot/hp17-road.jpg')end end
local step=DoFrame;DoFrame=function(...)for i=1,4 do step(...)end end

'@
[IO.File]::AppendAllText($root,"`n"+$probe,[Text.UTF8Encoding]::new($false))
$args="setting.mod='YuyukoStage3';setting.y3_full=true;setting.y3_entry='road-1100';setting.y3_practice='all';setting.y3_invincible=true;setting.y3_test=false;setting.windowed=true;start_game=true"
$p=Start-Process (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args+'"') -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(45000)){throw 'Probe timeout, process retained'}
Copy-Item (Join-Path $game 'engine.log') 'G:\MySTG\work\logs\yuyuko3\hp17-native.log'
$log=Get-Content 'G:\MySTG\work\logs\yuyuko3\hp17-native.log' -Raw
if($p.ExitCode-ne0 -or $log-notmatch'HP17 PASS'){throw 'Probe failed; see hp17-native.log'}
Copy-Item (Join-Path $game 'userdata\snapshot\hp17-road.jpg') 'G:\MySTG\work\logs\yuyuko3\hp17-road.jpg'
Select-String -InputObject $log -Pattern 'HP17 PASS[^\r\n]*' -AllMatches | ForEach-Object {$_.Matches.Value}
}finally{[IO.File]::WriteAllBytes($root,$code);[IO.File]::WriteAllBytes($settings,$before)}
