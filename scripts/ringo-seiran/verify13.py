from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran')
v=LuaRuntime()
for p in m.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern
assert(P.specs.spell.hp==15000 and P.specs.spell.time==45 and P.specs.nonspell.hp==13000)
local w=P.new('spell');w.px,w.py=1000,1000
local b={kind='impactPellet',x=0,y=128,angle=0,speed=1,age=0,rotation=0,spinSpeed=12,alpha=1}
w.bullets={b}
for i=1,120 do P.advance(w)end
assert(b.age==120 and b.x==120 and b.y==128 and b.rotation==1440 and b.spinSpeed==12 and b.speed==1 and not b.dead)
w.px,w.py=b.x+49,b.y;P.advance(w)
assert(b.fadeAge==1 and b.alpha<1 and b.alpha>0)
w.px,w.py=-1000,-1000
local alpha=b.alpha
for i=2,15 do
 P.advance(w);assert(b.fadeAge==i and b.alpha<alpha);alpha=b.alpha
 if i<15 then assert(not b.dead)end
end
assert(b.dead and b.alpha==0 and #w.bullets==0 and b.rotation==1620 and b.x==135)
-- Far bullets disappear at the existing boundary, with no timed expiry.
local c={kind='impactPellet',x=255,y=128,angle=0,speed=2,age=0,rotation=0,spinSpeed=12,alpha=1}
w.bullets={c};P.advance(w);assert(c.dead)
-- Proximity logic never fades dango/gun shots.
local d={kind='gun',x=0,y=128,angle=0,speed=2,age=0}
w.px,w.py=0,128;w.bullets={d};P.advance(w);assert(not d.fadeAge and not d.dead)
-- Real emission retains count,palette and historical initial speed range.
local e=P.new('spell');e.t=0;e.px,e.py=0,380;P.seiranStep(e)
e.t=119;P.seiranStep(e)
assert(e.stats.pellet==8 and e.stats.gun==18)
local colors={};local n=0
for _,s in ipairs(e.bullets)do if s.kind=='impactPellet' then
 assert(s.speed>=36/41 and s.speed<=168/41 and s.spinSpeed==12 and not s.lifetime and not s.deceleration)
 if not colors[s.color]then colors[s.color]=true;n=n+1 end
end end
assert(n==2 or n==3)
''')
print('PASS: HP15000; constant flight/spin beyond90f;48px proximity irreversible15f smooth fade/removal;offscreen cull;8stars/2-3colors/initial speed retained;guns unaffected.')
