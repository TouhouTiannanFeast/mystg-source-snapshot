Include('THlib.lua')
Include('player.lua')
Include('feedback.lua')
Include('pattern.lua')
Include('word-points.lua')
LoadImage('rs.word-dot','bullet2',176,240,16,16)
LoadTexture('rs.ring','art/th165-ring-atlas.png')
LoadImage('rs.ring-red','rs.ring',16,32,16,16)
LoadSound('rs.charge','se/se_ch00.wav')
LoadTexture('rs.charge','art/th10-enemy.png')
LoadImage('rs.charge.glow','rs.charge',256,128,32,32)
LoadTTF('rs.dialogue','assets/font/wqy-microhei-mono.ttf',32)
local P=RingoSeiranPattern
local S={owned={},world=nil,phase=nil,finished=false,ended=0}
RingoSeiranHost=S
for _,n in ipairs({'dango-blue','dango-red','dango-pink','pixel'})do LoadImageFromFile('rs.'..n,'art/'..n..'.png')end
for _,who in ipairs({'ringo','seiran'})do
 LoadTexture('rs.'..who,'art/'..who..'.png')
 local h=who=='ringo' and 80 or 96
 for i=0,(who=='ringo' and 22 or 17)do
  local x,y
  if i<8 then x,y=i*64,0 elseif i<13 then x,y=(i-8)*64,h
  elseif i<18 then x,y=(i-13)*64,h*2 else x,y=(i-18)*64,h*3 end
  LoadImage('rs.'..who..'.'..i,'rs.'..who,x,y,64,h)
 end
end
local function clean()
 if S.world then P.clear(S.world)end
 local list={};for o in pairs(S.owned)do list[#list+1]=o end
 for _,o in ipairs(list)do if IsValid(o)then Del(o)end end
 S.owned={}
end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,b.kind=='gun' and gun_bullet or(b.kind=='impactPellet' and ball_mid or ball_small),b.color or(b.kind=='gun' and COLOR_BLUE or COLOR_RED),false,true);bullet.skip_fade_in(self)
 self.data=b;self.x,self.y=b.x,224-b.y;self.bound=false;self.rect=false
 self.vx,self.vy=0,0
 if b.kind=='impactPellet' then self.img='rs.ring-red'
 elseif b.kind~='gun' then self.img='rs.dango-'..b.kind end
 local radius=b.kind=='gun' and 2.5 or 2.4
 self.a,self.b=radius,radius
 S.owned[self]=true
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y=b.x,224-b.y;self.rot=b.kind=='gun' and -(b.heading or b.angle)*180/math.pi or(b.rotation or 0)
 if b.kind=='impactPellet' then
  self.colli=not b.fadeAge
  self._blend='';self._a=255*(b.alpha or 1);self._r,self._g,self._b=255,255,255
 end
end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
function Shot:del()
 self.data.dead=true;S.owned[self]=nil
 if not(self.data.kind=='impactPellet' and self.data.fadeAge)then bullet.del(self)end
end
local Hammer=Class(object)
function Hammer:init(w)
 self.patternWorld=w;self.group=GROUP_INDES;self.layer=LAYER_ENEMY+1
 self.bound=false;self.rect=false;self.a,self.b=P.pursuit.hitRadius,P.pursuit.hitRadius
 self.colli=false;S.owned[self]=true
end
function Hammer:frame()
 local s=self.patternWorld.seiran;if not s then Del(self);return end
 self.x,self.y=s.headX,224-s.headY;self.colli=s.active
end
-- This is an invulnerable familiar's weapon. Bomb cannot detach it from its owner.
function Hammer:kill()PreserveObject(self)end
function Hammer:del()S.owned[self]=nil end
-- Collision only: the hammer is already present in Seiran's original texture.
function Hammer:render()end
local Familiar=Class(object)
function Familiar:init(w)
 self.patternWorld=w;self.group=GROUP_INDES;self.layer=LAYER_ENEMY;self.colli=true;self.bound=false
 self.rect=false;self.a,self.b=P.pursuit.bodyA,P.pursuit.bodyB
 self.x,self.y=w.seiran.x,224-w.seiran.y
 S.owned[self]=true
end
function Familiar:frame()
 local s=self.patternWorld.seiran;if not s then Del(self);return end
 self.x,self.y=s.x+(s.spriteShift or 0)*(s.flip or 1),224-s.y
end
function Familiar:render()
 local s=self.patternWorld.seiran;if not s then return end
 local frame=math.floor(self.ani/7)%4
 if s.sprite then frame=s.sprite
 elseif s.entering or(s.targetX and math.abs(s.targetX-s.fromX)>8)then frame=10+math.floor(self.ani/6)%3 end
 local flip=s.flip or 1
 Render('rs.seiran.'..math.floor(frame),self.x,self.y,0,flip,1)
end
function Familiar:kill()PreserveObject(self)end
function Familiar:del()S.owned[self]=nil end
local Effects=Class(object)
function Effects:init(w)self.patternWorld=w;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET-1;self.colli=false;S.owned[self]=true end
function Effects:del()S.owned[self]=nil end
function Effects:render()
 local w=self.patternWorld
 if w.charging then
  -- Scale the charge to the configured intro; preserve pattern RNG.
  local age=w.chargeAge/P.introFrames*60
  local finish=math.max(0,math.min(1,(w.chargeAge-(P.introFrames-30))/30))
  local fade=1-finish*finish*(3-2*finish)
  local scale=2*(1-age/60)
  SetImageState('boss_shockwave','mul+add',Color((80+math.min(age,45)*2)*fade,160,160,255))
  Render('boss_shockwave',w.x,224-w.y,0,scale,scale)
  SetImageState('rs.charge.glow','mul+add',Color(160*fade,200,200,255))
  for i=0,23 do
   local life=(age+i*7)%30
   if finish>0 then
    -- Stop recycling at90f; existing light converges instead of popping off.
    local start=((P.introFrames-30)/P.introFrames*60+i*7)%30
    life=start+(30-start)*(1-fade)
   end
   local radius=(1-life/30)*150
   local angle=i*137.5+age*2
   local size=1.5*(1-life/30)
   Render('rs.charge.glow',w.x+radius*cos(angle),224-w.y+radius*sin(angle),0,size,size)
  end
 end
 for _,e in ipairs(self.patternWorld.effects)do
  SetImageState('rs.pixel','mul+add',Color(200*(1-e.age/18),255,218,140))
  local r=8+e.age*1.4
  for i=0,31 do
   local a,b=i*math.pi/16,(i+1)*math.pi/16
   local x1,y1=e.x+r*math.cos(a),224-e.y+r*math.sin(a)
   local x2,y2=e.x+r*math.cos(b),224-e.y+r*math.sin(b)
   Render('rs.pixel',(x1+x2)/2,(y1+y2)/2,-math.atan2(y1-y2,x2-x1)*180/math.pi,math.sqrt((x2-x1)^2+(y2-y1)^2),2)
  end
 end
end
local HammerWord=Class(object)
function HammerWord:init(x,y,index)
 self.x=math.max(-132,math.min(132,x));self.y=math.max(-172,math.min(172,y+36));self.index=index
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET+2;self.colli=false;self.bound=false
 S.owned[self]=true
end
function HammerWord:frame()if self.timer>=45 then Del(self)end end
function HammerWord:del()S.owned[self]=nil end
function HammerWord:render()
 local alpha=255*math.min(1,math.max(0,(45-self.timer)/15))
 local scale=1+0.12*math.max(0,1-self.timer/8)
 for _,p in ipairs(RingoSeiranWordPoints[self.index])do
  local r,g,b=255,255,255
  if p[3]==2 then g,b=32,24 elseif p[3]==12 then g,b=192,24 end
  SetImageState('rs.word-dot','',Color(alpha,r,g,b))
  Render('rs.word-dot',self.x+p[1]*scale,self.y+p[2]*scale,0,0.48*scale,0.48*scale)
 end
end
local Dialogue=Class(object)
function Dialogue:init(w)
 self.patternWorld=w;self.group=GROUP_GHOST;self.layer=LAYER_TOP+3;self.colli=false;self.bound=false
 S.owned[self]=true
end
function Dialogue:del()S.owned[self]=nil end
function Dialogue:render()
 local w=self.patternWorld;local who=w.dialogue;if not who then return end
 local speaker=who=='ringo' and w or w.seiran
 local text=who=='ringo' and '씨발！' or '싸빌 쌔끼야！'
 local width=who=='ringo' and 68 or 132
 local x=math.max(-184+width/2,math.min(184-width/2,speaker.x+42))
 local y=math.min(200,224-speaker.y+48)
 SetImageState('rs.pixel','',Color(230,45,38,65))
 Render('rs.pixel',x,y,0,width+4,30)
 SetImageState('rs.pixel','',Color(245,255,250,240))
 Render('rs.pixel',x,y,0,width,26)
 Render('rs.pixel',math.max(x-width/2+8,math.min(x+width/2-8,speaker.x)),y-13,45,9,9)
 RenderTTF('rs.dialogue',text,x-width/2,x+width/2,y-13,y+13,Color(255,40,30,50),'center','vcenter','noclip')
end
local function makeCard(id)
 local spec=P.specs[id]
 local c=boss.card.New(spec.name,0,0,spec.time,spec.hp,{0,0,0},false)
 c.init=function(o)
  clean();S.phase=id
  local w=P.new(id,function()return ran:Float(0,1)end,setting.rs_seed or 20261102);S.world=w
  o.x,o.y=w.x,224-w.y
  local soundTick={}
  if id=='nonspell' then o.rsNonspellReward=false end
  w.onShot=function(b)
   if setting.rs_test and b.kind=='gun' then assert(w.seiran.sprite==17 and w.seiran.swing,'Seiran firing pose missing')end
   New(Shot,b)
   RingoSeiranFeedback.shot(soundTick,b,w.t)
  end
  w.onSwing=RingoSeiranFeedback.swing
  w.onImpact=function(s)
   New(HammerWord,s.headX,224-s.headY,(w.stats.impacts-1)%2+1)
   RingoSeiranFeedback.impact(s)
   misc.ShakeScreen(P.pursuit.shakeTime,P.pursuit.shakeSize)
   if setting.rs_test then
    assert(w.stats.gun==w.stats.impacts*P.pursuit.gunCount,'triangle emission failed')
    assert(w.stats.pellet==w.stats.impacts*P.impactPellets.count,'impact star count failed')
    assert(lstg.tmpvar._G_shaker and lstg.tmpvar._G_shaker.time==10 and lstg.tmpvar._G_shaker.size==2,'impact shake failed')
    print(string.format('RS IMPACT t=%d locks=%d gun=%d x=%.2f y=%.2f',w.t,w.stats.locks,w.stats.gun,s.headX,s.headY))
    print(string.format('RS PELLETS t=%d total=%d',w.t,w.stats.pellet))
   end
  end
  if w.seiran then New(Familiar,w);New(Hammer,w)end
  New(Effects,w)
  if w.seiran then New(Dialogue,w)end
  w.onCharge=function()PlaySound('rs.charge',0.5,o.x/192)end
  task.New(o,function()
   while true do
    if setting.rs_invincible or setting.rs_test then player.protect=1000 end
    if setting.rs_test then
     o.hp=spec.hp
     player.x=80*math.sin(w.t*math.pi/180);player.y=-150
    end
    P.step(w,player.x,224-player.y)
    if setting.rs_test and w.opening then
     local hp=o.hp;Damage(o,100);assert(o.hp==hp,'intro invulnerability failed')
     assert(w.stats.dango==0 and w.stats.locks==0 and w.seiran.x==-80,'intro movement/fire failed')
     local u=math.max(0,math.min(1,(w.elapsed-P.dialogueFrames)/P.entryFrames))
     assert(math.abs(w.seiran.y-(-64+192*u*u*(3-2*u)))<1e-8,'intro entry path failed')
     if w.elapsed==P.openingFrames then print('RS INTRO PASS dialogue180 entry60 reply180 charge120 shots=0')end
    end
    if setting.rs_test and id=='spell' and w.t==140 then
     local live=0
     for obj in pairs(S.owned)do
      local b=obj.data
      if b and b.kind=='impactPellet' and not b.dead then
       live=live+1
       assert(b.speed>0 and b.spinSpeed>0 and not b.lifetime,'star early flight stopped')
       assert(obj.a==2.4 and b.spinSpeed==12,'small star host mismatch')
       if b.fadeAge and b.fadeAge>1 then assert(not obj.colli and obj._a<255,'star fade host state failed')end
      end
     end
     assert(live>0,'missing flying stars')
     print('RS STAR FLIGHT PASS live='..live)
    end
    o.lastX=o.x;o.x,o.y=w.x,224-w.y;o.moving=w.move~=nil
    if setting.rs_hammer_test and id=='spell' then
     if w.t==135 then
      assert(not lstg.tmpvar._G_shaker and lstg.worldoffset.dx==0 and lstg.worldoffset.dy==0,'impact shake did not reset')
      print('RS SHAKE PASS time=10 size=2 reset=0')
     elseif w.t==220 then
      -- Hammer is inactive here; enemy shots are removed to isolate body contact.
      for _,b in ipairs(w.bullets)do b.dead=true end
      w.bullets={};player.protect=0;player.death=0
      local familiar
      for obj in pairs(S.owned)do if obj.class==Familiar then familiar=obj end end
      assert(familiar and familiar.colli and familiar.a==16 and familiar.b==28,'missing body hitbox')
      player.x=w.seiran.x+(w.seiran.spriteShift or 0)*(w.seiran.flip or 1);player.y=224-w.seiran.y
      assert(not w.seiran.active,'hammer must be inactive for isolated body test')
      Kill(familiar);assert(IsValid(familiar),'Kill removed familiar')
     elseif w.t==221 then
      assert(player.death>0,'Seiran body contact did not hit player')
      print('RS BODY COLLISION PASS death='..player.death)
     elseif w.t==357 then
      -- Isolate the real engine collision: no enemy shot can cause this hit.
      for _,b in ipairs(w.bullets)do b.dead=true end
      w.bullets={}
      player.protect=0;player.death=0
      player.x,player.y=w.seiran.headX,224-w.seiran.headY
      local weapon
      for obj in pairs(S.owned)do if obj.class==Hammer then weapon=obj end end
      assert(weapon and IsValid(weapon),'missing hammer')
      Kill(weapon);assert(IsValid(weapon),'Bomb-style Kill removed hammer')
     elseif w.t==358 then
      assert(player.death>0,'real hammer collision did not hit player')
      print('RS HAMMER COLLISION PASS death='..player.death)
     end
    end
    if setting.rs_test and id=='spell' and w.t==360 then o.hp=0 end
    task.Wait(1)
   end
  end)
 end
 c.del=function(o)
  local w=S.world
  RingoSeiranFeedback.reward(o,id)
  if setting.rs_test then
   if id=='nonspell' then assert(w.t>=1800 and not w.seiran,'30s nonspell/absence failed')
   else assert(w.stats.impacts==3 and w.stats.gun==108,'spell hammer schedule failed')end
   print(string.format('RS END %s t=%d triples=%d gun=%d',id,w.t,w.stats.triples,w.stats.gun))
  end
  clean();S.ended=S.ended+1
  if setting.rs_test then assert(next(S.owned)==nil and not w.seiran and #w.bullets==0,'cleanup failed')end
 end
 return c
end
local RingoDamage=Class(boss)
function RingoDamage:take_damage(dmg)
 if S.world and S.world.opening then return end
 boss.take_damage(self,dmg)
end
local Ringo=Class(RingoDamage)
function Ringo:init()
 local cards={}
 for _,id in ipairs({'nonspell','spell'})do if not setting.rs_practice or setting.rs_practice=='all' or setting.rs_practice==id then cards[#cards+1]=makeCard(id)end end
 assert(#cards>0,'invalid practice phase')
 boss.init(self,0,96,'铃瑚',cards,nil,'Normal');self.a,self.b=20,20
end
function Ringo:render()
 self._bosssys:render()
 local frame=({0,1,2,1})[math.floor(self.ani/7)%4+1]
 if self.moving then frame=(self.x>=(self.lastX or self.x) and 10 or 15)+({0,1,2,1})[math.floor(self.ani/6)%4+1]end
 Render('rs.ringo.'..frame,self.x,self.y)
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Ringo Seiran@Normal',nil,true)
stage.group.DefStageFunc('Ringo Seiran@Normal','init',function(s)
 stage.group.initTask(s,function()
  ran:Seed(setting.rs_seed or 20261102)
  New(default_stage_background);task.Wait(60)
  local b=New(Ringo);while IsValid(b)do task.Wait(1)end
  clean();S.finished=true;S.phase=nil;print('RS COMPLETE phases='..S.ended);task.Wait(120)
 end)
end)
stage.group.DefStageFunc('Ringo Seiran@Normal','del',clean)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
if setting.rs_test then
 local oldFrame=FrameFunc;local finish=0
 FrameFunc=function()
  local signal=oldFrame()
  if S.finished then finish=finish+1;if finish==30 then stage.QuitGame()end end
  return signal
 end
 local oldRender=RenderFunc;local captured={}
 RenderFunc=function()
  oldRender()
  if S.world and S.phase then
   if S.phase=='spell' and S.world.charging and S.world.chargeAge>=30 and not captured.charge then
    captured.charge=true;lstg.Snapshot('userdata/snapshot/ringo-seiran-charge-30.jpg')
   end
   if S.phase=='spell' and S.world.charging then
    for _,elapsed in ipairs({90,110,119})do
     local key='charge-end-'..elapsed
     if S.world.chargeAge>=elapsed and not captured[key]then
      captured[key]=true;lstg.Snapshot('userdata/snapshot/ringo-seiran-'..key..'.jpg')
     end
    end
   end
   if S.phase=='spell' and S.world.dialogue then
    local key='dialogue-'..S.world.dialogue
    if not captured[key]then captured[key]=true;lstg.Snapshot('userdata/snapshot/ringo-seiran-'..key..'.jpg')end
   end
   for _,t in ipairs(S.phase=='spell' and {1,108,120,140,160,180,240,260} or {72,320})do
    local key=S.phase..'-'..t
    if S.world.t>=t and not captured[key]then captured[key]=true;lstg.Snapshot('userdata/snapshot/ringo-seiran-'..key..'.jpg')end
   end
  end
 end
 if setting.rs_fast then local old=DoFrame;DoFrame=function(...)for i=1,4 do old(...)end end end
end
