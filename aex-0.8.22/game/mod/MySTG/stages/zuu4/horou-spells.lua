-- HSoB06b_Spell02/07 Normal, using Horou's delayed path-segment lasers.
local R,P=Zuu4R,Zuu4Patterns
local H=R.horou
local sin,cos,atan=R.sin,R.cos,R.atan
local spawn,wait=R.spawn,R.wait
local colors={0,6,3,1,5,2,4,7}
local function square(x,y,angle,pattern,delay)
 spawn(function()
  wait(delay);local way=pattern==1 and 10 or 14
  for i=0,3 do
   local x1,y1=cos(angle+i*90)*2.5,sin(angle+i*90)*2.5
   local x2,y2=cos(angle+(i+1)*90)*2.5,sin(angle+(i+1)*90)*2.5
   for j=0,way-1 do
    local u=j/way;local vx,vy=x1*(1-u)+x2*u,y1*(1-u)+y2*u
    local speed=math.sqrt(vx*vx+vy*vy);local a=atan(vy,vx)
    local b=R.shot(x,y,speed,a,977,0,-speed/45,0)
    local emits=j%2==0
    spawn(function()
     wait(45);if b.dead then return end
     if emits then for k=0,2 do local s=speed*(1-math.abs(k-1)*0.025);R.shot(b.x,b.y,0,a+(k-1),97,0,s/360,s)end end
     b.dead=true
    end)
   end
  end
 end)
end
local function arrow(x,y,angle,pattern)
 spawn(function()
  local tip=R.shot(x,y,0,angle,545,30);tip.addDelay=true;tip.noCull=true;tip.bombProof=true
  -- Source red concentration marker180 frames before tracking begins.
  local notice=R.beam(x,y,angle,160,2,9999,180,'notice',0);notice.visual=377;notice.collidable=false
  wait(180);if tip.dead then return end
  local driver=H.curve(x,y,16/3,angle,30,18,265,60);driver.noCull=true;driver.accel,driver.limit=-(16/3)/30,0
  local function motion(speed,a)
   driver.speed,driver.angle,driver.accel,driver.limit=speed,a,-speed/30,0
   spawn(function()wait(60);if not tip.dead then tip.speed,tip.angle,tip.accel,tip.limit=speed,a,-speed/30,0 end end)
  end
  motion(16/3,angle);wait(30)
  for i=1,6 do motion(16,R.aim(driver));wait(30)end
  square(driver.x,driver.y,driver.angle,pattern,60);driver.dead=true;wait(60);tip.dead=true
 end)
end
local function sideAnchors(o,dir,fn)
 spawn(function()
  local n=dir>0 and 4 or 6
  for i=1,n do
   local left,right=R.horouAnchors(o,R.tick-R.wingStart);local a=(dir>0 and right or left)[i]
   if dir<0 then a={x=a.x+48*cos(a.angle),y=a.y+48*sin(a.angle),angle=a.angle}end
   fn(a,dir>0 and 0 or 1);wait(5)
  end
 end)
end
local function wingCard2(o,dir)
 spawn(function()
  for i=0,6 do
   local a=90-65*dir;local speed=2*(1+i/7);local way=30-i
   H.wingWay(o.x+108*cos(a),o.y+108*sin(a)-64,speed,a,545,30,60+i*5,way,(150-i*10)/way*dir,120-i*10,0.5)
   wait(5)
  end
 end)
end
P.spell2=function(o)
 R.enableWings(o);o.book=true;H.standby(o,192,140,300,true);wait(60)
 -- Original seven-colour weapon resonance returns immediately for ordinary AEX Reimu.
 local dir=1
 while true do
  if R.setAction then R.setAction(o,'shot1',180)end;wait(60)
  sideAnchors(o,dir,function(a,pattern)arrow(a.x,a.y,a.angle,pattern)end)
  wait(60);wingCard2(o,dir);wait(270);dir=-dir
 end
end
local function ring(x,y,n,speed,angle,id,delay,accel,limit,r)
 for i=0,n-1 do local a=angle+i*360/n;R.shot(x+(r or 0)*cos(a),y+(r or 0)*sin(a),speed,a,id,delay,accel,limit)end
end
local function finalBird(core,angle,dir)
 local f=R.actor(core.x,core.y,'bird',1000,1);f.color=3;f.visible=false;f.angle=angle;f.cull=64
 spawn(function()
  local a=angle
  for t=1,180 do
   if f.dead then return end
   local u=sin(t/180*90);a=a+(1-u)*1.75*dir;f.speed=(3-u*2)*1.25;f.angle=a;wait(1)
  end
  local s=f.speed
  while not f.dead do f.speed=math.min(s*3,f.speed+s/60);f.angle=f.angle+0.33*dir;wait(1)end
 end)
 spawn(function()
  wait(45);if f.dead then return end;f.visible=true
  local count=math.min(7,math.floor((1-R.hp/7777)*7/0.66));if R.finalRage>0 then count=7 end
  for i=0,count-1 do
   if f.dead then return end
   local id=353+colors[(i*6+2)%7+1];local s=1*(1+i*0.015)
   local b=R.shot(f.x,f.y,s,f.angle-90*dir,id,15,-s/30,s/4);b.bombProof=true;R.accelerate(b,30,s/600,s)
   wait(2)
  end
 end)
 spawn(function()
  wait(45)
  while not f.dead do
   local b=R.shot(f.x,f.y,1.66,f.angle+180+R.rand(-5,5),636,5,-1.66/30,0);b.life=30;wait(3)
  end
 end)
end
local function finalRay(x,y,angle)
 spawn(function()
  for i=5,0,-1 do
   for _,dir in ipairs(i==0 and {1}or {1,-1})do
    local offset=i*5*dir;local b=R.beam(x,y,angle+offset,0,2,9999,75,'notice',0);b.visual=364;b.collidable=false;b.noCull=true
    b.update=function(s)local u=math.min(1,(s.age+1)/45*2);s.length=800*u;s.angle=angle+offset*sin(math.min(1,(45-s.age)/45)*90)end
   end
   wait(5)
  end
  wait(60)
  for i=0,3 do for _,dir in ipairs(i==0 and {1}or {1,-1})do
   local offset=i*dir;local b=R.beam(x,y,angle,0,32,0,105,'finalRay',0);b.visual=236;b.noCull=true
   b.update=function(s)
    if s.age<75 then local u=1-cos((s.age+1)/75*90);s.angle=angle+u*offset;s.length=math.min(480,(s.age+1)*12);s.renderWidth=32
    else local t=104-s.age;local u=sin((t+1)/30*90);s.angle=angle+u*offset;s.length=480+(s.age-74)*12;s.renderWidth=32*u;s.collidable=t>=10 end
    s.hitWidth=s.renderWidth/3
   end
  end end
 end)
end
P.final=function(o)
 R.enableWings(o);R.finalRage=0;o.book=true
 H.standby(o,192,208,360,true);wait(120)
 if R.setAction then R.setAction(o,'shot2',999*60)end
 spawn(function()
  while true do
   local left=98-math.max(0,R.tick-360)/60
   if R.finalRage==0 and(R.hp<=7777*0.25 or left<=33)then R.finalRage=1 end
   if R.finalRage==1 and(R.hp<=7777*0.125 or left<=22)then R.finalRage=2 end
   if R.finalRage==2 and left<=11 then R.finalRage=3 end
   wait(1)
  end
 end)
 local core=R.nuclear(o.x,o.y-48,12,99999);core.noCull=true;core.moving=true;core.tint={255,255,0}
 core.speed,core.angle,core.accel,core.limit=0,270,1/30,1;R.accelerate(core,120,-1/120,0)
 core.update=function(b)if b.age>=240 and b.age<285 then b.radius=12+96*sin((b.age-239)/45*90)elseif b.age>=285 then b.radius=108 end end
 spawn(function()
  wait(240)
  for i=0,6 do local s=1.75*(1+i*0.15);ring(core.x,core.y,24,s*3,R.aim(core),356,30,-s/15,s,0)end
  for i=0,6 do local s=1.75*(1+i*0.15)*0.75;ring(core.x,core.y,24,s*3,R.aim(core)+180/24,356,30,-s/15,s,0)end
  local dir=1
  while true do
   local base=R.rand(0,360)
   for i=0,15 do local a=base+i*360/16;if sin(a+1.75*45*dir)> -0.5 then finalBird(core,a,dir)end end
   dir=-dir;wait(80)
  end
 end)
 spawn(function()
  wait(240+45);local t=0
  while true do
   if R.finalRage>0 and t%3==0 and t%55<15 then
    local s=1.25*0.75;ring(core.x,core.y,7,s*2,t*0.33,548,5,-s/30,s,core.radius)
   end
   if R.finalRage>1 and t%3==0 and(t+math.floor(55/2))%55<15 then
    ring(core.x,core.y,7,2.5,-t*0.33,548,5,-1.25/30,1.25,core.radius)
   end
   if t%5==0 then
    local dist=math.sqrt((R.px-core.x)^2+(R.py-core.y)^2)
    if dist<108+64 then
     local a=R.rand(0,360);if t%20==0 then a=R.aim(core)end
     ring(core.x,core.y,12,0,a,36,5,3.75/240,3.75,core.radius-32)
    elseif R.finalRage>2 then ring(core.x,core.y,6,0,R.rand(0,360),36,5,3.75/240,3.75,core.radius-32)end
   end
   t=t+1;wait(1)
  end
 end)
 spawn(function()
  wait(240+285)
  while true do
   wait(90);local angle=R.aim(core)
   local function volley(a)
    spawn(function()
     for i=12,0,-1 do
      for _,dir in ipairs((i==0 or i==12)and {1}or{1,-1})do
       local a=a+i*180/12*dir
       if sin(a)> -0.1 then finalRay(core.x+core.radius*cos(a),core.y+core.radius*sin(a),a)end
      end
      wait(3)
     end
    end)
   end
   volley(angle);wait(90);if R.finalRage>2 then volley(angle+180/24)end;wait(240)
  end
 end)
 wait(240)
end
