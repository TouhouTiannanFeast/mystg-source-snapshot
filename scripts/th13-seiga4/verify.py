"""One Lua51 backend: source schedules, shared transforms, paired actor lifecycle."""
from pathlib import Path
import json,hashlib,math
from collections import Counter
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH13Seiga4';L=R/'work/logs/th13-seiga4'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ref=json.loads((M/'source/reference.json').read_text(encoding='utf-8'))
assert sha(Path(ref['source']))==ref['source_sha256']
assert (M/'source/st04bs.named.utf8.txt').read_bytes()==Path(ref['source']).read_bytes()
assert sha(Path(ref['exe']))==ref['exe_sha256']
assert sha(Path(ref['archive']))==ref['archive_sha256']
for a in ref['assets']:
 assert sha(M/a['target'])==a['sha256']
 if 'rect'not in a:assert sha(Path(a['source']))==a['sha256']
 else:assert sha(Path(a['source']))==a['source_sha256']
for a in ref['player']:assert sha(M/a['target'])==a['sha256']
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
for n in ['pool','runtime','projectiles','programs','encounter','assets']:l.execute((M/(n+'.lua')).read_text(encoding='utf-8'))
l.execute('''R=SeigaRuntime;local fire=R.fire
R.fire=function(a,p)R.fireActor=a.name;fire(a,p)end
R.onActor=function(a)end
R.onShot=function(b)assert(b.laser or SeigaArt[b.typ..':'..b.color],'missing source emission art');shots[#shots+1]={t=R.tick,actor=R.fireActor,typ=b.typ,col=b.color,speed=b.speed,angle=b.angle,curve=b.laser~=nil};b.emitter=R.fireActor end
''')
report={}
for i,id in enumerate(['non1','spell1','non2','spell2'],1):
 l.execute('shots={};R.start(SeigaPool.specs[...],123)',i)
 track=[]
 for t in range(1100):
  l.execute('R.step(0,400,R.spec.hp);R.stepHazards()')
  if t in [59,60,209,210,239,240,399,400]:
   a=l.globals().R.yoshika;track.append([t,a.x,a.y,a.hp])
 shots=list(l.globals().shots.values());seiga=[s for s in shots if s['actor']=='Seiga'];yoshika=[s for s in shots if s['actor']=='Yoshika']
 assert seiga and yoshika
 assert all(s['typ']==20 and s['col']==3 for s in seiga)if id.startswith('non')else True
 if id.startswith('non'):
  first=seiga[0]['t'];volley=[s for s in seiga if s['t']==first]
  assert len(volley)==(5 if id=='non1'else 9)
  assert abs(volley[0]['speed']-1)<1e-8
  times=sorted(set(s['t']for s in seiga));assert times[1]-times[0]==10
  assert all(s['typ']==9 and s['col']==6 and abs(s['speed']-.3)<1e-8 for s in yoshika)
 elif id=='spell1':
  assert all(s['typ']==18 and s['col']==5 and abs(s['speed']-2.4)<1e-8 for s in seiga)
  assert sorted(set(s['t']for s in seiga))[:3]==[211,271,331]
  assert all(s['typ']==9 and s['col']==13 for s in yoshika)
 else:
  curves=[s for s in yoshika if s['curve']];assert len(curves)==80
  ct=Counter(s['t']for s in curves);assert sorted(ct.values())==[8]*10
  times=sorted(ct);assert all(times[j+1]-times[j]==20 for j in range(0,len(times),2))
  assert all(s['typ']==21 and s['col']==3 and abs(s['speed']-3)<1e-8 for s in seiga)
  for b in l.globals().R.hazards.values():
   if b.laser:assert len(b.points)<=40 and b.laser.width==16
 report[id]=dict(shots=len(shots),first_seiga=seiga[0]['t'],first_yoshika=yoshika[0]['t'],curves=sum(s['curve']for s in shots),positions=track)
 # Knock out Yoshika only; spells must revive her through the original GI1 handshake.
 l.execute('R.yoshika.hp=0')
 down=False;revived=False;charge=False
 for t in range(650):
  l.execute('R.step(0,400,R.spec.hp);R.stepHazards()')
  a=l.globals().R.yoshika
  if a.down:down=True
  elif down:revived=True
  if any(s['typ']==10 for s in l.globals().shots.values()):charge=True
 assert down
 assert revived if id.startswith('spell')else not revived
 if id=='spell1':assert charge,'paired revive-stream attack missing'
 report[id].update(down=down,revived=revived,revive_streams=charge)
 l.execute('R.clearHazards(false);for _,a in ipairs(R.actors)do a.dead=true end;R.stepHazards();assert(#R.hazards==0)')
# Shared modern step and curved motion are tested with their exact source coefficients.
l.execute('''shots={};R.start(SeigaPool.specs[4],123)
local a=R.yoshika;a.threads={};a.patterns[0].ex={};a.patterns[0].laser=nil
local p={typ=0,color=8,n=1,layers=1,aim=1,angle=0,speed=.1,speed2=.1,ex={[0]={async=1,kind=8,i=180,r=.027777778,s=.013962634}},laser={curved=true,width=16,length=0,history=40}}
R.fire(a,p);curve=R.hazards[1]
for i=1,100 do R.projectileStep(curve)end
assert(math.abs(curve.speed-(.1+100*.027777778))<1e-6)
assert(math.abs(curve.angle-100*.013962634)<1e-6)
assert(#curve.points==40)
''')
print(json.dumps(report,ensure_ascii=False,indent=2))
(L/'verify-summary.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS source/assets/player hashes; Lua51 syntax; 4 schedules; Yoshika down/revival; paired curves/history/acceleration; cleanup')
