from pathlib import Path
from lupa.lua51 import LuaRuntime
root=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages')
l=LuaRuntime(unpack_returned_tuples=True)
l.execute("""
function Class(base)return setmetatable({base=base},{__index=base})end
object={};background={};enemybase={init=function(self,hp)self.hp=hp end};bullet={init=function()end,skip_fade_in=function()end,del=function()end,kill=function()end}
GROUP_GHOST=0;GROUP_NONTJT=1;GROUP_ENEMY_BULLET=2;GROUP_INDES=3;LAYER_ENEMY_BULLET=100;LAYER_ITEM=200
function New(class,...)local o=setmetatable({class=class},{__index=class});class.init(o,...);return o end
function Del(o)if not o.removed then o.removed=true;if o.class.del then o.class.del(o)end end end
function IsValid(o)return o and not o.removed end
function LoadTexture()end;function SetTextureSamplerState()end;function LoadImage()end;function PlaySound()end
player={x=0,y=-176};lstg={var={power=200,lifeleft=3,money=137}}
""")
for name in ['suwako5/pool','th18_stage5/data','th18_stage5/anm','th18_stage5/runtime','th18_stage5/projectiles','th18_stage5/programs','th18_stage5/route','th18_stage5/host']:
 l.execute(root.joinpath(name+'.lua').read_text(encoding='utf-8-sig'))
l.execute("""
local H,R,A=Th18Stage5Host,Th18Stage5Runtime,Th18Stage5Animation
H.begin(123);local a=R.newActor('th18',0,100);a.name='GirlC01';a.drops={main=18,extra={[1]=4,[2]=4},timed={[2]=4},window=120,start=0,area={32,32}};R.tick=60;R.drop(a)
assert(H.counts.spawned[18]==1 and H.counts.spawned[1]==4 and H.counts.spawned[2]==6,'time bonus/main drop')
local item;for o in pairs(H.items)do if o.typ==1 then item=o;break end end
item.nativeX,item.nativeY,item.dropVX,item.dropVY=0,100,0,-2.2
for t=1,40 do item.class.frame(item)end
assert(math.abs(item.nativeY-35.4)<1e-5,'native gravity trajectory')
H.cleanup();H.counts={spawned={},collected={}}
local events={};H.onCollect=function(e)events[#events+1]=e end
for typ=16,19 do R.onDrop(typ,0,400,-math.pi/2,2.2,a)end
local cards={};for o in pairs(H.items)do cards[#cards+1]=o end
for _,o in ipairs(cards)do o.class.frame(o)end
for typ=16,19 do assert(H.counts.collected[typ]==1,'card pickup '..typ)end
assert(#events==4 and events[1].card,'future card hook');assert(lstg.var.power==200 and lstg.var.lifeleft==3 and lstg.var.money==137,'resource effects must remain inactive')
H.cleanup();H.counts={spawned={},collected={}};R.onDrop(9,0,100,-math.pi/2,2.2,a)
local point=next(H.items);for t=1,220 do if not point.removed then point.class.frame(point)end end
assert(point.removed and H.counts.collected[9]==1,'cancel-point intro/upthrow/homing')
R.hazards={{typ=5,color=4,x=0,y=0,dead=false,group='th18'}};local n=H.counts.spawned[9];R.cancel({x=0,y=0},640,false);assert(H.counts.spawned[9]==n,'pure clear made items')
R.hazards={{typ=5,color=4,x=0,y=0,dead=false,group='th18'}};R.cancel({x=0,y=0},640,true);assert(H.counts.spawned[9]==n+1,'cancel lost point')
R.hazards={{x=1,y=1,dead=false}};a.drops={main=0,extra={},timed={},area={32,32},start=R.tick};R.die(a);assert(not R.hazards[1].dead,'enemy death improperly cleared bullets')
H.cleanup();assert(next(H.owned)==nil and next(H.items)==nil,'owned object leak')
""")
print('PASS source drop count/time bonus; item gravity; four resource-card pickups/inactive hook; cancel-point intro/homing; clear-vs-cancel; enemy death retains bullets; cleanup')
