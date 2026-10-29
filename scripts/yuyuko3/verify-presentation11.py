from pathlib import Path
import sys,json
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
b=Path('G:/MySTG');m=b/'aex-0.8.22/game/mod';l=LuaRuntime(unpack_returned_tuples=True)
for p in list((m/'Le03Stage4Normal').glob('*.lua'))+list((m/'YuyukoStage3').glob('*.lua')):l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
l.execute((m/'Le03Stage4Normal/bullet-style.lua').read_text('utf-8'))
l.execute('''local S=Le03BulletStyle
for _,x in ipairs({{2700,3,3},{3100,5,5},{3500,2,7}})do
 local b={typ=3,col=x[2],age=20};S.assign(b,{appear=x[1],shot=47})
 assert(b.style=='butterfly');assert(S.image(b)=='le03.th.b.butterfly.'..x[3])
 local r,g,bl=S.bodyRGB(b);assert(r==255 and g==255 and bl==255)
end
local b={typ=3,col=1};S.assign(b,{appear=1100});assert(S.image(b)=='le03.th.b.scale.1')
local a,c,t=S.rainbowImages({age=0});assert(a=='le03.th.b.butterfly.3' and t==0)
print('PASS wave25/26/27 blue/green/pink original color sprites, scale and rainbow white highlights, Lua51 syntax')''')
for row in json.loads((m/'Le03Stage4Normal/art/touhou-bullets/colored-manifest.json').read_text()):
 assert (m/'Le03Stage4Normal/art/touhou-bullets'/row['file']).read_bytes()==Path(row['source']).read_bytes()
print('PASS all16 original TH10 colored sprites match source bytes')
