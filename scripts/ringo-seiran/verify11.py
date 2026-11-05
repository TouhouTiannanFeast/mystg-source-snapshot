from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran')
v=LuaRuntime()
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
Effects={};cos=math.cos;sin=math.sin
function Color(a,...)return a end
function SetImageState(img,blend,alpha)currentAlpha=alpha end
function Render(img,x,y,rot,sx,sy)draws[#draws+1]={img=img,x=x,y=y,scale=sx,alpha=currentAlpha}end
P=RingoSeiranPattern
''')
root=(m/'root.lua').read_text(encoding='utf-8')
v.execute(root[root.index('function Effects:render()'):root.index('local Dialogue=Class(object)')])
v.execute('''
local w={x=0,y=128,charging=true,effects={}}
local effect={patternWorld=w}
local last
for age=90,120 do
 w.chargeAge=age;draws={};Effects.render(effect)
 assert(#draws==25)
 for i=2,25 do
  local d=draws[i];local radius=((d.x)^2+(d.y-96)^2)^.5
  if last then assert(radius<=last[i]+1e-8,'particle reset outward in fade')end
  if age==120 then assert(radius<1e-8 and d.scale==0 and d.alpha==0)end
 end
 if last then assert(draws[1].alpha<=last.alpha,'ring brightened in fade')end
 last={alpha=draws[1].alpha}
 for i=2,25 do last[i]=(draws[i].x^2+(draws[i].y-96)^2)^.5 end
end
w.charging=false;draws={};Effects.render(effect);assert(#draws==0)
''')
print('PASS: actual render path final30f particle distances never reset outward; particle/ring alpha and size zero at120; no charge rendering after release.')
