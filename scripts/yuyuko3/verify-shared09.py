from pathlib import Path
import sys,hashlib,re
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3');src=m.parent/'Le03Stage4Normal'
l=LuaRuntime(unpack_returned_tuples=True)
for p in list(m.rglob('*.lua'))+list(src.glob('*.lua')):l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))

# Execute actual road host/run with minimal engine facade, tracking every owned object.
l.execute('''
setting={y3_seed=42,y3_invincible=true};player={protect=0,x=0,y=-176}
bullet={init=function()end,skip_fade_in=function()end,del=function()end,kill=function()end}
enemy={init=function(o,_,hp)o.hp=hp end,take_damage=function(o,d)o.hp=o.hp-d end}
laser={init=function()end,frame=function()end}
function Class(base)return setmetatable({},{__index=base})end
objects={}
function New(c,...)local o=setmetatable({},{__index=c});objects[#objects+1]=o;if c.init then c.init(o,...)end;return o end
function IsValid(o)return o~=nil and not o.deleted end
function Del(o)o.deleted=true;if o.del then o:del()end end
function LoadTexture()end;function LoadImage()end;function GetTextureSize()return 160,24 end
task={Wait=function(n)return coroutine.yield(n)end}
''')
loaded=[]
def include(name):
 loaded.append(name)
 l.execute((m.parent.parent/name).read_text('utf-8-sig'))
l.globals().Include=include
l.execute((m/'road/host.lua').read_text('utf-8-sig'))
assert all(name.startswith('mod/Le03Stage4Normal/') for name in loaded)
assert 'mod/Le03Stage4Normal/bullet-style.lua' in loaded
assert 'mod/Le03Stage4Normal/enemy-art.lua' in loaded
assert l.globals().Le03AssetRoot=='mod/Le03Stage4Normal/art/'
print('PASS live dependency modules:',','.join(loaded))
l.execute('''
local co=coroutine.create(function()Y3Road.run(9500)end)
for i=1,3000 do
 local ok,err=coroutine.resume(co);assert(ok,err)
 if coroutine.status(co)=='dead'then break end
end
assert(coroutine.status(co)=='dead','Road never ended')
assert(Le03.finished and Le03.counts.enemies>0 and Le03.counts.enemies<122)
for _,o in ipairs(objects)do assert(o.deleted,'Owned road object leaked')end
for _,b in ipairs(Le03.shots)do assert(not b.active)end
assert(player.protect==1000)
print('PASS actual road run/transition: frame9500 -> '..Le03.tick..'; skipped earlier waves; spawned='..Le03.counts.enemies..'; all owned objects/bullets cleared; invincibility')
''')
for n in ['runtime','th07','le04']:l.execute((m/f'{n}.lua').read_text('utf-8-sig'))
s=(m/'root.lua').read_text('utf-8-sig')
l.execute('Yuyuko={};R=Y3;card=function(id)return id end;boss={init=function(o,x,y,n,cards)o.cards=cards end}')
l.execute(re.search(r'function Yuyuko:init\(mode\).*?\nend',s,re.S)[0])
l.execute('''
for i,id in ipairs(Y3.order)do
 setting.y3_full=true;local o={};Yuyuko.init(o,id)
 assert(#o.cards==7-i and o.cards[1]==id and o.cards[#o.cards]=='spell3')
 setting.y3_full=false;o={};Yuyuko.init(o,id);assert(#o.cards==1 and o.cards[1]==id)
end
''')
print('PASS all six Boss suffix entry selections; original single-phase practice preserved; source module paths; Lua syntax')

