-- Isolated LE03 stage-four Normal road runtime; no existing encounter is patched.
Le03={enemies={},shots={},tick=0,finished=false,counts={enemies=0,shots=0}}
local R=Le03
local C=Le03Constants
local M=Le03Movement
local cos,sin=math.cos,math.sin
local function f(x)return M.f32()(x)end
local function inside(e)return e.x>=-150 and e.x<=534 and e.y>=-150 and e.y<=598 end
local function bulletInside(b)return b.x>=-50 and b.x<=434 and b.y>=-50 and b.y<=498 end
function R.start(seed)
 R.tick=0;R.finished=false;R.enemies={};R.shots={};R.spawned={};R.counts={enemies=0,shots=0,damage=0,defeats=0}
 R.seed=(seed or 20261029)%2147483647;if R.seed==0 then R.seed=1 end
 R.px,R.py=192,400
 assert(Le03Schedule and #Le03Schedule==122,'LE03 source schedule not loaded')
 for i,c in ipairs(Le03Schedule)do local e=M.create(c);e.active=false;e.sourceIndex=i;R.enemies[i]=e end
end
function R.randomUnit()
 R.seed=R.seed*16807%2147483647
 return math.floor((R.seed-1)/2147483646*10000)/10000
end
function R.randomInt(n)
 local v=R.randomUnit()*n*2-n
 return v>=0 and math.floor(v)or math.ceil(v)
end
function R.aim(x,y)return math.atan2(R.py-y,R.px-x)end
function R.shot(e,x,y,speed,angle,behavior)
 local b={x=f(x),y=f(y),speed=f(speed),angle=angle,behavior=behavior or 0,
  typ=e.bulletKind or e.typ or 3,col=e.color or e.col or 0,scale=1,age=0,
  vx=0,vy=0,state=0,p1=0,p2=0,active=true,cullDelay=0,alpha=255,birth=0}
 R.shots[#R.shots+1]=b;R.counts.shots=R.counts.shots+1
 return b
end
function R.laser(e,angle,length,period,index)
 local b=R.shot(e,e.x,e.y,10,angle,0)
 b.laser=true;b.length=length;b.width=10;b.hitScale=.6000000238418579
 b.orbit=angle;b.period=period;b.index=index;b.owner=e;b.renderX=e.x;b.renderY=e.y
 -- Host construction is delayed until the next step, so laser fields exist.
 b._needsLaserHost=true
 return b
end
function R.damageEnemy(e,amount)
 if not e.active or e.invincible~=0 then return end
 R.counts.damage=R.counts.damage+amount
 e.hp=e.hp-amount
 if e.hp<=0 then
  e.hp=0;e.active=false;e.defeated=true
  R.counts.defeats=R.counts.defeats+1
  if R.onDefeat then R.onDefeat(e)end
 end
end
function R.cancelBullets()for _,b in ipairs(R.shots)do b.active=false end end
local function laserStep(b)
 local e=b.owner
 if e.active then
  b.orbit=C.d('0086b298')/b.period*b.age+b.index*C.d('0086b1f8')
  b.angle=b.orbit
  -- Native secondary stores beam midpoint on a half-length orbit.
  b.x=e.x+cos(b.orbit)*b.length/2;b.y=e.y+sin(b.orbit)*b.length/2
  b.renderX=e.x;b.renderY=e.y
 else
  -- Native secondary1 releases six projectiles and deletes the beam.
  for i=0,5 do
   local offset=(b.length*.5)/3-(b.length/6)*i
   R.shot(b,b.x+cos(b.angle)*offset,b.y+sin(b.angle)*offset,2.5,b.angle+C.d('0086b1f8'),0)
  end
  b.active=false
 end
 b.age=b.age+1
end
function R.step(px,py)
 R.px,R.py=px or R.px,py or R.py
 for _,e in ipairs(R.enemies)do
  if e.active then M.step(e,function(o)Le03Firing.fire(R,o)end,inside)end
 end
 -- Native behavior pass precedes all bullet motion; snapshot avoids giving newly
 -- split children an extra behavior tick. Native motion still includes children.
 local n=#R.shots
 for i=1,n do local b=R.shots[i]
  if b.active then
   if b.laser then laserStep(b)
   else Le03Firing.behavior(R,b)end
  end
 end
 for _,b in ipairs(R.shots)do
  if b.active and not b.laser then
   b.x=f(b.x);b.y=f(b.y);b.speed=f(b.speed);b.vx=f(b.vx);b.vy=f(b.vy)
   b.angle=b.angle%(2*math.pi)
   b.x=f(b.x+f(f(cos(b.angle))*b.speed));b.y=f(b.y+f(f(sin(b.angle))*b.speed))
   b.x=f(b.x+b.vx);b.y=f(b.y+b.vy);b.speed=f(b.speed);b.vx=f(b.vx);b.vy=f(b.vy)
   b.age=b.age+1
   if b.age>=b.cullDelay and not bulletInside(b)then b.active=false end
  end
  if b.active and not b._host and R.onShot then R.onShot(b)end
 end
 -- FUN_0049bbf0 activates rows after enemy/bullet updating; retain authored order.
 for i,c in ipairs(Le03Schedule)do
  if not R.spawned[i] and c[1]==R.tick then
   local e=R.enemies[i];e.active=true;R.spawned[i]=true
   R.counts.enemies=R.counts.enemies+1;if R.onEnemy then R.onEnemy(e)end
  end
 end
 if R.tick>9500 then
  local alive=false;for _,e in ipairs(R.enemies)do if e.active then alive=true;break end end
  R.finished=not alive
 end
 R.tick=R.tick+1
 -- Keep active gameplay objects only; counters and source rows are retained.
 if R.tick%120==0 then local kept={};for _,b in ipairs(R.shots)do if b.active then kept[#kept+1]=b end end;R.shots=kept end
end
