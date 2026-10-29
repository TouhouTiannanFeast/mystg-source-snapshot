from pathlib import Path
import sys,re,math
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
l=LuaRuntime(unpack_returned_tuples=True)
s=(m/'root.lua').read_text('utf-8-sig');l.execute('assert(loadstring(...))',s)
l.execute((m/'runtime.lua').read_text('utf-8-sig'))
l.execute('Beam={};R=Y3;function Color(...)return {...}end;function SetImageState(...)blend={...}end;function Render(...)draw={...}end')
l.execute(re.search(r'function Beam:render\(\).*?\nend',s,re.S)[0])
l.execute('''
for _,col in ipairs({4,8})do
 for _,angle in ipairs({0,math.pi/2,math.pi,-math.pi/2})do
  local b={x=192,y=112,angle=angle,col=col,start=64,length=384,width=16,warn=120,duration=120,fade=60,age=150}
  Beam.render({data=b})
  assert(draw[1]=='y3.b3.'..col and blend[2]=='mul+add')
  assert(math.abs(draw[2]-256*math.cos(angle))<1e-6)
  assert(math.abs(draw[3]-(112-256*math.sin(angle)))<1e-6)
  assert(draw[5]==1 and draw[6]==24)
  assert(math.abs(draw[4]-(-angle*180/math.pi-90))<1e-6)
  b.age=0;Beam.render({data=b});assert(draw[5]<1 and draw[6]==24)
  b.age=270;Beam.render({data=b});assert(draw[5]==.5 and draw[6]==24)
 end
end
''')
print('PASS actual Beam.render: original sprite48+color, additive; midpoint/rotation/full-image stretch; two colors/four angles; warning/fade widths; syntax')
