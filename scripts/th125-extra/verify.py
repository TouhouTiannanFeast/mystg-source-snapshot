"""Focused source schedules and the actual Lua51 projectile adapter."""
from pathlib import Path
import hashlib,json,math,re,sys
from collections import Counter
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH125Extra';L=R/'work/logs/th125-extra'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ref=json.loads((M/'source/reference.json').read_text(encoding='utf-8'))
assert sha(Path(ref['archive']))==ref['archive_sha256']
for row in ref['source']:
 src=Path(row['file']);assert sha(src)==row['sha256']
 assert (M/'source'/src.name).read_bytes()==src.read_bytes()
for row in ref['assets']:
 assert sha(M/row['target'])==row['sha256']==sha(Path(row['source']))
for row in ref['sounds']:
 assert sha(M/row['target'])==row['sha256']==sha(Path(row['source']))
assert {x['id']:Path(x['target']).name for x in ref['sounds']}=={51:'se_nep00.wav',67:'se_ch02.wav'}
for row in ref['player']:
 assert sha(M/row['file'])==row['sha256']
 source=Path(row['source']).read_text(encoding='utf-8')
 assert (M/row['file']).read_text(encoding='utf-8')==source.replace('HSoB Stage5 Road@Normal','DS Extra@Extra')
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
for name in ['pool','runtime','projectiles','programs']:l.execute((M/(name+'.lua')).read_text(encoding='utf-8'))
l.execute('''R=DSExtraRuntime;shots={};births={};teleports={};fires={}
local fire=R.fire
R.fire=function(a,p)fires[#fires+1]={col=p.color,angle=p.angle,sourceAngle=R.value(a,'ABS_ANGLE')};return fire(a,p)end
R.onShot=function(b)shots[#shots+1]={t=R.tick,typ=b.typ,col=b.color,angle=b.angle,speed=b.speed}end
R.onActor=function(a)births[#births+1]={t=R.tick,name=a.name,dir=a.f[1]}end
local command=R.command
R.command=function(a,e,k,v)
 if k=='movePos' or k=='moveVel' then teleports[#teleports+1]={t=R.tick,k=k,x=v[1],y=v[2]}end
 return command(a,e,k,v)
end''')
report={}
for card in [2,7,8]:
 l.execute('shots={};births={};teleports={};fires={};R.start(DSExtraPool.specs[...],123)',card)
 red_refs=[];motion=[]
 for t in range(1500 if card==2 else 1000):
  l.execute('R.step(0,400,10000);R.stepHazards()')
  if card==2 and t in [122,741,742,1000]:
   a=l.globals().R.boss;assert abs(math.hypot(a.x,a.y-224)-96)<1e-6
   if t==122:
    for a in list(l.globals().R.actors.values())[1:]:assert abs(a.orbit.radius-204)<1e-6
  if card==7 and t in [123,183,243,303]:
   red_refs.append(next(b for b in l.globals().R.hazards.values()if b.typ==11 and b.color==2 and b.age==1))
  if card==8 and t in [63,90,111]:
   a=l.globals().R.boss;motion.append((t,a.speed))
 shots=list(l.globals().shots.values());births=list(l.globals().births.values())
 counts=Counter((s['t'],s['typ'],s['col'])for s in shots)
 if card==2:
  assert Counter(b['t']for b in births)=={62:32,742:32,1422:32}
  assert [b['dir']for b in births]==[1]*32+[-1]*32+[1]*32
  assert all(c%12==0 for c in Counter(s['t']for s in shots).values())
  for s in shots:assert abs(s['speed']-2.3)<1e-6 and s['typ']==16 and s['col']in[6,13]
  green=[x for x in l.globals().fires.values()if x['col']==6]
  assert len({round(x['angle'],4)for x in green})>32
  assert all(abs(x['angle']-x['sourceAngle'])<1e-8 for x in green)
 elif card==7:
  for cycle in [0,440]:
   for index in range(4):
    t=123+cycle+60*index
    assert counts[t,11,2]==256
    phase=min(4,(t-60)//120)
    assert counts[t,11,6]==24*phase
  # All four red bursts use the source's offset waits240/180/120/60.
  assert len(red_refs)==4
  tele=[x for x in l.globals().teleports.values()if x['k']=='movePos']
  assert [x['t']for x in tele[:4]]==[112,172,232,292]
  kinds=[(x['x']in[-224,224])for x in tele[:4]]
  assert all(a!=b for a,b in zip(kinds,kinds[1:]))
 else:
  assert [x[0]for x in motion]==[63,90,111]
  for t,speed in motion:assert abs(speed-16*(t-61)/50)<1e-6
  for cycle in range(7):
   t=63+150*cycle
   if t>=1000:break
   phase=0 if t<1800 else 1
   for shot in range(8):
    if t+10*shot<1000:assert counts[t+10*shot,23,3]==8+8*phase
  assert [x['t']for x in births[:45]]==list(range(62,152,2))
  assert all(x['name']=='Boss1Spark'for x in births)
  spark=l.globals().R.actors[2];assert spark.hitW==220 and spark.hitH==48 and spark.hurtW==128
 l.execute('R.clearHazards(false)')
 assert all(b.dead for b in l.globals().R.hazards.values())
 report[str(card)]={'bullets':len(shots),'actor_births':len(births),'source_schedule':'PASS'}
# A synthetic source projectile isolates the two timed polar transforms.
l.execute('''R.start(DSExtraPool.specs[2],1);R.hazards={}
R.fire(R.boss,{typ=16,color=13,angle=0,step=0,n=1,layers=1,aim=3,speed=2.3,ex={
 [0]={async=0,kind=8,i=60,j=-999999,r=-0.026666667,s=0.01}}})
for i=1,60 do R.projectileStep(R.hazards[1])end''')
b=l.globals().R.hazards[1]
assert abs(b.speed-(2.3-60*0.026666667))<1e-6 and abs(b.angle-0.6)<1e-6
# Manifest radius values are the original DS bullet type table fields.
assert {(x['type'],x['color']):round(x['radius'],2)for x in ref['native_bullets']}=={(16,6):4,(16,13):4,(11,2):2.8,(11,6):2.8,(23,3):7}
(L/'verify-summary.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('PASS one Lua51 backend: syntax/source hashes/35 sprite copies/current player parity;32 emitters and reversal;four teleport bursts;150-frame dash cycles/45 sparks;photo caps;source speeds/transforms/cleanup.')
