-- Verified TH12 v1.00b semantics; original and tuned profiles share this implementation.
local P=dofile('mod/Stage12Normal/stage1/anchor-pattern.lua')
local profile=P.profile(setting.stage12_anchor_original==true)
LoadTexture('stage12.anchor','art/anchor/anchor.png');LoadImage('stage12.anchor','stage12.anchor',0,0,128,128)
for i=0,3 do
 local n='stage12.anchor.medium'..i;LoadTexture(n,'art/anchor/medium-'..i..'.png');LoadImage(n,n,0,0,30,30,3,3)
end
for _,v in ipairs({{'drop',16,2},{'small',16,3},{'birth',30,0}})do
 local n='stage12.anchor.'..v[1];LoadTexture(n,'art/anchor/impact-'..v[1]..'.png');LoadImage(n,n,0,0,v[2],v[2],v[3],v[3])
end
local A={owned={},stats={},candidate=0,profile=profile}
local function track(o) A.owned[o]=true;th14.track(o);o.th14_bullet=true end
local function forget(o) A.owned[o]=nil;th14.owned[o]=nil end
local function clean() for o in pairs(A.owned) do if IsValid(o) then Del(o) end end;A.owned={} end
local Medium=Class(bullet)
function Medium:init(x,y,angle,speed,accel,burst)
 bullet.init(self,ball_mid,COLOR_BLUE,false,true);bullet.skip_fade_in(self)
 self.x,self.y,self.angle,self.initial,self.accel=x-4*speed*cos(angle),y-4*speed*sin(angle),angle,speed,accel
 self.colli=false
 self.burst,self.age,self.bound=burst,0,false;self.rect=true;self.a,self.b=burst and 2 or 3,burst and 2 or 3
 track(self)
 if burst then A.stats.burst=A.stats.burst+1 else A.stats.medium=A.stats.medium+1 end
end
function Medium:frame()
 local active_age=self.age-15
 self.colli=self.age>=8
 if active_age<0 then self.speed=self.initial*0.5
 else
  self.speed=self.burst and P.impact_speed(self.initial,active_age,profile) or P.medium_speed(self.initial,self.accel,active_age)
  if active_age==0 then self.speed=self.speed+self.initial*0.5 end
 end
 self.vx,self.vy=self.speed*cos(self.angle),self.speed*sin(self.angle)
 if self.burst and active_age==60 then self.a,self.b=3,3 end
 self.age=self.age+1
 local w,h=30,30
 if self.burst then w,h=16,16 end
 if self.age>10 and P.outside(self.x,self.y,w,h) then Del(self) end
end
function Medium:render()
 local n
 if self.burst then n=self.age<15 and 'stage12.anchor.birth' or (self.age<=75 and 'stage12.anchor.drop' or 'stage12.anchor.small')
 else n='stage12.anchor.medium'..(math.floor(math.max(self.age-15,0)/3)%4) end
 local alpha=math.min(self.age/15,1);local scale=self.age<15 and (self.burst and 0.5+2.5*(1-self.age/15)^4 or 1+4*(1-self.age/15)^2) or 1
 SetImageState(n,'mul+add',Color(math.floor(255*alpha),255,255,255));Render(n,self.x,self.y,self.burst and self.age>=15 and self.age<=75 and self.angle or 0,scale,scale)
end
function Medium:del() forget(self);bullet.del(self) end
function Medium:kill() forget(self);bullet.kill(self) end
local function emit_medium(x,y,v)
 local i=A.candidate;A.candidate=i+1;A.stats.candidates=A.stats.candidates+1
 if P.keep(i,profile) then New(Medium,x,y,v.angle,v.speed,v.accel,false) end
end
local Anchor=Class(object)
function Anchor:init(owner,angle)
 self.x,self.y=owner.x,owner.y;self.owner,self.angle=owner,angle
 self.group,self.layer,self.bound,self.colli=GROUP_ENEMY,LAYER_ENEMY_BULLET,false,true
 self.a,self.b,self.rect=48,48,true;self.age,self.state=0,'outbound';self.rot=0;self.render_angle=angle
 track(self);A.stats.anchors=A.stats.anchors+1;A.stats.launch_ticks[#A.stats.launch_ticks+1]=A.tick
 print('ANCHOR LAUNCH tick='..A.tick..' angle='..angle)
end
local function impact(o)
 o.vx,o.vy=0,0;o.state,o.clock='hold',0;o.edge_x,o.edge_y=o.x,o.y
 o.return_x,o.return_y=o.x,o.y;o.return_speed=0;o.return_age=0
 if not profile.return_visible then o.colli=false end
 A.stats.impacts=A.stats.impacts+1;A.lastHit={x=o.x,y=o.y}
 for i=1,(profile.original and 10 or 3) do
  local speed=th14.rand(0.5,2)
  local offset=th14.rand(-math.pi,math.pi)/1.5*180/math.pi;local radius=th14.rand(0,32)
  local angle=o.angle+180+th14.rand(-math.pi,math.pi)/1.3*180/math.pi
  local x,y=o.x+radius*cos(o.angle+180+offset),o.y+radius*sin(o.angle+180+offset)
  if not profile.original then y=math.max(-184,y-40) end
  New(Medium,x,y,angle,speed,0,true)
 end
 PlaySound('tan00',0.3);print('ANCHOR IMPACT tick='..A.tick)
end
function Anchor:frame()
 if self.state=='outbound' then
  if P.hit(self.x,self.y) then impact(self);return end
  if self.age%P.interval==0 then
   local x,y=self.x-32*cos(self.angle),self.y-32*sin(self.angle)
   for _,v in ipairs(P.trail(self.angle,self.age,profile)) do emit_medium(x,y,v) end
  end
  local speed=P.speed(self.age,profile);local nx,ny=self.x+speed*cos(self.angle),self.y+speed*sin(self.angle)
  if not profile.original then
   local e=P.edges;local u=1;local dx,dy=nx-self.x,ny-self.y
   if dx>0 then u=math.min(u,(e.r-self.x)/dx)elseif dx<0 then u=math.min(u,(e.l-self.x)/dx)end
   if dy>0 then u=math.min(u,(e.t-self.y)/dy)elseif dy<0 then u=math.min(u,(e.b-self.y)/dy)end
   nx,ny=self.x+dx*u,self.y+dy*u
  end
  self.vx,self.vy=nx-self.x,ny-self.y;self.age=self.age+1;return
 end
 self.clock=self.clock+1
 if not profile.return_visible then
  self.vx,self.vy=0,0
  assert(math.abs(self.x-self.edge_x)<1e-4 and math.abs(self.y-self.edge_y)<1e-4,'visible anchor returned')
  if self.clock>=P.fade_frames and not self.hide then self.hide=true;A.stats.faded=A.stats.faded+1 end
 end
 if self.state=='hold' then
  if profile.return_visible then self.render_angle=Angle(self,self.owner)+180 end
  if self.clock>=40 then self.state='return' end
 elseif self.state=='return' then
  local dx,dy=self.owner.x-self.return_x,self.owner.y-self.return_y
  local d=math.sqrt(dx*dx+dy*dy)
  if d<=32 then self.state='finish';self.finish_age=0;self.vx,self.vy=0,0
  else
   local sx,sy=dx/d*self.return_speed,dy/d*self.return_speed
   self.return_x,self.return_y=self.return_x+sx,self.return_y+sy
   self.return_speed=self.return_speed+0.09*profile.speed_scale
   if profile.return_visible then self.vx,self.vy=sx,sy;self.render_angle=math.atan2(dy,dx)*180/math.pi+180 end
  end
 elseif self.state=='finish' then
  self.finish_age=self.finish_age+1
  if self.finish_age>=20 then A.stats.completed=A.stats.completed+1;Del(self) end
 end
end
function Anchor:render()
 if self.hide then return end
 local alpha=not profile.return_visible and self.state~='outbound' and math.max(0,1-self.clock/P.fade_frames) or 1
 SetImageState('stage12.anchor','',Color(math.floor(255*alpha),255,255,255))
 local u=math.min(self.age/15,1);local sx=3-2*u;local sy=self.age<15 and 0.02+0.08*u or math.min(1,0.1+0.9*(self.age-15)/15)
 if profile.original and self.state=='finish' then sx,sy=math.max(0,1-self.finish_age/15),math.max(0,1-self.finish_age/15) end
 Render('stage12.anchor',self.x,self.y,self.render_angle,sx,sy)
end
function Anchor:del() forget(self) end
function Anchor:kill() forget(self) end
Stage1Anchor={Anchor=Anchor,Medium=Medium,pattern=P,state=A,clean=clean}
local function move(o)
 local angle=P.move_angle(o.x,224-o.y,player.x,th14.rand(-math.pi,math.pi),th14.randint(0,65535)%3)
 o.anchorMoveToken=(o.anchorMoveToken or 0)+1;local token=o.anchorMoveToken
 task.New(o,function()
  for i=0,199 do
   if token~=o.anchorMoveToken then return end
   local speed=1.5*(1-i/200)^2
   o.x=math.max(-140,math.min(140,o.x+speed*cos(angle)));o.y=math.max(32,math.min(160,o.y+speed*sin(angle)))
   task.Wait(1)
  end
 end)
end
function Stage1Anchor.card()
 local c=boss.card.New('倾覆「同路人之锚」',1,2,25,540,{5,5,0},false)
 c.init=function(o)
  th14.clean_bullets();th14.clean_actors();clean();A.candidate=0;A.lastHit=nil;A.tick=0
  A.stats={anchors=0,impacts=0,faded=0,completed=0,medium=0,burst=0,candidates=0,peak=0,launch_ticks={}}
  th14.stats.phases=th14.stats.phases+1;th14.label=profile.original and 'Companion Anchor / ORIGINAL' or 'Companion Anchor';o.th14_phase='scale'
  print('TH14 PHASE START scale frame='..th14.stage_frames..' original='..tostring(profile.original))
  task.New(o,function()for t=0,1499 do A.tick=t;if setting.stage12_anchor_test then local n=0;for b in pairs(A.owned)do if IsValid(b)then n=n+1 end end;A.stats.peak=math.max(A.stats.peak,n) end;task.Wait(1)end end)
  task.New(o,function()
   th14.pos(o,0,144,60,4);task.Wait(60)
   while true do
    local a=New(Anchor,o,th14.aim(o));task.Wait(120);move(o)
    while IsValid(a)do task.Wait(1)end
   end
  end)
 end
 c.del=function(o)
  clean();th14.clean_bullets();th14.clean_actors();th14.stats.ended=th14.stats.ended+1
  print('TH14 PHASE END scale frame='..th14.stage_frames..' anchors='..A.stats.anchors..' impacts='..A.stats.impacts..' faded='..A.stats.faded..' candidates='..A.stats.candidates..' medium='..A.stats.medium..' burst='..A.stats.burst..' peak_owned='..A.stats.peak)
  if setting.stage12_anchor_test then setting.stage12_kill=true end
 end
 return c
end
if setting.stage12_anchor_test then
 local render=RenderFunc;local seen={}
 RenderFunc=function()
  render()
  for _,t in ipairs({240,600,1200,1800,2300})do
   if A.tick and A.tick>=t and not seen[t] and th14.label and th14.label:find('Companion Anchor') then
    seen[t]=true;local mode=profile.original and 'original' or 'tuned';lstg.Snapshot('userdata/snapshot/anchor-'..mode..'-'..t..'.jpg')
   end
  end
 end
end
