local R=Zuu4R
local S={owned={},ended=0,current=nil}
Zuu4Stage=S
local prefix='stages/zuu4/'
Include(prefix..'art.lua');Include(prefix..'runtime.lua')
-- runtime.lua owns the sole encounter scheduler.
R=Zuu4R
Include(prefix..'patterns.lua');Include(prefix..'horou.lua');Include(prefix..'horou-spells.lua');Include(prefix..'th20.lua')
for _,name in ipairs({'bullet00','wing','zuu','bird','wings','nuclear'})do LoadTexture('zuu4.'..name,prefix..'art/'..name..'.png')end
for id,a in pairs(Zuu4Art.shots)do
 local rect=a.rect;a.image='zuu4.shot'..id
 LoadImage(a.image,'zuu4.'..a.texture,rect[1],rect[2],rect[3]-rect[1],rect[4]-rect[2])
 for i,f in ipairs(a.frames)do local r=f.rect;f.image=a.image..'.'..i;LoadImage(f.image,'zuu4.'..a.texture,r[1],r[2],r[3]-r[1],r[4]-r[2])end
end
for row=0,15 do for col=0,7 do LoadImage('zuu4.model'..(row*10+col),'zuu4.zuu',col*118,row*128,118,128)end end
LoadImage('zuu4.wingBase','zuu4.wings',0,256,256,128);SetImageCenter('zuu4.wingBase',0,64)
LoadImage('zuu4.wingNormal','zuu4.wings',0,0,512,256);SetImageCenter('zuu4.wingNormal',0,128)
LoadImage('zuu4.wingMachineBase','zuu4.wings',512,256,128,256)
LoadImage('zuu4.wingMachine','zuu4.wings',256,256,256,64);SetImageCenter('zuu4.wingMachine',0,32)
LoadImage('zuu4.wingUdjyat','zuu4.wings',0,384,256,128)
LoadImage('zuu4.wingEye','zuu4.wings',256,384,128,128)
LoadImage('zuu4.wingPupil','zuu4.wings',384,384,128,128)
LoadImage('zuu4.wingFlyer','zuu4.wings',256,320,256,64);SetImageCenter('zuu4.wingFlyer',0,32)
LoadImage('zuu4.wingImmortal','zuu4.wings',512,0,512,256);SetImageCenter('zuu4.wingImmortal',0,128)
for i=0,6 do LoadImage('zuu4.bird'..i,'zuu4.bird',(i%4)*64,math.floor(i/4)*64,64,64)end
LoadImage('zuu4.nuclearCore','zuu4.nuclear',0,0,512,512)
LoadImage('zuu4.nuclearGlow','zuu4.nuclear',0,512,512,512)
local function own(o)S.owned[o]=true end
local function clean()
 R.clear();local list={};for o in pairs(S.owned)do list[#list+1]=o end
 for _,o in ipairs(list)do if IsValid(o)then Del(o)end end;S.owned={}
end
S.cleanup=clean
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,1,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;own(self)
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 local art=assert(Zuu4Art.shots[b.id]);self.img=art.image
 if #art.frames>0 then
  local total=0;for _,f in ipairs(art.frames)do total=total+f.duration end
  local t=b.age%total;for _,f in ipairs(art.frames)do if t<f.duration then self.img=f.image;break else t=t-f.duration end end
 end
 local offset=art.offset or {0,0};local a=b.angle+90
 local dx=offset[1]*R.cos(a)-offset[2]*R.sin(a);local dy=offset[1]*R.sin(a)+offset[2]*R.cos(a)
 self.x,self.y,self.vx,self.vy=b.x+dx-192,224-b.y-dy,0,0
 self.a,self.b,self.rect=b.radius,b.radius,false
 self.colli=b.age>=b.delay;self.heading=-b.angle-90;self.rot=0
 self.hscale,self.vscale=1,1;self._a=255
 if b.age<b.delay then local u=(b.age+1)/b.delay;self.hscale,self.vscale=4-3*u,4-3*u;self._a=u*160 end
 self._blend=(art.add or(b.addDelay and b.age<b.delay))and 'mul+add' or ''
 self.group=b.bombProof and GROUP_INDES or GROUP_ENEMY_BULLET
 if b.collidable==false then self.colli=false end
end
function Shot:render()
 local b=self.data
 if b.wingGlow and Zuu4Art.shots[896]then
  local img=Zuu4Art.shots[896].image;SetImageState(img,'mul+add',Color(128,192,192,192));Render(img,b.x-192,224-b.y,self.heading)
 end
 SetImageState(self.img,self._blend,Color(self._a,255,255,255))
 Render(self.img,b.x-192,224-b.y,self.heading,self.hscale,self.vscale)
end
function Shot:del()S.owned[self]=nil;bullet.del(self)end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
local Beam=Class(laser)
function Beam:init(b)
 laser.init(self,1,b.x-192,224-b.y,-b.angle,0,b.length,0,b.width,0,0)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;self.alpha=1;own(self)
end
function Beam:frame()
 local b=self.data;if b.dead then Del(self);return end
 local x,y=b.x,b.y
 if b.mode=='loose' then x,y=x-b.length*R.cos(b.angle),y-b.length*R.sin(b.angle)end
 self.x,self.y,self.rot=x-192,224-y,-b.angle;self.l1,self.l2,self.l3=0,b.length,0
 local u=math.max(0,math.min(1,(b.age-b.delay+1)/15));u=u*u
 self.w=b.hitWidth or b.width*(b.mode=='static' and u/2 or 0.5)
 self.alpha=1;self.colli=b.age>=b.delay and b.collidable~=false
 laser.frame(self)
end
function Beam:render()
 local b=self.data;local a=Zuu4Art.shots[b.visual or 368]
 local w=b.renderWidth or(b.age<b.delay and 2 or b.width*math.max(0,math.min(1,(b.age-b.delay+1)/15))^2)
 SetImageState(a.image,b.mode=='loose' and 'mul+add' or '',Color(b.age<b.delay and 192 or 255,255,255,255))
 local r=a.rect
 Render(a.image,self.x+self.l2*0.5*cos(self.rot),self.y+self.l2*0.5*sin(self.rot),self.rot-90,w/(r[3]-r[1]),self.l2/(r[4]-r[2]))
end
function Beam:del()S.owned[self]=nil end
function Beam:kill()self.data.dead=true;S.owned[self]=nil end
local Explosion=Class(object)
function Explosion:init(b)
 self.data=b;self.bound=false;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY_BULLET-1;self.colli=false;own(self)
end
function Explosion:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y=b.x-192,224-b.y;self.a,self.b=b.radius,b.radius;self.rect=false
 self.colli=b.kind=='nuclear';self.vx,self.vy=0,0
end
function Explosion:render()
 local b=self.data
 if b.kind=='warning' then
  local r=b.radius*R.sin(90*math.min(1,(b.age+1)/40));local alpha=b.age<30 and 100 or 100*R.sin(90*math.max(0,49-b.age)/19)
  SetImageState('zuu4.nuclearGlow','mul+add',Color(alpha,128,128,255))
  Render('zuu4.nuclearGlow',self.x,self.y,0,(r+12)/160,(r+12)/160)
 else
  local r=b.radius;if b.age<30 then r=r*R.sin(90*(b.age+1)/30)end
  local sc=(r+12)/160
  SetImageState('zuu4.nuclearCore','mul+add',Color(255,255,255,255))
  local tint=b.tint or{191,191,255};SetImageState('zuu4.nuclearGlow','mul+add',Color(192,tint[1],tint[2],tint[3]))
  Render('zuu4.nuclearCore',self.x,self.y,b.age/5,sc,sc)
  Render('zuu4.nuclearGlow',self.x,self.y,-b.age*133,sc,sc)
  Render('zuu4.nuclearGlow',self.x,self.y,b.age*133,sc*1.5,sc*1.5)
 end
end
function Explosion:del()S.owned[self]=nil end
function Explosion:kill()self.data.dead=true;S.owned[self]=nil end
local FamiliarDamage=Class(enemybase)
local Familiar=Class(FamiliarDamage)
function Familiar:init(a)
 enemybase.init(self,a.hp,a.kind=='wingHitbox');self.data=a;self.a,self.b=a.hitRadius or 16,a.hitRadius or 16;self.bound=false;self.vx,self.vy=0,0;own(self)
end
function Familiar:frame()
 local a=self.data;if a.dead then Del(self);return end
 if self.hp<=0 then a.dead=true;Kill(self);return end
 a.hp=self.hp;self.x,self.y,self.vx,self.vy=a.x-192,224-a.y,0,0
 self.colli=a.visible and a.kind~='trail';SetAttr(self,'colli',self._colli)
end
function FamiliarDamage:take_damage(dmg)
 self.hp=self.hp-dmg
 if setting.zuu4_test_shoot then S.familiarHits=(S.familiarHits or 0)+1 end
 if self.data.link>0 and S.boss and IsValid(S.boss)then S.boss.class.base.take_damage(S.boss,dmg*self.data.link)end
end
function Familiar:render()
 local a=self.data
 if a.noVisual then return end
 if a.kind=='trail' then
  for i=2,#a.points do local x,y=a.points[i][1]-192,224-a.points[i][2];local prev=a.points[i-1]
   local angle=R.atan(a.points[i][2]-prev[2],a.points[i][1]-prev[1]);local len=math.sqrt((a.points[i][1]-prev[1])^2+(a.points[i][2]-prev[2])^2)
   SetImageState(Zuu4Art.shots[347].image,'mul+add',Color(80,255,255,255));Render(Zuu4Art.shots[347].image,x,y,-angle-90,0.4,len/256)
  end
 else
  local image='zuu4.bird'..(math.floor(a.age*0.2)%7)
  local col=a.color==4 and {198,128,198}or{128,160,255};SetImageState(image,'mul+add',Color(255,col[1],col[2],col[3]))
  local u=a.age<45 and R.sin(90*(a.age+1)/45)or 1
  Render(image,self.x,self.y,-a.angle-90,u,2-u)
 end
end
function Familiar:kill()self.data.dead=true;S.owned[self]=nil end
function Familiar:del()S.owned[self]=nil end
R.onActor=function(a)New(Familiar,a)end
R.onShot=function(b)New(b.kind=='shot' and Shot or b.kind=='beam' and Beam or Explosion,b)end
local function card(id,index)
 local spec=Zuu4Specs[id]
 local c=boss.card.New(spec.name or '',0,0,spec.time,spec.hp,{0,0,0},false)
 c.frame=function(o)if spec.hold and R.tick<spec.hold then o.timer=0 end end
 c.init=function(o)
  clean();S.boss=o;S.current=id;S.index=index;S.damage=0;S.familiarHits=0
  th08s4.label=spec.name or ('Torisumi Zuu / '..id)
  R.start(id,tonumber(setting.zuu4_seed)or 20261027,o.x+192,224-o.y)
  R.setHostHP=function(hp)o.hp=hp end
  print('ZUU4 START '..id..' hp='..spec.hp..' frames='..spec.time*60)
  task.New(o,function()
   while true do
    local px,py=192,400;if IsValid(player)then px,py=player.x+192,224-player.y end
    R.step(px,py,o.hp);o.x,o.y=R.boss.x-192,224-R.boss.y
    if R.hp~=o.hp then o.hp=R.hp end
    if setting.zuu4_test then
     if IsValid(player)then player.protect=1000 end
     if id=='stone' and setting.zuu4_test_progress then
      if R.tick==240 then o.hp=7900 elseif R.tick==400 then o.hp=4900 elseif R.tick==560 then o.hp=1900 end
     end
     if R.tick>=(tonumber(setting.zuu4_test_frames)or 800)then
      if id=='stone' and setting.zuu4_test_progress then assert(R.subphase==3,'Stone Goddess progression missing')end
      o.hp=0
     end
    end
    task.Wait(1)
   end
  end)
 end
 c.del=function(o)
  if setting.zuu4_test_shoot then
   assert(S.damage>0,'player shots did not damage Zuu4 '..id)
   print('ZUU4 SHOOT '..id..' damage='..S.damage..' familiarHits='..S.familiarHits)
  end
  print('ZUU4 END '..id..' ticks='..R.tick..' bullets='..R.counts.shots..' beams='..R.counts.beams..' subphase='..R.subphase)
  S.ended=S.ended+1;clean();assert(next(S.owned)==nil,'Zuu4 object leak')
 end
 return c
end
local ZuuDamage=Class(boss)
Zuu4Boss=Class(ZuuDamage)
function Zuu4Boss:init(mode)
 local cards={};local ids=Zuu4Order
 if mode and Zuu4Specs[mode]then ids={mode}end
 for i,id in ipairs(ids)do cards[#cards+1]=card(id,i)end
 S.ended=0;boss.init(self,0,96,'Torisumi Zuu',cards,nil,'Normal');self.a,self.b=24,16
end
function ZuuDamage:take_damage(dmg)
 local id=S.current;local spec=Zuu4Specs[id]
 if spec and R.boss and R.boss.visible~=false and not(id=='non3' and R.tick<120)then
  local before=self.hp;boss.take_damage(self,dmg*spec.rate);S.damage=(S.damage or 0)+(before-self.hp)
 end
end
function Zuu4Boss:render()
 self._bosssys:render()
 local y=self.y+12+4*sin(self.ani*4)
 if R.wings then
  local t=R.tick-R.wingStart
  Render('zuu4.wingBase',self.x+8*cos(212),y-8*sin(212),-212,0.5,-0.5)
  Render('zuu4.wingNormal',self.x+16*cos(192),y-16*sin(192),-192,0.5,-0.5*(0.8+0.2*sin(t*4)))
  local bx,by=self.x+64*cos(164),y-64*sin(164)
  Render('zuu4.wingMachineBase',bx,by,-74,0.6,0.6)
  local left,right=R.horouAnchors(R.boss,t)
  for i,a in ipairs(left)do Render('zuu4.wingMachine',a.x-192,224-a.y,-a.angle,0.5,-0.4-0.2*sin((204-(i-1)*12)+math.floor(t/4)*32))end
  bx,by=self.x+48*cos(-8),y-48*sin(-8)
  Render('zuu4.wingUdjyat',bx,by,8,0.8,0.8)
  Render('zuu4.wingEye',bx,by,8,0.5,0.5);Render('zuu4.wingPupil',bx,by,8,0.25,0.25)
  for _,a in ipairs(right)do Render('zuu4.wingFlyer',a.x-192,224-a.y,-a.angle,0.3,0.3*sin(a.angle*2+360*sin(t*2)))end
  for i=0,2 do local a=8+({-16,0,16})[i+1];local d=({4,8,16})[i+1];local sc=0.5-i*0.1
   Render('zuu4.wingImmortal',self.x+d*cos(a),y-d*sin(a),-a+8*sin(t/2*5),sc,sc)
  end
 end
 local frame=math.floor(R.tick/12)%4
 if R.boss and R.boss.action=='shot1' then frame=15 end
 if not R.boss or R.boss.book~=true then frame=frame+30 end
 Render('zuu4.model'..frame,self.x,y)
 if R.tablet then local tab=R.tablet;Render('zuu4.model'..(120+math.floor(R.tick/6)%8),tab.x-192,224-tab.y,0,0.75,0.75)end
end
if setting.zuu4_test then
 if setting.zuu4_test_shoot then player_lib.debug_data.keep_shooting=true end
 local oldRender=RenderFunc;local captures={}
 RenderFunc=function()
  oldRender()
  if S.current and R.tick>=(tonumber(setting.zuu4_snapshot_frame)or 450)then
   local key=S.current..'-'..R.subphase
   if not captures[key]then captures[key]=true;local path='userdata/snapshot/zuu4-'..key..'.jpg';lstg.Snapshot(path);print('ZUU4 SNAPSHOT '..path)end
  end
 end
 local oldMenu=stage_menu.frame
 stage_menu.frame=function(s)oldMenu(s);if th08s4.finished and s.timer>=30 then stage.Set('stage.quit')end end
 if setting.zuu4_test_fast then
  local oldFrame=DoFrame;DoFrame=function(...)for i=1,4 do oldFrame(...)end end
 end
end
local oldAfter=AfterFrame
AfterFrame=function()
 oldAfter()
 if setting.zuu4_invincible and stage.current_stage and stage.current_stage.name=='Stage 4B@Normal' and IsValid(player)then player.protect=1000 end
end
