from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/SixStageCampaign');l=LuaRuntime()
l.execute("""
function Class(base)local c={};setmetatable(c,{__index=base});return c end
function New(c,...)local o=setmetatable({},{__index=c});c.init(o,...);made[#made+1]=o;return o end
SixStageCampaign={install=function()end};enemy_death_ef={render=function()end,frame=function()end};GROUP_GHOST=0;LAYER_ENEMY=10;made={};calls=0
Th18Stage5Runtime={};Th18Stage5Host={owned={},begin=function()Th18Stage5Runtime.onDeath=function(a)calls=calls+1 end end}
""")
l.execute((m/'road4-death.lua').read_text('utf-8'))
l.execute('SixStageCampaign.install(4,{});Th18Stage5Host.begin()')
route=(m.parent/'MarisaMixed/road/route.lua').read_text('utf-8');a=route.index('function R.die(a)');b=route.index('function R.interrupt',a)
l.execute('local R=Th18Stage5Runtime;R.drop=function()end;'+route[a:b])
l.execute("local R=Th18Stage5Runtime;a={hp=0,x=12,y=90};R.die(a);R.die(a);assert(#made==1 and calls==1);assert(made[1].x==12 and made[1].y==134 and made[1].render==enemy_death_ef.render);R.die({hp=30,x=0,y=0});assert(#made==1 and calls==2);made[1]:del();assert(next(Th18Stage5Host.owned)==nil)")
print('PASS actual R.die: one effect/one sound callback, no duplicate, no positive-HP clear effect, source-to-world position, base visual lifecycle and cleanup')
