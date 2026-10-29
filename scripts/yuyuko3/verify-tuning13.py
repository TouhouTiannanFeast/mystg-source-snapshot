from pathlib import Path
import sys,math,re
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3');src=(m/'runtime.lua').read_text('utf-8-sig')
def setup(control=False):
 l=LuaRuntime(unpack_returned_tuples=True)
 l.execute(src.replace("if R.id=='spell3' then","if false then") if control else src)
 for n in ['th07.lua','le04.lua']:l.execute((m/n).read_text('utf-8-sig'))
 l.execute("all={};Y3.onShot=function(b)b.testID=#all+1;all[#all+1]=b end;Y3.start('spell3',42,192,112)")
 return l
l,c=setup(),setup(True);checked=0
for tick in range(650):
 before={i:(b['x'],b['y'],b['dead']) for i,b in l.globals().all.items()}
 for state in [l,c]:state.globals().Y3.step(192,400)
 for i,b in l.globals().all.items():
  ref=c.globals().all[i]
  assert ref is not None
  assert abs(b['vx']-ref['vx'])<1e-9 and abs(b['vy']-ref['vy'])<1e-9
  if i in before and not before[i][2]:
   x,y,_=before[i];actual=math.hypot(b['x']-x,b['y']-y)
   raw=math.hypot(b['vx'],b['vy']);expected=math.floor(raw*.75*100+.500000001)/100
   assert abs(actual-expected)<1e-8,(tick,actual,expected)
   checked+=1
 assert l.globals().Y3.counts.shots==c.globals().Y3.counts.shots
 assert l.globals().Y3.counts.lasers==c.globals().Y3.counts.lasers
print('PASS rounded final velocity displacements:',checked,'; source vectors, emission counts and laser counts unchanged')
root=(m/'root.lua').read_text('utf-8-sig')
l.execute('assert(loadstring(...))',root)
# Execute actual image choice against existing green/purple variants.
fragment=re.search(r" if R.id=='non2'.*?end\n",root)[0]
l.execute("R={id='non2'};self={};b={le04=true,nativeType=3,nativeColor=5};"+fragment+"assert(self.img=='y3.b8.2')")
l.execute("R.id='spell2';self.img='original';"+fragment+"assert(self.img=='original')")
print('PASS only non2 green butterfly remapped to purple; root/runtime Lua51 syntax')
