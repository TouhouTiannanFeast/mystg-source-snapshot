-- Encounter-local source coordinates: x[0,384], y[0,448], down positive.
-- No existing stage scheduler, projectile table or resource rule is modified.
Zuu4R={}
local R=Zuu4R
local pi=math.pi
function R.cos(a)return math.cos(a*pi/180)end
function R.sin(a)return math.sin(a*pi/180)end
function R.atan(y,x)return math.atan2(y,x)*180/pi end
function R.rand(lo,hi)return lo+(hi-lo)*R.random()end
function R.aim(o)return R.atan(R.py-o.y,R.px-o.x)end
function R.wait(n)coroutine.yield(math.max(1,math.ceil(n)))end
function R.spawn(fn)
 local t={co=coroutine.create(fn),wake=R.tick,generation=R.generation}
 R.threads[#R.threads+1]=t;R.resume(t);return t
end
function R.resume(t)
 local ok,n=coroutine.resume(t.co);assert(ok,n)
 t.dead=coroutine.status(t.co)=='dead';t.wake=R.tick+(n or 1)
end
function R.actor(x,y,kind,hp,link)
 local a={x=x,y=y,kind=kind,hp=hp or 55,link=link or 0,age=0,angle=0,speed=0,visible=true}
 R.actors[#R.actors+1]=a;if R.onActor then R.onActor(a)end;return a
end
function R.move(o,x,y,n,mode)
 o.motion={x=o.x,y=o.y,tx=x,ty=y,n=n,t=0,mode=mode};o.speed=0
end
function R.weightMove(o,x,y,weight,maxspeed,accel,initial)
 o.motion={tx=x,ty=y,weight=weight,maxspeed=maxspeed,accel=accel,speed=initial};o.speed=0
end
function R.motionStep(o)
 if o.motion then
  local m=o.motion
  if m.weight then
   local dx,dy=m.tx-o.x,m.ty-o.y;local d=math.sqrt(dx*dx+dy*dy)
   m.speed=math.min(m.maxspeed,m.speed+m.accel)
   local s=math.min(d,math.min(m.speed,d/m.weight))
   if d<0.1 then o.x,o.y=m.tx,m.ty;o.motion=nil else o.x,o.y=o.x+dx/d*s,o.y+dy/d*s end
  else
   m.t=m.t+1;local u=math.min(1,m.t/m.n)
   if m.mode=='smooth' then u=(1-math.cos(u*pi))/2 elseif m.mode=='decel' then u=1-(1-u)^2 end
   o.x,o.y=m.x+(m.tx-m.x)*u,m.y+(m.ty-m.y)*u
   if m.t>=m.n then o.motion=nil end
  end
 elseif o.speed then o.x,o.y=o.x+o.speed*R.cos(o.angle),o.y+o.speed*R.sin(o.angle)end
end
function R.shot(x,y,speed,angle,id,delay,accel,limit)
 local b={x=x,y=y,speed=speed,angle=angle,id=id,delay=delay or 0,accel=accel or 0,limit=limit,
 age=0,radius=assert(Zuu4Art.shots[id],'unknown HSoB shot '..id).radius,kind='shot'}
 R.hazards[#R.hazards+1]=b;R.counts.shots=R.counts.shots+1
 if R.onShot then R.onShot(b)end;return b
end
function R.beam(x,y,angle,length,width,warning,life,mode,speed)
 local b={x=x,y=y,angle=angle,length=length,width=width,delay=warning or 0,life=life or 120,
 age=0,kind='beam',mode=mode,speed=speed or 0,radius=width/2}
 R.hazards[#R.hazards+1]=b;R.counts.beams=R.counts.beams+1
 if R.onShot then R.onShot(b)end;return b
end
function R.nuclear(x,y,r,life)
 local b={x=x,y=y,radius=r,life=life,delay=30,age=0,kind='nuclear',angle=0}
 R.hazards[#R.hazards+1]=b;if R.onShot then R.onShot(b)end;return b
end
function R.accelerate(b,at,accel,limit)
 b.events=b.events or {};b.events[#b.events+1]={at=at,accel=accel,limit=limit}
end
function R.clear()
 for _,b in ipairs(R.hazards or {})do b.dead=true end
 for _,a in ipairs(R.actors or {})do a.dead=true end
 R.threads={};R.generation=(R.generation or 0)+1
end
function R.clearBullets()for _,b in ipairs(R.hazards)do b.dead=true end end
function R.start(id,seed,x,y)
 R.clear();R.id=id;R.tick=0;R.threads={};R.actors={};R.hazards={};R.counts={shots=0,beams=0}
 R.px,R.py=192,400;R.hp=Zuu4Specs[id].hp;R.maxhp=R.hp;R.subphase=0
 R.tablet=nil;R.wings=id=='non3' or id=='stone';R.wingStart=0;R.finalRage=0;R.links={};R.wingColliders=nil
 local state=(seed or 20261027)%2147483647;if state<=0 then state=1 end
 R.random=function()state=state*16807%2147483647;return (state-1)/2147483646 end
 R.boss={x=x or 192,y=y or 128,angle=0,speed=0}
 R.spawn(function()Zuu4Patterns[id](R.boss)end)
 if R.wings and R.enableWings then R.enableWings(R.boss)end
end
local function targetSpeed(b)
 if b.profile then
  local t=b.age-(b.nativeBirth and 8 or 0);local p=b.profile
  if t<p.hold then return p.initial end
  t=t-p.hold
  if t<p.n1 then return p.initial+(p.s1-p.initial)*(t+1)/p.n1 end
  t=t-p.n1
  if p.n2 and t<p.n2 then return p.s1+(p.s2-p.s1)*(t+1)/p.n2 end
  return p.s2 or p.s1
 end
end
function R.projectileStep(b)
 if b.dead then return end
 if b.update then b.update(b)end
 if b.dead then return end
 for _,e in ipairs(b.events or {})do if b.age==e.at then b.accel,b.limit=e.accel,e.limit end end
 if (b.kind=='shot' or b.kind=='driver' or(b.kind=='nuclear' and b.moving)) and not b.scriptedPosition and not(b.nativeBirth and b.age<8) then
  if b.vx then
   if b.avy and b.avy~=0 then
    local vy=b.vy+b.avy
    if b.avy>0 then vy=math.min(vy,b.maxvy)else vy=math.max(vy,b.maxvy)end;b.vy=vy
   end
   b.x,b.y=b.x+b.vx,b.y+b.vy;b.angle=R.atan(b.vy,b.vx)
  else
   local s=targetSpeed(b)
   if s then b.speed=s
   elseif b.accel~=0 then
    b.speed=b.speed+b.accel
    if b.limit then if b.accel>0 then b.speed=math.min(b.speed,b.limit)else b.speed=math.max(b.speed,b.limit)end end
   end
   b.x,b.y=b.x+b.speed*R.cos(b.angle),b.y+b.speed*R.sin(b.angle)
  end
 elseif b.kind=='beam' and b.mode=='loose' then
  b.x,b.y=b.x+b.speed*R.cos(b.angle),b.y+b.speed*R.sin(b.angle)
 end
 if b.wraps and b.wraps>0 and b.age>=128 and (b.y<0 or b.y>448)then
  if b.y<0 then b.y=b.y+448 else b.y=b.y-448 end;b.wraps=b.wraps-1
 end
 if b.afterMove then b.afterMove(b)end
 b.age=b.age+1
 if b.life and b.age>=b.life then b.dead=true end
 if not b.noCull and (b.x< -96 or b.x>480 or b.y< -96 or b.y>544)then b.dead=true end
end
function R.step(px,py,hp)
 R.px,R.py,R.hp=px,py,hp
 local n=#R.threads
 for i=1,n do local t=R.threads[i];if not t.dead and t.generation==R.generation and t.wake<=R.tick then R.resume(t)end end
 local live={};for _,t in ipairs(R.threads)do if not t.dead and t.generation==R.generation then live[#live+1]=t end end;R.threads=live
 R.motionStep(R.boss)
 local actors={};for _,a in ipairs(R.actors)do if not a.dead then
  if a.follow then a.x,a.y=R.boss.x+a.ox,R.boss.y+a.oy;a.visible=R.boss.visible~=false else R.motionStep(a)end
  a.age=a.age+1
  if a.cull and(a.x< -a.cull or a.x>384+a.cull or a.y< -a.cull or a.y>448+a.cull)then a.dead=true else actors[#actors+1]=a end
 end end;R.actors=actors
 local previous=R.hazards;R.hazards={}
 for _,b in ipairs(previous)do R.projectileStep(b);if not b.dead then R.hazards[#R.hazards+1]=b end end
 R.tick=R.tick+1
end
