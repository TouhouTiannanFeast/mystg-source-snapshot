from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran');v=LuaRuntime()
for p in m.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute((m/'pattern.lua').read_text(encoding='utf-8'))
v.execute((m/'word-points.lua').read_text(encoding='utf-8'))
v.execute('''
object={};GROUP_GHOST=1;LAYER_ENEMY_BULLET=2;S={owned={}};setting={}
function Class()return {}end
function Color(a,...)return a end
function SetImageState(image,blend,a)alpha=a end
function Render(...)draws[#draws+1]=alpha end
function Del(o)o.deleted=true end
function New(class,x,y,index)words[#words+1]=index end
misc={ShakeScreen=function()end};RingoSeiranFeedback={impact=function()end}
P=RingoSeiranPattern
''')
root=(m/'root.lua').read_text(encoding='utf-8')
code=root[root.index('local HammerWord='):root.index('local Dialogue=')]
v.execute(code.replace('local HammerWord=','HammerWord=',1))
hook=root[root.index('  w.onImpact=function(s)'):]
hook=hook[:hook.index('   if setting.rs_test then')]+ '  end\n'
v.execute("w=P.new('spell',function()return .5 end);words={}")
v.execute(hook)
v.execute('''
for i=1,900 do P.step(w,0,380)end
assert(#words==3 and words[1]==1 and words[2]==2 and words[3]==1)
assert(w.stats.gun==108 and w.stats.pellet==18)
for i=1,2 do
 local colors={};for _,p in ipairs(RingoSeiranWordPoints[i])do colors[p[3]]=true end
 assert(colors[2] and colors[12] and colors[16])
end
local o={timer=0};HammerWord.init(o,0,-150,1)
assert(o.colli==false and o.group==GROUP_GHOST and S.owned[o])
draws={};HammerWord.render(o);assert(#draws==#RingoSeiranWordPoints[1] and draws[1]==255)
o.timer=44;draws={};HammerWord.render(o);assert(draws[1]>0 and draws[1]<20)
o.timer=45;HammerWord.frame(o);assert(o.deleted)
HammerWord.del(o);assert(not S.owned[o])
''')
print('PASS: native impact hook alternates ssi/bal/ssi; all3colors; visual-only45f/fade15f/cleanup; gun/star counts unchanged;Lua51 syntax.')
