from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran');v=LuaRuntime()
for p in m.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute('sounds={};drops={};item_bomb={};function PlaySound(...)sounds[#sounds+1]={...}end;function New(...)drops[#drops+1]={...}end')
v.execute((m/'feedback.lua').read_text(encoding='utf-8'))
v.execute('''
local F=RingoSeiranFeedback;local s={}
for i=1,100 do F.shot(s,{kind='red',x=0},1)end
for i=1,18 do F.shot(s,{kind='gun',x=0},1)end
for i=1,8 do F.shot(s,{kind='impactPellet',x=0},1)end
assert(#sounds==3 and sounds[1][1]=='tan00' and sounds[2][1]=='gun00' and sounds[3][1]=='tan01')
F.shot(s,{kind='red',x=0},2);assert(#sounds==4)
F.swing({x=0});F.impact({headX=0});assert(sounds[5][1]=='slash' and sounds[6][1]=='don00')
local b={hp=0,x=10,y=96}
assert(F.reward(b,'nonspell') and #drops==1 and drops[1][1]==item_bomb)
assert(not F.reward(b,'nonspell') and #drops==1)
assert(not F.reward({hp=0,timeout=true},'nonspell'))
assert(not F.reward({hp=0},'spell'))
assert(not F.reward({hp=100},'nonspell'))
''')
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern;local w=P.new('spell');w.px,w.py=0,224
local seen={};local swing=0;w.onSwing=function()swing=swing+1 end
for cycle=0,99 do
 w.t=cycle*120;P.seiranStep(w)
 w.t=cycle*120+89;P.seiranStep(w)
 w.t=cycle*120+119;P.seiranStep(w)
 local colors={};local n=0
 for _,b in ipairs(w.bullets)do if b.kind=='impactPellet' then colors[b.color]=true;n=n+1 end end
 local count=0;for _ in pairs(colors)do count=count+1 end
 assert(n==8 and(count==2 or count==3));seen[count]=true;w.bullets={}
end
assert(swing==100 and seen[2] and seen[3])
''')
se=Path('G:/MySTG/aex-0.8.22/game/packages/thlib-scripts/THlib/se/se.lua').read_text(encoding='utf-8')
for name in ('tan00','gun00','tan01','slash','don00'):assert "'"+name+"'" in se
root=(m/'root.lua').read_text(encoding='utf-8');assert 'RingoSeiranFeedback.reward(o,id)' in root
print('PASS Lua51/audio routing+dedup/sound registration/nonspell B kill-only+dedup/100 bursts random2..3 colors/swing cadence')
