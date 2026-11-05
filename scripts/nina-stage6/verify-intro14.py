from pathlib import Path
from lupa.lua51 import LuaRuntime
import math,hashlib
base=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('object={};function Class()return{}end;function Include()end;function LoadTexture()end;function LoadImage()end')
for name in ['root.lua','intro12.lua','intro14.lua']:
 result=lua.eval('function(s)return loadstring(s)end')((base/name).read_text(encoding='utf-8'));assert not isinstance(result,tuple),result
for name in ['intro14.lua','intro12.lua']:lua.execute((base/name).read_text(encoding='utf-8'))
n,m=lua.globals().NinaIntro12,lua.globals().NinaIntro14
assert tuple(n.pulseStarts.values())==(136,) and n.duration==473
assert n.pose(0)==(232,-48,False,False) and n.pose(473)==(80,112,True,False)
assert n.reveal(306)==0 and n.reveal(326)==.5 and n.reveal(346)==1
particles=m.build(lua.eval('function()return .5 end'))
assert len(particles)==800
for birth in range(50):assert sum(p.birth==birth for _,p in particles.items())==16
assert sum(bool(p.light) for _,p in particles.items())==200
for _,p in particles.items():
 for t,field in [(0,'p0'),(60,'p1'),(120,'p2')]:
  sample=m.sample(p,p.birth+t);expected=p[field]
  assert abs(sample[0]-expected[1])<1e-5 and abs(sample[1]-expected[2])<1e-5
 a=m.sample(p,p.birth+30);x0,y0=p.p0[1],p.p0[2];x1,y1=p.p1[1],p.p1[2]
 assert abs((a[0]-x0)*(y1-y0)-(a[1]-y0)*(x1-x0))>1
 assert m.sample(p,p.birth+141) is None
 # Native travel ends in a radius20 disk, not a forced stack at0,0.
 assert math.hypot(p.p2[1],p.p2[2])<=20.0001
lua.execute("events={};function SetImageState(name,blend,c)activeBlend=blend end;function Color(...)return{...}end;function Render(...)table.insert(events,activeBlend)end")
m.render(particles,69,0,96)
events=list(lua.globals().events.values());assert events and set(events)=={'mul+add','mul+rev'}
first_sub=events.index('mul+rev');assert all(e=='mul+add' for e in events[:first_sub]) and all(e=='mul+rev' for e in events[first_sub:])
source=Path(r'G:/TouHou/MLforDanmu/data/local/bullet-assets/th20-20261027/th20_9db8d7c43f/effect/effect/eff_charge.png')
assert hashlib.sha256(source.read_bytes()).digest()==hashlib.sha256((base/'art/intro12-charge.png').read_bytes()).digest()
print('PASS Lua51; native4 roots*4 particles*50f=800; 60+60f curved tangent interpolation; radius20 finish;141f per-particle lifetime; subtract/add pass order; single playback/fade/handoff preserved')

assert n.revealStart>136+49+120 and n.sideStart>n.revealStart+40
assert n.pose(305)[2] is False and n.pose(306)[2] is True
assert m.displayScale==2.5
lua.execute("function Render(name,x,y,rotation,sx,sy)lastRender={x,y,sx,sy}end")
p=particles[1];one=lua.table_from([p]);age=30
px,py,alpha,scale=m.sample(p,age);m.render(one,age,0,96)
r=lua.globals().lastRender
assert abs(r[1]-px*2.5)<1e-6 and abs(r[2]-(128-py*2.5))<1e-6
assert abs(r[3]-scale*2.5)<1e-6 and r[3]==r[4]
print('PASS whole-group uniform2.5x; hidden until last inward curve completes;40f reveal then side flight; handoff endpoint preserved')
