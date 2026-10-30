-- TH15 Normal BossCard2; coordinates are centered, Y up, one unit per pixel.
RingoDangoPattern={}
local P=RingoDangoPattern
local pi=math.pi
P.hp=2400;P.duration=2400;P.intro=90;P.cycle=334
P.rings=6;P.count=140;P.spacing=14;P.bigTick=174
P.radius={pellet=2.4,outline=4,mentos=8.5}
function P.new(random)
 return {t=0,bullets={},nextId=0,random=random or math.random,
  stats={rings=0,pellet=0,mentos=0,influenced=0,bounces=0},move=nil}
end
local function velocity(b)
 b.vx,b.vy=b.speed*math.cos(b.angle),b.speed*math.sin(b.angle)
end
local function spawn(w,kind,x,y,angle,speed,turn)
 w.nextId=w.nextId+1
 local b={id=w.nextId,kind=kind,x=x,y=y,angle=angle,speed=speed,age=0,
  turn=turn or 0,tag=kind=='mentos' and 1 or 0,bounces=0}
 velocity(b);w.bullets[#w.bullets+1]=b;w.stats[kind]=w.stats[kind]+1
 return b
end
P.spawn=spawn
function P.emit(w,x,y,px,py)
 local t=w.t-P.intro
 if t<0 then return end
 local q=t%P.cycle
 if q<84 and q%14==0 then
  local turn=(q/14)%2==0 and -0.012 or 0.012 -- reflect source Y-down angles.
  for i=0,139 do
   local a=-i*2*pi/140
   spawn(w,'pellet',x+20*math.cos(a),y+8+20*math.sin(a),a,0.6,turn)
  end
  w.stats.rings=w.stats.rings+1
 elseif q==174 then
  -- etAim(0) uses the enemy center, before applying emission offset.
  local aim=math.atan2(py-y,px-x)
  -- etNew(1) resets the offset: large bullets originate at the boss itself.
  for i=-1,1 do spawn(w,'mentos',x,y,aim+i*pi/4,2) end
 end
 -- Synchronous BossCard2_at returns at174; 60+60, then moveRand30, wait40.
 if q==294 then
  local a=(w.random()*2-1)*pi/4
  if x>120 or (x>=-120 and (px<x)==(w.random()<2/3)) then a=a+pi end
  local sy=-y+224 -- native playfield Y.
  if sy<96 then a=math.abs(a) elseif sy>160 then a=-math.abs(a) end
  w.move={angle=-a,age=0}
 end
end
function P.influence(w)
 -- Native func1 @0x4315f0: tag1 affects tag0 once, within squared radius400.
 for _,large in ipairs(w.bullets) do
  if not large.dead and large.tag==1 then
   for _,small in ipairs(w.bullets) do
    if not small.dead and small.tag==0 and (small.x-large.x)^2+(small.y-large.y)^2<=400 then
     small.tag=2;small.angle=large.angle;small.speed=large.speed
     small.vx,small.vy=large.vx,large.vy;small.bounces=1
     w.stats.influenced=w.stats.influenced+1
    end
   end
  end
 end
end
function P.advance(w)
 local live={}
 for _,b in ipairs(w.bullets) do
  if not b.dead then
   if b.scatter==0 then
    -- Synchronous slot9 blocks slots10..12 until the single bounce ends.
    b.angle=-(w.random()*2-1)*2.6179938
    b.speed=1;velocity(b);b.scatter=1
   elseif b.scatter==1 then
    b.speed=b.speed+(w.random()*2-1)*0.3;velocity(b);b.scatter=2
   elseif b.scatter==2 then
    b.kind='outline';b.scatter=nil
   elseif b.tag==0 and b.age<60 then
    b.angle=b.angle+b.turn;velocity(b)
   end
   b.x,b.y=b.x+b.vx,b.y+b.vy;b.age=b.age+1
   if b.bounces>0 then
    local hit=false
    if b.x< -192 and b.vx<0 or b.x>192 and b.vx>0 then b.x=(b.x<0 and -384 or 384)-b.x;b.vx=-b.vx;hit=true end
    if b.y< -224 and b.vy<0 or b.y>224 and b.vy>0 then b.y=(b.y<0 and -448 or 448)-b.y;b.vy=-b.vy;hit=true end
    if hit then b.angle=math.atan2(b.vy,b.vx);b.bounces=b.bounces-1;b.scatter=0;w.stats.bounces=w.stats.bounces+1 end
   end
   if math.abs(b.x)>256 or math.abs(b.y)>288 then b.dead=true else live[#live+1]=b end
  end
 end
 w.bullets=live
end
function P.step(w,x,y,px,py)
 P.emit(w,x,y,px,py);P.influence(w);P.advance(w)
 if w.move then
  -- moveRand sets speed1 over30frames with decelerating interpolation4.
  local m=w.move;local speed=(1-m.age/30)^2
  x=x+speed*math.cos(m.angle);y=y+speed*math.sin(m.angle)
  m.age=m.age+1;if m.age>=30 then w.move=nil end
 end
 w.t=w.t+1;return x,y
end
