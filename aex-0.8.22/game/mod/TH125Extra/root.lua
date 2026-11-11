Include('THlib.lua')
Include('player.lua');Include('power-lock.lua')
Include('pool.lua');Include('runtime.lua');Include('projectiles.lua');Include('programs.lua');Include('assets.lua');Include('sound.lua')
local R,P,A=DSExtraRuntime,DSExtraPool,DSExtraArt
local S={owned={},finished=false};DSExtraState=S
R.onSound=function(id)DSExtraSound(id,R.boss and R.boss.x or 0);S.soundCalls=(S.soundCalls or 0)+1 end
R.onShake=function(t,x,y)if S.current==8 then misc.ShakeScreen(t,math.max(x,y));S.shakeCalls=(S.shakeCalls or 0)+1;S.ownsShake=true end end
for _,art in pairs(A)do
 if not CheckRes('img',art.image)then
  LoadTexture(art.image,art.path);LoadImage(art.image,art.image,0,0,art.w,art.h)
 end
end
local function own(o)S.owned[o]=true;return o end
local function clean()
 if S.ownsShake and lstg.tmpvar._G_shaker then Del(lstg.tmpvar._G_shaker)end;S.ownsShake=false
 R.clearHazards(false)
 for _,a in ipairs(R.actors or{})do a.dead=true end
 for o in pairs(S.owned)do if IsValid(o)then Del(o)end end
 S.owned={}
end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,COLOR_RED,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;own(self)
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 local art=assert(A[b.typ..':'..b.color],'unmapped DS bullet')
 self.x,self.y,self.vx,self.vy=b.x,224-b.y,0,0
 self.img=art.image;self.a,self.b=art.radius,art.radius;self.rect=false
 self.heading=art.spin and art.spin*b.age or -(b.angle or 0)*180/math.pi-90;self.rot=0
 self.colli=b.collidable~=false
 self.hscale,self.vscale=1,1;self._a=255
 if b.birth and b.age<b.birth then
  local u=b.age/b.birth;self.hscale=1+2*(1-u)^2;self.vscale=self.hscale;self._a=255*u
 end
end
function Shot:render()self.rot=self.heading or 0;bullet.render(self);self.rot=0 end
function Shot:del()S.owned[self]=nil;if not self.data.offscreenRemoval then bullet.del(self)end end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
R.onShot=function(b)New(Shot,b)end
local ActorHit=Class(object)
function ActorHit:init(a)
 self.data=a;self.group=GROUP_INDES;self.layer=LAYER_ENEMY_BULLET-1
 self.bound=false;self.colli=false;self.vx,self.vy=0,0;own(self)
end
function ActorHit:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.x,self.y,self.vx,self.vy=a.x,224-a.y,0,0
 self.rot=-(a.angle or 0)*180/math.pi;self.rect=true
 self.a,self.b=(a.hitW or 0)/2,(a.hitH or 0)/2;self.colli=a.hitW~=nil
end
function ActorHit:render()end
function ActorHit:del()S.owned[self]=nil end
local Actor=Class(enemy)
function Actor:init(a)
 enemybase.init(self,a.hp or 1)
 self.data=a;self.bound=false;self.colli=true;self.group=GROUP_NONTJT
 self.layer=LAYER_ENEMY_BULLET-1;self.vx,self.vy=0,0;own(self)
 if a.name=='Boss1Spark'then self.colli=false;self.homingExcluded=true;self.x,self.y=a.x,224-a.y;self.rot=-(a.angle or 0)*180/math.pi;New(ActorHit,a)end
end
function Actor:frame()
 local a=self.data;if a.dead then Del(self);return end
 enemybase.frame(self)
 self.x,self.y,self.vx,self.vy=a.x,224-a.y,0,0
 self.rot=-(a.angle or 0)*180/math.pi
 self.rect=true;self.a,self.b=(a.hurtW or 0)/2,(a.hurtH or 0)/2
 -- These are photo targets in DS, not ordinary HP1 shooting enemies.
 -- Keep player contact in ActorHit; shooting must not punch holes in the beam.
 self.colli=a.name~='Boss1Spark' and a.hurtW~=nil
end
function Actor:render()
 local a=self.data
 if a.name=='BossAt'then
  local img=A['enemy:139'].image
  SetImageState(img,'mul+add',Color(255,255,255,255))
  local k=1.2+0.2*sin(a.age*4.5)
  Render(img,self.x,self.y,a.age*18,k,k)
 elseif a.name=='Boss1Spark'then
  local img=A['enm27:29'].image;local k=2.5*math.min(1,a.age/8)
  SetImageState(img,'mul+add',Color(255,255,255,255))
  -- Source coordinates avoid stale/newly reused host slots flashing at origin.
  Render(img,a.x,224-a.y,-(a.angle or 0)*180/math.pi,k,k)
 end
end
function Actor:del()S.owned[self]=nil end
function Actor:kill()self.data.dead=true;S.actorKills=(S.actorKills or 0)+1;S.owned[self]=nil end
R.onActor=function(a)New(Actor,a)end
local Background=Class(object)
function Background:init()self.group=GROUP_GHOST;self.layer=LAYER_BG;self.bound=false;self.colli=false end
function Background:render()
 SetViewMode('world')
 local group=S.current==7 and 'enm26' or 'enm27'
 local base,glow=A[group..':0'].image,A[group..':1'].image
 SetImageState(base,'',Color(255,255,255,255));Render(base,0,0,0,1.5,1.75)
 SetImageState(glow,'mul+add',Color(192,255,255,255))
 Render(glow,0,0,S.current==7 and -self.timer*0.45 or 0,2.3046875,2.3046875)
end
local function card(spec)
 local c=boss.card.New(spec.name,0,0,spec.frames/60,spec.hp,{0,0,0},true);c.t3=spec.frames
 c.init=function(o)
  clean();S.current=spec.id;S.damaged=false;S.actorKills=0;S.bossProbe=false;S.interactionActor=nil;S.soundCalls=0;S.shakeCalls=0
  R.start(spec,tonumber(setting.ds_extra_seed)or 20261103)
  print('DS EXTRA PHASE '..spec.id..' hp='..spec.hp..' frames='..spec.frames)
  task.New(o,function()
   while true do
    local px,py=0,400;if IsValid(player)then px,py=player.x,224-player.y end
    R.step(px,py,o.hp);R.stepHazards()
    o.x,o.y=R.boss.x,224-R.boss.y
    o.a,o.b=24,24;o.rect=true
    o.colli=not R.boss.hidden
    o.dmg_factor=(R.invuln>0 or R.boss.hidden)and 0 or 1
    if o.hp<spec.hp then S.damaged=true end
    if setting.ds_extra_test then
     player.protect=1000
     if setting.ds_extra_test_interactions and R.tick==180 and spec.id~=7 then
      for _,a in ipairs(R.actors)do
       if a~=R.boss and not a.dead and a.hurtW and a.x>-180 and a.x<180 and a.y>0 and a.y<448 then
        New(Y3Player.Shot,a.x,224-a.y-10,0,1,true);S.interactionActor=a;break
       end
      end
      assert(S.interactionActor,'no in-field actor for shooting probe')
     end
     if setting.ds_extra_test_interactions and not S.bossProbe and R.tick>=100 and not R.boss.hidden
       and o.x>-160 and o.x<160 and o.y>-192 and o.y<192 and R.invuln==0 then
      S.bossProbe=true;New(Y3Player.Shot,o.x,o.y,0,1,true)
     end
     if R.tick>=(tonumber(setting.ds_extra_test_frames)or 780)then
      assert(R.stats.bullets>0,'source emitted no bullets')
      if spec.id==2 then assert(#R.actors>=33,'32 orbit emitters missing')end
      if spec.id==8 then assert(#R.actors>45,'spark actors missing');assert(S.shakeCalls>=2 and S.soundCalls>=3,'source audio/shake callbacks missing');print('DS EXTRA EFFECTS PASS shake='..S.shakeCalls..' sounds='..S.soundCalls)end
      if setting.ds_extra_test_interactions then
       assert(S.damaged,'ordinary shot did not damage Boss')
       if spec.id==2 then assert(S.interactionActor.dead and S.actorKills>0,'ordinary shot did not clear orbit emitter')end
       if spec.id==8 then assert(S.actorKills==0,'ordinary shots cleared spark segments')end
       print('DS EXTRA SHOOT PASS card='..spec.id..' actorKills='..S.actorKills)
      end
      print('DS EXTRA NATIVE PASS card='..spec.id..' tick='..R.tick..' bullets='..R.stats.bullets..' actors='..#R.actors..' damaged='..tostring(S.damaged))
      o.hp=0;return
     end
    end
    task.Wait(1)
   end
  end)
 end
 c.del=function()
  clean();assert(next(S.owned)==nil,'DS Extra cleanup leak')
  print('DS EXTRA CLEANUP PASS card='..spec.id)
 end
 return c
end
local Boss=Class(boss)
function Boss:init(id)
 local spec=P.specs[id];self.dsID=id
 boss.init(self,spec.x,224-spec.y,spec.boss,{card(spec)},nil,'Extra')
 self.a,self.b=24,24;self.bound=false
end
function Boss:render()
 self._bosssys:render()
 local a=R.boss;if not a or a.hidden then return end
 local group=self.dsID==7 and 'enm26' or 'enm27'
 local dx=self.x-(self.oldDrawX or self.x);self.oldDrawX=self.x
 local sid=math.abs(dx)>0.1 and (dx>0 and 10 or 6)+math.floor(self.ani/5)%4 or 2+math.floor(self.ani/5)%4
 local img=A[group..':'..sid].image
 SetImageState(img,'',Color(255,255,255,255))
 Render(img,self.x,self.y,0,1,1)
end
stage.group.New('Extra','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Extra','DS Extra@Extra',nil,true)
stage.group.DefStageFunc('DS Extra@Extra','init',function(s)
 S.finished=false
 stage.group.initTask(s,function()
  New(Background);task.Wait(60)
  local only=tonumber(setting.ds_extra_card)
  for _,id in ipairs({2,7,8})do
   if not only or only==id then
    S.current=id;local b=New(Boss,id)
    while IsValid(b)do
     if setting.ds_extra_test or setting.ds_extra_invincible then player.protect=1000 end
     task.Wait(1)
    end
    clean();task.Wait(90)
   end
  end
  S.finished=true
  print('DS EXTRA COMPLETE')
  if setting.ds_extra_test then stage.QuitGame()else stage.group.FinishStage()end
 end)
end)
stage.group.DefStageFunc('DS Extra@Extra','del',clean)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Extra')
 end
end
if setting.ds_extra_test then
 local render=RenderFunc;local captured={}
 RenderFunc=function()
  render()
  if S.current and R.tick then
   for _,t in ipairs({160,320,760})do
    local key=S.current..'-'..t
    if R.tick>=t and not captured[key]then
     captured[key]=true;local path='userdata/snapshot/ds-extra-'..key..'.jpg'
     lstg.Snapshot(path);print('DS EXTRA SNAPSHOT '..path)
    end
   end
  end
 end
end
