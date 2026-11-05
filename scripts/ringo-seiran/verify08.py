from pathlib import Path
import sys
sys.path.insert(0, 'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m = Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran')
v = LuaRuntime()
for p in m.glob('*.lua'):
    v.execute('assert(loadstring(...))', p.read_text(encoding='utf-8'))
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern
assert(P.specs.nonspell.hp==13000 and P.specs.nonspell.time==30)
assert(P.specs.spell.hp==15000 and P.specs.spell.time==45)
local w=P.new('spell',function()return .5 end)
assert(w.seiran.y==-64 and w.dialogue=='ringo')
local charges=0;w.onCharge=function()charges=charges+1 end
local previous=-64
for i=1,540 do
 P.step(w,50,380)
 assert(w.opening and w.t==0 and w.elapsed==i and #w.bullets==0)
 assert(w.seiran.x==-80 and not w.seiran.active)
 assert(w.seiran.y>=previous and w.seiran.y<=128)
 if i<=180 then assert(w.dialogue=='ringo' and w.seiran.y==-64 and not w.charging)
 elseif i<=240 then assert(not w.dialogue and not w.charging)
 elseif i<=420 then assert(w.dialogue=='seiran' and w.seiran.y==128 and not w.charging)
 else assert(not w.dialogue and w.charging and w.chargeAge==i-420)end
 if i>=240 then assert(w.seiran.y==128 and not w.seiran.entering)end
 previous=w.seiran.y
 assert(w.stats.locks==0 and not w.seiran.sprite)
end
assert(charges==1)
P.step(w,50,380)
assert(not w.opening and not w.charging and not w.dialogue and w.t==1 and w.stats.dango==3 and w.stats.locks==1)
for i=2,120 do P.step(w,50,380)end
assert(w.elapsed==660 and w.stats.impacts==1 and w.stats.gun==36 and w.stats.pellet==6)
assert(w.seiran.sprite==17 and w.seiran.swing and w.seiran.active)
local n=P.new('nonspell',function()return .5 end)
for i=1,31 do P.step(n,0,380)end
assert(n.t==31 and n.stats.dango==72 and not n.charging)
''')
print('PASS: Lua51 syntax; unchanged HP/time; Ringo180->entry60->Seiran180->charge120; no shots540f; charge sound once; attack541/impact660; original nonspell schedule.')
