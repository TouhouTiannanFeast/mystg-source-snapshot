-- Encounter-local coordinates: source 384 x 448, positive y downward, radians.
Y3={tick=0,shots={},lasers={},threads={},birthEffects={},counts={shots=0,lasers=0},order={'non1','spell1','non2','spell2','non3','spell3'}}
local R=Y3
local pi=math.pi
R.specs={
 non1={name='',label='Nonspell 1 / TH07 Normal non2',hp=8000,time=25,hold=120},
 spell1={name='亡舞「生者必滅の理 -死蝶-」',label='Spell 1 / TH07 Normal',hp=10000,time=35,hold=240},
 non2={name='',label='Nonspell 2 / LE04 Normal',hp=10000,time=30,hold=120},
 spell2={name='生死「Eros Thanatos」',label='Spell 2 / LE04 Normal',hp=10000,time=50,hold=240},
 non3={name='',label='Nonspell 3 / TH07 Normal non4',hp=6000,time=25,hold=120},
 spell3={name='「返魂蝶 一分咲」',label='Spell 3 / TH07 Easy',hp=12000,time=35,hold=120,survival=true},
}
function R.random(a,b)
 R.seed=R.seed*16807%2147483647
 return a+(b-a)*(R.seed-1)/2147483646
end
function R.atan(y,x) return math.atan2(y,x) end
function R.aim(x,y)return R.atan(R.py-y,R.px-x)end
function R.wait(n)return coroutine.yield(n)end
function R.fork(f)R.threads[#R.threads+1]={co=coroutine.create(f),wake=R.tick}end
function R.move(x,y,n,ease)
 R.motion={x=R.boss.x,y=R.boss.y,dx=x-R.boss.x,dy=y-R.boss.y,n=n,t=0,ease=ease or 4}
end
function R.moveRandom(n,speed,loX,loY,hiX,hiY,ease)
 local a=R.random(-pi,pi)
 R.bounds={loX,loY,hiX,hiY}
 R.move(R.boss.x+math.cos(a)*speed*n,R.boss.y+math.sin(a)*speed*n,n,ease)
end
local function bit(v,n)return math.floor(v/n)%2==1 end
R.bit=bit
function R.shot(typ,col,x,y,speed,angle,flags,commands)
 flags=flags or 0
 local birth=bit(flags,2)and 8 or(bit(flags,4)and 16 or(bit(flags,8)and 32 or 0))
 local b={kind='shot',typ=typ,col=col,x=x,y=y,speed=speed,angle=angle,vx=speed*math.cos(angle),vy=speed*math.sin(angle),age=0,birth=birth,birthDiv=bit(flags,2)and 2 or(bit(flags,4)and 2.5 or 3),cmds={},ci=1,ct=0,state2=0,alpha=255,scale=1,cullDelay=0}
 for _,c in ipairs(commands or {})do if bit(flags,c[1])then
  if c[1]==8192 then b.cullDelay=c[2] else b.cmds[#b.cmds+1]={unpack(c)} end
 end end
 if birth>0 then b.x=b.x-b.vx*4;b.y=b.y-b.vy*4 end
 R.shots[#R.shots+1]=b;R.counts.shots=R.counts.shots+1
 if R.onShot then R.onShot(b)end
 return b
end
function R.pattern(mode,typ,col,n,layers,speed,speed2,a,spread,flags,cmds,x,y)
 x,y=x or R.boss.x,y or R.boss.y
 local aim=R.aim(x,y)
 for j=0,layers-1 do for i=0,n-1 do
  local s=layers>1 and speed-(speed-speed2)*j/layers or speed
  local ang=a
  if mode<=1 then
   local off=n%2==1 and math.floor((i+1)/2)*spread or(math.floor(i/2)+0.5)*spread
   ang=ang+(i%2==1 and -off or off)+(mode==0 and aim or 0)
  elseif mode<=3 then ang=ang+i*2*pi/n+j*spread+(mode==2 and aim or 0)
  elseif mode<=5 then ang=ang+pi/n+i*2*pi/n+(mode==4 and aim or 0)
  elseif mode==6 then ang=R.random(spread,a)
  elseif mode==7 then ang=ang+i*2*pi/n+j*spread;s=R.random(speed2,speed)
  elseif mode==8 then ang=R.random(spread,a);s=R.random(speed2,speed)end
  R.shot(typ,col,x,y,s,ang,flags,cmds)
 end end
end
function R.laser(x,y,a,col)
 local b={kind='laser',x=x,y=y,angle=a,col=col,age=0,start=64,length=384,width=16,warn=120,duration=120,fade=60}
 R.lasers[#R.lasers+1]=b;R.counts.lasers=R.counts.lasers+1
 if R.onLaser then R.onLaser(b)end
 return b
end
-- TH07's warning/fade hitbox mistakenly uses width/2 as its full length.
-- Keep that source behavior while rendering the full beam independently.
function R.laserGeometry(b)
 local a=b.age
 local visual=a<=90 and 1.2 or(a<b.warn and b.width*a/b.warn or b.width)
 if a>=b.warn+b.duration then visual=b.width*(1-(a-b.warn-b.duration)/b.fade)end
 local small=a<b.warn or a>=b.warn+b.duration
 local length=small and visual/2 or b.length
 return visual,b.start+(b.length-length)/2,length,b.width/2,a>=90 and a<b.warn+b.duration+30
end
function R.clear()
 for _,b in ipairs(R.shots)do b.dead=true end
 for _,b in ipairs(R.lasers)do b.dead=true end
 R.shots={};R.lasers={};R.threads={};R.birthEffects={};R.motion=nil;R.circle=nil;R.circles=nil
end
function R.start(id,seed,x,y)
 R.clear();R.id=id;R.tick=0;R.seed=(seed or 20261029)%2147483647
 if R.seed<=0 then R.seed=1 end
 R.boss={x=x or 192,y=y or 112};R.px,R.py=192,400
 R.counts={shots=0,lasers=0};R.bounds=nil;R.circle=nil;R.circles=nil;R.callback=nil
 R.begin[id]()
end
local function displace(b,vx,vy)
 if R.id=='spell3' then
  local speed=math.sqrt(vx*vx+vy*vy)
  if speed>0 then
   local scale=math.floor(speed*0.75*100+0.500000001)/100/speed
   vx,vy=vx*scale,vy*scale
  end
 end
 b.x=b.x+vx;b.y=b.y+vy
end
local function stepBullet(b)
 if b.birth>0 then
  displace(b,b.vx/b.birthDiv,b.vy/b.birthDiv);b.birth=b.birth-1
 else
  if b.update then b.update(b)end
  local c=b.cmds[b.ci]
  if c then
   local kind,n,acc,ang=c[1],c[2],c[3],c[4]
   if b.ct>=n then
    if kind==64 or kind==128 then
     b.angle=kind==128 and R.aim(b.x,b.y)+acc or b.angle+acc;b.speed=ang
    end
    b.ci=b.ci+1;b.ct=0;b.cmdvx=nil;b.cmdvy=nil;c=b.cmds[b.ci]
   end
   if c then
    kind,n,acc,ang=c[1],c[2],c[3],c[4]
    if kind==32 then b.freeVector=false;b.speed=b.speed+acc;b.angle=b.angle+ang
    elseif kind==16 then
     if not b.cmdvx then local aa=ang<=-990 and b.angle or ang;b.cmdvx=acc*math.cos(aa);b.cmdvy=acc*math.sin(aa)end
     b.freeVector=true;b.vx=b.vx+b.cmdvx;b.vy=b.vy+b.cmdvy;b.angle=R.atan(b.vy,b.vx)
    elseif kind==64 or kind==128 then
     b.freeVector=false;local s=b.speed*(1-b.ct/n);b.vx=s*math.cos(b.angle);b.vy=s*math.sin(b.angle)
    end
    b.ct=b.ct+1
   end
  end
  if not b.freeVector and(not c or(c[1]~=16 and c[1]~=64 and c[1]~=128))then b.vx=b.speed*math.cos(b.angle);b.vy=b.speed*math.sin(b.angle)end
  displace(b,b.vx,b.vy)
 end
 b.age=b.age+1
 if b.alpha<=0 or(b.age>b.cullDelay and(b.x< -64 or b.x>448 or b.y< -64 or b.y>512))then b.dead=true end
end
function R.step(px,py)
 R.px,R.py=px,py
 for i=#R.birthEffects,1,-1 do
  local e=R.birthEffects[i];e.age=e.age+1
  if e.age>=10 then table.remove(R.birthEffects,i)end
 end
 local i=1
 while i<=#R.threads do
  local t=R.threads[i]
  if t.wake<=R.tick then
   local ok,n=coroutine.resume(t.co);assert(ok,n)
   if coroutine.status(t.co)=='dead'then table.remove(R.threads,i);i=i-1 else t.wake=R.tick+(n or 1)end
  end
  i=i+1
 end
 if R.motion then
  local m=R.motion;m.t=m.t+1;local u=math.min(1,m.t/m.n)
  if m.ease==4 then u=1-(1-u)^2 end
  R.boss.x=m.x+m.dx*u;R.boss.y=m.y+m.dy*u
  if R.bounds then local b=R.bounds;R.boss.x=math.max(b[1],math.min(b[3],R.boss.x));R.boss.y=math.max(b[2],math.min(b[4],R.boss.y))end
  if m.t>=m.n then R.motion=nil end
 end
 if R.callback then R.callback()end
 local list={};for _,b in ipairs(R.shots)do if not b.dead then stepBullet(b);if not b.dead then list[#list+1]=b end end end;R.shots=list
 local lasers={};for _,b in ipairs(R.lasers)do
  b.age=b.age+1;if b.turn and b.age<=60 then b.angle=b.base+b.turn*(1-(1-b.age/60)^2)end
  if b.age>=b.warn+b.duration+b.fade then b.dead=true end
  if not b.dead then lasers[#lasers+1]=b end
 end;R.lasers=lasers
 R.tick=R.tick+1
end
