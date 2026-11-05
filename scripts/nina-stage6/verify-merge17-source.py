from pathlib import Path
from lupa.lua51 import LuaRuntime
m=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
l=LuaRuntime(unpack_returned_tuples=True)
for p in m.rglob('*.lua'):
 result=l.eval('function(s)return loadstring(s)end')(p.read_text(encoding='utf-8-sig'));assert not isinstance(result,tuple),(str(p),result)
l.execute('ran={Float=function(self,a,b)return (a+b)/2 end}')
for name in ['runtime','road-runtime','projectiles','programs']:l.execute((m/'road17'/(name+'.lua')).read_text(encoding='utf-8'))
l.execute('''
local R=TH11S6Runtime;R.start()
while not R.roadEnd and R.tick<25000 do
 if R.midbossBorn and R.bossPresent and R.tick>=R.midbossBorn+5400 then
  for _,a in ipairs(R.actors)do if not a.controller then a.dead=true end end
  R.bossPresent=false
 end
 R.step(0,400,1);R.stepHazards()
end
assert(R.roadEnd,'road did not end')
print('ROAD END tick='..R.tick..' midBorn='..tostring(R.midbossBorn))
''')
print('PASS all merged Lua51 syntax')

import json,hashlib,re
src=Path(r'G:/MySTG/aex-0.8.22/game/mod/TH11Stage6Normal')
manifest=json.loads((m/'source/road17.json').read_text(encoding='utf-8'))
for rel,expected in manifest['files_sha256'].items():
 original=src/rel;target=m/'road17'/rel
 assert hashlib.sha256(original.read_bytes()).hexdigest()==expected,('original road changed',rel)
 if original.suffix!='.lua':assert target.read_bytes()==original.read_bytes(),rel
 elif rel!='voice.lua':
  transformed=re.sub(r"([\"'])(art|milk|music|voice|se)/",r'\1road17/\2/',original.read_text(encoding='utf-8-sig'))
  if rel=='background.lua':transformed=transformed.replace('function B.Object:render()','function B.Object:render()\n if self.ninaHidden then return end')
  assert target.read_text(encoding='utf-8')==transformed,('unexpected road logic edit',rel)
load=(m/'road17/load.lua').read_text(encoding='utf-8')
assert load.count('TH11S6Voice.play(4)')==1 and load.index('TH11S6Voice.play(4)')>load.index('function road.arrived()')
l.execute("object={};function Class()return{}end;stage={current_stage={timer=500,stage_name='Nina Six@Normal'}};item={PlayerMiss=function()lstg.var.lifeleft=lstg.var.lifeleft-1 end};lstg={var={lifeleft=8}};NinaRoad17={active=false,pendingLaugh=false};plays={};volumes={};function LoadMusic()end;function StopMusic()end;function PlayMusic(n,v)table.insert(plays,n)end;function SetBGMVolume(n,v)table.insert(volumes,v)end")
l.execute((m/'road17/voice.lua').read_text(encoding='utf-8'))
arrived=load[load.index('function road.arrived()'):load.index('function road.clean()')]
l.execute('local road=NinaRoad17;'+arrived)
l.execute("NinaRoad17.arrived();assert(#plays==0);NinaRoad17.pendingLaugh=true;NinaRoad17.arrived();NinaRoad17.arrived();assert(#plays==1 and plays[1]=='th11s6.voice4');for i=1,232 do TH11S6Voice.step()end;assert(TH11S6Voice.active[4]==nil);assert(math.abs(volumes[1]-1/30)<1e-8)")
l.execute("item:PlayerMiss();assert(#plays==1);NinaRoad17.active=true;item:PlayerMiss();assert(#plays==2 and plays[2]=='th11s6.voice1')")
print('PASS original road hashes/unchanged source logic and assets; deferred fourth laugh once with original232f/30f envelope; miss laugh road-only')
