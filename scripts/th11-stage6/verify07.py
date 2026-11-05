from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
ref=json.loads((M/'source/integration07.json').read_text())
for c in ref['clips']:
 assert Path(c['source']).read_bytes()==(M/c['output']).read_bytes()
 assert hashlib.sha256((M/c['output']).read_bytes()).hexdigest()==c['sha256']
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
object={};Class=function()return {}end
item={PlayerMiss=function()end}
LoadMusic=function()end;GROUP_GHOST=0;states={};volumes={};plays={}
StopMusic=function(n)states[n]='stopped'end
PlayMusic=function(n,v)states[n]='playing';volumes[n]=v;plays[n]=(plays[n]or 0)+1 end
SetBGMVolume=function(n,v)volumes[n]=v end
''')
l.execute((M/'voice.lua').read_text(encoding='utf-8'))
l.execute('''
local V=TH11S6Voice
for id=1,4 do
 V.play(id);local c=V.clips[id];assert(volumes[c.name]==0)
 for t=1,c.frames do
  V.step()
  if t<c.frames then assert(math.abs(volumes[c.name]-({.5,2,2,1})[id]*math.min(1,t/30,(c.frames-t)/30))<1e-9)
  else assert(not V.active[id]and states[c.name]=='stopped')end
 end
 assert(plays[c.name]==1)
end
V.play(1);V.play(2);V.clean();assert(next(V.active)==nil)
for _,c in ipairs(V.clips)do assert(states[c.name]=='stopped')end
assert(V.clips[1].volume==.5)
V.play(1,1)
for t=1,V.clips[1].frames do
 V.step()
 if t<V.clips[1].frames then assert(math.abs(volumes[V.clips[1].name]-math.min(1,t/30,(V.clips[1].frames-t)/30))<1e-9)end
end
local calls=0;local original=V.play;V.play=function(id)assert(id==1);calls=calls+1 end
local first={name='Crow00'};local second={name='Crow01'}
local R={tick=299,actors={}}
V.checkFirstBatch(R);assert(calls==0,'gap before final births')
R.tick=300;V.checkFirstBatch(R);assert(calls==0,'final birth tick')
R.tick=301;R.actors={first,second};V.checkFirstBatch(R);assert(calls==0,'last Crow00 alive')
first.dead=true;R.tick=420;V.checkFirstBatch(R);assert(calls==1,'cleared first batch even with later batch alive')
for i=1,40 do V.checkFirstBatch(R)end;assert(calls==1,'once only')
V.clean();assert(not V.firstBatchDone);V.play=original
''')
root=(M/'root.lua').read_text(encoding='utf-8');l.execute('assert(loadstring(...))',root)
for i in range(2,5):assert root.count(f'TH11S6Voice.play({i})')==1
assert 'TH11S6Voice.play(1)'not in root
assert "if checkpoint==0 then TH11S6Voice.checkFirstBatch(R)end"in root
assert "while TH11S6Voice.active[4]do task.Wait(1)end"in root
print('PASS exact4OGGs; firstbatch gate once/reset; peaks0.5/2/2/1; all4 full30f-in/out envelopes/stop/cleanup;root syntax and trigger.')
