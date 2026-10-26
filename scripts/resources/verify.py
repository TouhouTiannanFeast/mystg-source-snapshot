from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
root=Path('G:/MySTG');base=root/'aex-0.8.22/game/mod/MySTG'
lua=LuaRuntime(unpack_returned_tuples=True)
for p in (base/'systems').glob('*.lua'):lua.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
lua.execute('''
setting={};lstg={var={score=0,power=100},lstg_ui={drawInfo1=function() end,drawInfo2=function() end}}
function LoadImage()end;function SetImageState()end;function Color(...)return ... end;function PlaySound()end
item={PlayerInit=function()lstg.var={score=0,power=100}end,playercollect=function()legacycombo=true end}
item_point={init=function(s)s.img='blue'end,collect=function()lstg.var.score=lstg.var.score+123 end}
item_faith={init=function(s)s.img='green'end,collect=function()lstg.var.faith=100 end}
item_faith_minor={init=function(s)s.img='minor'end,collect=function()lstg.var.score=lstg.var.score+500 end}
function GetPower(v) legacyPower=v end
player_lib={debug_data={},system={updateKeyState=function()end,shoot=function(s)s.shots=(s.shots or 0)+1 end}}
''')
def include(name):
 lua.execute((base/name).read_text(encoding='utf-8-sig'))
lua.globals().Include=include
include('systems/resources.lua')
lua.execute('''
item.PlayerInit();local R=MyResources;local C=MyResourceConfig
local s={};item_point.init(s);assert(s.img=='my.coin');item_point.collect(s);item_faith.collect(s)
assert(R.state().coins==2 and lstg.var.score==0 and not lstg.var.faith)
item_faith_minor.init(s);assert(s.img=='my.yellow');item_faith_minor.collect(s);assert(lstg.var.score==500)
GetPower(1);assert(lstg.var.power==101 and lstg.var.score==500)
lstg.var.power=400;GetPower(1);assert(lstg.var.score==600);GetPower(100);assert(lstg.var.score==10600)
local state=R.state();assert(R.state()==state);R.equip('tap_shot');assert(R.rule('shoot_mode','hold')=='press')
local sys=setmetatable({player={}}, {__index=player_lib.system})
local function tick(held,blocked)
 sys.player.__shoot_flag=held;sys:updateKeyState();if held and not blocked then sys:shoot()end
end
for i=1,20 do tick(true)end;assert(sys.shots==1)
tick(false);tick(true);assert(sys.shots==2)
tick(false);tick(true,true);tick(true);assert(sys.shots==2)
R.remove('tap_shot');for i=1,5 do tick(true)end;assert(sys.shots==7)
R.equip('tap_shot');item.PlayerInit();assert(not R.has('tap_shot') and R.state().coins==0)
C.enabled=false;item_point.init(s);assert(s.img=='blue');item_point.collect(s);assert(lstg.var.score==123)
GetPower(9);assert(legacyPower==9);item.playercollect();assert(legacycombo)
C.enabled=true;legacycombo=false;item.playercollect();assert(not legacycombo)
''')
print('PASS Lua5.1 syntax; coin/yellow collection; power/full-P score; run reset/carry; equip/remove; hold/press/cooldown; legacy fallback')

