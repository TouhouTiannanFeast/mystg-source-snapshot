local R=Y3
local pi=math.pi
local W=R.wait
-- The Normal source level is 1. The source Boss callback clocks and pixel
-- coordinates are retained. RNG is encounter-local, not retail replay RNG.
local level=1
-- Native effect 0xb/variant 1 (00508870 passes double 1.0): stationary
-- b033 flash. Scale=4, alpha=50; -.3 scale/+15 alpha per frame, life=10.
function R.le04Birth(b)
 if R.id~='spell2' then return end
 R.birthEffects[#R.birthEffects+1]={x=b.x,y=b.y,angle=b.angle,
  typ=b.nativeType,col=b.col,age=0}
end
function R.birthGeometry(e)
 return 4-0.3*e.age,math.min(255,50+15*e.age),e.age<10
end
local function color(b)
 -- 0040ddc0(10000) + 00450100(Normal=1), no equipment modifiers.
 local code=math.floor(R.random(-10000,10001))+46666
 b.nativeColor=code>49999 and 5 or(code>39999 and 4 or 3)
end
local function ring(count,typ,col,x,y,speed,offset,state,scale)
 local out={}
 for i=0,count-1 do
  local b=R.shot(typ,col,x,y,speed,2*pi*i/count+offset)
  b.le04=true;b.nativeType=typ;b.state=state;b.scale=scale or 1;b.parity=i%2;color(b)
  R.le04Birth(b)
  out[#out+1]=b
 end
 return out
end
-- boss30/phase7 FUN_0050c300, Shion_07. Untitled nonspell at host level.
R.begin.non2=function()
 R.fork(function()
  while true do
   local t=R.tick
   R.circle={x=R.boss.x,y=R.boss.y,r=t<1000 and 700-t*0.3 or 400}
   if t%50==0 then
    local offset=R.random(-pi/10,pi/10)
    for _,b in ipairs(ring(level*7+19,3,2,R.boss.x,R.boss.y,1.5-level*0.2,offset,1,1))do
     b.update=R.soulUpdate
    end
    offset=R.random(-pi/10,pi/10)
    for _,b in ipairs(ring((level+1)*3,10,4,R.boss.x,R.boss.y,1.5-level*0.2,offset,2,1))do
     b.update=R.soulUpdate
    end
   end
   W(1)
  end
 end)
end
function R.soulUpdate(b)
 -- Requested adaptation: retain the early curve, always render fully opaque.
 b.alpha=255
 if b.state==1 and b.age<100 then b.angle=b.angle+(b.parity==0 and pi/100 or -pi/100)end
end
-- boss30/phase3 FUN_00508870, Shion_03. Two rotating 400/550 circles;
-- two separate tests in source order (repel, then capture/accelerate).
R.begin.spell2=function()
 R.move(192,224,60)
 R.fork(function()
  while true do
   local t=R.tick;local a=t*pi/750-pi/2
   local b=(t+750)*pi/750-pi/2
   local x1,y1=192+500*math.cos(a),224+500*math.sin(a)
   local x2,y2=192+500*math.cos(b),224+500*math.sin(b)
   R.circles={{x=x1,y=y1,r=400,col=1},{x=x2,y=y2,r=550,col=2}}
   if t>=100 then
    if t%100==50 then
     ring((level+3)*5,12,1,R.boss.x,R.boss.y,1,R.random(-R.erosJitter, R.erosJitter),0)
    end
    if t%100==0 then
     local offset=R.random(-pi/100,pi/100)
     for i=0,(level+2)*40-1 do
      local aa=2*pi*i/((level+2)*40)
      local q=R.shot(3,2,x1+400*math.cos(aa),y1+400*math.sin(aa),1.5,aa+offset)
      q.le04=true;q.nativeType=3;q.state=1;q.update=R.erosUpdate;color(q);R.le04Birth(q)
     end
    elseif t%100==50 then
     local offset=R.random(-pi/50,pi/50)
     for i=0,(level+2)*20-1 do
      local aa=2*pi*i/((level+2)*20)
      local q=R.shot(3,1,x1+400*math.cos(aa),y1+400*math.sin(aa),2,aa+offset+pi)
      q.le04=true;q.nativeType=3;q.state=0;color(q);R.le04Birth(q)
     end
    end
   end
   W(1)
  end
 end)
end
function R.erosUpdate(q)
 if q.state~=1 then return end
 local c1,c2=R.circles[1],R.circles[2]
 local dx,dy=q.x-c1.x,q.y-c1.y
 if dx*dx+dy*dy<=(400+2.5)^2 then q.angle=R.atan(-dy,-dx)+pi end
 dx,dy=q.x-c2.x,q.y-c2.y
 if dx*dx+dy*dy<=(550+2.5)^2 then
  q.angle=R.atan(-dy,-dx);q.speed=q.speed+level*0.01+0.03;q.col=3;q.state=0
 end
end
-- Exact native float64 range for FUN_0040dcd0 at 00508ae8.
R.erosJitter=0.20943951023926666
