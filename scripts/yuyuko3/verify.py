from pathlib import Path
import sys,math,json
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
lua=LuaRuntime(unpack_returned_tuples=True)
for f in M.glob('*.lua'):
 lua.execute('assert(loadstring(...))',f.read_text('utf-8-sig'))
 print('SYNTAX',f.name)
for f in ['runtime.lua','th07.lua','le04.lua']:lua.execute((M/f).read_text('utf-8'))
lua.execute('''
assert(table.concat(Y3.order,',')=='non1,spell1,non2,spell2,non3,spell3')
assert(Y3.specs.non2.name=='' and Y3.specs.spell2.name~='')
assert(Y3.specs.spell3.survival and Y3.specs.spell3.time==67)
''')
r=lua.globals().Y3
for phase in ['non1','spell1','non2','spell2','non3','spell3']:
 r.start(phase,20261029,192,112)
 r.onShot=lua.eval('function(b) assert(b.x==b.x and b.angle==b.angle) end')
 for tick in range(int(r.specs[phase].time)*60):
  r.step(192+80*math.sin(tick/180),400)
  if phase=='non1' and tick==176:assert r.counts.shots==9
  if phase=='non2' and tick==0:assert r.counts.shots==32
  if phase=='spell2' and tick==100:assert r.counts.shots==120
  if phase=='non3' and tick==200:assert r.counts.shots==36
  if phase=='spell3' and tick==180:
   assert r.counts.shots==60 and r.counts.lasers==6
  if phase=='spell3' and tick==230:assert r.counts.shots==300
  for b in r.shots.values():
   assert all(math.isfinite(b[k]) for k in ('x','y','angle','vx','vy','alpha'))
 print('PASS',phase,'frames',r.tick,'shots',r.counts.shots,'lasers',r.counts.lasers,'live',len(r.shots))
 r.clear();assert len(r.shots)==len(r.lasers)==len(r.threads)==0
# Soul fade must change state to pulsing rather than delete or change speed.
lua.execute('''
Y3.start('non2',42,192,112)
local b={x=600,y=112,typ=3,state=1,alpha=55,age=101,parity=0,angle=0,speed=1.3}
Y3.soulUpdate(b)
assert(b.state==10 and b.speed==1.3 and b.alpha==50)
Y3.start('spell2',42,192,224);Y3.step(192,400)
local c=Y3.circles[2]
local q={x=c.x,y=c.y,angle=0,speed=1.5,state=1,col=2}
Y3.erosUpdate(q)
assert(q.state==0 and q.col==3 and math.abs(q.speed-1.54)<1e-8)
Y3.start('non3',42,192,112);assert(Y3.circle==nil and Y3.circles==nil)
local b={age=89,start=64,length=384,width=16,warn=120,duration=120,fade=60}
local w,offset,length,hitwidth,active=Y3.laserGeometry(b)
assert(not active and length==0.6)
b.age=90;w,offset,length,hitwidth,active=Y3.laserGeometry(b);assert(active and length<1 and offset>250)
b.age=120;w,offset,length,hitwidth,active=Y3.laserGeometry(b);assert(active and length==384 and offset==64 and hitwidth==8)
b.age=240;w,offset,length,hitwidth,active=Y3.laserGeometry(b);assert(active and length==8 and offset==252)
b.age=270;w,offset,length,hitwidth,active=Y3.laserGeometry(b);assert(not active)
Y3.clear();assert(Y3.circle==nil and Y3.circles==nil)
''')
print('PASS six source-backed schedules, source state changes, no NaN, phase clear/reset')
