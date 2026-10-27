-- st06bs.ecl Normal only: Boss3_at, Boss4_at, BossCard7 and four layers.
-- Native transform evidence: source/../source-reference.json and work/logs/zuu4.
local R,P=Zuu4R,Zuu4Patterns
local wait,spawn=R.wait,R.spawn
local degrees=180/math.pi
-- Native large-eight palette: red, green, blue, yellow, purple, cyan, orange, white.
-- TH20 type48 is deliberately never loaded: HSoB CHRYSTAL_M uses radius4.
local palette={[1]=369,[3]=371,[5]=373,[6]=374}
local function diamond(o,angle,speed,color,ox,oy,dist)
 local b=R.shot(o.x+(ox or 0)+(dist or 0)*R.cos(angle),o.y+(oy or 0)+(dist or 0)*R.sin(angle),speed,angle,palette[color],8)
 b.nativeBirth=true;b.x,b.y=b.x-4*speed*R.cos(angle),b.y-4*speed*R.sin(angle)
 b.sourceColor=color;return b
end
local function ring(o,n,base,speed,color,ox,oy,dist,setup)
 for i=0,n-1 do local b=diamond(o,base+i*360/n,speed,color,ox,oy,dist);if setup then setup(b)end end
end
local function fan(o,n,base,spread,speed,color,ox,oy,dist,setup)
 -- Native odd/even centered shooter ordering.
 for i=0,n-1 do
  local delta=(n%2==1 and math.floor((i+1)/2)or(math.floor(i/2)+0.5))*spread
  if i%2==1 then delta=-delta end
  local b=diamond(o,base+delta,speed,color,ox,oy,dist);if setup then setup(b)end
 end
end
local function randomMove(o,n,mode,scale,cy,height,width)
 local x=math.max(192-width/2,math.min(192+width/2,o.x+R.rand(-1,1)*n*scale))
 local y=math.max(cy-height/2,math.min(cy+height/2,o.y+R.rand(-1,1)*n*scale))
 R.move(o,x,y,n,mode==4 and 'decel' or 'linear')
end
P.non3=function(o)
 R.move(o,192,128,60,'decel');o.visible=true
 spawn(function()
  -- Boss3's pre-dialogue positioning120, attack animation90+30.
  wait(240)
  while true do
   randomMove(o,60,0,0.8,128,96,280)
   for _,color in ipairs({3,1,5,6})do
    ring(o,34,R.rand(-180,180),5*0.2,color)
    wait(20)
   end
  end
 end)
 spawn(function()
  wait(120)
  while true do
   randomMove(o,120,0,0.4,128,64,280)
   for _,direction in ipairs({-1,1})do
    local angle=R.aim(o)+90*direction+R.rand(-10,10)
    for i=0,29 do
     fan(o,3,angle,0.09424778*degrees,1*0.2,3,0,0,32,function(b)
      b.profile={hold=60+i*2,initial=1*0.2,n1=60,s1=0.2*0.2,n2=60,s2=3*0.2}
     end)
     angle=angle-0.10472*degrees*direction;wait(2)
    end
   end
  end
 end)
end
local function layer(o,phase)
 -- Each script starts with an independent RAND_ANGLE register.
 local base=R.rand(-180,180)
 while R.subphase==phase do
  -- Unused source %E random draw must still consume RNG before the aim jitter.
  local unused=R.rand(0,20)
  local angle=R.aim(o)+R.rand(-10,10)
  base=base+R.rand(-180,180)
  local r=R.rand(-128,128);local ox,oy=r*R.cos(base),r*R.sin(base)
  fan(o,7,angle,0.436332*degrees,1.5,6,ox,oy,0,function(b)
   b.profile={hold=0,initial=1.5,n1=120,s1=0.5};b.wraps=1;b.wrapMask=3;b.noCull=true
  end)
  wait(({20,24,28,28})[phase+1])
 end
end
local function ringLayer(o,phase)
 local base=R.rand(-180,180)
 while R.subphase==phase do
  local unused=R.rand(0,20)
  local angle=R.rand(-180,180);local r=R.rand(-128,128)
  ring(o,32,angle,1.8,3,r*R.cos(base),r*R.sin(base),0,function(b)b.profile={hold=0,initial=1.8,n1=80,s1=0.8};b.noCull=true end)
  base=base+3.883222*degrees;wait(120)
 end
end
local function tripleLayer(o,phase,final)
 local base=R.rand(-180,180)
 while R.subphase==phase do
  local unused=R.rand(0,20);local angle=final and R.aim(o)or base;local r=R.rand(-128,128)
  ring(o,final and 1 or 3,angle,3.8,final and 1 or 5,r*R.cos(base),r*R.sin(base),0,function(b)
   b.profile={hold=0,initial=3.8,n1=60,s1=final and 2.2 or 1.2};b.transformIndex=3;b.noCull=true
  end)
  base=base+3.883222*degrees;wait(final and 8 or 13)
 end
end
local function launchLayers(o,phase)
 R.subphase=phase;spawn(function()layer(o,phase)end)
 if phase>=1 then spawn(function()ringLayer(o,phase)end)end
 if phase>=2 then spawn(function()tripleLayer(o,phase,false)end)end
 if phase>=3 then spawn(function()tripleLayer(o,phase,true)end)end
end
P.stone=function(o)
 R.move(o,192,144,60,'decel');o.visible=true;wait(120)
 launchLayers(o,0)
 local elapsed=0
 while elapsed<=1800 and R.hp>8000 do wait(1);elapsed=elapsed+1;if elapsed%200==0 then randomMove(o,60,4,1,144,64,128)end end
 for phase=1,3 do
  local cap=({8000,5000,2000})[phase]
  R.hp=cap;if R.setHostHP then R.setHostHP(cap)end
  R.clearBullets();launchLayers(o,phase)
  if phase<3 then
   local elapsed=0;local nextHP=phase==1 and 5000 or 2000
   while elapsed<1800 and R.hp>nextHP do wait(1);elapsed=elapsed+1;if elapsed%200==0 then randomMove(o,60,4,1,144,64,128)end end
  end
 end
 while true do wait(200);randomMove(o,60,4,1,144,64,128)end
end
