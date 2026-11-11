Include('THlib.lua');Include('player.lua');Include('power-lock.lua')
Include('runtime.lua');Include('projectiles.lua');Include('programs.lua');Include('encounter.lua');Include('encounter-nina.lua');Include('assets.lua')
Include('import08/load.lua')
Include('art08-local.lua')
Include('import10/pool.lua');Include('import10/runtime.lua');Include('import10/projectiles.lua');Include('import10/programs.lua');Include('import10/specs.lua');Include('import10/art.lua')
Include('fix02.lua')
Include('programs-fix03.lua');Include('art03.lua');Include('art06.lua');Include('fix03.lua');Include('suwako03.lua');Include('suwako11.lua');Include('intro12.lua');Include('suwako16.lua')
Include('haniwa05.lua')
LoadTexture('nina.note.sheet','art/yellow-note-sheet.png')
LoadAnimation('nina.note.yellow','nina.note.sheet',300,0,48,32,1,3,8,4,4)
SetAnimationCenter('nina.note.yellow',20,12)
Include('scenery/load.lua')
Include('music06/load.lua');Include('road17/load.lua')
local S={owned={},finished=false};NinaState=S
NinaSuwako03.onRevive=function(a)PlaySound('powerup',.7);print('NINA SUWAKO REVIVE '..a.flightTick)end
local A=NinaCoreArt
for _,a in pairs(A)do LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h)end
for _,a in pairs(Nina08LocalArt)do LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h)end
for _,a in pairs(Nina03Art)do LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h)end
for _,a in pairs(Nina06Art)do LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h)end
LoadSound('nina.se.tan00','se/se_tan00.wav');LoadSound('nina.se.lazer00','se/se_lazer00.wav')
local loaded={}
for _,a in ipairs(Nina10Art.records or{})do if not loaded[a.image]then LoadTexture(a.image,a.path);LoadImage(a.image,a.image,0,0,a.w,a.h);loaded[a.image]=true end end
for _,a in pairs(Nina10Art.actor or{})do
 local records=a.frames or{a}
 for _,v in pairs(records)do if v.path and not loaded[v.image]then LoadTexture(v.image,v.path);LoadImage(v.image,v.image,0,0,v.w,v.h);loaded[v.image]=true end end
end
-- TH20 No.13 Stone Goddess (sixth-stage boss) as the battle BGM.
local Music=NinaStage6Music
local function musicStart()
 if GetMusicState(Music.name)=='playing' then return end
 local _,bgm=EnumRes('bgm');for _,n in pairs(bgm)do StopMusic(n)end
 PlayMusic(Music.name,1);print('NINA MUSIC start state='..GetMusicState(Music.name))
end
local function musicStop()
 StopMusic(Music.name);print('NINA MUSIC stop')
end
local pauseSound,resumeSound=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pauseSound(self);self.ninaMusicPaused=GetMusicState(Music.name)=='playing'
 if self.ninaMusicPaused then PauseMusic(Music.name)end
end
function ext.pausemenu:ResumeSound()
 resumeSound(self)
 if self.ninaMusicPaused and GetMusicState(Music.name)=='paused' then ResumeMusic(Music.name)end
 self.ninaMusicPaused=false
end
local function pan(x)return math.max(-1,math.min(1,(x or 0)/224))end
local function own(o)S.owned[o]=true;return o end
local function clean()
 if S.runtime then S.runtime.clearHazards(false);for _,a in ipairs(S.runtime.actors or{})do a.dead=true end end
 for o in pairs(S.owned)do if IsValid(o)then Del(o)end end;S.owned={}
end
local function draw(key,x,y,scale,mirror,opacity)
 local a=assert(A[key],'missing actor art '..key);SetImageState(a.image,'',Color(opacity or 255,255,255,255));Render(a.image,x,224-y,0,(scale or 1)*(mirror or 1),scale or 1)
end
local function body(a,kind)
 local t=a.age or 0
 if kind=='suwako'then
  if a.colorDownStart then
   local q=a.colorDownAge or(S.runtime.tick-a.colorDownStart);local sid=a.group=='silent-suwako'and NinaSuwako03.downSprite(q)or(q<16 and 22+math.floor(q/4)or 26+math.floor((q-16)/4)%4)
   draw('suwakoDown:'..sid,a.x,a.y)
  else local frame,mirror=NinaSuwako11.frame(a);draw('suwako:'..frame,a.x,a.y,1,mirror)end
  if a.glow then local frame,mirror=NinaSuwako11.frame(a);local ar=A['suwako:'..frame];local u=a.glow/30;SetImageState(ar.image,'mul+add',Color(255*u,255,255,190));Render(ar.image,a.x,224-a.y,0,mirror*(1+(1-u)*.7),1+(1-u)*.7)end
 elseif kind=='frog'then local ar=Nina08LocalArt[1000+math.floor(t/8)%3];Render(ar.image,a.x,224-a.y)
 elseif kind=='haniwa'then draw(NinaHaniwa05.frame(a),a.x,a.y)
 elseif kind=='kanako'then
  local ar=Nina10Art.actor and Nina10Art.actor.kanako
  local f={0,1,2,3,2,1};local frame=assert(ar.frames[f[math.floor(t/7)%6+1]]);Render(frame.image,a.x,224-a.y)
 else
  local opacity=a.visualAlpha or 255
  local skirt=A['nina:5'];SetImageState(skirt.image,'',Color(opacity,255,255,255));Render(skirt.image,a.x+2,224-a.y-34,3*sin(t*3),1,1)
  local f={6,7,8,9,8,7};draw('nina:'..f[math.floor(t/8)%6+1],a.x-8,a.y+8,1,1,opacity)
  local f={0,1,2,3,2,1};draw('nina:'..f[math.floor(t/8)%6+1],a.x,a.y,1,1,opacity)
 end
end
local Shot=Class(bullet)
function Shot:init(b,r)
 bullet.init(self,grain_b,COLOR_RED,false,true);bullet.skip_fade_in(self);self.data=b;self.runtime=r;self.bound=false;self.vx,self.vy=0,0;own(self)
end
local function shotart(b)
 local group=b.group=='th13L'and'th13'or(b.group or'')
 local art=A[group..':'..b.typ..':'..b.color]
 if art then return art end
 if b.group=='th08'and type(Nina08Art.lookup)=='function'then return Nina08Art.lookup(b.typ,b.color)end
 if type(Nina10Art.lookup)=='function'then return Nina10Art.lookup(b.typ,b.color,b.group)end
 return nil
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 local a=assert(NinaFix03.art(b,shotart(b)),'missing projectile art '..tostring(b.group)..':'..b.typ..':'..b.color);self.x,self.y,self.vx,self.vy=b.x,224-b.y,0,0
 if a then self.img=a.image;self.a,self.b=a.radius or a.width or 4,a.radius or a.width or 4 end
 self.rect=false;self.colli=b.collidable~=false;self.heading=NinaHaniwa05.isNote(b)and -90 or NinaFix02.heading(b.angle or 0);self.rot=0;self.hscale,self.vscale=1,1;self._a=255
 if b.birth and b.age<b.birth then local u=b.age/b.birth;self.hscale=1+2*(1-u)^2;self.vscale=self.hscale;self._a=255*u end
 if b.diamond then local s=b.diamondScale or 0.8;self.hscale=s;self.vscale=s end
end
function Shot:render()self.rot=self.heading or 0;bullet.render(self);self.rot=0 end
function Shot:del()S.owned[self]=nil;if not self.data.offscreenRemoval then bullet.del(self)end end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
local Curve=Class(object)
function Curve:init(b)self.data=b;self.group=GROUP_INDES;self.layer=LAYER_ENEMY_BULLET;self.bound=false;self.colli=false;own(self)end
function Curve:frame()
 local b=self.data;if b.dead then Del(self);return end
 if not IsValid(player)then return end
 local pts=b.points or{};local r=b.laser.width/2
 for i=2,#pts do local p,q=pts[i-1],pts[i];local dx,dy=q.x-p.x,q.y-p.y;local n=dx*dx+dy*dy
  local u=n>0 and math.max(0,math.min(1,((player.x-p.x)*dx+(224-player.y-p.y)*dy)/n))or 0
  local d=(player.x-p.x-u*dx)^2+(224-player.y-p.y-u*dy)^2
  if d<(r+player.A)^2 then player.class.colli(player,self);break end
  if self.timer%4==0 and d<(r+24)^2 then player.grazer.class.colli(player.grazer,self);break end
 end
end
function Curve:render()
 local b=self.data;local pts=b.points or{};local img=A.curve.image;local c=Color(255,255,255,255)
 for i=2,#pts do local p,q=pts[i-1],pts[i];local dx,dy=q.x-p.x,p.y-q.y;local n=math.sqrt(dx*dx+dy*dy)
  if n>.001 then local w=b.laser.width/2;local nx,ny=-dy/n*w,dx/n*w;local u,v=(i-2)/(#pts-1)*256,(i-1)/(#pts-1)*256
   RenderTexture(img,'mul+add',{p.x+nx,224-p.y+ny,.5,u,0,c},{q.x+nx,224-q.y+ny,.5,v,0,c},{q.x-nx,224-q.y-ny,.5,v,16,c},{p.x-nx,224-p.y-ny,.5,u,16,c})
  end
 end
end
function Curve:del()S.owned[self]=nil end
function Curve:kill()self.data.dead=true;S.owned[self]=nil end
local Straight=Class(laser)
function Straight:init(b)
 local l=b.laser;local edge=math.min(8,l.length/4)
 laser.init(self,math.max(1,math.min(16,b.color+1)),b.x,224-b.y,-b.angle*180/math.pi,edge,math.max(0,l.length-edge*2),edge,l.width,0,0)
 self.data=b;self.bound=false;own(self);self.alpha=1
end
function Straight:frame()
 local b=self.data;if b.dead then Del(self);return end
 local l=b.laser;self.x,self.y=b.x,224-b.y;self.alpha=1;self.w=l.width*(l.scale or .03);self.colli=b.collidable
 laser.frame(self)
end
function Straight:render()
 local b=self.data;local l=b.laser;local ar=Nina10Art.lookup(b.typ,b.color,b.group)
 SetImageState(ar.image,'mul+add',Color(255,255,255,255))
 Render(ar.image,b.x+math.cos(b.angle)*l.length/2,224-b.y-math.sin(b.angle)*l.length/2,-b.angle*180/math.pi-90,self.w/ar.w,l.length/ar.h)
end
function Straight:del()S.owned[self]=nil end
function Straight:kill()self.data.dead=true;S.owned[self]=nil;Del(self)end
local Contact=Class(object)
function Contact:init(a,r)self.data=a;self.runtime=r;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false;self.rect=true;own(self)end
function Contact:frame()
 local a=self.data;if a.dead then Del(self);return end

 self.x,self.y=a.x,224-a.y;self.a,self.b=(a.hitW or 0)/2,(a.hitH or 0)/2
 self.colli=not a.down and a.hitW~=nil and(not self.runtime.bitAnd or self.runtime.bitAnd(a.flags or 0,2)==0)
end
function Contact:render()end
function Contact:del()S.owned[self]=nil end
function Contact:kill()if self.data.name=='Yoshika'then PreserveObject(self)else Del(self)end end
local Damage=Class(enemy)
function Damage:take_damage(dmg)
 if self.protect or self.data.dead then return end
 self.data.hp=self.data.hp-dmg;self.hp=math.max(1,self.data.hp)
end
local Actor=Class(Damage)
function Actor:init(a,r)
 if a.name=='Yoshika'then NinaSuwako11.init(a)end
 enemybase.init(self,a.hp or 1);self.data=a;self.runtime=r;self.bound=false;self.group=GROUP_NONTJT;self.layer=LAYER_ENEMY;self.vx,self.vy=0,0;self.rect=true;own(self);New(Contact,a,r)
end
function Actor:frame()
 local a=self.data;if a.dead then Del(self);return end
 if a.name=='Yoshika'then NinaSuwako11.step(a)end
 self.x,self.y,self.vx,self.vy=a.x,224-a.y,0,0;self.hp=math.max(1,a.hp or 1);self.maxhp=a.maxhp or a.hp or 1
 self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2
 self.colli=not a.down and a.hp~=nil and self.runtime.bitAnd and self.runtime.bitAnd(a.flags or 0,1)==0
 self.protect=a.down or(a.invuln or 0)>0 or(self.runtime.bitAnd and self.runtime.bitAnd(a.flags or 0,17)~=0)
 enemybase.frame(self)
 if a.hp and a.hp<=0 and a.name~='Yoshika'then Kill(self)end
end
function Actor:render()
 local a=self.data;if a.hidden then return end
 if a.visual and a.visual:find('kanako%-orb')then local ar=assert(Nina10Art.actor[a.visual:gsub('-','_')],'missing Kanako orb');local c=ar.tint or{255,255,255,128};SetImageState(ar.image,'mul+add',Color(c[4],c[1],c[2],c[3]));Render(ar.image,a.x,224-a.y)
 elseif a.visual=='familiar'then body(a,'frog')
 else body(a,a.name=='Yoshika'and'suwako'or a.visual=='frog'and'frog'or a.group=='th17'and'haniwa'or'frog')end
end
function Actor:kill()if self.data.name=='Yoshika'then self.data.hp=0;PreserveObject(self)else self.data.dead=true;S.owned[self]=nil;New(enemy_death_ef,1,self.x,self.y)end end
function Actor:del()S.owned[self]=nil end
local specs={};local map={}
for _,s in ipairs(NinaCoreSpecs)do map[s.id]=s;s.runtime=NinaCoreRuntime end
for _,s in ipairs(Nina10Specs)do map[s.id]=s;s.runtime=Nina10Runtime end
for _,s in pairs(Nina08Specs)do map[s.id]=s;s.runtime=Nina08Runtime end
map.non2.name='';map.non4.name='';map.spell2.name='开海「摩西之奇迹」';map.spell3.name='吗哪「五谷丰穰米之浴」';map.final.name='醇符「七色的益达」';map.kanako.name='「信仰之山」'
for _,id in ipairs({'non1','spell1','non2','spell2','non3','spell3','non4','spell4','final','kanako'})do specs[#specs+1]=assert(map[id])end
NinaSpecs=specs
local function bind(r)
 -- Source firing sounds: original se_tan00 / se_lazer00, one per emission tick.
 local shotTick,laserTick=-1,-1
 r.onShot=function(b)
  if b.laser then
   if r.tick~=laserTick then laserTick=r.tick;PlaySound('nina.se.lazer00',.35,pan(b.x))end
  elseif r.tick~=shotTick then shotTick=r.tick;PlaySound('nina.se.tan00',.32,pan(b.x))end
  S.shots=(S.shots or 0)+1;if b.laser and b.laser.straight then New(Straight,b)elseif b.laser then New(Curve,b)else New(Shot,b,r)end
 end
 r.onActor=function(a)if a~=r.boss then New(Actor,a,r)end end
end
local function card(spec)
 local c=boss.card.New(spec.name,0,0,spec.frames/60,spec.hp,{0,0,0},spec.name~='')
 c.init=function(o)
  if spec.id=='spell2'then o.is_final=false end
  NinaScenery.setPhase(spec.id=='kanako'and'kanako'or(spec.name~=''and'spell'or'normal'))
  clean();S.runtime=spec.runtime;S.current=spec.id;S.spec=spec;S.shots=0;S.damaged=false;S.colorDown=false;local r=S.runtime;bind(r);r.start(spec,tonumber(setting.nina_seed)or 20261104)
  if S.lastPos then r.boss.x,r.boss.y=S.lastPos.x,S.lastPos.y;if spec.id=='non2' then r.continuousEntry=true end end
  if spec.id=='non2'or spec.id=='spell2'then
   if not S.suwakoFlight then S.suwakoFlight=NinaSuwako03.new(S.suwakoPose,(tonumber(setting.nina_seed)or 20261104)+73)end
   New(Actor,S.suwakoFlight,r)
  end
  print('NINA PHASE '..spec.id..' hp='..spec.hp..' frames='..spec.frames)
  task.New(o,function()
   while true do
    local px,py=0,400;if IsValid(player)then px,py=player.x,224-player.y end
    r.step(px,py,o.hp);if not r.stepsHazards then r.stepHazards()end
    o.x,o.y=r.boss.x,224-r.boss.y;o.a,o.b=24,24;o.rect=true;o.dmg_factor=(r.invuln or 0)>0 and 0 or 1
    if o.hp<spec.hp then S.damaged=true end
    if r.yoshika and r.yoshika.colorDownStart then S.colorDown=true end
    if r.yoshika then S.suwakoPose={x=r.yoshika.x,y=r.yoshika.y,hp=r.yoshika.hp,age=r.yoshika.age,colorDownStart=r.yoshika.colorDownStart,colorDownAge=r.yoshika.colorDownStart and(r.tick-r.yoshika.colorDownStart)}
    elseif S.suwakoFlight and(spec.id=='non2'or spec.id=='spell2')then NinaSuwako03.step(S.suwakoFlight);S.suwakoPose=S.suwakoFlight end
    if setting.nina_test then
     if spec.id=='final'then
      if r.tick==400 then local a=r.actors[1];S.finalFrog=a;S.finalFrogHP=a.hp;S.finalFrogProbe=New(Y3Player.Shot,a.x,224-a.y,0,20000,true)end
      if r.tick==403 then if IsValid(S.finalFrogProbe)then Del(S.finalFrogProbe)end;assert(not S.finalFrog.dead and S.finalFrog.hp==S.finalFrogHP,'final familiar lost HP');print('NINA FINAL IMMORTAL PASS '..S.finalFrogHP)end
      if not S.finalBounce then for _,b in ipairs(r.hazards)do if(b.bounces or 0)>0 then S.finalBounce=true;print('NINA FINAL REBOUND PASS');break end end end
      if r.tick==750 then assert(S.finalBounce,'final rebound not observed')end
     end
     local probeTick=spec.id=='final'and 2550 or 350
     if r.tick==probeTick then S.probe=New(Y3Player.Shot,o.x,o.y,0,1,true)end
     if r.tick==probeTick+3 and IsValid(S.probe)then Del(S.probe)end
     if r.tick==400 and r.yoshika then S.suwakoProbe=New(Y3Player.Shot,r.yoshika.x,224-r.yoshika.y,0,20000,true)end
     if r.tick==403 and IsValid(S.suwakoProbe)then Del(S.suwakoProbe)end
     if setting.nina_probe=='suwako'and S.suwakoFlight then
      local a=S.suwakoFlight
      if r.tick==400 then S.flightProbe=New(Y3Player.Shot,a.x,224-a.y,0,20000,true)end
      if r.tick==403 then if IsValid(S.flightProbe)then Del(S.flightProbe)end;assert(a.down,'silent Suwako did not absorb player shot');print('NINA SUWAKO SHIELD DOWN')end
      if r.tick==660 then assert(not a.down and a.hp==4000,'silent Suwako revival failed');print('NINA SUWAKO REVIVAL PASS')end
      if r.tick==700 and IsValid(player)then
       S.savedPlayer={x=player.x,y=player.y};local cls=player.class;local old,oldIndex=cls.colli,cls[5];S.suwakoContacts=0
       cls.colli=function(p,other)if other and other.data==a then S.suwakoContacts=S.suwakoContacts+1 end;return old(p,other)end;cls[5]=cls.colli
       S.restoreContact=function()cls.colli=old;cls[5]=oldIndex end;player.x,player.y=a.x,224-a.y
      end
      if r.tick==703 then
       if S.savedPlayer then player.x,player.y=S.savedPlayer.x,S.savedPlayer.y end
       if S.restoreContact then S.restoreContact();S.restoreContact=nil end
       assert(S.suwakoContacts>0,'Suwako body contact missing');print('NINA SUWAKO CONTACT PASS '..S.suwakoContacts)
      end
     end
     if r.tick>=(tonumber(setting.nina_test_frames)or 700)then
      if r.tick>=600 then assert(S.damaged,'Boss shot collision failed');assert(S.shots>0,'no source shots');if r.yoshika then assert(S.colorDown,'Suwako down/color trigger missing')end end
      print('NINA NATIVE PASS '..spec.id..' tick='..r.tick..' shots='..S.shots..' damaged='..tostring(S.damaged));o.hp=0;return
     end
    end
    task.Wait(1)
   end
  end)
 end
 c.del=function()if S.restoreContact then S.restoreContact();S.restoreContact=nil end;S.lastPos={x=S.runtime.boss.x,y=S.runtime.boss.y};clean();print('NINA CLEANUP '..spec.id)end
 return c
end
local EscapeFrog=Class(object)
function EscapeFrog:init(x,y,angle,aimed)
 self.x,self.y=x,224-y;self.vx,self.vy=3.2*math.cos(angle),-3.2*math.sin(angle)
 self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY_BULLET;self.bound=false;self.colli=true;self.a,self.b=8,8;self.rect=false
 self.aimed=aimed;self.angle=angle;own(self);S.escapeCount=(S.escapeCount or 0)+1
end
function EscapeFrog:frame()
 if self.x< -224 or self.x>224 or self.y< -256 or self.y>256 then Del(self)end
end
function EscapeFrog:render()body({x=self.x,y=224-self.y,age=self.timer},'frog')end
function EscapeFrog:del()S.owned[self]=nil;S.escapeCount=S.escapeCount-1 end
function EscapeFrog:kill()PreserveObject(self)end
local function frogTransition()
 local c=boss.move.New(0,128,1,0)
 c.init=function(o)
  S.current='frog-escape';S.escapeCount=0;S.transitionAge=0
  local a=S.suwakoPose or{x=80,y=112};S.suwakoPose=nil
  S.suwakoFlight=nil
  New(enemy_death_ef,1,a.x,224-a.y);PlaySound('enep00',.5)
  local px,py=0,400;if IsValid(player)then px,py=player.x,224-player.y end
  local random=NinaCorePool.rng((tonumber(setting.nina_seed)or 20261104)+math.floor(px*7+py*13))
  local angles,aim=NinaFix02.frogAngles(a.x,a.y,px,py,random)
  for i,v in ipairs(angles)do local f=New(EscapeFrog,a.x,a.y,v,i==1);if i==1 then S.aimedFrog=f end end
  print('NINA FROGS 7 collidable=7 aimed=1 avoid=6 aim='..aim)
  task.New(o,function()
   local saved,old,oldIndex,cls;S.frogContacts=0
   if setting.nina_test and IsValid(player)then
    cls=player.class;old=cls.colli;oldIndex=cls[5]
    cls.colli=function(p,other)if other and other.aimed~=nil then S.frogContacts=S.frogContacts+1 end;return old(p,other)end
    cls[5]=cls.colli;S.restoreFrogCollision=function()cls.colli=old;cls[5]=oldIndex end
   end
   while S.escapeCount>0 do
    if setting.nina_test and IsValid(player)then
     if S.transitionAge==30 and IsValid(S.aimedFrog)then saved={x=player.x,y=player.y};player.x,player.y=S.aimedFrog.x,S.aimedFrog.y
     elseif S.transitionAge==33 and saved then player.x,player.y=saved.x,saved.y end
    end
    task.Wait(1)
   end
   if S.restoreFrogCollision then S.restoreFrogCollision();S.restoreFrogCollision=nil;assert(S.frogContacts>0,'frog player collision callback missing');print('NINA FROGS CONTACT PASS '..S.frogContacts)end
   print('NINA FROGS EXIT 7');Kill(o)
  end)
 end
 c.del=function()if S.restoreFrogCollision then S.restoreFrogCollision();S.restoreFrogCollision=nil end;clean()end
 c.frame=function(o)S.transitionAge=(S.transitionAge or 0)+1 end
 return c
end
local Boss=Class(boss)
function Boss:init(list,kanako)
 local cards={};for _,s in ipairs(list)do cards[#cards+1]=card(s);if s.id=='spell2'then cards[#cards+1]=frogTransition()end end
 self.kanako=kanako;boss.init(self,0,128,kanako and 'Yasaka Kanako'or'Watari Nina',cards,nil,'Normal');self.bound=false
 if cards[#cards]and not cards[#cards].is_combat then self.last_card=#cards;self.is_final=false end
end
function Boss:frame()
 boss.frame(self)
 -- The host computes dmg_factor after card tasks. Reapply MBoss's source
 -- entry protection here so sustained fire cannot erase non2 before it fires.
 if S.current=='non2'and not self.__is_waiting and(S.runtime.invuln or 0)>0 then self.dmg_factor=0 end
end
function Boss:render()
 self._bosssys:render();if S.runtime and S.runtime.boss then body(S.runtime.boss,self.kanako and'kanako'or'nina')end
end
local Arrival=Class(object)
function Arrival:init()self.layer=LAYER_ENEMY;self.group=GROUP_GHOST;self.bound=false;self.colli=false end
function Arrival:render()body({x=0,y=-64+192*math.min(1,self.timer/90),age=self.timer},'kanako')end
function Arrival:frame()
 if setting.nina_test and(self.timer==30 or self.timer==60)then local p='userdata/snapshot/nina-arrival-'..self.timer..'.jpg';lstg.Snapshot(p);print('NINA SNAPSHOT '..p)end
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Nina Six@Normal',nil,true)
stage.group.DefStageFunc('Nina Six@Normal','init',function(s)
 NinaRoad17.clean();S.lastPos=nil;S.finished=false;S.suwakoFlight=nil;S.finalBounce=nil;S.suwakoPose={x=80,y=112,age=0}
 stage.group.initTask(s,function()
  local list={};local selection=setting.nina_phase or'all'
  local withRoad=selection=='all'or selection=='road'or(setting.nina_test and setting.nina_road_probe)
  if withRoad then
   S.current='road';NinaRoad17.run(s)
   if selection=='road'then
    S.current=nil;S.finished=true;print('NINA COMPLETE');stage.group.FinishStage();return
   end
   S.current='road-wait';task.Wait(120)
   assert(s.timer-NinaRoad17.endFrame==120,'road-to-intro wait must be120 frames')
   print('NINA ROAD WAIT120 stageframe='..s.timer)
  end
  musicStart();NinaScenery.phase='normal';New(NinaScenery.Object,withRoad and TH11S6Background.current or nil)
  if not withRoad then task.Wait(60)end
  if selection=='boss'then selection='all'end
  S.onNinaArrival=NinaRoad17.arrived
  for _,spec in ipairs(specs)do if spec.id~='kanako'and(selection=='all'or selection==spec.id)then list[#list+1]=spec end end
  if #list>0 and list[1].id=='non1'then NinaIntro12.run(S,body)end
  if #list>0 then local b=New(Boss,list,false);while IsValid(b)do if(setting.nina_invincible or setting.nina_test)and IsValid(player)then player.protect=1000 end;task.Wait(1)end end
  if selection=='all'or selection=='kanako'then
   clean();S.current='arrival';S.lastPos=nil;task.Wait(240)
   NinaScenery.arrival(120);local a=New(Arrival);task.Wait(90);Del(a);print('NINA KANAKO ARRIVAL 240+90');local b=New(Boss,{map.kanako},true)
   while IsValid(b)do if(setting.nina_invincible or setting.nina_test)and IsValid(player)then player.protect=1000 end;task.Wait(1)end
  end
  clean();musicStop();task.Wait(90);S.finished=true;print('NINA COMPLETE');if setting.nina_test then stage.QuitGame()else stage.group.FinishStage()end
 end)
end)
stage.group.DefStageFunc('Nina Six@Normal','del',function(s)clean();musicStop();NinaRoad17.clean()end)
stage_init.frame=function(s)if s.timer==30 then lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal')end end
if setting.nina_test then
 local frame=FrameFunc;FrameFunc=function()local ok,v=xpcall(frame,debug.traceback);if not ok then print('NINA ERROR '..tostring(v));stage.QuitGame()end;return v end
 local render=RenderFunc;local captured={};RenderFunc=function()
  local ok,v=xpcall(render,debug.traceback);if not ok then print('NINA RENDER ERROR '..tostring(v));stage.QuitGame();return end
  if S.current=='road-wait'and NinaRoad17.endFrame then
   local t=stage.current_stage.timer-NinaRoad17.endFrame
   for _,n in ipairs({30,90})do local key='road-exit-'..n;if t>=n and not captured[key]then captured[key]=true;local p='userdata/snapshot/nina-'..key..'.jpg';lstg.Snapshot(p);print('NINA SNAPSHOT '..p)end end
  end
  local h=NinaScenery.host
  if h and IsValid(h)and h.fade==60 then
   local key='bg-fade-'..NinaScenery.phase..'-60'
   if not captured[key]then captured[key]=true;local p='userdata/snapshot/nina-'..key..'.jpg';lstg.Snapshot(p);print('NINA SNAPSHOT '..p)end
  end
  if S.current=='intro'and S.intro then
   local t=S.intro.timer;for _,n in ipairs({60,160,260,305,315,350,465})do local key='intro-'..n;if t>=n and not captured[key]then captured[key]=true;local p='userdata/snapshot/nina-'..key..'.jpg';lstg.Snapshot(p);print('NINA SNAPSHOT '..p)end end
  end
  if S.current and S.runtime then local t=S.current=='frog-escape'and S.transitionAge or S.runtime.tick or 0;for _,n in ipairs(S.current=='frog-escape'and{10,40,80}or{320,480})do local key=S.current..'-'..n;if t>=n and not captured[key]then captured[key]=true;local p='userdata/snapshot/nina-'..key..'.jpg';lstg.Snapshot(p);print('NINA SNAPSHOT '..p)end end end
 end
end

