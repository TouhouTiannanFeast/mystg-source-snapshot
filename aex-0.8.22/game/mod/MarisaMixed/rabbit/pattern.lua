-- TH165 native coordinates: centered X, positive Y downward. Host maps Y -> 224-Y.
RingoSeiranPattern={}
local P=RingoSeiranPattern
local pi=math.pi
P.specs={nonspell={name='',hp=13000,time=30},spell={name='西八「打你就像打蚂蚁」',hp=15000,time=45}}
P.introFrames=120
P.entryFrames=60
P.dialogueFrames=180
P.openingFrames=P.dialogueFrames*2+P.entryFrames+P.introFrames
P.pursuit={period=120,headX=-20,headY=-18,hitRadius=11,bodyA=16,bodyB=28,gunSpeed=2,gunCount=36,gunGroups=6,triangleRadius=5,shakeTime=10,shakeSize=2}
P.impactPellets={count=6,speedMin=6,speedMax=12,stopMin=8,stopMax=20,launchDivisor=41,radiusScale=2/3,spinSpeed=12,fadeDistance=24,fadeFrames=15,color=2}
function P.new(phase,random,pelletSeed)
 assert(P.specs[phase],'unknown phase')
 return {phase=phase,t=0,elapsed=0,opening=phase=='spell',charging=false,chargeAge=0,dialogue=phase=='spell' and 'ringo' or nil,x=0,y=128,bullets={},nextId=0,random=random or math.random,pelletSeed=math.max(1,(pelletSeed or 20261102)%2147483647),colorSeed=math.max(1,((pelletSeed or 20261102)+9187)%2147483647),
  seiran=phase=='spell' and {x=-80,y=-64,headX=-80,headY=-64,active=false,entering=false} or nil,
  stats={triples=0,dango=0,gun=0,pellet=0,locks=0,impacts=0},effects={}}
end
local function spawn(w,kind,x,y,a,s,extra)
 w.nextId=w.nextId+1
 local b={id=w.nextId,kind=kind,x=x,y=y,angle=a,speed=s,age=0}
 for k,v in pairs(extra or {})do b[k]=v end
 w.bullets[#w.bullets+1]=b
 local stat=kind=='gun' and 'gun' or(kind=='impactPellet' and 'pellet' or 'dango')
 w.stats[stat]=w.stats[stat]+1
 if w.onShot then w.onShot(b)end
 return b
end
function P.triple(w,a,s,sign)
 local flower=w.phase=='nonspell'
 local radius=flower and 12.8 or 12
 local speed=flower and 0.32 or 0.3
 local turn=(pi/120)*sign/(flower and 0.8 or 1)
 -- etOffsetRad uses angle A, signed distance. Side bullets have independent
 -- polar velocity plus the same constant forward vector as the red center.
 spawn(w,'blue',w.x-radius*math.cos(a),w.y-radius*math.sin(a),a-pi/2*sign,speed,{turn=turn,driftA=a,driftS=s})
 spawn(w,'red',w.x,w.y,a,s)
 spawn(w,'pink',w.x+radius*math.cos(a),w.y+radius*math.sin(a),a+pi/2*sign,speed,{turn=turn,driftA=a,driftS=s})
 w.stats.triples=w.stats.triples+1
end
local function startMove(w,n)
 -- Local reproduction of moveRand: choose toward/away from player, retain source
 -- speed1/ease4 and native240x64 movement rectangle around(0,128).
 local a=(w.random()*2-1)*pi/4
 if w.x>120 or(w.x>=-120 and (w.px<w.x)==(w.random()<2/3))then a=a+pi end
 if w.y<96 then a=math.abs(a)elseif w.y>160 then a=-math.abs(a)end
 w.move={dx=math.cos(a),dy=math.sin(a),n=n,age=0}
end
local function flower(w)
 local q=w.t%450
 local a=P.aim(w)-pi/2
 if q==30 or q==70 then
  local n=q==30 and 12 or 18
  local step=q==30 and 0.261799 or 0.174533
  for i=0,n-1 do P.triple(w,a+2*i*step,1.4,1);P.triple(w,a+(2*i+1)*step,1.4,-1)end
 elseif q>=200 and q<=320 and (q-200)%30==0 then
  -- Aim captured once before all five dense bursts, rather than every burst.
  if q==200 then w.flowerA=a end
  local k=(q-200)/30
  for i=0,29 do
   local base=w.flowerA+k*(60*0.10472+0.05236)+2*i*0.10472
   P.triple(w,base,1.9,1);P.triple(w,base+0.10472,1.9,-1)
  end
 end
 if q==130 then startMove(w,30)
 elseif q==0 and w.t>0 then startMove(w,60)end
end
local function sisters(w)
 local q=w.t%630
 if q<400 and q%4==0 then
  P.triple(w,(w.random()*2-1)*pi,0.5+w.random(),q%8==0 and 1 or -1)
 elseif q>=430 and q<590 and q%2==0 then
  if q==430 then w.fanA=P.aim(w)-pi/2 end
  if q==510 then w.fanA=P.aim(w)+pi/2 end
  local second=q>=510
  local i=(q-(second and 510 or 430))/2
  local a=w.fanA+(second and -1 or 1)*i*0.174533+(w.random()*2-1)*0.17453292
  P.triple(w,a,2,i%2==0 and 1 or -1)
 end
 if q==0 and w.t>0 then startMove(w,60)end
end
function P.aim(w)return math.atan2(w.py-w.y,w.px-w.x)end
local function pelletRandom(w)
 -- Keep the added scatter independent of the existing Ringo RNG stream.
 w.pelletSeed=w.pelletSeed*16807%2147483647
 return (w.pelletSeed-1)/2147483646
end
local function colorRandom(w)
 w.colorSeed=w.colorSeed*16807%2147483647
 return(w.colorSeed-1)/2147483646
end
function P.seiranStep(w)
 local s=w.seiran;if not s then return end
 local q=w.t%P.pursuit.period
 if q==0 then
  s.fromX,s.fromY=s.x,s.y;s.flip=w.px<s.x and -1 or 1
  -- Final native firing pose: hammer anchor(-20,-18), ANM x-shift-10.
  -- Position the character so its existing texture's hammer lands at the sample.
  s.targetX,s.targetY=w.px-(P.pursuit.headX-10)*s.flip,w.py-P.pursuit.headY
  s.lockX,s.lockY=w.px,w.py;w.stats.locks=w.stats.locks+1
 end
 local u=(q+1)/120;local f=u*u*(3-2*u)
 s.x=s.fromX+(s.targetX-s.fromX)*f;s.y=s.fromY+(s.targetY-s.fromY)*f
 -- Original ANM script5/6: 13,14,15,16,17,16,15 at7f intervals.
 -- Start30f before impact; keep the original recovery frames next cycle.
 s.attackAge=q>=89 and q-89 or(w.t>=120 and q<=11 and q+31 or nil)
 s.swing=s.attackAge~=nil
 s.spriteShift=s.attackAge and s.attackAge>=14 and -10 or 0
 if s.attackAge then s.sprite=({13,14,15,16,17,16,15})[math.min(7,math.floor(s.attackAge/7)+1)]else s.sprite=nil end
 s.headX=s.x+(P.pursuit.headX+s.spriteShift)*s.flip
 s.headY=s.y+P.pursuit.headY
 s.active=q>=114
 if q==89 and w.onSwing then w.onSwing(s)end
 if q==119 then
  w.stats.impacts=w.stats.impacts+1
  w.effects[#w.effects+1]={x=s.headX,y=s.headY,age=0}
  local a=math.atan2(w.py-s.headY,w.px-s.headX)
  for i=0,P.pursuit.gunGroups-1 do
   local direction=a+i*pi/3
   for row=0,2 do for col=0,row do
    -- Rows1/2/3, same nearest-neighbor spacing and centroid as the old triangle.
    local r=P.pursuit.triangleRadius
    local forward=2*r-row*1.5*r
    local side=(col-row/2)*math.sqrt(3)*r
    local dx=forward*math.cos(direction)-side*math.sin(direction)
    local dy=forward*math.sin(direction)+side*math.cos(direction)
    spawn(w,'gun',s.headX+dx,s.headY+dy,direction,P.pursuit.gunSpeed)
   end end
  end
  local cfg=P.impactPellets
  local color=cfg.color
  for i=1,cfg.count do
   pelletRandom(w) -- Preserve the established speed sampling stream.
   local direction=a+pi/6+(i-1)*pi/3
   local speed=cfg.speedMin+(cfg.speedMax-cfg.speedMin)*pelletRandom(w)
   local stop=cfg.stopMin+math.floor(pelletRandom(w)*(cfg.stopMax-cfg.stopMin+1))
   local radius=math.floor(speed*(stop+1)/2*cfg.radiusScale+0.5)
   local initial=2*radius/cfg.launchDivisor
   spawn(w,'impactPellet',s.headX,s.headY,direction,initial,{color=color,rotation=0,spinSpeed=cfg.spinSpeed,alpha=1})
  end
  if w.onImpact then w.onImpact(s)end
 end
end
function P.advance(w)
 local live={}
 for _,b in ipairs(w.bullets)do if not b.dead then
  b.angle=b.angle+(b.turn or 0)
  local vx,vy=b.speed*math.cos(b.angle),b.speed*math.sin(b.angle)
  if b.driftS then vx=vx+b.driftS*math.cos(b.driftA);vy=vy+b.driftS*math.sin(b.driftA)end
  b.heading=math.atan2(vy,vx);b.x,b.y=b.x+vx,b.y+vy;b.age=b.age+1
  if b.kind=='impactPellet' then
   b.rotation=b.rotation+b.spinSpeed
   local cfg=P.impactPellets
   if not b.fadeAge and w.px and (b.x-w.px)^2+(b.y-w.py)^2<=cfg.fadeDistance^2 then b.fadeAge=0 end
   if b.fadeAge then
    b.fadeAge=b.fadeAge+1
    local f=math.min(1,b.fadeAge/cfg.fadeFrames)
    b.alpha=1-f*f*(3-2*f)
    if b.fadeAge>=cfg.fadeFrames then b.dead=true end
   end
  end
  if b.dead or b.lifetime and b.age>=b.lifetime or math.abs(b.x)>256 or b.y< -64 or b.y>512 then b.dead=true else live[#live+1]=b end
 end end
 w.bullets=live
 local fx={};for _,e in ipairs(w.effects)do e.age=e.age+1;if e.age<=18 then fx[#fx+1]=e end end;w.effects=fx
end
function P.step(w,px,py)
 w.px,w.py=px,py
 w.opening=w.phase=='spell' and w.elapsed<P.openingFrames
 w.elapsed=w.elapsed+1
 w.dialogue=nil;w.charging=false
 if w.opening then
  local s=w.seiran
  local entryStart=P.dialogueFrames
  local entryEnd=entryStart+P.entryFrames
  local chargeStart=entryEnd+P.dialogueFrames
  local u=math.max(0,math.min(1,(w.elapsed-entryStart)/P.entryFrames))
  s.x=-80;s.y=-64+192*u*u*(3-2*u)
  s.headX=s.x+P.pursuit.headX;s.headY=s.y+P.pursuit.headY
  s.entering=w.elapsed>entryStart and w.elapsed<entryEnd
  if w.elapsed<=entryStart then w.dialogue='ringo'
  elseif w.elapsed>entryEnd and w.elapsed<=chargeStart then w.dialogue='seiran'
  elseif w.elapsed>chargeStart then
   w.charging=true;w.chargeAge=w.elapsed-chargeStart
   if w.chargeAge==1 and w.onCharge then w.onCharge()end
  end
  return
 end
 if w.phase=='nonspell' then flower(w)else sisters(w)end
 P.seiranStep(w)
 if w.move then
  local m=w.move;local speed=(1-m.age/m.n)^2;m.age=m.age+1
  w.x=math.max(-120,math.min(120,w.x+m.dx*speed));w.y=math.max(96,math.min(160,w.y+m.dy*speed))
  if m.age>=m.n then w.move=nil end
 end
 P.advance(w);w.t=w.t+1
end
function P.clear(w)
 for _,b in ipairs(w.bullets)do b.dead=true end
 w.bullets={};w.effects={};w.seiran=nil;w.move=nil
end
