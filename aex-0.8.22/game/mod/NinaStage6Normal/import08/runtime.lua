-- Source-bounded, host-neutral TH08 scheduler. Coordinates are centered x and y-down.
Nina08Runtime={}
local R=Nina08Runtime
local pi=math.pi
function R.bitAnd(a,b)local n,p=0,1;while a>0 and b>0 do if a%2==1 and b%2==1 then n=n+p end;a=math.floor(a/2);b=math.floor(b/2);p=p*2 end;return n end
local function rad(a)return a*pi/180 end
local function atan2(y,x) return math.atan2 and math.atan2(y,x) or math.atan(y/x)+(x<0 and pi or 0) end
local function rng(seed)
 local s=(seed or 1)%2147483647;if s<=0 then s=s+2147483646 end
 return function()s=(s*16807)%2147483647;return (s-1)/2147483646 end
end
local function aim(x,y)return atan2(R.py-y,R.px-x)end
local function add(t,v)t[#t+1]=v;return v end
local function bullet(x,y,a,s,typ,color,opt)
 opt=opt or {};local b=add(R.hazards,{group='th08',x=x,y=y,angle=a,speed=s,typ=typ,color=color,radius=(Nina08Art.bullet[typ]or{}).radius or 5,age=0,life=opt.life or 900,accel=opt.accel or 0,accelFrames=opt.accelFrames or 0,turn=opt.turn or 0,source=opt.source,change=opt.change,bounceExceptBottom=opt.bounceExceptBottom,bounceLimit=opt.bounceLimit,bounces=0,dead=false})
 -- Boss 发射的固定弹（Sub63 的 type3 环）改为大菱形弹。
 if R.spec and R.spec.id=='final' and typ==3 then
  b.diamond=true;b.diamondScale=0.8
  b.diamondSprite=({[2]=577,[4]=579,[6]=581,[8]=580,[10]=578,[13]=582,[14]=576})[color] or 576
 end
 if R.onShot then R.onShot(b) end
 return b
end
local function fan(x,y,a,n,spread,s,typ,color,opt)
 for i=0,n-1 do bullet(x,y,a+(i-(n-1)/2)*spread,s,typ,color,opt)end
end
local function ring(x,y,a,n,s,typ,color,opt)
 for i=0,n-1 do bullet(x,y,a+i*2*pi/n,s,typ,color,opt)end
end
local function actor(x,y,visual,color,data)
 data=data or {}
 local a=add(R.actors,{group='th08',x=x,y=y,visual=visual,color=color,age=0,dead=false,data=data,hp=data.life or 300,hurtW=24,hurtH=24,hitW=24,hitH=24,immortal=data.immortal,flags=data.flags or(visual=='frog'and 3 or 0)})
 if R.onActor then R.onActor(a) end
 return a
end
local function eirinBurst()
 -- Sub18: Normal has 32 offset points, type2/color2, ten, speed 3 -> +0.8.
 local base=R.random()*2*pi
 for i=0,31 do
  local a=base+i*rad(11.25);local x,y=R.boss.x+math.cos(a)*64,R.boss.y+math.sin(a)*64
  fan(x,y,a+rad(11.25),10,rad(14.0625),3,2,2,{change={age=60,angle=i%2==0 and -2.5132742 or 2.5132742,speed=1.5,color=4},source='ecldata6/Sub18'})
 end
end
local function eirinFamiliar(a)
 -- Sub19/Sub20: starts moving at 1, then emits paired 1.5 red / 3 green every 20f, ten times.
 local d=a.data.angle;a.vx,a.vy=math.cos(d),math.sin(d);a.data.shots=0;a.data.next=0
end
local function finalEmitter(angle,color,life)
 -- Sub61 makes six type54 familiars, centered at source (192,280), radius96.
 local tx,ty=math.cos(angle)*96,280+math.sin(angle)*96
 -- Sub62 floatTime(x/y,120,7,0,start,target,cos/sin*400,randSign(400)).
 -- Sub62 sets flags 16 and 3, then clears only 3 after its 120-frame entry.
 -- The remaining flag 16 keeps the source familiar unkillable for its lifetime.
 return actor(R.boss.x,R.boss.y,'frog',color,{angle=angle,color=color,delay=120,life=life,next=nil,ring=32,cycles=0,source='ecldata7sp/Sub62',immortal=true,flags=19,float={x0=R.boss.x,y0=R.boss.y,x1=tx,y1=ty,cx=math.cos(angle)*400,cy=math.sin(angle)*400,rx=(R.random()*2-1)*400,ry=(R.random()*2-1)*400}})
end
function R.clearHazards()
 for i=#R.hazards,1,-1 do R.hazards[i]=nil end
 for i=#R.actors,1,-1 do R.actors[i]=nil end
end
function R.start(spec,seed)
 R.spec=assert(spec,'spec');R.random=rng(seed);R.tick=0;R.px=0;R.py=384;R.hp=spec.hp;R.hazards={};R.actors={};R.events={};R.boss={x=spec.x or 0,y=spec.y or 128,group='th08'};R.done=false;R.stepsHazards=true;R.invuln=spec.id=='non4' and 120 or 90
 return R
end
function R.onActor(a)return Nina08Art.actor[a.visual]end
function R.onShot(b)return Nina08Art.lookup(b.typ,b.color)end
local function stepEirin()
 local t=R.tick
 if t%260==0 then eirinBurst()end
 if t>=120 and (t-120)%260==0 then
  local a0=R.random()*2*pi
  for i=0,15 do local a=actor(R.boss.x,R.boss.y,'familiar',nil,{angle=a0+i*rad(22.5),life=300});eirinFamiliar(a)end
 end
 local q=t%260
 if q==200 then R.moveX=R.boss.x;R.moveY=R.boss.y;local a=R.random()*2*pi;R.targetX=math.max(-160,math.min(160,R.boss.x+30*math.cos(a)));R.targetY=math.max(48,math.min(128,R.boss.y+30*math.sin(a)))end
 if q>=200 then local u=(q-199)/60;local k=1-(1-u)^2;R.boss.x=R.moveX+(R.targetX-R.moveX)*k;R.boss.y=R.moveY+(R.targetY-R.moveY)*k end
end
local rainbow={2,4,6,8,10,13,14}
local function stepFinal()
 local t=R.tick
 -- Sub61: 90f entry/invuln; at +20 (frame110) create seven Sub62s and start Sub63 async.
 if t==110 then
  local colors={2,4,6,8,10,13,14};local start=-2.1991148
  for i,c in ipairs(colors)do finalEmitter(start+(i-1)*rad(12),c,({4000,2100,1000,1000,1000,2100,4000})[i])end
 end
 -- Sub63 Normal: after 600, speed1.0; seven color rings, 16 each, 20f cadence;
 -- subsequent cycles use the paired +/- pi/256 rotation before each successive color.
 if t>=710 then
  local q=t-710
  if q<1400 then
   -- Sub63 first section: 10 groups, seven rings at 20f; no artificial 600f pause.
   local u=q%140;if u%20==0 then ring(R.boss.x,R.boss.y,0,16,1,3,rainbow[math.floor(u/20)+1],{accel=.5/60,accelFrames=60,source='ecldata7sp/Sub63:first'})end
  else
   -- Sub63 second section: 10f cadence, alternating +/- accumulated pi/256 angles.
   local u=(q-1400)%140;if u%10==0 then
    local n=math.floor((q-1400)/10);local i=n%7+1;local a=n*rad(.703125)
    ring(R.boss.x,R.boss.y,n%2==0 and a or -a,16,1,3,rainbow[i],{source='ecldata7sp/Sub63:second'})
   end
  end
 end
end
local function stepActors()
 for i=#R.actors,1,-1 do
  local a=R.actors[i];a.age=a.age+1
  if not a.dead then
  if a.data.float and a.age<=120 then
   local f=a.data.float;local u=a.age/120;local om=1-u
   -- Source mode 7 is the four-control-point float interpolation; retain each supplied control.
   a.x=om*om*om*f.x0+3*om*om*u*(f.x0+f.cx)+3*om*u*u*(f.x1+f.rx)+u*u*u*f.x1
   a.y=om*om*om*f.y0+3*om*om*u*(f.y0+f.cy)+3*om*u*u*(f.y1+f.ry)+u*u*u*f.y1
  end
  -- Sub62 enters with flagSet(16)+flagSet(3), then clears only flag 3 at +120.
  -- The root host's protect bit includes 16, so this retains its source immunity.
  if a.visual=='frog' and a.age==120 then a.flags=16 end
  if a.visual=='familiar' then
   a.x=a.x+(a.vx or 0);a.y=a.y+(a.vy or 0)
   if a.age<=182 and a.age%20==2 and a.data.shots<10 then
    local d=a.data.angle+pi;fan(a.x,a.y,d,1,rad(5.625),1.5,3,2,{source='ecldata6/Sub20'});fan(a.x,a.y,d,1,rad(5.625),3,3,6,{change={age=60,angle=0,speed=1.5},source='ecldata6/Sub20'});a.data.shots=a.data.shots+1
   end
  elseif a.visual=='frog' and a.age>=a.data.delay then
   -- Sub62 Normal: I4=1 gives a 32-way ring, then a single 34-way repeat
   -- after its 360-frame wait.  It does not repeat forever.
   if a.age==120 or a.age==480 then
    -- etEx(0,2048,...,-999.9,0) installs the one-bounce, except-bottom
    -- transform before Sub62's aimed ring.  2048 is TH08's 0x800 transform.
    local n=a.data.ring;ring(a.x,a.y,aim(a.x,a.y),n,1.2,2,a.color,{source='ecldata7sp/Sub62',bounceExceptBottom=true,bounceLimit=1});a.data.ring=n+2;a.data.cycles=a.data.cycles+1
   end
   -- Sub62 reaches local150, waits360, performs its one ins_5 ring repeat,
   -- then starts Sub65 at510 and Sub66 at514. Both run for every familiar.
   local function subfan(key,start,base,source)
    local d=a.data[key]
    if not d then d={next=start,speed=1.3,angle=base,turn=rad(3)};a.data[key]=d end
    if a.age>=d.next then
     fan(a.x,a.y,d.angle,1,0,d.speed,17,a.color,{source=source,bounceExceptBottom=true,bounceLimit=1})
     d.speed=d.speed+.2
     if d.speed>=2.2 then d.speed=1.0;d.turn=-d.turn;d.angle=base+d.turn;d.next=a.age+208 else d.angle=d.angle+d.turn;d.next=a.age+8 end
    end
   end
   if a.age>=570 then subfan('fan65',570,pi,'ecldata7sp/Sub65') end
   if a.age>=574 then subfan('fan66',574,0,'ecldata7sp/Sub66') end
  end
  -- familiarCreate's 4000/2100/1000 values are HP, not a lifetime: source Sub62 loops.
  end
 end
end
function R.stepHazards()
 for i=#R.hazards,1,-1 do
  local b=R.hazards[i];b.age=b.age+1;if b.accelFrames==0 or b.age<=b.accelFrames then b.speed=b.speed+b.accel end;b.angle=b.angle+b.turn;b.x=b.x+math.cos(b.angle)*b.speed;b.y=b.y+math.sin(b.angle)*b.speed
  if b.change and b.age==b.change.age then b.angle=b.angle+b.change.angle;b.speed=b.change.speed;b.color=b.change.color or b.color end
  if b.bounceExceptBottom and b.bounces<(b.bounceLimit or 1)then
   -- TH08 BounceExceptBottom reflects side/top boundaries but deliberately lets
   -- a lower-edge exit continue.  Coordinates here are centered-x, y-down.
   if b.x< -192 or b.x>=192 then b.angle=-b.angle-pi;b.bounces=b.bounces+1
   elseif b.y<0 then b.angle=-b.angle;b.bounces=b.bounces+1 end
   if b.bounces>0 then
    -- 原作：反弹后的子弹改为自机狙。
    b.angle=aim(b.x,b.y)
    -- 使魔发射的反弹弹改为米弹。
    if R.spec and R.spec.id=='final' then b.rice=true end
   end
  end
  if b.age>=b.life or b.x<-240 or b.x>240 or b.y<-64 or b.y>512 then b.dead=true;table.remove(R.hazards,i)end
 end
end
function R.step(px,py,hp)
 R.px,R.py,R.hp=px or R.px,py or R.py,hp or R.hp
 if R.done then return R end
 if R.spec.id=='non4' then
  stepEirin()
 else
  if R.tick==90 then R.invuln=2400 end
  if R.tick>=110 and R.tick<350 then R.boss.y=128+(64-128)*((R.tick-109)/240) end
  stepFinal()
 end
 stepActors();R.stepHazards();R.tick=R.tick+1
 R.invuln=math.max(0,R.invuln-1)
 if R.tick>=R.spec.frames or R.hp<=0 then R.done=true end
 return R
end
