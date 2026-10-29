-- LE03 road: Unreal baseline with the requested presentation, HP and pacing edits.
Le03={enemies={},shots={},tick=0,finished=false,counts={enemies=0,shots=0}}
local R=Le03
local C=Le03Constants
local M=Le03Movement
local cos,sin=math.cos,math.sin
local function f(x)return M.f32()(x)end
local function inside(e)return e.x>=-150 and e.x<=534 and e.y>=-150 and e.y<=598 end
local function bulletInside(b)return b.x>=-50 and b.x<=434 and b.y>=-50 and b.y<=498 end
-- Keep e.appear / the source CSV intact: presentation gates use source frames.
function R.spawnTick(sourceFrame)
 local gateDelay=sourceFrame>=2700 and(R.post24Delay or 0)or 0
 if sourceFrame<=300 then return sourceFrame end
 if sourceFrame<=4700 then
  local delay=(sourceFrame>=1900 and 180 or 0)+(sourceFrame>=4700 and 120 or sourceFrame>=4300 and 60 or 0)
  return math.floor(300+(sourceFrame-300)*.75+.5)+delay+gateDelay
 end
 return sourceFrame-800+gateDelay
end
function R.start(seed)
 R.tick=0;R.finished=false;R.enemies={};R.shots={};R.spawned={};R.openingAdded=false;R.counts={enemies=0,shots=0,damage=0,defeats=0,supplements=0,opening=0}
 R.seed=(seed or 20261029)%2147483647;if R.seed==0 then R.seed=1 end
 R.fillSeed=R.seed;R.nextFill=480
 R.post24Delay=0;R.gate24Released=false
 R.rewarded={}
 R.px,R.py=192,400
 assert(Le03Schedule and #Le03Schedule==122,'LE03 source schedule not loaded')
 for i,c in ipairs(Le03Schedule)do local e=M.create(c);e.sourceHP=e.hp;if Le03EnemyHealth then e.hp=Le03EnemyHealth.value(e)end;e.survival=e.appear==9500 and e.shot==60;if e.survival then e.invincible=1 end;e.spawnTick=R.spawnTick(e.appear);e.active=false;e.sourceIndex=i;R.enemies[i]=e end
end
local function fillRandom()
 -- Supplemental spawns must not consume the original patterns' random stream.
 R.fillSeed=R.fillSeed*16807%2147483647
 return (R.fillSeed-1)/2147483646
end
local function addFairy(index,count,opening,silent)
 local x=40+304*(index-1+fillRandom())/count
 local y=opening and 8+24*fillRandom()or -20
 local e=M.create({0,22,2,x,y,1500,0,0,0,-1,0,8,math.floor(fillRandom()*4)+3,0,-1,-1,-1,-1,-1,-1})
 e.sourceHP=e.hp;e.hp=Le03EnemyHealth and Le03EnemyHealth.value(e)or 120
 e.supplement=true;e.opening=opening;e.pointBurst=opening;e.silent=silent;e.sourceIndex=#R.enemies+1
 e.spawnTick=R.tick;e.vx=fillRandom()<.5 and -.35 or .35
 if silent then e.extraArt=silent;e.artColor=math.floor(fillRandom()*4)end
 R.enemies[#R.enemies+1]=e;R.counts.enemies=R.counts.enemies+1;R.counts.supplements=R.counts.supplements+1
 if opening then R.counts.opening=R.counts.opening+1 end
 if R.onEnemy then R.onEnemy(e)end
end
local function sparseFill()
 if R.tick<R.nextFill or R.tick>=R.spawnTick(9200)then return end
 R.nextFill=R.tick+60
 local bullets,extras=0,0
 for _,b in ipairs(R.shots)do if b.active then
  if b.laser then return end
  if b.x>=0 and b.x<=384 and b.y>=0 and b.y<=448 then bullets=bullets+1;if bullets>36 then return end end
 end end
 for _,e in ipairs(R.enemies)do if e.supplement and not e.opening and e.active then extras=extras+1 end end
 local count=5+math.floor(fillRandom()*3)
 if extras+count>14 then return end -- Whole batches only; never truncate below five.
 local batchArt=({'fairy','orb13','kedama'})[math.floor(fillRandom()*3)+1]
 local art;if batchArt~='fairy'then art=batchArt end
 for i=1,count do
  addFairy(i,count,false,art)
  R.enemies[#R.enemies].silent=true
 end
 R.nextFill=R.tick+240+math.floor(fillRandom()*121)
end
local function supplementStep(e)
 e.x=f(e.x+e.vx);e.y=f(e.y+1.5)
 if not inside(e)then e.active=false;return end
 if e.pointBurst then
  -- Newly activated objects first update at spawn+1: ages9/19/29 are +10/+20/+30.
  if e.age==9 or e.age==19 or e.age==29 then
   local errorAngle=e.age==9 and 0 or (fillRandom()*2-1)*math.pi/60
   R.shot(e,e.x,e.y,3,R.aim(e.x,e.y)+errorAngle,0)
  end
 elseif not e.silent and e.age==55 then R.shot(e,e.x,e.y,3,R.aim(e.x,e.y),0)end
 e.age=e.age+1
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
 if Le03BulletStyle then Le03BulletStyle.assign(b,e)end
 local source=e.appear or e.sourceAppear
 local first21=source==700 or source==1500 or(source and source>=1900 and source<=2220)
 local extraSlow=source==700 or source==1500
 b.roadSpeedMultiplier=e.roadSpeedMultiplier or (extraSlow and .5625 or source==1100 and .5 or (first21 or source==3900 or source==4300 or source==4700)and .75 or 1)
 b.previousX,b.previousY=b.x,b.y
 R.shots[#R.shots+1]=b;R.counts.shots=R.counts.shots+1
 return b
end
function R.laser(e,angle,length,period,index)
 local b=R.shot(e,e.x,e.y,10,angle,0)
 b.laser=true;b.length=length*2/3;b.width=10;b.hitScale=.6000000238418579
 b.orbit=angle;b.period=period;b.index=index;b.owner=e;b.renderX=e.x;b.renderY=e.y
 -- Host construction is delayed until the next step, so laser fields exist.
 b._needsLaserHost=true
 return b
end
local function reward(key,kind,e)
 if R.rewarded[key]then return end
 R.rewarded[key]=true
 if R.onReward then R.onReward(kind,e)end
end
function R.damageEnemy(e,amount)
 if not e.active or e.invincible~=0 then return end
 R.counts.damage=R.counts.damage+amount
 e.hp=e.hp-amount
 if e.hp<=0 then
  e.hp=0;e.active=false;e.defeated=true
  R.counts.defeats=R.counts.defeats+1
  if e.appear==2220 then reward('wave21Life','life',{x=192,y=80})end
  if not e.supplement and e.appear==4700 then reward('wave30Life','life',e)end
  if e.appear==3900 and e.shot==63 then reward('wave28Bomb','bomb',e)end
  if e.appear and e.appear>=7300 and e.appear<=7700 and e.shot==54 then
   local all=true
   for _,other in ipairs(R.enemies)do
    if other.appear>=7300 and other.appear<=7700 and other.shot==54 and not other.defeated then all=false;break end
   end
   if all then reward('railBomb','bomb',e)end
  end
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
  -- Native Unreal secondary1 releases eight projectiles and deletes the beam.
  for i=0,7 do
   local offset=(b.length*.5)/4-(b.length/8)*i
   R.shot(b,b.x+cos(b.angle)*offset,b.y+sin(b.angle)*offset,2.5,b.angle+C.d('0086b1f8'),0)
  end
  b.active=false
 end
 b.age=b.age+1
end
function R.step(px,py)
 R.px,R.py=px or R.px,py or R.py
 for _,e in ipairs(R.enemies)do
  if e.active then
   if e.appear==9500 and R.tick-e.spawnTick>=720 then
    e.active=false;e.timedOut=true -- Forced exit, never counted as a defeat.
    if e.survival then reward('finalLife','life',e)end
   elseif e.supplement then supplementStep(e)else M.step(e,function(o)Le03Firing.fire(R,o)end,inside)end
   if e.appear==2220 and not e.active then reward('wave21Life','life',{x=192,y=80})end
   if not e.supplement and e.appear==4700 and not e.active then reward('wave30Life','life',{x=192,y=80})end
  end
 end
 -- Native behavior pass precedes all bullet motion; snapshot avoids giving newly
 -- split children an extra behavior tick. Native motion still includes children.
 local n=#R.shots
 for i=1,n do local b=R.shots[i]
  if b.active then
   b.previousX,b.previousY=b.x,b.y
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
   if b.motionMultiplier==2 then b.x=f(b.previousX+2*(b.x-b.previousX));b.y=f(b.previousY+2*(b.y-b.previousY))end
   local travel=b.roadSpeedMultiplier or 1
   if travel~=1 then b.x=f(b.previousX+travel*(b.x-b.previousX));b.y=f(b.previousY+travel*(b.y-b.previousY))end
   b.age=b.age+1
   if b.age>=b.cullDelay and not bulletInside(b)then b.active=false end
  end
  if b.active and not b._host and R.onShot then R.onShot(b)end
 end
 -- Hold wave25 and all later waves until wave24's enemy and last bullets are gone.
 if not R.gate24Released and R.tick>=R.spawnTick(2700)then
  local busy=false
  for i,e in ipairs(R.enemies)do
   if e.appear==2280 and(not R.spawned[i]or e.active)then busy=true;break end
  end
  if not busy then for _,b in ipairs(R.shots)do
   if b.active and b.sourceAppear==2280 then busy=true;break end
  end end
  if busy then
   R.post24Delay=R.post24Delay+1
   for i,e in ipairs(R.enemies)do
    if e.appear>=2700 and not R.spawned[i]then e.spawnTick=e.spawnTick+1 end
   end
  else R.gate24Released=true end
 end
 -- FUN_0049bbf0 activates rows after enemy/bullet updating; retain authored order.
 for i,c in ipairs(Le03Schedule)do
  if not R.spawned[i] and R.enemies[i].spawnTick==R.tick then
   local e=R.enemies[i];e.active=true;R.spawned[i]=true
   R.counts.enemies=R.counts.enemies+1;if R.onEnemy then R.onEnemy(e)end
  end
 end
 if not R.openingAdded and R.tick==R.spawnTick(300)then
  R.openingAdded=true;for i=1,10 do addFairy(i,10,true)end
 end
 sparseFill()
 if R.tick>R.spawnTick(9500)then
  local alive=false;for _,e in ipairs(R.enemies)do if e.active then alive=true;break end end
  R.finished=not alive
 end
 R.tick=R.tick+1
 -- Keep active gameplay objects only; counters and source rows are retained.
 if R.tick%120==0 then local kept={};for _,b in ipairs(R.shots)do if b.active then kept[#kept+1]=b end end;R.shots=kept end
end
