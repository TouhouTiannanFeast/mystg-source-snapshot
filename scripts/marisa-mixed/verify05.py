from pathlib import Path
import json,hashlib,re
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed';B=R/'work/marisa-mixed/change05/before'
def read(p):return p.read_text(encoding='utf-8-sig')
def runtime():
 l=LuaRuntime(unpack_returned_tuples=True)
 l.execute('''
function LoadTexture()end;function LoadImage()end;function LoadSound()end
function SetImageState()end;function Color(...)return{...}end
draws={};function Render(...)draws[#draws+1]={...}end
function PlaySound(...)end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end
''')
 for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua','ssg-selected05.lua']:l.execute(read(M/p))
 return l
l=runtime()
for p in ['root.lua','visual.lua']:l.execute('assert(loadstring(...))',read(M/p))
l.execute('''
local X,R=SSGSelected05,SSG
X.start(20261106,'full')
for i=1,3600 do
 X.step(319,400,10000)
 if i<=1200 then assert(X.stage=='A2')elseif i<=2400 then assert(X.stage=='B1')else assert(X.stage=='B3')end
 if i==2400 then bitsBefore={};for j,b in ipairs(R.bits)do bitsBefore[j]=b end end
 if i==2401 then for j,b in ipairs(R.bits)do assert(b==bitsBefore[j],'bits unnecessarily respawned')end end
 if i<3600 then assert(not R.done,'early phase termination')end
end
assert(R.done and X.duration==3600 and X.clock==3600)
assert(#X.stats.stages==3 and X.stats.stages[1].at==1 and X.stats.stages[2].at==1201 and X.stats.stages[3].at==2401)
for helper in pairs(R.stats.branches)do assert(helper==0x60b)end
for helper in pairs(R.stats.bitBranches)do assert(helper==0x6e4 or helper==0x73e)end
assert(X.stats.births.A2>0 and X.stats.births.B1>0 and X.stats.births.B3>0)
assert(X.stats.skins.bigstar>0 and X.stats.skins.yellowdot>0 and X.stats.skins.smallstar>0 and X.stats.sounds>0)
''')
print('PASS exact A2/B1/B3 1200f windows; only selected helpers; same5bits across B1->B3; 3600f end and current HP30000')
for mode in ['A2','B1','B3']:
 base=runtime();mod=runtime()
 base.execute('SSGInspect04.start(20261106,...);for i=1,1100 do SSG.step(319,400,10000)end',mode)
 mod.execute('SSGSelected05.start(20261106,...);for i=1,1100 do SSGSelected05.step(319,400,10000)end',mode)
 a=base.globals().SSG.bullets;b=mod.globals().SSG.bullets
 assert len(a)==len(b)and len(a)>0
 for i in range(1,len(a)+1):
  if mode=='A2'and b[i].c==51:
   assert b[i].dead and b[i].motionScale is None
   continue
  # Random colors must not consume combat RNG, change counts or source movement state.
  for key in ['d','v0','a','c','typ']:assert a[i][key]==b[i][key],(mode,i,key)
  assert b[i].motionScale==0.5
  if mode=='A2':
   assert b[i].selected05Skin==({48:'bigstar',50:'smallstar'}.get(b[i].c))
  elif mode=='B1':assert b[i].selected05Skin=='yellowdot'and b[i].selected05Color==13
  elif mode=='B3':assert b[i].selected05Skin==('smallstar'if b[i].c==21 else None)
 if mode=='A2':
  assert {v.selected05Color for _,v in b.items()if v.c==48}=={6}
  assert {v.selected05Color for _,v in b.items()if v.c==50}=={2,4,6}
print('PASS A2 smallest removed; retained shots preserve direction/source speed RNG; yellow-big-star/red-purple-blue-smallstar palettes independent of combat RNG; B1 yellow dots')
l.execute('''
local R,X=SSG,SSGSelected05
X.stop();SSGInspect04.start(4,'A2');R.body.dead=true
local a={x=319,y=89,d=64,v=7.5,a=-0.125,typ=1,rep=45,c=21,age=0}
local b={x=319,y=89,d=64,v=7.5,a=-0.125,typ=1,rep=45,c=21,age=0,motionScale=0.5}
R.bullets={a,b}
for i=1,90 do
 R.step(319,400,10000)
 assert(math.abs((b.y-89)*2-(a.y-89))<0.0000001,'not exactly half displacement')
 assert(a.v==b.v and a.a==b.a and a.rep==b.rep,'source deceleration state changed')
end
X.start(5,'B3');R.onBeam({});assert(X.active)
local beam={selected05Laser=true,x=319,y=89,d=64,width=8};X.drawLaser(beam);assert(#draws==7)
X.stop();local p={c=48,x=319,y=89};R.onBullet(p);assert(p.motionScale==nil and p.selected05Skin==nil,'override leaked to old inspection')
''')
print('PASS exact half displacement through90f deceleration/final-speed steps; original laser800px/width16 tiling and override teardown')
refs=json.loads(read(M/'source/selected05-assets.json'))
for row in refs:assert hashlib.sha256(Path(row['source']).read_bytes()).hexdigest()==row['sha256']
root=read(M/'root.lua');assert 'frames/60,30000,'in root and '3600 or 1200' in root
print('PASS source asset hashes, Lua51 syntax and selected-only integration')
