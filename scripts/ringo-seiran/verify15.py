from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran');v=LuaRuntime()
for p in m.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern;local w=P.new('spell')
w.px,w.py=0,380;w.t=0;P.seiranStep(w);w.t=119;P.seiranStep(w)
assert(w.stats.gun==36 and w.stats.pellet==31)
local head=w.seiran;local guns,big,small={},{},{};local color
for _,b in ipairs(w.bullets)do
 if b.kind=='gun'then guns[#guns+1]=b else
  if color then assert(b.color==color)else color=b.color end
  local list=b.large and big or small;list[#list+1]=b
 end
end
assert(#big==7 and #small==24 and #guns==36)
for group=0,5 do
 local sumx,sumy=0,0;local rows={0,0,0};local direction=guns[group*6+1].angle
 for i=1,6 do
  local b=guns[group*6+i];local dx,dy=b.x-head.headX,b.y-head.headY
  sumx,sumy=sumx+dx,sumy+dy
  local forward=dx*math.cos(direction)+dy*math.sin(direction)
  local row=math.floor((10-forward)/7.5+.5)+1
  rows[row]=rows[row]+1
  assert(b.angle==direction and b.speed==2)
 end
 assert(math.abs(sumx)<1e-7 and math.abs(sumy)<1e-7)
 assert(rows[1]==1 and rows[2]==2 and rows[3]==3)
 local nearest=100
 for i=1,6 do for j=i+1,6 do
  local a,b=guns[group*6+i],guns[group*6+j]
  nearest=math.min(nearest,((a.x-b.x)^2+(a.y-b.y)^2)^.5)
 end end
 assert(math.abs(nearest-5*math.sqrt(3))<1e-7)
end
-- Isolate real emitted stars from player proximity and screen bounds.
local b,s=big[1],small[1];local speedB,speedS=b.speed,s.speed
b.x,b.y,b.angle=0,128,0;s.x,s.y,s.angle=0,128,0
w.bullets={b,s};w.px,w.py=1000,1000
for i=1,40 do P.advance(w)end
assert(s.speed==0 and s.spinSpeed>0 and not s.dead)
local sx,sy=s.x,s.y
for i=41,60 do P.advance(w)end
assert(s.speed==0 and s.spinSpeed==0 and s.x==sx and s.y==sy)
local rot=s.rotation
-- Keep big star within bounds while checking beyond the former90f lifetime.
b.speed=.1;b.x=0
for i=61,120 do P.advance(w)end
assert(s.rotation==rot and not s.dead and b.spinSpeed==12 and b.rotation==1440 and not b.dead)
assert(math.abs(b.x-6)<1e-7)
-- Check24px boundary for each subtype and the irreversible15f fade.
for _,large in ipairs({false,true})do
 local test={kind='impactPellet',large=large,x=0,y=128,angle=0,speed=0,age=60,rotation=0,spinSpeed=large and 12 or 0,deceleration=0,alpha=1}
 w.bullets={test};w.px,w.py=24.01,128;P.advance(w);assert(not test.fadeAge)
 w.px=24;P.advance(w);assert(test.fadeAge==1 and test.alpha<1)
 w.px,w.py=1000,1000
 for i=2,15 do P.advance(w)end
 assert(test.dead and test.alpha==0 and #w.bullets==0)
end
assert(P.specs.nonspell.hp==13000 and P.specs.spell.hp==15000 and P.specs.spell.time==45)
''')
print('PASS:6x6 guns rows1/2/3,centroid/spacing/speed;7big+24small single color;small stop40/spin60,persist;big flight/spin120f;both24px trigger/15f fade;HP/time unchanged.')
