from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran');v=LuaRuntime()
for p in m.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern;local w=P.new('spell');w.px,w.py=0,380
P.seiranStep(w);w.t=119;P.seiranStep(w)
assert(w.stats.gun==36 and w.stats.pellet==6)
local rings,guns={},{}
for _,b in ipairs(w.bullets)do
 if b.kind=='impactPellet'then rings[#rings+1]=b;assert(b.color==2)
 else guns[#guns+1]=b end
end
for i,b in ipairs(rings)do
 local expected=guns[(i-1)*6+1].angle+math.pi/6
 assert(math.abs(b.angle-expected)<1e-9)
 assert(not b.lifetime and not b.deceleration and b.speed>0 and b.spinSpeed==12)
end
local b=rings[1];b.x,b.y,b.angle,b.speed=0,128,0,1
w.bullets={b};w.px,w.py=1000,1000
for i=1,120 do P.advance(w)end
assert(b.x==120 and not b.dead and b.spinSpeed==12)
w.px,w.py=145,128;P.advance(w);assert(b.fadeAge==1)
w.px,w.py=1000,1000;for i=2,15 do P.advance(w)end
assert(b.dead and b.alpha==0)
Shot={};bullet={render=function()error('filled ball renderer used')end}
function Color(a,...)return a end
function SetImageState(image,blend,alpha)drawAlpha=alpha end
function Render4V(image,...)local q={...};quads[#quads+1]=q end
''')
root=(m/'root.lua').read_text(encoding='utf-8')
v.execute(root[root.index('function Shot:render()'):root.index('function Shot:kill()')])
v.execute('''
quads={};Shot.render({x=0,y=0,data={kind='impactPellet',alpha=.5}})
assert(#quads==64 and drawAlpha==127.5)
for _,q in ipairs(quads)do for i=1,12,3 do
 local radius=(q[i]^2+q[i+1]^2)^.5
 assert(radius>=6-1e-8 and radius<=10+1e-8,'filled center or wrong radius')
end end
''')
print('PASS:6red rings;each gun direction+30deg;36guns unchanged;constant motion/proximity24/fade15 retained;actual render emits only annular geometry,no filled center;Lua51 syntax.')
