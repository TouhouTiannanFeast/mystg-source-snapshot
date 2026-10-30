from pathlib import Path
import json,hashlib,re
from lupa.lua51 import LuaRuntime
root=Path('G:/MySTG');mod=root/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5';work=root/'work/stage5/pyramid21'
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''classes={}; function Class(base)local c={};classes[#classes+1]=c;return c end
object={};enemybase={};bullet={};setting={};Th18Stage5Runtime={random=function()return .5 end}
textures={};images={};renders={};states={}
function LoadTexture(n,p)textures[n]=p end
function SetTextureSamplerState()end
function LoadImage(n,t,x,y,w,h)images[n]={t,x,y,w,h}end
function SetImageState(n,b,c)states[n]={b,c}end
function Color(a,r,g,b)return {a,r,g,b}end
function Render(...)renders[#renders+1]={...}end
''')
for name in ['data.lua','anm.lua','host.lua']:
 s=(mod/name).read_text(encoding='utf-8-sig');l.execute('assert(loadstring(...))',s);l.execute(s)
l.execute('''local A=Th18Stage5Animation;local H=Th18Stage5Host
for i=0,4 do local r=images['th18s5.pyramid.'..i];assert(r[2]==i*48 and r[3]==96 and r[4]==48 and r[5]==48)end
local a=A.new('enemy',251);local frames={}
for t=0,100 do
 if t>0 then A.step(a)end
 renders={}; classes[4].render({data={name='MBoss'},animations={[0]=a},x=12,y=30})
 assert(#renders==1);local v=renders[1];local expected=math.floor(t/8)%5
 assert(v[1]=='th18s5.pyramid.'..expected);frames[expected]=true
 assert(v[2]==12 and v[3]==30 and v[4]==0)
 assert(math.abs(v[5]*48-a.values.scale[1]*32)<1e-8)
 assert(states[v[1]][2][1]==a.values.alpha[1])
end
for i=0,4 do assert(frames[i])end
assert(math.abs(renders[1][5]*48-64)<1e-8)
local old=A.render;local count=0;A.render=function()count=count+1 end
classes[4].render({data={name='Cir00'},animations={[0]=a},x=0,y=0});assert(count==1)
A.render=old
print('PASS actual host render: MBoss only, all five frames, source birth size/alpha, final64x64; ordinary enemy render retained; Lua51 syntax')
''')
manifest=json.loads((mod/'art/th20-pyramid/source.json').read_text());assert hashlib.sha256((mod/'art/th20-pyramid/enemy_stone.png').read_bytes()).hexdigest()==manifest['textureSHA256']
before=json.loads((work/'protected-before.json').read_text())
for name,h in before.items():assert hashlib.sha256((mod/name).read_bytes()).hexdigest()==h,name
s=(mod/'host.lua').read_text();old=(work/'host.lua.before').read_text(encoding='utf-8-sig')
start=s.index('-- Only the MBoss visual');end=s.index(' local list={}',start)
s=s[:start]+'function Enemy:render()\n'+s[end:]
start=s.index("LoadTexture('th18s5.pyramid'");end=s.index('\n',s.index("for i=0,4 do LoadImage",start))+1
s=s[:start]+s[end:];assert s==old,'unexpected host changes'
print('PASS texture source SHA256; exact render/load-only delta;',len(before),'protected files unchanged; no native/full-stage run')
