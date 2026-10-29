local R=Y3
local pi=math.pi
local W=R.wait
local P=R.pattern
R.begin={}
-- Sub34 + its eleven-frame periodic Sub35. The source's 32000 -> 3000
-- life callback is represented by a 29000-HP standalone nonspell.
R.begin.non1=function()
 R.move(192,112,60)
 R.fork(function()
  W(165)
  R.fork(function()
   while true do
    W(11)
    local x,y=R.boss.x+R.random(-176,176),R.boss.y+R.random(-24,24)
    P(0,3,4,3,1,1,1,0,pi/6,516,{{32,80,0,0}},x,y)
    P(0,3,1,3,1,1,1,0,pi/6,36,{{32,80,0,0},{32,60,0.01,pi/120}},x,y)
    P(0,3,1,3,1,1,1,0,pi/6,36,{{32,80,0,0},{32,60,0.01,-pi/120}},x,y)
   end
  end)
  local gap=120
  while true do W(gap);P(0,10,1,9,1,2.8,1,0,pi/15,4);gap=math.max(60,gap-5)end
 end)
end
-- Sub50/51. Four interleaved families, three-frame periodic callback;
-- angle advances for 300 callbacks, reverses for the next 300.
R.begin.spell1=function()
 R.move(192,112,120)
 R.fork(function()
  W(120)
  local counter,angle,redCounter,redGate=0,0,0,0
  while true do
   W(3);counter=counter+1
   local mode=counter%4
   if mode==0 then P(3,8,4,4,1,1.4,1,angle,pi/6,512)
   elseif mode==1 then
    redCounter=redCounter+1;redGate=redGate+1
    if redGate>=16 and redCounter%8<5 then
     P(1,10,1,1,1,3.4,1,angle,pi/6,644,{{128,100,0,2.4}})
    end
   elseif mode==2 then P(3,8,3,2,1,3.2,1,angle,pi/6,576,{{64,100,pi/2,1.1}})
   else P(3,8,2,2,1,3.0,1,angle,pi/6,576,{{64,100,-pi/2,1.1}})end
   angle=angle+(counter%600<300 and 0.04759989 or -0.04759989)
  end
 end)
end
-- Sub38, four successive periodic fans from Sub39..42.
R.begin.non3=function()
 R.move(192,112,60)
 R.fork(function()
  W(180)
  local fans={{{6,0,pi/4,0}},{{8,-pi/8,pi/4,pi/8},{8,pi/8,pi/4,-pi/8}},{{6,0,pi/2,0},{10,-pi/8,pi/4,pi/6},{10,pi/8,pi/4,-pi/6}},{{8,-pi/8,pi/4,pi/4},{8,pi/8,pi/4,-pi/4},{8,-3*pi/8,pi/4,pi/12},{8,3*pi/8,pi/4,-pi/12}}}
  while true do
   for group=1,4 do
    -- Installing a new periodic callback resets its counter (source ins144).
    local start=R.tick;local duration=group==4 and 100 or 80
    for age=0,duration-1 do
     if age>0 and age%8==0 then
      for _,f in ipairs(fans[group])do
       P(0,6,f[1],2,1,3.8,1,f[2],f[3],658,{{128,60,f[4],0.1},{16,80,0.038,-999}})
      end
     end
     if age==20 then
      R.moveRandom(60,1.5,32,48,352,128)
      P(3,8,5,32,1,1.6,1,R.random(-pi,pi),pi/6,512)
     end
     W(1)
    end
   end
  end
 end)
end
local function finalRing(n,col,a,curve,speed,rows)
 for i=0,rows-1 do
  local acceleration=rows==2 and (0.06-i*0.065)or(0.06-i*0.0325)
  P(3,8,col,n,1,speed,1,a,pi/4,8752,{{32,120,0.01,curve},{8192,200},{16,80,acceleration,-999}})
 end
end
local function laserFan(n,dir)
 for i=0,n-1 do
  local angle=dir==1 and (pi/2+pi/n/2+i*2*pi/n+pi/3)or(pi/2-pi/n/2+i*2*pi/n-pi/3)
  local b=R.laser(R.boss.x,R.boss.y,angle,dir==1 and 4 or 8)
  b.base=angle;b.turn=-dir*pi/3
 end
end
-- Sub70/71 issue ins_124 (SPAWN_ITEM), NOT ins_121 (RUN_EX_INS).
-- Their helpers drop items; they never redirect or reset live bullets.
-- Drop effects are outside this attack-only host; do not synthesize EX0/1/8.
-- Sub62 Easy after spell declaration: no previous-card death cinematic.
-- It is a survival spell in the original (canBeDamaged remains false).
R.begin.spell3=function()
 R.move(192,96,120)
 R.fork(function()
  W(120);R.move(192,112,60);W(60)
  local n,nlasers,speed=20,6,0.5
  while true do
   local a=R.random(-pi,pi);local delta=pi/n
   laserFan(math.floor(nlasers/2),1);laserFan(math.floor(nlasers/2),-1)
   for i=0,5 do
    finalRing(n,i%2==0 and 3 or 2,a+i*delta,0,speed,i%2==0 and 3 or 2)
    W(i==5 and 120 or 10)
   end
   for i=0,3 do
    local count=({32,32,38,40})[i+1];local curve=({pi/600,-pi/600,pi/300,-pi/300})[i+1]
    finalRing(count,1,R.random(-pi,pi),curve,0.8,3)
    if i<3 then W(30)end
   end
   R.moveRandom(60,0.2,128,96,256,128,0);W(60)
   -- Sub69 is guarded by H/L difficulty masks: Easy has no bubble layer.
   speed=speed+0.08;n=n+3;nlasers=nlasers+2
   W(95)
  end
 end)
end
