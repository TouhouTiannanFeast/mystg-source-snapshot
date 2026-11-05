Include('THlib.lua')
Include('player.lua');Include('power-lock.lua')
Include('pool.lua');Include('runtime.lua');Include('projectiles.lua');Include('programs.lua');Include('encounter.lua');Include('assets.lua')
local R,P,A=SeigaRuntime,SeigaPool,SeigaArt
local S={owned={},finished=false};SeigaState=S
for _,a in pairs(A)do
 LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h)
end
local function own(o)S.owned[o]=true;return o end
local function clean()
 R.clearHazards(false)
 for _,a in ipairs(R.actors or{})do a.dead=true end
 for o in pairs(S.owned)do if IsValid(o)then Del(o)end end
 S.owned={}
end
local function body(a,group)
 local dx=a.x-(a.lastDrawX or a.x);a.lastDrawX=a.x
 local sid=0;local flip=1;local t=a.age
 if a.down then sid=group=='yoshika'and 14 or 0
 elseif math.abs(dx)>0.08 then
  if group=='seiga'then sid=(dx>0 and 7 or 4)+math.min(2,math.floor((t-(a.moveStart or t))/6))
  else sid=8+math.floor(t/7)%2;flip=dx>0 and -1 or 1 end
 else
  a.moveStart=t
  if group=='seiga'then local frames={0,1,2,1,0,1,2,1,0,1,2,1,0,1,3,1};sid=frames[math.floor(t/10)%16+1]
  else local frames={0,0,1,2,3,4,4,3,2,1};sid=frames[math.floor(t/10)%10+1]end
 end
 local img=A[group..':'..sid].image
 SetImageState(img,'',Color(255,255,255,255));Render(img,a.x,224-a.y,0,flip,1)
end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,COLOR_RED,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;own(self)
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 local art=assert(A[b.typ..':'..b.color],'missing TH13 projectile art '..b.typ..':'..b.color)
 self.x,self.y,self.vx,self.vy=b.x,224-b.y,0,0;self.img=art.image
 self.a,self.b=art.radius,art.radius;self.rect=false;self.colli=b.collidable~=false
 self.heading=-(b.angle or 0)*180/math.pi+90;self.rot=0;self.hscale,self.vscale=1,1;self._a=255
 if b.birth and b.age<b.birth then local u=b.age/b.birth;self.hscale=1+2*(1-u)^2;self.vscale=self.hscale;self._a=255*u end
end
function Shot:render()self.rot=self.heading or 0;bullet.render(self);self.rot=0 end
function Shot:del()S.owned[self]=nil;if not self.data.offscreenRemoval then bullet.del(self)end end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
-- Curved lasers use the same centerline for rendering, damage and graze.
local Curve=Class(object)
function Curve:init(b)
 self.data=b;self.group=GROUP_INDES;self.layer=LAYER_ENEMY_BULLET
 self.bound=false;self.colli=false;self._inf_graze=true;own(self)
end
local function distance2(px,py,a,b)
 local dx,dy=b.x-a.x,b.y-a.y;local n=dx*dx+dy*dy
 local u=n>0 and math.max(0,math.min(1,((px-a.x)*dx+(py-a.y)*dy)/n))or 0
 return(px-a.x-u*dx)^2+(py-a.y-u*dy)^2
end
function Curve:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y=b.x,224-b.y
 if not IsValid(player)then return end
 local pts=b.points or{};local r=b.laser.width/2
 for i=2,#pts do
  local d=distance2(player.x,224-player.y,pts[i-1],pts[i])
  if d<(r+player.A)^2 then
   if setting.seiga_test then S.curveContacts=(S.curveContacts or 0)+1 end
   player.class.colli(player,self);break
  end
  if self.timer%4==0 and d<(r+24)^2 then player.grazer.class.colli(player.grazer,self);break end
 end
end
function Curve:render()
 local b=self.data;local pts=b.points or{};local img=A.curve.image;local color=Color(255,255,255,255)
 for i=2,#pts do
  local p,q=pts[i-1],pts[i];local dx,dy=q.x-p.x,p.y-q.y;local n=math.sqrt(dx*dx+dy*dy)
  if n>0.001 then
   local w=b.laser.width/2
   local nx,ny=-dy/n*w,dx/n*w;local y1,y2=224-p.y,224-q.y
   local u0,u1=(i-2)/(#pts-1)*256,(i-1)/(#pts-1)*256
   RenderTexture(img,'mul+add',{p.x+nx,y1+ny,.5,u0,0,color},{q.x+nx,y2+ny,.5,u1,0,color},{q.x-nx,y2-ny,.5,u1,16,color},{p.x-nx,y1-ny,.5,u0,16,color})
  end
 end
end
function Curve:del()S.owned[self]=nil end
function Curve:kill()self.data.dead=true;S.owned[self]=nil end
R.onShot=function(b)if b.laser then New(Curve,b)else New(Shot,b)end end
local Contact=Class(object)
function Contact:init(a)
 self.data=a;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false;self.rect=true;own(self)
end
function Contact:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.x,self.y=a.x,224-a.y;self.a,self.b=(a.hitW or 0)/2,(a.hitH or 0)/2
 self.colli=not a.down and R.bitAnd(a.flags or 0,2)==0 and a.hitW~=nil
end
function Contact:render()end
function Contact:del()S.owned[self]=nil end
local DamageActor=Class(enemy)
function DamageActor:take_damage(dmg)
 if self.protect or self.data.dead then return end
 self.data.hp=self.data.hp-dmg;self.hp=math.max(1,self.data.hp)
 if self.data.name=='Yoshika'and self.data.hp<=0 then S.yoshikaHits=(S.yoshikaHits or 0)+1 end
end
local Actor=Class(DamageActor)
function Actor:init(a)
 enemybase.init(self,a.hp or 1);self.data=a;self.bound=false;self.group=GROUP_NONTJT
 self.layer=LAYER_ENEMY;self.vx,self.vy=0,0;self.rect=true;self.x,self.y=a.x,224-a.y;self.contact=New(Contact,a);own(self)
 if a.name=='Yoshika'then S.yoshikaHost=self end
end
function Actor:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.x,self.y,self.vx,self.vy=a.x,224-a.y,0,0;self.hp=math.max(1,a.hp);self.maxhp=a.maxhp or a.hp
 self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2
 self.colli=not a.down and R.bitAnd(a.flags or 0,1)==0
 self.protect=a.down or(a.invuln or 0)>0 or R.bitAnd(a.flags or 0,17)~=0
 enemybase.frame(self)
 if a.hp<=0 and a.name~='Yoshika'then Kill(self)end
end
function Actor:render()
 local a=self.data
 if a.name=='Yoshika'then body(a,'yoshika')
 else
  local img=A['seiga:15'].image;SetImageState(img,'mul+add',Color(255,255,255,255))
  local scale=.9+.1*cos(self.timer*18);Render(img,self.x,self.y,0,scale,scale)
 end
end
function Actor:kill()
 if self.data.name=='Yoshika'then self.data.hp=0;PreserveObject(self)
 else self.data.dead=true;S.ballKills=(S.ballKills or 0)+1;S.owned[self]=nil;New(enemy_death_ef,1,self.x,self.y)end
end
function Actor:del()S.owned[self]=nil end
R.onActor=function(a)New(Actor,a)end
local function card(spec)
 local c=boss.card.New(spec.name,0,0,spec.frames/60,spec.hp,{0,0,0},spec.name~='')
 c.init=function(o)
  clean();S.current=spec.id;S.damaged=false;S.yoshikaHits=0;S.sawDown=false;S.sawRevive=false;S.ballKills=0;S.curveContacts=0
  S.probeBallTarget=nil;S.curveProbeDone=nil;S.probeRestoreTick=nil
  R.start(spec,tonumber(setting.seiga_seed)or 20261103)
  if S.lastSeiga then R.boss.x,R.boss.y=S.lastSeiga.x,S.lastSeiga.y end
  if S.lastYoshika then R.yoshika.x,R.yoshika.y=S.lastYoshika.x,S.lastYoshika.y end
  print('SEIGA PHASE '..spec.id..' hp='..spec.hp..' frames='..spec.frames)
  task.New(o,function()
   while true do
    local px,py=0,400;if IsValid(player)then px,py=player.x,224-player.y end
    R.step(px,py,o.hp);R.stepHazards();o.x,o.y=R.boss.x,224-R.boss.y
    o.a,o.b=24,24;o.rect=true;o.dmg_factor=R.invuln>0 and 0 or 1
    if o.hp<spec.hp then S.damaged=true end
    if R.yoshika.down then S.sawDown=true elseif S.sawDown then S.sawRevive=true end
    if setting.seiga_test then
     player.protect=1000
     if R.tick==350 then S.probeBoss=New(Y3Player.Shot,o.x,o.y,0,1,true)end
     if R.tick==353 and IsValid(S.probeBoss)then Del(S.probeBoss)end
     if R.tick==400 then
      local a=R.yoshika;S.probeYoshika=New(Y3Player.Shot,a.x,224-a.y,0,20000,true)
     end
     if R.tick==403 and IsValid(S.probeYoshika)then Del(S.probeYoshika)end
     if spec.id=='spell2'and R.tick>=800 and not S.probeBallTarget then
      for _,a in ipairs(R.actors)do
       if a.name=='EvilBall01'and not a.dead and math.abs(a.x)<170 and a.y>0 and a.y<420 then
        S.probeBallTarget=a;S.probeBallDeleteTick=R.tick+3;S.probeBall=New(Y3Player.Shot,a.x,224-a.y,0,20,true);break
       end
      end
     end
     if R.tick==S.probeBallDeleteTick and IsValid(S.probeBall)then Del(S.probeBall)end
     if spec.id=='spell2'and R.tick>=800 and not S.curveProbeDone then
      for _,b in ipairs(R.hazards)do if b.laser and b.points and #b.points>20 then
       local p=b.points[20]
       if math.abs(p.x)<170 and p.y>0 and p.y<420 then
        S.curveProbeDone=true;S.probeRestoreTick=R.tick+3;S.probePlayer={x=player.x,y=player.y};player.x,player.y=p.x,224-p.y;break
       end
      end end
     end
     if R.tick==S.probeRestoreTick and S.probePlayer then player.x,player.y=S.probePlayer.x,S.probePlayer.y;S.probePlayer=nil end
     if R.tick>=(tonumber(setting.seiga_test_frames)or 1100)then
      assert(R.stats.bullets>0,'no source bullets');assert(S.damaged,'Boss shooting collision failed')
      assert(S.yoshikaHits>0 and S.sawDown,'Yoshika shooting/down interaction failed')
      if spec.name~=''then assert(S.sawRevive,'Yoshika source revival missing')end
      if spec.id=='spell2'then
       assert(R.stats.lasers>=16 and #R.actors>2,'curve/ball births missing')
       assert(S.probeBallTarget and S.probeBallTarget.hp==10 and R.bitAnd(S.probeBallTarget.flags,1)==1,'source spirit no-hurtbox flag changed')
       assert(S.curveContacts>0,'curve collision trigger missing')
       print('SEIGA CURVE/SPIRIT PASS hits='..S.curveContacts..' spiritHP='..S.probeBallTarget.hp..' flags='..S.probeBallTarget.flags)
      end
      print('SEIGA NATIVE PASS '..spec.id..' tick='..R.tick..' bullets='..R.stats.bullets..' curves='..R.stats.lasers..' down='..tostring(S.sawDown)..' revive='..tostring(S.sawRevive))
      o.hp=0;return
     end
    end
    task.Wait(1)
   end
  end)
 end
 c.del=function()
  S.lastSeiga={x=R.boss.x,y=R.boss.y};S.lastYoshika={x=R.yoshika.x,y=R.yoshika.y}
  clean();assert(next(S.owned)==nil,'phase owned objects leaked');print('SEIGA CLEANUP PASS '..spec.id)
 end
 return c
end
local Boss=Class(boss)
function Boss:init()
 local cards={};local first
 for _,s in ipairs(P.specs)do if not setting.seiga_phase or setting.seiga_phase=='all'or setting.seiga_phase==s.id then cards[#cards+1]=card(s);first=first or s end end
 assert(first,'unknown Seiga phase');boss.init(self,first.x,224-first.y,'Seiga Kaku',cards,nil,'Normal');self.bound=false
end
function Boss:render()self._bosssys:render();if R.boss then body(R.boss,'seiga')end end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Seiga Four@Normal',nil,true)
stage.group.DefStageFunc('Seiga Four@Normal','init',function(s)
 S.finished=false;S.lastSeiga=nil;S.lastYoshika=nil
 stage.group.initTask(s,function()
  New(default_stage_background);task.Wait(60)
  local b=New(Boss)
  while IsValid(b)do
   if(setting.seiga_test or setting.seiga_invincible)and IsValid(player)then player.protect=1000 end
   task.Wait(1)
  end
  clean();task.Wait(90);S.finished=true;print('SEIGA COMPLETE')
  if setting.seiga_test then stage.QuitGame()else stage.group.FinishStage()end
 end)
end)
stage.group.DefStageFunc('Seiga Four@Normal','del',clean)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal')
 end
end
if setting.seiga_test then
 local frame=FrameFunc
 FrameFunc=function()
  local ok,value=xpcall(frame,debug.traceback)
  if not ok then print('SEIGA FRAME ERROR '..tostring(value));stage.QuitGame()end
  return value
 end
 local render=RenderFunc;local captured={}
 RenderFunc=function()
  local ok,value=xpcall(render,debug.traceback)
  if not ok then print('SEIGA RENDER ERROR '..tostring(value));stage.QuitGame();return end
  if S.current then for _,t in ipairs({320,510,1000})do
   local key=S.current..'-'..t
   if R.tick>=t and not captured[key]then
    captured[key]=true;local path='userdata/snapshot/seiga-'..key..'.jpg';lstg.Snapshot(path);print('SEIGA SNAPSHOT '..path)
   end
  end end
 end
end
