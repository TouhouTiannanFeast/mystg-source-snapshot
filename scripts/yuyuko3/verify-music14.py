from pathlib import Path
import sys,json,wave
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3');l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''loads={};states={};ext={pausemenu={PauseSound=function()end,ResumeSound=function()end}}
LoadMusic=function(n,p,e,d)assert(e==d and d>0);loads[n]={p,e,d};states[n]='stopped'end
EnumRes=function()return {'menu'}, {'y3.music.road','y3.music.boss'}end
StopMusic=function(n)states[n]='stopped'end
PlayMusic=function(n)states[n]='playing'end
GetMusicState=function(n)return states[n]end
PauseMusic=function(n)states[n]='paused'end
ResumeMusic=function(n)states[n]='playing'end''')
l.execute((m/'music.lua').read_text('utf-8-sig'))
l.execute('''Y3Music.play('road');assert(states['y3.music.road']=='playing');Y3Music.play('boss');assert(states['y3.music.road']=='stopped' and states['y3.music.boss']=='playing')
ext.pausemenu:PauseSound();assert(states['y3.music.boss']=='paused');ext.pausemenu:ResumeSound();assert(states['y3.music.boss']=='playing');Y3Music.stop();assert(states['y3.music.boss']=='stopped')''')
for row in json.loads((m/'music/manifest.json').read_text('utf-8')):
 with wave.open(str(m/row['output'])) as w:assert abs(row['duration']-w.getnframes()/w.getframerate())<1e-9
l.execute('assert(loadstring(...))',(m/'root.lua').read_text('utf-8-sig'))
print('PASS WAV durations/full-track loop boundaries, road->boss, pause/resume/stop and Lua51 syntax')
