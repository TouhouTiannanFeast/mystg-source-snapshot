from pathlib import Path
import json,hashlib,re,math
from lupa.lua51 import LuaRuntime
root=Path('G:/MySTG');base=root/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5'
l=LuaRuntime(unpack_returned_tuples=True)
for f in ['background.lua','background-probe.lua','../suwako5/stage.lua']:l.execute('assert(loadstring(...))',(base/f).read_text(encoding='utf-8'))
for f in ['../suwako5/pool.lua','data.lua','anm.lua','background.lua']:
 s=(base/f).read_text(encoding='utf-8');l.execute(s.split('B.Object=Class(background)')[0])
l.execute("""
local B,A=Th18Stage5Background,Th18Stage5Animation
local gate=B.new();B.armMidboss(gate)
for t=1,4176 do B.stageStep(gate);assert(gate.age<=2047 and gate.anms[1].values.color[1]==255,'forest must remain before midboss')end
local oldY=B.camera(gate)[2];B.beginValley(gate);assert(gate.age==2176 and gate.valleyStarted and not gate.awaitMidboss)
assert(math.abs(B.camera(gate)[2]-oldY)<1e-5,'scroll continuity')
for t=1,1224 do B.stageStep(gate)end
assert(gate.age==3400 and gate.anms[1].values.pos[1]==0 and gate.anms[1].values.color[1]==64,'valley after midboss')
local s=B.new();assert(#s.groups==60)
assert(s.anms[0].renderType==8 and s.anms[3].renderType==8 and s.anms[1].renderType==4 and s.anms[2].renderType==4)
assert(s.std.values.fov[1]>.6283 and s.std.values.fov[1]<.6284)
for t=1,6000 do
 B.step(s)
 if t==2899 then assert(s.anms[1].values.pos[1]==64)end
 if t==3400 then assert(math.abs(s.anms[1].values.pos[1])<.001 and s.anms[1].values.color[1]==64)end
end
assert(s.loops==3 and s.std.clock==4464)
local eye,f,r,u=B.camera(s)
for _,v in ipairs({f,r,u})do assert(math.abs(v[1]^2+v[2]^2+v[3]^2-1)<1e-6)end
for _,g in ipairs(s.groups)do
 local vs,c=B.vertices(g,f,r,u)
 if g.anm.renderType==4 then
  for _,v in ipairs(vs)do assert(math.abs((v[1]-c[1])*f[1]+(v[2]-c[2])*f[2]+(v[3]-c[3])*f[3])<1e-5,'billboard must face camera')end
  local w,h=0,0;for i=1,3 do w=w+(vs[2][i]-vs[1][i])^2;h=h+(vs[4][i]-vs[1][i])^2 end
  assert(math.abs(math.sqrt(w)-256)<1e-5 and math.abs(math.sqrt(h)-217.5)<1e-5)
 else
  for _,v in ipairs(vs)do assert(math.abs(v[3]-c[3])<.001,'true3D ground/mist plane')end
  assert(vs[1][2]>vs[3][2],'source X=pi texture orientation')
 end
end
assert(B.interrupt(s,1));assert(s.broadcasts==1)
for t=1,1024 do B.step(s)end;assert(s.loops==5)
for _,v in ipairs(Suwako5Pool.spells)do assert(v.frames==1800)end
for _,v in ipairs(Suwako5Pool.nonspells)do assert(v.frames==1800)end
""")
records=json.loads((base/'assets-source.json').read_text(encoding='utf-8'))['records']
for rec in records:
 if rec['target'].startswith('art/background-'):
  assert hashlib.sha256((base/rec['target']).read_bytes()).hexdigest()==rec['sha256']==hashlib.sha256(Path(rec['source']).read_bytes()).hexdigest()
source=Path('G:/TouHou/MLforDanmu/data/local/backgrounds/th18-th185-20261026-v2/th18/scenes.json')
scene=next(s for s in json.loads(source.read_text(encoding='utf-8'))if s['id']=='st02.std')
expected=[]
for e in scene['entries']:
 for inst in e['instances']:
  for q in e['quads']:expected.append((e['layer_source_field'],inst['source_offset'],q['source_offset'],[a+b for a,b in zip(inst['position'],q['position'])]+[q['animation_script_id']]))
expected.sort(key=lambda x:x[:3])
text=(base/'background-native.hlsl').read_text(encoding='utf-8');geom=text.split('geometry[60]={')[1].split('};')[0]
actual=[[float(v)for v in x.split(',')]for x in re.findall(r'float4\(([^)]+)\)',geom)]
assert actual==[x[3]for x in expected],'source geometry/draw order'
assert 'child.hp=v[4];' in (base/'route.lua').read_text(encoding='utf-8')
assert "SetAttr(self,'colli',self._colli)" in (base/'host.lua').read_text(encoding='utf-8')
print('PASS Lua5.1 syntax; midboss gate/scroll continuity/valley reveal; full source STD/ANM timelines, 60-quad order, mode4 billboard geometry/mode8 UV orientation, camera basis, loops/interrupt, 3 original texture hashes; ordinary HP0.1 and collision fix retained; Suwako30s retained.')
