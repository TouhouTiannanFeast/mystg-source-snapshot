from pathlib import Path
import hashlib,math
from lupa.lua51 import LuaRuntime
p=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal/scenery')
reference=Path(r'G:/TouHou/MLforDanmu/data/local/backgrounds/th09-20261029/anm/world06/data/world06')
for name in ['stg4bg3.png','stg4bg4.png','stg4bg5.png']:
 assert hashlib.sha256((p/'art'/name).read_bytes()).digest()==hashlib.sha256((reference/name).read_bytes()).digest()
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
background={init=function()end};function Class()return{}end
function LoadTexture()end;function LoadImage()end
function Color(...)return{...}end
calls={};views={}
function SetImageState(name,blend,c)currentImage=name end
function Render4V(...)table.insert(calls,{image=currentImage,vertices={...}})end
function Set3D(key,...)views[key]={...}end
function SetPerspective(...)perspective={...}end
function SetZBufferEnable(x)depth=x end
function SetFog()end;function SetViewMode()end;function RenderClear()end;function ClearZBuffer()end
NinaScenery={host={timer=0}};player={x=0}
''')
lua.execute((p/'world06.lua').read_text(encoding='utf-8'))
w=lua.globals().NinaWorld06
for t,expected in [(0,(-200,-250)),(500,(-100,-300)),(1000,(0,-350)),(1500,(-100,-300)),(2000,(-200,-250))]:
 c=w.camera(t);angle=(t%2048)*.003067961661145091-math.pi
 assert abs(c[0]-30*math.sin(angle))<1e-6
 assert abs(c[1]-expected[0])<1e-6
 assert abs(c[2]-expected[1]-30*math.cos(angle))<1e-6
 assert c[3]==0 and abs(c[4]-expected[0]-400)<1e-6 and abs(c[5]-expected[1]-200)<1e-6
for t,a,b in [(0,96,64),(60,84,64),(120,48,64),(180,60,56),(240,96,32),(300,84,40),(360,48,64)]:
 assert abs(w.alpha(t,6)-a)<1e-6 and abs(w.alpha(t,7)-b)<1e-6
for t in [0,320,1000,2000]:
 lua.execute(f'calls={{}};NinaScenery.host.timer={t};NinaWorld06.Object.render({{timer=99999}})')
 calls=lua.globals().calls
 counts={};centers={}
 for _,call in calls.items():
  name=call.image;counts[name]=counts.get(name,0)+1
  v=list(call.vertices.values())[1:];center=tuple(sum(v[axis::3])/4 for axis in range(3));centers.setdefault(name,[]).append(center)
 assert counts['nina.world06.pillar']==8 and counts['nina.world06.cap']==4
 assert centers['nina.world06.gate']==[(0,918,64)]
 assert centers['nina.world06.sigil']==[(0,878,64),(0,838,64)]
 assert set(centers['nina.world06.cap'])=={(-96,685,-94),(96,685,-94),(-96,553,-94),(96,553,-94)}
 assert lua.globals().depth==0
 assert abs(lua.globals().perspective[11]-288/448)<1e-6
 before=tuple(lua.globals().views.eye.values());lua.execute('player.x=180;calls={};NinaWorld06.Object.render({timer=1})')
 assert tuple(lua.globals().views.eye.values())==before
print('PASS retail texture hashes; cubic camera keys/orbit2048; camera target/eye separation; alpha240 native mode4; 4 pillar caps/8 faces; gate/seal untranslated origins; native288:448 projection; continuous clock; player independent; render state restored')
