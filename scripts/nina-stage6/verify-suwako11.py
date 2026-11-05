from pathlib import Path
from lupa.lua51 import LuaRuntime
p=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
lua=LuaRuntime(unpack_returned_tuples=True)
for f in ['root.lua','suwako11.lua']:
 result=lua.eval('function(s) return loadstring(s) end')((p/f).read_text(encoding='utf-8'));assert not isinstance(result,tuple),result
lua.execute((p/'suwako11.lua').read_text(encoding='utf-8'))
lua.execute('a={x=0,y=100,age=0,hp=4000};NinaSuwako11.init(a)')
a=lua.globals().a;n=lua.globals().NinaSuwako11
for direction in [1,-1]:
 for t in range(20):
  a.x=a.x+direction*.1;n.step(a);frame,mirror=n.frame(a)
  assert frame==4+min(2,t//4) and mirror==direction,(t,frame,mirror)
 for t in range(16):
  n.step(a);frame,mirror=n.frame(a)
  assert frame==(6 if t<4 else 5 if t<8 else ((t-8)//7)%4),(t,frame)
assert a.y==100 and a.hp==4000
for key in ['down','colorDownStart']:
 a[key]=True;a.x=a.x+2;n.step(a);assert a.suwakoAnimation.direction==0;a[key]=None
print('PASS Lua51 syntax; left/right4f enter/held6; reverse6/5 then7f idle; down-animation precedence; HP/y unchanged; actual source frames already shipped')
assert (p/'root.lua').read_text(encoding='utf-8').count('NinaSuwako11.step(a)')==1
