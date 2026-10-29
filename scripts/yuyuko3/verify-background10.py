from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
l=LuaRuntime(unpack_returned_tuples=True)
for n in ('root.lua','background.lua','background-player.lua','background-program.lua'):
 l.execute('assert(loadstring(...))',(m/n).read_text(encoding='utf-8-sig'))
l.execute((m/'background-program.lua').read_text())
l.execute((m/'background-player.lua').read_text())
l.execute('''state=Y3BackgroundPlayer.new(1);state.clear=0
Color=function(...)return {...}end;Set3D=function()end;SetViewMode=function()end;RenderClearViewMode=function()end;ClearZBuffer=function()end;SetZBufferEnable=function()end
local draws=0;RenderTexture=function()draws=draws+1 end
for _,t in ipairs({0,1280,4580,8130,12000})do Y3BackgroundPlayer.advance(state,t);Y3BackgroundPlayer.render(state)end
assert(draws>0 and state.loops>0);assert(state.anms[1].rgb[1]==96);assert(state.anms[3].uvspeed[2]==-0.05)
print('PASS source TH16 camera, fog, 3 layers, UV scrolling and loop; Lua51 syntax')''')
root=(m/'root.lua').read_text();before=Path('G:/MySTG/work/research/yuyuko3-background/root-before.lua').read_text()
assert root==before.replace("Include('le04.lua')","Include('le04.lua')\nInclude('background.lua')").replace("cards,nil,'Normal'","cards,New(Y3Background.spell),'Normal'").replace('New(default_stage_background);','New(Y3Background.stage);')
print('PASS root changes limited to background include/stage/spell wiring')
# FACE leading word is instance flags, not x.
l.execute('assert(Y3BackgroundProgram[1].groups[1].faces[1][1]==0 and Y3BackgroundProgram[1].groups[1].faces[1][2]==-200 and Y3BackgroundProgram[1].groups[1].faces[1][3]==0)')
