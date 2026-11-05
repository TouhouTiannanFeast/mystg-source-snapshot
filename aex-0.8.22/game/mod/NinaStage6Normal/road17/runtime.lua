-- Narrow ECL scheduler for the selected stage-five routines.
-- Native source coordinates are x[-192,192], y[0,448] (downward).
TH11S6Runtime={}
local R=TH11S6Runtime
local pi=math.pi
local function zeros() return setmetatable({},{__index=function()return 0 end}) end
function R.copy(v)
 if type(v)~='table' then return v end
 local t={};for k,x in pairs(v) do t[k]=R.copy(x) end;return t
end
function R.rad(x)return (x+pi)%(2*pi)-pi end
function R.float(x)return x end
function R.integer(x)return x<0 and math.ceil(x) or math.floor(x) end
function R.bitAnd(a,b)
 local out,p=0,1
 while a>0 and b>0 do local x,y=a%2,b%2;if x==1 and y==1 then out=out+p end;a=math.floor(a/2);b=math.floor(b/2);p=p*2 end
 return out
end
function R.truth(x)return x~=false and x~=nil and x~=0 end
function R.dec(t,k)local x=t[k];t[k]=x-1;return x end
function R.polar(ang,r)return math.cos(ang)*r,math.sin(ang)*r end
function R.aim(a)return math.atan2(R.playerY-a.y,R.playerX-a.x) end
function R.value(a,k)
 if k=='DIFF' then return 1
 elseif k=='ABS_ANGLE_PLAYER' then return a.mirror and R.rad(pi-R.aim(a)) or R.aim(a)
 elseif k=='ANGLE_PLAYER' then return R.aim(a)
 elseif k=='FINAL_X' then return a.x elseif k=='FINAL_Y' then return a.y
 elseif k=='FINAL_ANGLE' then return a.angle or 0
 elseif k=='PLAYER_X2' then return R.playerX elseif k=='PLAYER_Y2' then return R.playerY
 elseif k=='RAND' then return math.floor(R.random()*2147483647)
 elseif k=='RANDF' then return R.random() elseif k=='RANDF2' then return R.random()*2-1
 elseif k=='RANDRAD' then return (R.random()*2-1)*pi
 elseif k=='TIMEOUT' then return 0 elseif k=='TIME' then return R.tick
 elseif k=='LIFE' then return R.hp
 elseif k=='DS1' then return R.photos or 0 end
 error('unhandled source register '..k)
end
function R.newActor(group,x,y)
 local a={group=group,x=x,y=y,i=zeros(),f=zeros(),patterns={},threads={},bounds={0,128,280,64},age=0}
 for id=0,15 do a.patterns[id]={typ=0,color=0,n=1,layers=1,aim=0,angle=0,step=0,speed=1,speed2=1,ox=0,oy=0,dist=0,ex={},next=0} end
 R.actors[#R.actors+1]=a;return a
end
function R.call(a,name,args)
 if name=='et_ofs_r' then
  local p=a.patterns[args[1]];local x,y=R.polar((R.random()*2-1)*pi,args[2]*R.random());p.ox,p.oy=x,y;return
 elseif name=='EffChargePoint3' or name=='Ecl_EtBreak' then return end
 local fn=assert(TH11S6Programs[a.group][name],'missing source routine '..a.group..'/'..name)
 local e={i=zeros(),f=zeros(),clock=0,pc=1}
 for i,k in ipairs(fn.params) do e.i[k]=args[i] or 0;e.f[k]=args[i] or 0 end
 while e.pc>0 and fn.ops[e.pc] and not a.dead do
  local op=fn.ops[e.pc]
  if e.clock<op.t then coroutine.yield(op.t-e.clock);e.clock=op.t end
  local target,clock=op.run(a,e)
  if target==0 then return end
  e.pc=target or e.pc+1;if clock then e.clock=clock end
  R.instructions=R.instructions+1
  assert(R.instructions<200000,'source routine failed to yield: '..name)
 end
end
function R.spawn(a,name,args,id)
 local thread={id=id or -1,wake=R.tick,co=coroutine.create(function()R.call(a,name,args)end)}
 a.threads[#a.threads+1]=thread;return thread
end
local ignore={nop=true,DS_nice=true,DS_scoreMult=true,DS_timer=true,anmOnPhoto=true,anmPlay=true,anmSelect=true,anmSelectedPlay=true,anmSetMain=true,anmSetSprite=true,bombShield=true,dropArea=true,dropClear=true,dropExtra=true,dropItems=true,fog=true,lifeMarker=true,lifeSet=true,playSound=true,setBoss=true,setChapter=true,setInterrupt=true,spellEnd=true,spellEx=true,spellTimeout=true,stars=true,timerReset=true,unknown461=true,unknown462=true,spec4=true}
R.hostCommands=ignore
local function pat(a,id)return assert(a.patterns[id],'missing etNew '..id) end
-- Only the two pre-midboss crow batches use Hard attack parameters.
local function attackDifficulty(a)return (a.name=='Crow00' or a.name=='Crow01')and 2 or 1 end
local function tween(a,kind,duration,mode,from,to)
 a[kind]={age=0,n=duration,mode=mode,from=from,to=to}
end
function R.command(a,e,k,v)
 R.coverage[k]=true
 -- ECL wait subtracts currentTime, then resumes at the same script time.
 if k=='wait' then local n=math.max(1,math.floor(v[1]));coroutine.yield(n)
 elseif k=='delete' then a.dead=true
 elseif k=='anmSetSprite' and a.name=='BossBomb' then
  -- The ECL mnemonic selects an ANM script, not a raw sprite number.
  if a.name=='BossBomb' and v[2]==26 then a.visualStart=R.tick end
 elseif k=='playSound' then if R.onSound then R.onSound(v[1],a.x) end
 elseif k=='dropMain' then a.dropMain=v[1]
 elseif k=='dropClear' then a.dropExtra={}
 elseif k=='dropExtra' then a.dropExtra=a.dropExtra or {};a.dropExtra[v[1]]=v[2]
 elseif k=='dropArea' then a.dropArea={v[1],v[2]}
 elseif k=='anmSetMain' or k=='anmSetSprite' then a.anm=a.anm or {};a.anm[v[1]]=v[2];if v[1]==0 then a.poseStart=a.age;a.walkMain=k=='anmSetMain' end
 elseif k=='unknown361' then a.entryTimer=v[1]

 elseif k=='dialogRead' then if v[1]==0 then R.roadEnd=true;a.dead=true end
 elseif k=='dialogWait' then return -- dialogue UI omitted
 elseif k=='waitMidboss' then
  while R.bossPresent do coroutine.yield(1)end
  R.resumeTick=R.tick -- post-boss source waves start here, without a1000f gap
 elseif k=='anmPlayAbs' then return -- source MapleEnemy effects handled by the local scene
 elseif ignore[k] then return
 elseif k=='killAllAsync' then for _,th in ipairs(a.threads) do if th.co~=coroutine.running() and th.id~=-2 then th.dead=true end end
 elseif k=='killAsync' then for _,th in ipairs(a.threads) do if th.id==v[1] then th.dead=true end end
 elseif k=='flagSet' or k=='flagClear' then
  -- Retail boss survival/invulnerability flags are replaced by the shooting host.
  if a~=R.boss then
   local flags=a.flags or 0
   if k=='flagSet' then a.flags=flags+v[1]-R.bitAnd(flags,v[1]) else a.flags=flags-R.bitAnd(flags,v[1]) end
  end
 elseif k=='setInvuln' then a.invuln=v[1]
 elseif k=='setHurtbox' then a.hurtW,a.hurtH=v[1],v[2]
 elseif k=='setHitbox' then a.hitW,a.hitH=v[1],v[2]
 elseif k=='enmKillAll' then for _,o in ipairs(R.actors) do if o~=a then o.dead=true end end
 elseif k=='etCancel' or k=='etClear' or k=='laserCancel' then R.clearHazards(k=='laserCancel')
 elseif k=='moveLimit' then a.bounds=R.copy(v)
 elseif k=='moveLimitReset' then a.bounds=nil
 elseif k=='movePos' then a.x,a.y=v[1],v[2];a.positionTween=nil;a.orbit=nil
 elseif k=='moveCircleRel' then
  local o=a.relativeOrbit or {angle=0,omega=0,radius=0,dr=0}
  for i,key in ipairs({'angle','omega','radius','dr'})do if v[i]>-990 then o[key]=v[i] end end
  a.relativeOrbit=o
 elseif k=='diffWait' then coroutine.yield(math.max(1,v[attackDifficulty(a)+1]))
 elseif k=='etCountD' then local p=pat(a,v[1]);local d=attackDifficulty(a);p.n,p.layers=v[d+2],v[d+6]
 elseif k=='etSpeedD' then local p=pat(a,v[1]);local d=attackDifficulty(a);p.speed,p.speed2=v[d+2],v[d+6]
 elseif k=='movePosTime' then
  a.orbit=nil;tween(a,'positionTween',v[1],v[2],{a.x,a.y},{v[3],v[4]})
 elseif k=='movePosRelTime' then
  tween(a,'relativeTween',v[1],v[2],{a.offsetX or 0,a.offsetY or 0},{v[3],v[4]})
 elseif k=='moveVelRel' then a.relativeAngle,a.relativeSpeed=v[1],v[2]
 elseif k=='moveVel' then a.angle,a.speed=v[1],v[2];a.positionTween=nil;a.orbit=nil
 elseif k=='moveVelTime' then tween(a,'velocityTween',v[1],v[2],{a.angle or 0,a.speed or 0},{v[3]<-990 and (a.angle or 0) or v[3],v[4]<-990 and (a.speed or 0) or v[4]})
 elseif k=='moveAngleTime' then tween(a,'angleTween',v[1],v[2],{a.angle or 0},{v[3]})
 elseif k=='moveSpeedTime' then tween(a,'speedTween',v[1],v[2],{a.speed or 0},{v[3]})
 elseif k=='moveCircle' then a.orbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],x=a.x,y=a.y}
 elseif k=='moveEllipse' then
  -- Retail 0x414455 / 0x459670: arg5 is axis rotation; arg6
  -- scales the perpendicular radius. Linear relative motion is independent.
  a.orbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],x=a.x,y=a.y,tilt=v[5],ratio=v[6]}

 elseif k=='moveRand' then
  local ang
  local b=a.bounds
  if b then
   local u=R.random()*2-1
   if a.x<b[1]-b[3]/4 then ang=u*pi/3
   elseif a.x>b[1]+b[3]/4 then ang=R.rad(pi+u*pi/3)
   elseif a.x<R.playerX then ang=u*pi/2 else ang=R.rad(pi+u*2*pi) end
   if a.y<b[2]-b[4]/4 then ang=math.abs(ang) elseif a.y>b[2]+b[4]/4 then ang=-math.abs(ang) end
  else ang=(R.random()*2-1)*pi end
  a.orbit=nil;a.angle=ang;a.speed=v[3];tween(a,'velocityTween',v[1],v[2],{ang,v[3]},{ang,0})
 elseif k:match('^enmCreate') then
  if v[1]=='MapleEnemy' then return end
  if v[1]=='Boss' then R.roadEnd=true;return end
  if v[1]=='MBoss' then
   -- Suspend only the road controller; surviving minors keep their own clocks.
   R.midbossRequested=R.tick;R.midbossPending=true
   while R.roadRemaining()>0 do coroutine.yield(1)end
   R.midbossPending=false;R.bossPresent=true;R.midbossBorn=R.tick
   if R.onMidboss then R.onMidboss()end;return
  end
  if k:sub(-1)=='F' and R.bossPresent then R.skipped=R.skipped+1;return end
  if v[1]=='Ecl_EtBreak' then return end
  local x,y=v[2],v[3];if not k:find('A') then x,y=x+a.x,y+a.y end
  local child=R.newActor(a.group,x,y);child.i,child.f=R.copy(a.i),R.copy(a.f)
  setmetatable(child.i,{__index=function()return 0 end});setmetatable(child.f,{__index=function()return 0 end})
  child.hp=v[4]*2;child.dropMain=v[6];child.mirror=k:find('M')~=nil;child.name=v[1];child.born=R.tick;R.spawn(child,v[1],{},-2)
  if child.name=='BPhantom00' then child.hp=child.hp*2 end
  if R.onActor then R.onActor(child) end
 elseif k=='etNew' then a.patterns[v[1]]={typ=0,color=0,n=1,layers=1,aim=0,angle=0,step=0,speed=1,speed2=1,ox=0,oy=0,dist=0,ex={},next=0}
 elseif k=='etCopy' then a.patterns[v[1]]=R.copy(pat(a,v[2]))
 elseif k=='etAim' then pat(a,v[1]).aim=v[2]
 elseif k=='etSprite' then local p=pat(a,v[1]);p.typ,p.color=v[2],v[3]
 elseif k=='etCount' then local p=pat(a,v[1]);p.n,p.layers=v[2],v[3]
 elseif k=='etAngle' then local p=pat(a,v[1]);p.angle,p.step=v[2],v[3]
 elseif k=='etSpeed' then local p=pat(a,v[1]);p.speed,p.speed2=v[2],v[3]
 elseif k=='etOffset' or k=='etOffsetAbs' then local p=pat(a,v[1]);p.ox,p.oy,p.absolute=v[2],v[3],k=='etOffsetAbs'
 elseif k=='etOffsetRad' then local p=pat(a,v[1]);p.ox,p.oy=R.polar(v[2],v[3]);p.absolute=false
 elseif k=='etDist' then pat(a,v[1]).dist=v[2]
 elseif k=='etSound' then return
 elseif k=='etEx' or k=='etEx2' or k=='etExSet' or k=='etExSet2' then
  local p=pat(a,v[1]);local indexed=a.group=='th11' or a.group:sub(1,2)=='ds' or k:find('Set')
  local slot=indexed and v[2] or p.next;local start=indexed and 3 or 2
  local rec={async=v[start],kind=v[start+1],i=v[start+2],j=v[start+3],r=v[start+4],s=v[start+5]}
  if k:sub(-1)=='2' then rec.i,rec.j,rec.k,rec.l=v[start+2],v[start+3],v[start+4],v[start+5];rec.r,rec.s,rec.u,rec.v=v[start+6],v[start+7],v[start+8],v[start+9] end
  p.ex[slot]=rec;if not indexed then p.next=slot+1 end
 elseif k=='etOn' then R.fire(a,pat(a,v[1]))
 elseif k=='laserNew' then
  local p=pat(a,v[1]);p.laser={start=v[2],length=v[3],max=v[4],width=v[5]}
  if a.group=='dsd' then p.laser={nativeLine=true,initial=v[2],length=v[2],max=v[3],terminal=v[4],travel=0,width=v[5]} end
 elseif k:find('^laserOn') then
  if a.group=='th11' then
   local p={typ=v[1],color=v[2],angle=v[3],speed=v[4],n=1,layers=1,aim=1,ox=0,oy=0,dist=v[5],ex={}}
   p.laser={length=v[6],max=v[6],width=v[8]}
   -- All selected TH10 laser cards use native growth before tail movement.
   -- Keep card1 covered: verify-line-growth.py guards against partial fixes.
   if R.spec.id=='th11-card1' or R.spec.id=='th11-card2' or R.spec.id=='th11-card6' then
    p.dist=0
    p.laser={nativeLine=true,initial=v[5],length=v[5],max=v[6],terminal=v[7],width=v[8]}
   end
   if k=='laserOn3' or k=='laserOnA2' then p.ex=R.copy(pat(a,0).ex) end
   R.fire(a,p)
  else R.fire(a,pat(a,v[1])) end
 else error('unimplemented ECL command '..k) end
end
local function ease(x,mode)
 if mode==1 then return x*x elseif mode==2 then return x*x*x elseif mode==3 then return x*x*x*x
 elseif mode==4 then return 1-(1-x)^2 elseif mode==5 then return 1-(1-x)^3 elseif mode==6 then return 1-(1-x)^4 end
 return x
end
local function advance(t)
 if t.mode==7 then
  t.age=t.age+1
  if t.age<t.n then for i,x in ipairs(t.from) do t.from[i]=x+t.to[i] end end
  return R.copy(t.from),t.age>=t.n
 end
 t.age=t.age+1;local u=ease(math.min(1,t.age/math.max(1,t.n)),t.mode);local v={}
 for i,x in ipairs(t.from) do v[i]=x+(t.to[i]-x)*u end
 return v,t.age>=t.n
end
function R.motion(a)
 a.x,a.y=a.x-(a.offsetX or 0),a.y-(a.offsetY or 0)
 if a.positionTween then
  local v,done=advance(a.positionTween);a.x,a.y=v[1],v[2];if done then a.positionTween=nil end
 else
  if a.velocityTween then local v,done=advance(a.velocityTween);a.angle,a.speed=v[1],v[2];if done then a.velocityTween=nil end end
  if a.angleTween then local v,done=advance(a.angleTween);a.angle=v[1];if done then a.angleTween=nil end end
  if a.speedTween then local v,done=advance(a.speedTween);a.speed=v[1];if done then a.speedTween=nil end end
  if a.orbit then
   local o=a.orbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
   local u=(o.angle-o.tilt);local x,y=math.cos(u)*o.radius,math.sin(u)*o.radius*o.ratio
   a.x=o.x+x*math.cos(o.tilt)-y*math.sin(o.tilt)
   a.y=o.y+x*math.sin(o.tilt)+y*math.cos(o.tilt)
  elseif a.speed then a.x=a.x+(a.mirror and -1 or 1)*math.cos(a.angle)*a.speed;a.y=a.y+math.sin(a.angle)*a.speed end
 end
 if a.relativeTween then local v,done=advance(a.relativeTween);a.offsetX,a.offsetY=v[1],v[2];if done then a.relativeTween=nil end end
 if a.relativeOrbit then
  local o=a.relativeOrbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
  a.offsetX,a.offsetY=math.cos(o.angle)*o.radius,math.sin(o.angle)*o.radius
 end
 if a.relativeSpeed then
  a.offsetX=(a.offsetX or 0)+math.cos(a.relativeAngle)*a.relativeSpeed
  a.offsetY=(a.offsetY or 0)+math.sin(a.relativeAngle)*a.relativeSpeed
 end
 a.x,a.y=a.x+(a.offsetX or 0),a.y+(a.offsetY or 0)
end
function R.roadRemaining()
 local n=0
 for _,a in ipairs(R.actors or {})do if not a.controller and not a.dead then n=n+1 end end
 return n
end
function R.start(seed)
 R.midbossRequested=nil;R.midbossPending=false
 R.resumeTick=nil
 R.actors={};R.hazards={};R.tick=0;R.instructions=0;R.coverage={};R.stats={bullets=0,lasers=0,actors=0};R.invuln=0;R.bossPresent=false;R.roadEnd=false;R.midbossBorn=nil;R.skipped=0
 R.random=function()return ran:Float(0,1)end;R.playerX,R.playerY=0,400
 R.spec={group='th11',id='road'};R.hp=1
 R.controller=R.newActor('th11',0,0);R.controller.controller=true;R.controller.name='RoadController';R.spawn(R.controller,'main',{},-2)
end
