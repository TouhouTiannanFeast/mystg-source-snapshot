Include('THlib.lua')
Include('assets.lua')
Include('sound-assets.lua')
Include('runtime.lua')
Include('road-runtime.lua')
Include('projectiles.lua')
Include('programs.lua')
Include('presentation.lua')
Include('sound.lua')
Include('host.lua')
Include('background-assets.lua')
Include('background.lua')
local R,H,S=TH10S6Runtime,TH10S6Host,TH10S6Sound
local Hud=Class(object)
function Hud:init()self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()
 RenderText('menu',H.finished and 'ROAD COMPLETE' or 'TH10 STAGE 6 / NORMAL',0,-200,.22,'centerpoint')
end
local function clean()H.clean();S.active=false end
function H.run(s)
 H.clean();H.finished=false;H.spawns=0;H.kills=0;H.culls=0;H.damage=0;H.drops=0;S.count=0;S.active=true
 R.start();New(TH10S6Background.Object);New(Hud)
 local _,bgm=EnumRes('bgm');for _,name in pairs(bgm)do StopMusic(name)end
 -- Checkpoints run source scheduling without a host, then instantiate only
 -- currently living objects. They never award kills/items for skipped waves.
 local checkpoint=tonumber(setting.th10s6_checkpoint)or 0
 if checkpoint>0 then
  local actorHook,shotHook,soundHook=R.onActor,R.onShot,R.onSound
  R.onActor,R.onShot,R.onSound=nil,nil,nil
  while R.tick<checkpoint do R.step(0,400,1);R.stepHazards()end
  R.onActor,R.onShot,R.onSound=actorHook,shotHook,soundHook
  for _,a in ipairs(R.actors)do if not a.controller and not a.dead then actorHook(a)end end
  -- Existing bullets are materialized silently at their current age.
  for _,b in ipairs(R.hazards)do New(H.Shot,b)end
  while TH10S6Background.current.state.t<R.tick-1 do TH10S6Background.Object.frame(TH10S6Background.current)end
 end
 local stop=setting.th10s6_test and checkpoint+(tonumber(setting.th10s6_test_frames)or 360)or 3668
 while R.tick<3668 and R.tick<stop do
  if setting.th10s6_invincible or setting.th10s6_test then player.protect=1000 end
  R.step(player.x,224-player.y,1);R.stepHazards()
  if setting.th10s6_test then
   local t=R.tick-checkpoint
   -- Focused native trigger checks: one real death/drop + one Bomb-style clear.
   if t==170 then for o in pairs(H.enemies)do if IsValid(o)and not o.protect then
    local hp=o.hp;Damage(o,1);assert(o.hp==hp-1 and H.damage>0,'native damage dispatch failed')
    o.hp=0;break
   end end end
   if t==240 then for o in pairs(H.owned)do if IsValid(o)and o.data and o.data.typ then Kill(o)end end end
  end
  task.Wait(1)
 end
 if setting.th10s6_test then
  assert(H.spawns>0 and R.stats.bullets>0 and S.count>0,'native source hooks missing')
  if checkpoint==0 or checkpoint==1320 or checkpoint==2410 then assert(H.kills>=1 and H.drops>=1,'native defeat/drop missing')end
  print(string.format('TH10S6 PASS tick=%d spawns=%d shots=%d kills=%d culls=%d drops=%d sounds=%d',R.tick,H.spawns,R.stats.bullets,H.kills,H.culls,H.drops,S.count))
 end
 H.clean();assert(next(H.owned)==nil and next(H.enemies)==nil,'host cleanup failed');H.finished=true;task.Wait(120)
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Mountain of Faith 6@Normal',nil,true)
stage.group.DefStageFunc('Mountain of Faith 6@Normal','init',function(s)stage.group.initTask(s,function()H.run(s)end)end)
stage.group.DefStageFunc('Mountain of Faith 6@Normal','del',clean)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
if setting.th10s6_test then
 local oldFrame=FrameFunc;local finish=0
 FrameFunc=function()
  local signal=oldFrame()
  if H.finished then finish=finish+1;if finish==30 then stage.QuitGame()end end
  return signal
 end
 local oldRender=RenderFunc;local captured={}
 RenderFunc=function()
  oldRender()
  local checkpoint=tonumber(setting.th10s6_checkpoint)or 0
  for _,t in ipairs({165,172,245,320})do
   if R.tick and R.tick>=checkpoint+t and not captured[t]then
    captured[t]=true;lstg.Snapshot('userdata/snapshot/th10s6-'..checkpoint..'-'..t..'.jpg')
   end
  end
 end
end
