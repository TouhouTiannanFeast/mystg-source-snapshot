from pathlib import Path
import sys,os,json,hashlib
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';O=R/'work/logs/six-stages/road5-background-20261114';os.chdir(G)
ref=json.loads((M/'road5-background/source.json').read_text('utf-8'))
for a in ref['files']:assert hashlib.sha256((M/'road5-background'/a['file']).read_bytes()).hexdigest()==a['sha256']
l=LuaRuntime();l.execute("SixStageCampaign={install=function()end};setting={};function LoadTexture()end;function SetTextureSamplerState()end;function Class()return {}end")
for n in ['road5-background.lua','background5.lua','road5-background/meshes.lua']:l.execute('assert(loadstring(...))',(M/n).read_text('utf-8'))
l.execute((M/'road5-background.lua').read_text('utf-8'))
l.execute("""
local B=SixRoad5Background
assert(#B.meshes.b.faces==64 and #B.meshes.e.faces==12 and #B.meshes.fa.faces==32 and #B.meshes.fb.faces==32)
s=B.new(1);for i=1,601 do B.step(s,0)end;assert(s.phase=='a'and s.camera[4]==64)
B.step(s,1);assert(s.phase=='b'and s.changed)
for i=1,1200 do B.step(s,1)end;assert(#s.models>0 and #s.clouds>0)
B.step(s,2);assert(s.phase=='warp')
for i=1,math.floor(39.435*64)-60 do B.step(s,2)end;assert(s.phase=='c')
for i=1,2000 do B.step(s,2)end;assert(#s.models<=16 and #s.clouds<=35)
B.step(s,3);assert(s.phase=='end')
BG={render=assert(loadstring('return function()end','@mod/HSoBStage5Normal/background.lua'))()}
Warp={render=BG.render};made={}
function New(c)table.insert(made,c);return c end
HSoB5={section=1,newBackground=function()New(BG);New(Warp)end}
SixStageCampaign.install(5,{});HSoB5.newBackground();assert(made[1]~=BG and made[2]==Warp and #made==2)
""")
(O/'verify.log').write_text('PASS source asset hashes, all140 MQO faces, Lua51; phase/camera/warp sample states, bounded object lifetimes; actual replacement hook creates new road background and preserves source Warp. Native campaign entry four-scene snapshots inspected; no full-route original-frame parity claim.\n','utf-8')
print('PASS road5 background source/phase/lifetime/integration')
