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
assert(w.stats.gun==36 and w.stats.pellet==24)
local stars={};local color
for _,b in ipairs(w.bullets)do if b.kind=='impactPellet' then
 assert(not b.large and not b.deceleration and not b.lifetime)
 if color then assert(b.color==color)else color=b.color end
 stars[#stars+1]=b
end end
assert(#stars==24)
local b=stars[1];b.x,b.y,b.angle,b.speed=0,128,0,1
w.bullets={b};w.px,w.py=1000,1000
for i=1,120 do P.advance(w)end
assert(not b.dead and b.x==120 and b.speed==1 and b.spinSpeed==12 and b.rotation==1440)
w.px,w.py=b.x+25,b.y;P.advance(w);assert(b.fadeAge==1)
w.px,w.py=1000,1000
for i=2,15 do P.advance(w)end
assert(b.dead and b.alpha==0 and #w.bullets==0)
''')
print('PASS:24small/no big;single burst color;36guns;small constant flight/spin120f;24px trigger/15f fade+cleanup;Lua51 syntax.')
