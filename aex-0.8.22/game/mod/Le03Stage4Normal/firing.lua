-- LE03 1.21a Unreal (difficulty index 3), native callback IDs retained.
-- Source functions and binary constants are preserved under work/le03/source.
Le03Firing={ids={34,35,42,43,46,47,52,54,58,59,60,61,62,63,66,67,69,70,71}}
local F=Le03Firing
local C=Le03Constants
local D=3
local function v(a)return C.f('0086'..a)end
local function d(a)return C.d('0086'..a)end
local cos,sin=math.cos,math.sin
local function add(R,e,a,s,behavior,x,y)
 return R.shot(e,x or e.x,y or e.y,s,a,behavior or 0)
end
function F.fire(R,e)
 local D=e.appear==9500 and 1 or D
 local t,id=e.shotAge,e.shot
 local a=R.aim(e.x,e.y)
 if id==34 then -- 004b8020
  if t%120==0 then for layer=0,D*2+1 do for j=0,2 do
   add(R,e,j*d('b298')/(D*2+4)+a-d('b298')/(D*2+4),layer/v('b37c')+v('af98'))
  end end end
 elseif id==35 then -- 004b8520
  if t%120==0 then for layer=0,D*2+1 do for j=0,1 do
   add(R,e,a-d('b298')/(D*4+4)+j*d('b298')/(D*2+2),layer*v('ac50')+v('af98'))
  end end end
 elseif id==42 then -- 004be830
  if t%2==0 and t%100<70 then
   local x,y=e.x+R.randomInt(20),e.y+R.randomInt(20)
   add(R,e,a,D*v('ac74')+v('b50c'),2,x,y)
  end
 elseif id==43 then -- 004bef20
  if t%50==0 then for j=1,D*v('b230')+v('b458') do
   local ang=R.randomUnit()*d('b298')-2*d('b1f8')
   add(R,e,ang,R.randomUnit()*v('b230')-d('b178')+v('af98'),13)
  end end
 elseif id==46 or id==47 then -- 004c05b0 / 004c1540
  if t%100==0 then
   local sp=D*v('ac74')+v('b50c')
   if id==46 then
    local rows=4
    for row=0,rows-1 do for j=0,2 do
     local i=row*3/(rows-1)
     local q=a+j*d('b240');local p=q+d('b1f8')
     add(R,e,a,sp,2,e.x-cos(q)*v('b54c')+(i-2)*cos(p)*v('b544'),e.y-sin(q)*v('b54c')+(i-2)*sin(p)*v('b544'))
    end end
   else
    local rows=5
    for row=0,rows-1 do for j=0,1 do
     local i=row*4/(rows-1)
     local q=j*d('b1f8')+a+d('b128')
     add(R,e,a,sp,2,e.x+(i-2)*cos(q)*v('b544'),e.y+(i-2)*sin(q)*v('b544'))
    end end
   end
  end
 elseif id==52 then -- 004c46f0
  if t%100==10 then for j=0,(D+2)*10-1 do
   local pos=j*d('af28')+a-d('b1f8')
   add(R,e,d('b298')/((D+2)*10)*j+a-d('b1f8'),D+v('b500'),2,e.x+cos(pos)*v('b560'),e.y+sin(pos)*v('b560'))
  end end
 elseif id==54 then -- 004c5f20, two opposite staggered rails
  local reduced=e.appear and e.appear>=7300 and e.appear<=7700
  local count=reduced and 5 or D*3+11
  if t%100==0 then for side=0,1 do for index=0,count-1 do
   local j=reduced and index*19/4 or index -- Keep the current Unreal rail endpoints.
   local sign=side==0 and 1 or -1
   local dir=a+(side==0 and 0 or d('b298'))
   add(R,e,a,0,14+side,
    e.x-cos(a+d('b1f8'))*v('b570')*sign-cos(dir)*v('b498')*j*sign,
    e.y-sin(a+d('b1f8'))*v('b570')*sign-sin(dir)*v('b498')*j*sign)
  end end end
 elseif id==58 then -- 004c9e60: difficulty-dependent rotating spokes + drift
  if t%60==0 then for j=0,D*3+4 do
   local b=add(R,e,d('b2d8')/(D*3+5)*j,0,17)
   b.p1=.8999999761581421;b.p2=a;b.cullDelay=500
  end end
 elseif id==59 then -- 004ca9d0
  if t%60==0 then for j=0,(D+2)*3-1 do
   local pos=d('b240')/((D+2)*3)*j+a-d('b188')
   local b=add(R,e,a-d('b240')/((D+2)*3)*j+d('b188'),0,18,e.x+cos(pos)*v('b5a0'),e.y+sin(pos)*v('b5a0'))
   b.p1=50;b.cullDelay=500
  end end
 elseif id==60 then -- 004cba90
  if t%5==0 then for side=0,1 do for j=0,2 do
   local pos=side*d('b298')+t*d('ae78')
   local b=add(R,e,j*d('b298')/(D*2+3)+d('b1f8')-d('b298')/(D*2+3),0,18,e.x+(side==0 and 100 or -100),e.y+sin(pos)*v('b578'))
   b.p1=0
  end end end
 elseif id==61 then -- 004cbe30: Unreal adds two more ten-bullet rings.
  if t==0 then
   local radius=D*v('b568')+v('b544')
   for ring=1,3 do for j=0,9 do
    local spawnRadius=radius*({1,1.5,2})[ring]
    local q=j*d('b020')+a-d('b188')
    local b=add(R,e,0,0,19,e.x+cos(q)*spawnRadius,e.y+sin(q)*spawnRadius)
    b.state=j;b.owner=e;b.p2=radius/({1,2,3})[ring];b.cullDelay=500
   end end
  end
 elseif id==62 then -- 004cca50 + secondary1 00485e00
  if t==0 then for j=0,3 do R.laser(e,j*d('b1f8'),D*v('b568')+v('b594'),v('b5ec')-D*v('b568'),j)end end
 elseif id==63 then -- 004cd0b0
  if t%(11-D*2)==0 then for arm=0,3 do for j=0,D+1 do
   local q,r=arm*d('b1f8')+t*d('af28')-t*d('ae00'),10+j*50
   add(R,e,q+d('b1f8'),1.5,0,e.x+cos(q)*r,e.y+sin(q)*r)
  end end end
 elseif id==66 then -- 004cfcb0
  if t%80==0 or t%80==10 then
   local a0=R.randomUnit()*d('b338')-d('b2d8')
   for j=0,D*20+29 do local b=add(R,e,d('b2d8')/(D*20+30)*j+a0,17,12);b.cullDelay=200;b.state=t%80==0 and 1 or 2 end
  end
 elseif id==67 then -- 004d1270
  if t%60==0 then local a0=R.randomUnit()*d('b338')-d('b2d8')
   for j=0,(D+2)*10-1 do add(R,e,d('b2d8')/((D+2)*10)*j+a0,3,21)end
  end
 elseif id==69 or id==71 then -- 004d2430 / 004d3c80
  if t%60==0 then
   if id==69 then R.randomUnit()end -- preserve source unused RNG advance
   for j=0,4 do
    local side,forward=40-j*20,j<3 and 30+j*10 or 70-j*10
    local b=add(R,e,a,id==69 and 1 or 0,id==69 and 18 or 22,
      e.x+cos(a+d('b1f8'))*side+cos(a)*forward,
      e.y+sin(a+d('b1f8'))*side+sin(a)*forward)
    b.p1=id==71 and D+3 or 0
   end
   if id==71 then for forward=50,-30,-20 do
    local b=add(R,e,a,0,22,e.x+cos(a)*forward,e.y+sin(a)*forward);b.p1=D+3
   end end
  end
 elseif id==70 then -- 004d2ba0
  if t%60==0 then for j=0,D*3+6 do
   local pos=d('b298')/(D*3+7)*j+a-d('b1f8')
   add(R,e,a,cos(d('b2d8')/(D*3+7)*j)+v('b230'),0,e.x+cos(pos)*d('b3e0'),e.y+sin(pos)*d('b3e0'))
  end end
 else error('Unported LE03 firing '..tostring(id))end
end

function F.behavior(R,b)
 local D=b.sourceAppear==9500 and 1 or D
 local t,k=b.age,b.behavior
 if k==0 then return
 elseif k==2 then if t<10 then b.speed=b.speed-v('ae10')end
 elseif k==12 then
  if t<10 then b.speed=b.speed-v('af98')end
  if t>49 then
   local target=D*v('ac34')+v('ac68')
   if b.speed>=target then b.speed=target else b.speed=b.speed+v('abe0')end
   if t<150 then b.angle=b.angle+(b.state==1 and d('aed0')or -d('aed0'))end
  end
 elseif k==13 then b.vy=b.vy+v('ab6c')+v('ab74')
 elseif k==14 or k==15 then
  if t>49 then b.speed=b.speed+D*v('aba8')+v('ab94')end
  local sign=k==14 and 1 or -1
  if t>=70 and t<80 then b.vx=b.vx+cos(b.angle+d('b1f8'))*v('ac44')*sign;b.vy=b.vy+sin(b.angle+d('b1f8'))*v('ac44')*sign end
  if t>=90 and t<100 then b.vx=b.vx-cos(b.angle+d('b1f8'))*v('ac44')*sign;b.vy=b.vy-sin(b.angle+d('b1f8'))*v('ac44')*sign end
 elseif k==17 then
  b.x=b.x+b.p1*cos(b.p2);b.y=b.y+b.p1*sin(b.p2)
  b.speed=b.speed+D*v('ab28')+v('ab48');b.angle=b.angle+d('aea0')
 elseif k==18 then if t>=b.p1 then b.speed=b.speed+D*v('ab60')+v('ab74')end
 elseif k==19 then
  local e=b.owner
  if not e.active then b.speed=D+v('ae10')
  else
   local q=b.state*d('b0f8')+t*d('aee0')
   b.x=e.x+cos(q)*b.p2;b.y=e.y+sin(q)*b.p2
   b.angle=b.state*d('b0f8')+t*d('aed0')-d('b1f8')
  end
 elseif k==21 then
  if t==60 then
   for j=0,2 do local n=R.shot(b,b.x,b.y,1,b.angle-d('b188')+j*d('b188'),0);n.typ=3;n.col=b.col end
   b.active=false
  end
 elseif k==22 then
  if t>59 then if b.speed<b.p1 then b.speed=b.speed+v('abe0')else b.speed=b.p1 end end
 else error('Unported LE03 bullet behavior '..tostring(k))end
end
