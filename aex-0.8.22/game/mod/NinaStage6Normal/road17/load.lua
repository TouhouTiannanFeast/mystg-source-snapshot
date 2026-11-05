NinaRoad17={active=false,pendingLaugh=false}
local road=NinaRoad17
local defaultMinor=item_faith_minor
Include('road17/assets.lua');Include('road17/sound-assets.lua');Include('road17/music.lua')
Include('road17/voice.lua')
Include('road17/runtime.lua');Include('road17/road-runtime.lua');Include('road17/projectiles.lua');Include('road17/programs.lua')
Include('road17/presentation.lua');Include('road17/sound.lua');Include('road17/host.lua')
Include('road17/departure18.lua')
Include('road17/background-assets.lua');Include('road17/background.lua')
Include('road17/milk/pattern.lua');Include('road17/milk/actor-assets.lua');Include('road17/milk/actor.lua');Include('road17/milk/nonspell.lua');Include('road17/milk/boss.lua')
local R,H,S,M=TH11S6Runtime,TH11S6Host,TH11S6Sound,TH11S6Milk
local function clearRoad()
 for _,a in ipairs(R.actors or {})do if not a.controller then a.dead=true end end
 R.clearHazards()
end
local nonInit,nonDel=M.nonspell.init,M.nonspell.del
M.nonspell.init=function(o)
 R.clearHazards();H.midboss=o;H.midbossPhase='nonspell';nonInit(o)
end
M.nonspell.del=function(o)nonDel(o);H.midbossPhase='transition' end
local originalInit,originalDel=M.card.init,M.card.del
M.card.init=function(o)clearRoad();originalInit(o);H.midboss=o;H.midbossPhase='spell' end
M.card.del=function(o)
 if not o.lifeRewarded then o.lifeRewarded=true;New(item_extend,o.x,o.y)end
 originalDel(o);clearRoad();R.bossPresent=false;H.midboss=nil;H.midbossPhase=nil;H.midbossEnds=(H.midbossEnds or 0)+1
 print('TH11S6 MIDBOSS END roadTick='..R.tick)
 TH11S6Voice.play(3)
end
R.onMidboss=function()
 R.clearHazards()
 if H.midbossStarts==0 then New(item_extend,0,128)end
 print('TH11S6 MIDBOSS START roadTick='..R.tick)
 H.midbossStarts=(H.midbossStarts or 0)+1
 TH11S6Voice.play(2)
 New(M.Boss)
end
local Hud=Class(object)
function Hud:init()self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()RenderText('menu',H.finished and 'ROAD COMPLETE' or 'TH11 STAGE 6 / NORMAL',0,-200,.22,'centerpoint')end
local function clean()
 M.clean();H.clean();S.active=false;StopMusic('th11s6.road');TH11S6Voice.clean()
end
function H.run(s)
 H.frogLife=false
 clean();H.finished=false;H.spawns=0;H.kills=0;H.culls=0;H.damage=0;H.drops=0;H.midbossStarts=0;H.midbossEnds=0;S.active=true;S.count=0
 for _,key in ipairs({'main','secondary','moves','checks','redRing','yellowRice','headingChecks'})do M.state[key]=0 end
 M.state.tick=-1;M.state.finished=false
 R.start();New(TH11S6Background.Object)
 local _,bgm=EnumRes('bgm');for _,n in pairs(bgm)do StopMusic(n)end;PlayMusic('th11s6.road',1)
 local checkpoint=tonumber(setting.th11s6_checkpoint)or 0
 New(TH11S6Voice.Driver)
 if checkpoint>0 then
  local actor,shot,sound,mid=R.onActor,R.onShot,R.onSound,R.onMidboss
  R.onActor,R.onShot,R.onSound,R.onMidboss=nil,nil,nil,nil
  while R.tick<checkpoint do
   if R.midbossBorn and R.bossPresent and R.tick>=R.midbossBorn+5400 then clearRoad();R.bossPresent=false end
   if setting.th11s6_test_earlyclear and R.midbossBorn and R.tick==R.midbossBorn+300 then clearRoad();R.bossPresent=false end
   R.step(0,400,1);R.stepHazards()
  end
  R.onActor,R.onShot,R.onSound,R.onMidboss=actor,shot,sound,mid
  for _,a in ipairs(R.actors)do if not a.controller and not a.dead then actor(a)end end
  for _,b in ipairs(R.hazards)do New(H.Shot,b)end
  while TH11S6Background.current.state.t<R.tick-1 do TH11S6Background.Object.frame(TH11S6Background.current)end
  -- Checkpoints inside the replacement restore its elapsed pattern in tests
  -- only via a checkpoint before its source spawn; public entry is complete road.
 end
 local stop=setting.th11s6_test and checkpoint+(tonumber(setting.th11s6_test_frames)or 360)or math.huge
 local crowLife=checkpoint>790
 while not R.roadEnd and R.tick<stop do
  if setting.th11s6_invincible or setting.th11s6_test then player.protect=1000 end
  R.step(player.x,224-player.y,1);R.stepHazards()
  if checkpoint==0 then TH11S6Voice.checkFirstBatch(R)end
  if not crowLife and R.tick>790 then
   local alive=false
   for _,a in ipairs(R.actors)do if a.name=='Crow01'and not a.dead then alive=true;break end end
   if not alive then crowLife=true;New(item_extend,0,128)end
  end
  if setting.th11s6_test then
   local t=R.tick-checkpoint
   if t==210 then for o in pairs(H.enemies)do if IsValid(o)and not o.protect then
    local hp=o.hp;Damage(o,1);assert(o.hp==hp-1 and H.damage>0,'host damage dispatch');o.hp=0;break
   end end end
   if setting.th11s6_test_killboss and t==280 and H.midboss then H.midboss.hp=0 end
   if H.midboss and (H.midbossPhase=='nonspell' or H.midbossPhase=='spell') then
    assert(H.midboss.maxhp==(H.midbossPhase=='spell'and 24000 or 12000),'replacement HP changed')
    assert(M.card.t3==3000,'replacement time changed')
   end
  end
  task.Wait(1)
 end
 if setting.th11s6_test then
  assert(H.spawns>0 or H.midbossStarts>0 or R.roadEnd,'checkpoint produced no source events')
  if H.midbossStarts>0 and H.midbossPhase=='spell' then assert(M.state.main>0 and M.state.secondary>0,'replacement did not emit both layers')end
  if setting.th11s6_test_killboss then assert(H.midbossEnds==1 and not R.bossPresent and next(M.state.owned)==nil,'replacement exit did not release source F spawns')end
  print(string.format('TH11S6 PASS tick=%d spawns=%d shots=%d kills=%d drops=%d midStarts=%d midEnds=%d skipped=%d end=%s',R.tick,H.spawns,R.stats.bullets,H.kills,H.drops,H.midbossStarts,H.midbossEnds,R.skipped,tostring(R.roadEnd)))
 end
 if H.midboss and IsValid(H.midboss)then Del(H.midboss)end
 if R.roadEnd then H.finishFrogs();H.finalFrogLife(0,128)end
 clean();assert(next(H.owned)==nil and next(H.enemies)==nil and next(M.state.owned)==nil,'stage cleanup')
 H.finished=true

end

-- Host's blue road cancel drops must not replace Boss cancel drops.
item_faith_minor=defaultMinor
function road.run(s)
 setting.th11s6_test=false
 setting.th11s6_invincible=setting.nina_invincible or setting.nina_test
 setting.th11s6_checkpoint=setting.nina_test and(tonumber(setting.nina_road_checkpoint)or 0)or 0
 setting.th11s6_test_earlyclear=false;setting.th11s6_test_killboss=false
 road.active=true;road.pendingLaugh=false;item_faith_minor=H.Minor
 print('NINA ROAD START checkpoint='..setting.th11s6_checkpoint)
 H.run(s)
 assert(R.roadEnd,'road must finish naturally before Boss')
 road.active=false;item_faith_minor=defaultMinor;road.pendingLaugh=true;road.endFrame=s.timer
 print('NINA ROAD END tick='..R.tick..' stageframe='..s.timer)
end
function road.arrived()
 if not road.pendingLaugh then return end
 road.pendingLaugh=false;TH11S6Voice.play(4)
 print('NINA LAUGH4 AFTER APPEAR stageframe='..stage.current_stage.timer)
end
function road.clean()
 clean();road.active=false;road.pendingLaugh=false;item_faith_minor=defaultMinor
end
