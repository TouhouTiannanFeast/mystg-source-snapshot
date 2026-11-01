-- Horou's source animation tables and wing geometry (lib_Anime / lib_HorouEffect01..04).
-- Cosmetic state has its own RNG: rendering must not consume the attack RNG.
local R=Zuu4R
local A={clock=0};R.animation=A
local sin,cos=R.sin,R.cos
local function clamp(x)return math.max(0,math.min(1,x))end
local function round(x)return math.floor(x+0.5)end
local function shadowColor(h)
 local c=64*192/255;local x=c*(1-math.abs((h/60)%2-1));local m=64-c
 local a=({{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}})[math.floor(h/60)%6+1]
 return a[1]+m,a[2]+m,a[3]+m
end
local function random(lo,hi)
 A.seed=(A.seed or 20261027)*16807%2147483647
 return lo+(hi-lo)*(A.seed-1)/2147483646
end
function R.setAction(o,kind,duration)
 o.pose={kind=kind,start=R.tick,duration=duration or 216000}
end
function R.resetAnimation(o)
 o.book=A.book~=false;A.float=A.float or 0;A.idleStart=R.tick
 A.eyes={angle=0,phase=0,age=0,returning=false,cooldown=random(30,60)}
 A.pupil={angle=0,phase=0,age=0,returning=false,cooldown=random(15,45)}
 A.blink={phase=0,age=0,cooldown=random(30,60)}
 R.wingVisual=nil
 A.shadows={}
end
local function eyeStep(e,speed,lo,hi,alo,ahi)
 local u=sin(e.phase)
 if not e.returning then
  if u<1 then e.phase=e.phase+speed
  else
   if e.age>0 and e.age>e.cooldown then e.age=0;e.returning=true;e.cooldown=random(lo,hi)end
   e.age=e.age+1
  end
 elseif u>0 then e.phase=e.phase+speed
 else
  if e.age>0 and e.age>e.cooldown then e.age=0;e.phase=0;e.returning=false;e.angle=random(alo,ahi);e.cooldown=random(lo,hi)end
  e.age=e.age+1
 end
end
function R.animateStep(o)
 A.clock=A.clock+1;A.float=math.min(6,(A.float or 0)+0.1);A.book=o.book
 if R.wings or R.wingVisual then A.wingClock=(A.wingClock or 0)+1 end
 eyeStep(A.eyes,10,30,60,-90,90);eyeStep(A.pupil,15,15,45,0,360)
 local b=A.blink
 if sin(b.phase)<1 then b.phase=b.phase+10 else
  if b.age>0 and b.age>b.cooldown then b.age=0;b.phase=0;b.cooldown=random(30,60)end
  b.age=b.age+1
 end
 if o.pose and R.tick-o.pose.start>=o.pose.duration then o.pose=nil;A.idleStart=R.tick end
 if R.tablet then
  local t=R.tablet;t.age=(t.age or 0)+1;t.anime=t.anime or 0
  if t.age<=30 and t.sx then
   local u=sin(t.age/30*90);t.x=t.sx+(t.tx-t.sx)*u;t.y=t.sy+(t.ty-t.sy)*u
  else
   t.anime=t.anime+math.min(math.max(0,t.age-30)/120,1)/6
   if t.age%6<3 then A.shadows[#A.shadows+1]={x=t.x,y=t.y,frame=math.floor(t.anime)%8,age=0,vx=random(-2,2),hue=t.age/3}end
  end
 end
 local live={}
 for _,s in ipairs(A.shadows)do
  s.age=s.age+1;local u=s.age/30;s.x=s.x+u*s.vx;s.y=s.y-1.5*u
  if s.age<30 then live[#live+1]=s end
 end
 A.shadows=live
end
function A.bodyFrame(o,t,clock)
 t=t or R.tick;clock=clock or A.clock
 local p=o.pose;local kind=p and p.kind or 'stand';local age=p and t-p.start or t-(A.idleStart or 0)
 local left=p and math.max(0,p.duration-age)or 216000;local frame
 if kind=='shot1' then
  local n=math.min(math.floor(age/6),5);if math.floor(left/6)<1 then n=6 end
  frame=({4,5,6,7,14,15,16})[n+1]
 elseif kind=='shot2' or kind=='shot3' then
  local n=math.min(math.floor(age/6),kind=='shot2' and 3 or 4);local tail=math.floor(left/6)
  if tail<(kind=='shot2' and 4 or 3)then n=7-tail end
  frame=20+(kind=='shot2' and n or 7-n)
 elseif kind=='left' or kind=='right' or kind=='move' or o.motion then
  local direction=kind
  if kind=='move' or not p then
   local dx=o.motion and o.motion.tx-o.x or 0
   direction=math.abs(dx)<0.25 and 'stand' or dx<0 and 'left' or 'right'
  end
  local n=math.min(1,math.floor(age/8),math.floor(left/8))
  frame=direction=='stand' and 0 or(direction=='left' and 12 or 10)+n
 else frame=math.floor(age/12)%4 end
 if kind~='shot2' and kind~='shot3' and o.book==false then frame=frame+30 end
 if clock%180>170 then frame=frame+60 end
 return frame
end
function A.origin(o)
 return round(o.x),round(o.y+sin(A.clock*3)*(A.float or 0))
end
local function part(list,order,image,x,y,angle,sx,sy,vertices)
 list[#list+1]={order=order,image=image,x=x,y=y,angle=angle,sx=sx,sy=sy,vertices=vertices}
end
function A.wingParts(o,frame,opening,originX,originY)
 local parts={};local x,y=originX,originY
 if not x then x,y=A.origin(o)end
 local t=frame or A.wingClock or 0;local q=math.floor(t/4)*4
 local unfold=opening and sin(math.min(90,opening*2))or 1
 local function base(angle,distance,sy)
  part(parts,31,'zuu4.wingBase',x+distance*cos(angle),y+distance*sin(angle),angle,0.5,sy*unfold)
 end
 base(212,8,-0.5);base(164,16,-0.5);base(-32,8,0.5)
 -- Eight independently deformed texture strips, not a uniformly scaled sprite.
 local flap=8*sin(-math.floor((t-1)/2)*2*3)
 local function normalVertex(i,bottom)
  return {i*64*cos((i+(bottom and 1 or 4))*flap),(bottom and 128 or -128)+(i+1)*32*sin((i+1)*flap)}
 end
 for i=0,7 do
  part(parts,35,'zuu4.normalStrip'..i,x+16*cos(192),y+16*sin(192),192,0.5,-0.5*unfold,
   {normalVertex(i,false),normalVertex(i+1,false),normalVertex(i+1,true),normalVertex(i,true)})
 end
 local bx,by=x+64*cos(164),y+64*sin(164)
 part(parts,32,'zuu4.wingMachineBase',bx,by,opening and 74+unfold*360 or 164,0.6*unfold,0.6*unfold)
 for i=0,5 do
  local a=204-i*12;local angle=a+4*sin(a*4+q*8);local d=16-i*8
  local u=opening and sin(math.min(90,math.max(0,opening-46)*2))or 1
  part(parts,31,'zuu4.wingMachine',bx+unfold*d*cos(u*angle),by+unfold*d*sin(u*angle),u*angle,0.5,-0.4-0.2*sin(a+q*8))
 end
 bx,by=x+48*cos(-8),y+48*sin(-8)
 part(parts,35,'zuu4.wingUdjyat',bx,by,-8,0.8,0.8*unfold)
 local e=A.eyes or{phase=0,angle=0};local p=A.pupil or{phase=0,angle=0};local bl=A.blink or{phase=90}
 local ex,ey=bx+sin(e.phase)*24*cos(e.angle),by+sin(e.phase)*16*sin(e.angle)
 local px,py=ex+sin(p.phase)*12*cos(p.angle),ey+sin(p.phase)*12*sin(p.angle)
 part(parts,34,'zuu4.wingEye',ex,ey,-8+(opening and unfold*360 or 0),0.5*unfold,0.5*unfold)
 local blink=sin(bl.phase)
 part(parts,34,'zuu4.wingPupil',px,py,-8+(opening and unfold*360 or 0),(0.5-0.25*blink)*unfold,0.25*blink*unfold)
 for i=0,3 do
  local a=72-i*30;local d=8*sin(a*2+t*2);local cycle=opening and math.max(0,opening-46)or t
  local phase=cycle%92;local u=sin(phase*2)
  part(parts,36,'zuu4.wingFlyer',bx+(64+d)*cos(unfold*a),by+(48+d)*sin(unfold*a),unfold*a,
   opening and 0.6-0.3*unfold or 0.3,unfold*0.3*sin(a*2+u*360))
 end
 for i=0,2 do
  local a=8+({-16,0,16})[i+1];local d=({4,8,16})[i+1];local sc=0.5-i*0.1
  local f=math.floor(t+sin(t/16+a)*32-sin(t/512+a*5)*16+sin(t*32+a*2)*1.25)/2*5
  local angle=a-8*sin(f)
  part(parts,33-i,'zuu4.wingImmortal',x+d*cos(angle),y+d*sin(angle),angle,sc,sc*unfold)
 end
 for i,p in ipairs(parts)do p.sequence=i end
 table.sort(parts,function(a,b)return a.order==b.order and a.sequence<b.sequence or a.order<b.order end)
 return parts
end
local rects={['zuu4.wingBase']={0,-64,256,64},['zuu4.wingMachine']={0,-32,256,32},
 ['zuu4.wingFlyer']={0,-32,256,32},['zuu4.wingImmortal']={0,-128,512,128},
 ['zuu4.wingMachineBase']={-64,-128,64,128},['zuu4.wingUdjyat']={-128,-64,128,64},
 ['zuu4.wingEye']={-64,-64,64,64},['zuu4.wingPupil']={-64,-64,64,64}}
function A.drawPart(p,alpha)
 local r=rects[p.image];local v=p.vertices or{{r[1],r[2]},{r[3],r[2]},{r[3],r[4]},{r[1],r[4]}}
 local out={}
 for i,z in ipairs(v)do
  -- Strip texture coordinates are local, while vertices retain source mesh X.
  local dx,dy=z[1]*p.sx,z[2]*p.sy
  out[i]={p.x+dx*cos(p.angle)-dy*sin(p.angle)-192,224-p.y-dx*sin(p.angle)-dy*cos(p.angle),0.5}
 end
 SetImageState(p.image,'',Color(alpha or 255,255,255,255))
 Render4V(p.image,unpack({out[1][1],out[1][2],out[1][3],out[2][1],out[2][2],out[2][3],out[3][1],out[3][2],out[3][3],out[4][1],out[4][2],out[4][3]}))
end
function A.render(o)
 local x,y=A.origin(o);local frame=A.bodyFrame(o);local wings={}
 if R.wings then wings=A.wingParts(o)
 elseif R.wingVisual then
  local v=R.wingVisual;local age=R.tick-v.start;local u=sin(clamp((age-60)/60)*90)
  wings=A.wingParts(o,A.wingClock,age,v.x+(o.x-v.x)*u,v.y+(o.y-v.y)*u)
 end
 -- Source wing priorities31..36 precede the boss body at priority41.
 for _,p in ipairs(wings)do A.drawPart(p)end
 for _,s in ipairs(A.shadows or{})do
  local u=s.age/30;local image='zuu4.model'..(120+s.frame)
  local r,g,b=shadowColor(s.hue)
  SetImageState(image,'mul+add',Color((1-u)*255,r,g,b));Render(image,s.x-192,224-s.y,0,1+u*1.5,1+u*1.5)
 end
 Render('zuu4.model'..frame,x-192,224-y+6)
 if R.tablet then
  local tab=R.tablet;local u=1-cos(clamp((tab.age or 0)/30)*90)
  local sx,sy=0.75*(3-u*2),0.75*u
  local image='zuu4.model'..(120+math.floor(tab.anime or 0)%8)
  SetImageState(image,'',Color(255,255,255,255));Render(image,round(tab.x)-192,224-round(tab.y),0,sx,sy)
 end
end
function A.detach(o)
 local pieces=A.wingParts(o)
 for _,p in ipairs(pieces)do p.wait=random(0,60);p.accel=random(0.5,1);p.exitAngle=random(58,122);p.speed=0;p.initialY=p.sy end
 return pieces
end
function A.fadeStep(parts,t)
 for _,p in ipairs(parts)do
  local age=t-p.wait
  p.active=age>=0 and age<90
  if age>=0 and age<90 then
   p.x=p.x+p.speed*cos(p.exitAngle);p.y=p.y+p.speed*sin(p.exitAngle);p.speed=p.speed+p.accel
   p.sy=p.initialY*(1-sin(age))
  end
 end
end
