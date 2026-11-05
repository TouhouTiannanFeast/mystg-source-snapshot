"""One Lua51 targeted preboss gate, exact user art, and current wave census."""
from pathlib import Path
from collections import Counter
import hashlib,json,struct
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change05'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
allowed={'runtime.lua','root.lua','milk/art/stg7enm2.png','source/suwako04-reference.json','README.md'}
for row in json.loads((L/'before-hashes.json').read_text(encoding='utf-8-sig')):
 if row['path']not in allowed:assert sha(M/row['path'])==row['sha256'],row['path']
src=R/'work/th11-stage6/boss04/stgenm/stg7enm2.png'
assert src.read_bytes()==(M/'milk/art/stg7enm2.png').read_bytes()
assert struct.unpack('>II',src.read_bytes()[16:24])==(256,256)
root=(M/'root.lua').read_text(encoding='utf-8')
assert "R.clearHazards();H.midboss=o;H.midbossPhase='nonspell'" in root
assert "R.onMidboss=function()\n R.clearHazards()"in root
l=LuaRuntime(unpack_returned_tuples=True)
for n in ['runtime.lua','root.lua']:l.execute('assert(loadstring(...))',(M/n).read_text(encoding='utf-8'))
l.execute("ran={Float=function(self,a,b)return a+(b-a)*.376123 end};births={}")
for n in ['runtime.lua','road-runtime.lua','projectiles.lua','programs.lua']:l.execute((M/n).read_text(encoding='utf-8'))
l.execute('''
local R=TH11S6Runtime
R.start();local calls=0
R.onActor=function(a)births[#births+1]={name=a.name,t=R.tick,hp=a.hp,x=a.x,y=a.y}end
R.onMidboss=function()calls=calls+1;assert(R.roadRemaining()==0)end
while R.tick<3161 do R.step(0,400,1)end
assert(R.midbossRequested==3160 and R.midbossPending and not R.bossPresent and calls==0)
local held
for _,a in ipairs(R.actors)do if not a.controller and not a.dead then held=a end end
assert(held,'gate must have live source minors');local age=held.age;local x,y=held.x,held.y;local shots=R.stats.bullets
for i=1,40 do R.step(0,400,1)end
assert(not held.dead and held.age==age+40 and (held.x~=x or held.y~=y),'gate froze/deleted source minor')
assert(R.stats.bullets>shots and R.midbossPending and calls==0,'gate froze attacks or spawned boss early')
local remaining=R.roadRemaining();assert(remaining>1)
for _,a in ipairs(R.actors)do if not a.controller and a~=held and not a.dead then a.dead=true;a.defeated=true end end
for i=1,3 do R.step(0,400,1)end
assert(calls==0 and R.roadRemaining()==1,'must wait for last minor')
held.dead=true;held.defeated=true;local endTick=R.tick
R.step(0,400,1)
assert(calls==1 and R.midbossBorn==endTick and not R.midbossPending and R.bossPresent)
for i=1,3 do R.step(0,400,1)end;assert(calls==1)
R.bossPresent=false;local resume=R.tick;R.step(0,400,1)
assert(R.resumeTick==resume and R.skipped==0,'postboss continuation regressed')
-- Empty preboss field introduces immediately at the original request tick.
R.start();R.onActor=function(a)a.dead=true;a.defeated=true end;calls=0
while R.tick<3161 do R.step(0,400,1)end
assert(R.midbossBorn==3160 and calls==1 and not R.midbossPending)
''')
rows=[{k:row[k] for k in ['name','t','hp','x','y']}for _,row in l.globals().births.items() if row['t']<=3160]
counts=Counter(row['name']for row in rows)
assert counts=={'Crow00':32,'Crow01':12,'BPhantom00':144},counts
groups=[];by_key={}
for row in rows:
 if row['name']=='BPhantom00':
  key=(row['x'],row['y'],row['hp'])
  by_key.setdefault(key,[]).append(row['t'])
for key,ticks in by_key.items():
 for i in range(0,len(ticks),12):
  batch=ticks[i:i+12];assert all(b-a==20 for a,b in zip(batch,batch[1:]))
  groups.append(dict(key=key,start=batch[0],last=batch[-1],count=len(batch)))
groups.sort(key=lambda g:g['start'])
assert len(groups)==12 and all(g['count']==12 for g in groups),groups
report=dict(status='PASS',frog_sha256=sha(src),frog_dimensions=[256,256],preboss_total=sum(counts.values()),counts=dict(counts),phantom_batches=groups)
(L/'verify.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('PASS Lua51 gate: minors remain alive/moving/firing during wait; waits for last defeat; once-only release; empty field3160; postboss immediate continuation. Exact new frog256x256. All other existing gameplay/assets byte-identical.')
print(json.dumps(dict(preboss_total=188,counts=dict(counts),phantom_batches=groups),ensure_ascii=False))
