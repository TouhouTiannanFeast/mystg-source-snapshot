from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
GAME=Path('G:/MySTG/aex-0.8.22/game');MOD=GAME/'mod/SixStageCampaign'
def read(p):return p.read_text(encoding='utf-8-sig')
l=LuaRuntime()
l.execute('''
setting={marisa_phase='stardust',marisa_ssg_mode='full'}
SixStageCampaign={install=function()end};function Include()end
GROUP_ENEMY_BULLET=1;GROUP_INDES=2;LAYER_ENEMY_BULLET=100
function LoadSound()end;function PlaySound()end;function SetViewMode()end
function IsValid(o)return o and not o.removed end
function Del(o)o.removed=true end;function Kill(o)o.removed=true end
function Dist(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
owned={};function ObjList()return ipairs(owned)end
bullet_deleter={frame=function(o)o.original=true end}
boss={card={New=function(name,t1,t2,t3,hp)return{name=name,hp=hp,t3=t3*60}end},
 move={New=function(x,y,t,m)return{name='move',x=x,y=y,t=t,m=m}end},take_damage=function()end,
 frame=function()end,init=function(o,x,y,name,cards)o.cards=cards;o.x=x;o.y=y end}
classes={};function Class(base)
 local c={base=base};setmetatable(c,{__index=base});classes[#classes+1]=c;return c
end
task={New=function()end}; MOVE_DECEL=1
th08s4={phase_specs={milky={hp=2300}},clear=function()end,Beam={frame=function(o)o.checked=true end},
 card=function(id)return{name=id=='milky'and'Magic Sign / Milky Way'or id,hp=id=='milky'and th08s4.phase_specs.milky.hp or({stardust=16000,non1=15700,non3=15500,master=2000})[id],init=function()end}end}
SSG={};SSGSelected05={frames=function()return 3780 end,accept=function()return true end}
SSGInspect04={};MarisaVisual={clear=function()end}
MarisaDS={clean=function()end,card=function()return{name='comet',hp=10000,init=function()end}end}
DSExtraPool={specs={[8]={}}}
''')
source=read(GAME/'mod/MarisaMixed/root.lua')
l.execute(source.split('function Boss:render()')[0],name='@mod/MarisaMixed/root.lua')
l.execute(read(MOD/'combat-review.lua'))
l.execute("""
SixStageCampaign.install(4,classes)
local b={};classes[#classes].init(b)
assert(#b.cards==7 and b.cards[2].name=='stardust' and b.cards[3].name=='non1')
assert(type(b.cards[2].after)=='function')
task.MoveTo=function(x,y,t,m)assert(x==0 and y==135 and t==60 and m==MOVE_DECEL)end
b.cards[2].after(b)
assert(b.cards[4].hp==12000)
print('PASS Stardust after uses exact Milky-practice entry move(0,135,60,MOVE_DECEL); card order and HP retained')
""")
