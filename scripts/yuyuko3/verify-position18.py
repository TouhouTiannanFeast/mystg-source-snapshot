from pathlib import Path
import re, sys
sys.path.insert(0, 'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime

mod = Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
lua = LuaRuntime(unpack_returned_tuples=True)
root = (mod/'root.lua').read_text('utf-8-sig')
adapter = (mod/'road/host.lua').read_text('utf-8-sig')
for source in (root, adapter):
    lua.execute('assert(loadstring(...))', source)
lua.execute('Include=function()end; Le03={tick=0}; Le03Host={clean=function()end,run=function()end}')
lua.execute((mod.parent/'Le03Stage4Normal/schedule.lua').read_text('utf-8-sig'))
lua.execute(adapter)
frames = sorted({row[1] for _, row in lua.globals().Le03Schedule.items()})
assert len(frames) == 63
for frame in [0, *frames, *[f-1 for f in frames], 10822]:
    lua.globals().Le03.tick = frame
    wave, total, actual = lua.globals().Y3Road.position()
    assert (wave, total, actual) == (sum(f <= frame for f in frames), 63, frame)
lua.execute('Hud={};S={};R={tick=123};lines={};RenderText=function(_,s)lines[#lines+1]=s end')
lua.execute(re.search(r'function Hud:render\(\).*?\nend', root, re.S)[0])
lua.execute('Y3Road.active=true;Le03.tick=3100;Hud:render();assert(lines[1]=="ROAD / WAVE 26/63 / FRAME 3100")')
for phase, label in [('non1','NON 1'), ('spell1','SPELL 1'), ('non2','NON 2'), ('spell2','SPELL 2'), ('non3','NON 3'), ('spell3','SPELL 3')]:
    lua.globals().S.current = phase
    lua.execute('Y3Road.active=false;lines={};Hud:render()')
    assert lua.globals().lines[1] == f'BOSS / {label} / FRAME 123'
lua.execute('S.current=nil;S.finished=true;lines={};Hud:render();assert(lines[1]=="STAGE 3 / COMPLETE")')
print('PASS Lua51 syntax; all 63 wave boundaries and preceding frames; checkpoint 3100 = wave26; six Boss phase labels and local frame; complete state')
