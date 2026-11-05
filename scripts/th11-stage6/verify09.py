from pathlib import Path
import json,hashlib,struct
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change09'
before=json.loads((L/'before-hashes.json').read_text())
for n,h in before.items():
 if n not in ['voice.lua','presentation.lua','README.md']:assert hashlib.sha256((M/n).read_bytes()).hexdigest()==h,n
ref=json.loads((M/'source/integration09.json').read_text())
for c in ref['frog_frames']:
 assert Path(c['source']).read_bytes()==(M/c['output']).read_bytes()
 assert struct.unpack('>II',(M/c['output']).read_bytes()[16:24])==(32,32)
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
object={};Class=function()return {}end;GROUP_GHOST=0
LoadMusic=function()end;PlayMusic=function()end;StopMusic=function()end;SetBGMVolume=function()end
lstg={var={lifeleft=5}};stage={current_stage={stage_name='Subterranean Animism 6@Normal'}}
loss=true;forward=0
item={PlayerMiss=function(o,arg)forward=forward+1;assert(arg=='original');if loss then lstg.var.lifeleft=lstg.var.lifeleft-1 end;return 73 end}
''')
l.execute((M/'voice.lua').read_text(encoding='utf-8'))
l.execute('''
local V=TH11S6Voice;local calls=0
V.play=function(id,gain)assert(id==1 and gain==1);calls=calls+1 end
assert(item.PlayerMiss({},'original')==73 and calls==1 and lstg.var.lifeleft==4)
item.PlayerMiss({},'original');assert(calls==2 and lstg.var.lifeleft==3,'every life loss')
loss=false;item.PlayerMiss({},'original');assert(calls==2,'no loss must not trigger')
loss=true;stage.current_stage.stage_name='other';item.PlayerMiss({},'original');assert(calls==2 and forward==4,'other stage/baseline forwarding')
assert(V.clips[1].volume==.5 and V.clips[2].volume==2 and V.clips[3].volume==2 and not V.clips[4].volume)
LoadTexture=function()end;LoadImage=function()end
local function sprites()return setmetatable({},{__index=function(_,k)return 'original'..k end})end
TH11S6Sprites={crow=sprites(),enemy=sprites()}
''')
l.execute((L/'before-presentation.lua').read_text(encoding='utf-8'));l.execute('oldPresentation=TH11S6Presentation')
l.execute((M/'presentation.lua').read_text(encoding='utf-8'))
l.execute('''
local P=TH11S6Presentation
for t=0,35 do
 local a={name='RPhantom01',age=t,poseStart=0,anm={[0]=94,[1]=46}}
 local img,rot,flip=P.enemy(a);assert(img==P.frog[math.floor(t/3)%3+1]and rot==0 and flip==1)
 local i,r,s,c=P.ring(a);local oi,orr,os,oc=oldPresentation.ring(a)
 assert(i==oi and r==orr and s==os and c==oc,'red halo changed')
 for _,name in ipairs({'BPhantom00','Crow00','Crow01','Crow02','Crow03'})do
  a.name=name;local i,r,f=P.enemy(a);local oi,orr,of=oldPresentation.enemy(a);assert(i==oi and r==orr and f==of,'other body changed')
 end
end
''')
programs=(M/'programs.lua').read_text(encoding='utf-8');assert programs.count('"enmCreate",{"RPhantom01"')==2
# Discover only a native checkpoint; no rendered full-stage run.
l.execute('ran={Float=function(self,a,b)return a+(b-a)*.376123 end}')
for n in ['runtime.lua','road-runtime.lua','projectiles.lua','programs.lua']:l.execute((M/n).read_text(encoding='utf-8'))
l.execute('''
local R=TH11S6Runtime;R.start();frogCheckpoint=nil
R.onActor=function(a)if a.name=='RPhantom01'and not frogCheckpoint then frogCheckpoint=R.tick-1 end end
while not frogCheckpoint and R.tick<16000 do
 if R.midbossBorn and R.bossPresent and R.tick>=R.midbossBorn+5400 then R.bossPresent=false end
 R.step(0,400,1)
end
assert(frogCheckpoint)
''')
(L/'checkpoint.txt').write_text(str(int(l.globals().frogCheckpoint)))
print('PASS actual miss wrapper: life loss/repeat/nonloss/otherstage/original callback+return;gains0.5/2/2/1. Exact3PNGs32px,ordered3f animation;halo+other bodies identical;host/trail/death/spawn/programs/HP/collision/player/music hashes unchanged. Both red actors use frog. Native checkpoint='+str(l.globals().frogCheckpoint))
