-- HSoB stage6 BOSS_ID_HOROU. Normal attack files06b; no Siran routines.
local R,P=Zuu4R,Zuu4Patterns
local sin,cos,atan=R.sin,R.cos,R.atan
local wait,spawn=R.wait,R.spawn
local colors={0,6,3,1,5,2,4,7}
local function rot(x,y,a)return x*cos(a)-y*sin(a),x*sin(a)+y*cos(a)end
R.enableWings=function(o)
 R.wings=true
 if R.wingColliders then return end
 R.wingStart=R.tick;R.wingColliders=true
 for _,x in ipairs({-96,96})do
  local a=R.actor(o.x+x,o.y,'wingHitbox',999999,1,48)
  a.follow=true;a.ox,a.oy=x,0;a.noVisual=true
 end
end
local function standby(o,x,y,n,stopTimer)
 o.visible=false;R.weightMove(o,x,y,10,4,0.1,12)
 spawn(function()wait(n);o.visible=true end)
end
local function moveRandom(o,distance)
 -- HSoB EnemyRandomMove envelope, with source distance range.
 local angle=R.rand(-180,180);local dist=R.rand(distance/2,distance)
 local x=math.max(48,math.min(336,o.x+dist*cos(angle)))
 local y=math.max(124,math.min(196,o.y+dist*sin(angle)))
 R.weightMove(o,x,y,15,4,0.1,12)
 if R.setAction then R.setAction(o,'move',160)end
end
R.horouAnchors=function(o,frame)
 local left,right={},{}
 local y=o.y-12+4*sin(frame*4)
 local bx,by=o.x+64*cos(164),y+64*sin(164)
 local step=math.floor(frame/4)*4
 for i=0,5 do local base=204-i*12;local a=base+4*sin(base*4+step*8);local d=16-i*8
  left[i+1]={x=bx+d*cos(a),y=by+d*sin(a),angle=a}
 end
 bx,by=o.x+48*cos(-8),y+48*sin(-8)
 for i=0,3 do local a=72-i*30;local d=8*sin(a*2+frame*2)
  right[i+1]={x=bx+(64+d)*cos(a),y=by+(48+d)*sin(a),angle=a}
 end
 return left,right
end
local function wing(x,y,speed,angle,id,delay,timer,arc,radius,offset)
 local b=R.shot(x,y,0,angle,id,delay);b.wingGlow=true;b.scriptedPosition=true
 b.update=function(s)
  local t=s.age
  if t<timer then
   local d=sin((t+1)/timer*90);local a=(1-cos((t+1)/timer*180))/2
   local r=d*radius;local heading=angle+arc*a
   s.x,s.y=x+r*cos(heading),y+r*sin(heading);s.angle=heading+offset*d
  else s.scriptedPosition=false;s.accel=speed/120;s.limit=speed;s.update=nil end
 end
 return b
end
local function wingWay(x,y,speed,angle,id,delay,timer,way,spread,radius,offsetRate)
 for i=0,way-1 do local arc=(i-(way-1)/2)*spread
  wing(x,y,speed,angle,id,delay,timer,arc,(0.25+0.75*(i+1)/way)*radius,arc*(offsetRate or 0.5))
 end
end
local function delayedPair(x,y,angle,speed,spread,delay,id)
 spawn(function()
  wait(delay)
  for i=0,1 do R.shot(x,y,0,angle+(i-0.5)*spread,id,30,speed/240,speed)end
 end)
end
local function curve(x,y,speed,angle,length,width,id,delay)
 local b={x=x,y=y,angle=angle,speed=speed,accel=0,age=0,kind='driver',radius=0,segments=0,visual=id}
 R.hazards[#R.hazards+1]=b
 b.afterMove=function(s)
  local dx,dy=s.x-x,s.y-y;local distance=math.sqrt(dx*dx+dy*dy)
  if s.x>=-16 and s.x<=400 and s.y>=-16 and s.y<=464 then
   local beam=R.beam(s.x-dx*2,s.y-dy*2,atan(dy,dx),distance*4,width,delay,delay+length,'curve',0)
   beam.visual=id;beam.noCull=true
   beam.update=function(q)
    if q.age<delay then q.renderWidth=(q.age%6+1)*0.75;q.collidable=false
    else
     local t=q.age-delay;q.renderWidth=width*(1-(t+1)/length);q.hitWidth=q.renderWidth/3
     q.collidable=t<=math.max(5,length-5)
    end
   end
   s.segments=s.segments+1
  end
  x,y=s.x,s.y
 end
 return b
end
local function homing(b,power,peak,timer)
 local t=b.age;if t>=timer then return end
 local h=power*(t<peak and (t+1)/peak or (timer-t)/(timer-peak))
 local d=(R.aim(b)-b.angle+180)%360-180;b.angle=b.angle+math.max(-h,math.min(h,d))
end
local function laserA1(x,y,a,color,offset)
 local vx,vy=rot(16*cos(a)/2,16*sin(a),offset);local initial=math.sqrt(vx*vx+vy*vy)
 local b=curve(x,y,initial/2,atan(vy,vx),20,24,265+color,60)
 b.accel,b.limit=-initial/60,initial/4
 R.accelerate(b,30,16/30,16)
 b.update=function(s)homing(s,6,60,75)end
 spawn(function()
  wait(45)
  for t=0,4 do if b.dead then return end;delayedPair(b.x,b.y,b.angle,1.5*(1-t*0.05),45+(5-t+1)*8,60,377+color);wait(1)end
 end)
end
local function laserA2(anchor)
 local b=curve(anchor.x,anchor.y,6,anchor.angle,20,24,265,60);b.accel,b.limit=-6/30,0
 spawn(function()
  wait(30);if b.dead then return end;b.angle=R.aim(b);b.accel,b.limit=16/30,16;wait(1)
  for t=0,4 do if b.dead then return end;delayedPair(b.x,b.y,b.angle,1.5*(1+t*0.1),5+(5-t+1)*5,60,377);wait(2)end
 end)
end
local function wingNon1(o,dir)
 spawn(function()
  local angle=sin(R.aim(o))<0 and 270 or 90
  for i=0,6 do
   local a=angle+45*dir;local x=o.x+64*cos(a)-16*cos(angle);local y=o.y+64*sin(a)-16*sin(angle)
   wingWay(x,y,2,a,545+colors[i+1],30,60+i*5,15-i,(135-i*5)/(15-i)*dir,160-i*10,0.5)
   wait(10)
  end
 end)
end
local function wingNon2(o)
 spawn(function()
  local angle=R.aim(o);local dir=1
  for i=0,8 do
   for side=1,2 do local a=angle+90*dir
    wingWay(o.x+32*cos(a),o.y+32*sin(a),2,a,545,30,60+i*5,15-i,(135-i*5)/(15-i)*dir,160-i*10,1)
    dir=-dir
   end
   wait(10)
  end
 end)
end
P.non1=function(o)
 o.book=true;standby(o,192,160,300,true);wait(1)
 if R.setAction then R.setAction(o,'shot2',90)end
 spawn(function()
  wait(90);R.tablet={x=o.x-24,y=o.y-58,sx=o.x-24,sy=o.y-58,tx=o.x,ty=o.y-96,age=0}
  wait(1);o.book=false
 end)
 wait(150)
 local function lasers()
  spawn(function()
   for i=0,6 do
    local tablet=R.tablet or {x=o.x,y=o.y-96};local offset=R.aim(tablet)
    for _,dir in ipairs({1,-1})do laserA1(tablet.x,tablet.y,180+(i+0.5)*180/7*dir,colors[i+1],offset)end
    wait(3)
   end
  end)
 end
 lasers();wait(120);local count=0;local dir=R.random()<0.5 and -1 or 1;local interval=150
 while true do
  for i=0,2 do
   if count%2==1 then moveRandom(o,48)end;wingNon1(o,dir);dir=-dir;count=count+1;wait(interval)
   if R.py<o.y+48 then break end
  end
  lasers();interval=(interval-120)*0.8+120
 end
end
P.non2=function(o)
 o.book=false;standby(o,192,224,360,true);wait(60)
 -- A02_OpeningMotion:90+60+30+90, while the source scene timer is stopped.
 o.book=true;R.tablet=nil;if R.setAction then R.setAction(o,'shot3',60)end
 spawn(function()
  wait(150);R.wingVisual={x=o.x,y=o.y-96,start=R.tick}
  wait(30);if R.setAction then R.setAction(o,'shot1',120)end
 end)
 wait(270);R.tablet=nil;R.enableWings(o)
 R.wingVisual=nil
 if R.setAction then R.setAction(o,'left',90)end
 R.move(o,192,140,90,'linear');wingNon2(o);wait(180);local count=0;local dir=1
 while true do
  if count%2==1 then moveRandom(o,24)end
  wingNon2(o);wait(60)
  local sign=dir
  spawn(function()
   local n=sign>0 and 4 or 6
   for i=1,n do
    local left,right=R.horouAnchors(o,R.tick-R.wingStart);local a=(sign>0 and right or left)[i]
    if sign<0 then a={x=a.x+48*cos(a.angle),y=a.y+48*sin(a.angle),angle=a.angle}end
    laserA2(a);wait(5)
   end
  end)
  wait(120);dir=-dir;count=count+1
 end
end
P.spell1=function(o)
 o.book=false;standby(o,192,160,60);wait(60);wait(60);local count=0;local dir=1
 while true do
  local center=({192,192+R.rand(64,128),192,192-R.rand(64,128)})[count%4+1]
  if R.setAction then R.setAction(o,'shot2',90)end
  wait(90);R.move(o,center,160,90,'linear');if R.setAction then R.setAction(o,'move',90)end;wait(30)
  local direction=dir
  spawn(function()
   local base=R.rand(0,360)
   for t=0,359 do
    local u=(t+1)/360;local y
    if t<120 then y=512/3*sin(t/360*3*90)
    else y=512*(1/3+(1-cos((t-120)/360/2*3*180))/2*2/3)end
    for i=0,6 do
     local a=base+i*360/7+(t*137.35/7-u*u*180)*direction;local x=center+sin(a)*360
     if x> -64 and x<448 and math.abs(x-center)>64*sin(u*90)then
      local angle=90-cos(a)*10;local speed=3*(1+u*0.5)
      local b=R.shot(x,y,0,angle,319,30,-3/15,-3);b.addDelay=true;R.accelerate(b,30,-3/120,-12)
      if i%3==0 then b.update=function(s)
       if s.age>=30 then
        if s.age==30 and s.y<0 then s.update=nil;return end
        if s.y<0 then local child=R.shot(s.x,s.y,speed,180-angle,380,15,-speed/120,speed/8);child.addDelay=true;R.accelerate(child,180,speed/480,speed/2);s.update=nil end
       end
      end end
     end
    end
    wait(1)
   end
  end)
  wait(300);dir=-dir;count=count+1
 end
end
-- Export only shared source mechanisms used by spell2/final.
R.horou={standby=standby,wingWay=wingWay,curve=curve,moveRandom=moveRandom}
