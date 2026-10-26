from pathlib import Path
import importlib
import math

root = Path('G:/MySTG/aex-0.8.22/game/mod/DeepSeekCoT')
for backend in ('lua51', 'luajit21', 'lua54'):
    lua = importlib.import_module('lupa.' + backend).LuaRuntime(unpack_returned_tuples=True)
    lua.execute(r'''
objects={}; created={}; classes={}; player={x=0,y=-165}; setting={}
function Include() end
function Class(base) local c=setmetatable({}, {__index=base}); classes[#classes+1]=c; return c end
function New(c,...) local o=setmetatable({alive=true},{__index=c}); objects[#objects+1]=o; c.init(o,...); created[#created+1]=o; return o end
function IsValid(o) return o.alive end
function Del(o) if o.alive then o.alive=false; if o.del then o:del() end end end
function cos(a) return math.cos(a*math.pi/180) end
function sin(a) return math.sin(a*math.pi/180) end
function Angle(o,p) return math.atan2(p.y-o.y,p.x-o.x)*180/math.pi end
bullet={init=function(o) o.img='mock' end,skip_fade_in=function() end,del=function() end,kill=function() end,render=function() end}
boss={card={New=function() return {} end},init=function() end}
object={}; stage={group={New=function() end,AddStage=function() end,DefStageFunc=function() end}}; stage_init={}; task={}
ball_big='big'; ball_mid='mid'; grain_a='rice'; COLOR_BLUE=1; COLOR_CYAN=2; COLOR_PURPLE=3
function step()
 local batch={}; for _,o in ipairs(objects) do if o.alive then batch[#batch+1]=o end end
 for _,o in ipairs(batch) do if o.alive then o:frame(); if o.alive then o.x=o.x+(o.vx or 0); o.y=o.y+(o.vy or 0) end end end
 local live={}; for _,o in ipairs(objects) do if o.alive then live[#live+1]=o end end; objects=live
end
''')
    if backend == 'lua54':
        lua.execute('math.atan2=math.atan')
    lua.execute("package.path='" + root.as_posix() + "/?.lua;'..package.path")
    lua.execute((root / 'root.lua').read_text(encoding='utf-8'))
    lua.execute('R=require("rules"); assert(R.turn(179,-179,0.8)==179.8); assert(not R.trigger(44,0,-165,0,-165)); assert(R.trigger(45,0,-165,0,-165)); assert(R.trigger(150,190,130,0,-165))')
    # One mother: exactly 3 children then 6 terminal descendants.
    lua.execute("m=New(classes[1],0,-60,-90,'mother'); m.age=45; step(); assert(m.warning==1 and m.vx==0); for i=1,29 do step() end; assert(m.alive); step(); assert(not m.alive and #created==4)")
    lua.execute('for i=1,79 do step() end; assert(#created==10); for i=5,10 do assert(created[i].kind=="scatter") end')
    # Deletion and kill suppress branching, including during the warning.
    lua.execute("created={}; m=New(classes[1],0,-60,-90,'mother'); m.age=45; step(); Del(m); n=#created; for i=1,120 do step() end; assert(#created==n); c=New(classes[1],0,0,-90,'child'); c:kill(); c.alive=false; n=#created; for i=1,120 do step() end; assert(#created==n)")
    lua.execute('objects={}; created={}')
    peak = 0
    for tick in range(3600):
        lua.globals().player.x = 95 * math.sin(math.radians(tick * 0.55))
        if tick % 210 == 0:
            lua.execute("for i=-1,1 do New(classes[1],i*26,132,-90+i*18,'mother') end")
        lua.execute('step()')
        peak = max(peak, len(lua.globals().objects))
    assert peak < 160
    lua.execute('for _,o in ipairs(objects) do Del(o) end; for _,o in ipairs(objects) do assert(not IsValid(o)) end')
    print(f'{backend}: PASS warning timing, 1->3->6, terminal generation, cancellation, angle wrapping, 3600-frame budget (peak={peak}) and cleanup')
