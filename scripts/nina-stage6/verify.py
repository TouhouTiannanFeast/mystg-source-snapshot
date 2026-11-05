from pathlib import Path
from lupa.lua51 import LuaRuntime
import json,hashlib,subprocess,sys
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal');L=Path('G:/MySTG/work/logs/nina-stage6')
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.rglob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
for n in ['runtime','projectiles','programs','encounter','encounter-nina','assets','import10/pool','import10/runtime','import10/projectiles','import10/programs','import10/specs','import10/art','import08/specs','import08/art','import08/runtime','art08-local','fix02','programs-fix03','art03','fix03','suwako03']:l.execute((M/(n+'.lua')).read_text(encoding='utf-8-sig'))
for name in ['NinaCoreArt','Nina08LocalArt']:
 for a in l.globals()[name].values():assert (M/a.path).is_file(),a.path
for a in l.globals().Nina10Art.records.values():assert(M/a.path).is_file(),a.path
for p in ['source/reference.json','import10/source/reference.json']:
 ref=json.loads((M/p).read_text(encoding='utf-8'))
 for a in (ref.get('sources',ref)).values():
  if isinstance(a,dict)and 'source'in a and 'sha256'in a and Path(a['source']).is_file():assert hashlib.sha256(Path(a['source']).read_bytes()).hexdigest()==a['sha256']
report={}
for rname,sname in [('NinaCoreRuntime','NinaCoreSpecs'),('Nina10Runtime','Nina10Specs'),('Nina08Runtime','Nina08Specs')]:
 r=l.globals()[rname];ss=l.globals()[sname]
 for s in ss.values():
  r.onActor=l.eval('function(a)end');r.onShot=l.eval('function(b)end');r.start(s,123)
  count=0;times=[]
  def shot(b):
   
   group='th13' if b.group=='th13L' else str(b.group)
   art=l.globals().NinaCoreArt[group+':'+str(b.typ)+':'+str(b.color)] if rname=='NinaCoreRuntime' else l.globals().Nina10Art.lookup(b.typ,b.color,b.group) if rname=='Nina10Runtime' else l.globals().Nina08Art.lookup(b.typ,b.color)
   assert b.laser or art is not None,(s.id,b.typ,b.color)
   tick=r.tick;times.append(tick[-1] if isinstance(tick,tuple) else tick)
  r.onShot=shot
  frames=min(int(s.frames),2800 if s.id=='final'else 1700)
  for t in range(frames):
   r.step(0,400,s.hp)
   if not r.stepsHazards:r.stepHazards()
  assert times,s.id
  report[s.id]={'frames':frames,'shots':len(times),'first_shot':times[0]}
  r.clearHazards(False)
  if rname!='Nina08Runtime':r.stepHazards()
  assert len(r.hazards)==0,s.id
# Source-dependent final startup checkpoints: seven persistent emitters, delayed rings, invuln expiry.
r=l.globals().Nina08Runtime;s=l.globals().Nina08Specs.final;r.onShot=l.eval('function(b)end');r.start(s,123)
for _ in range(110):r.step(0,400,s.hp)
assert len(r.actors)==0
r.step(0,400,s.hp);assert len(r.actors)==7
for _ in range(2490-111):r.step(0,400,s.hp)
assert r.invuln==0
print(json.dumps(report,ensure_ascii=False,indent=2));print('PASS Lua51 syntax/source hashes/local art/ten schedules/cleanup/final delayed actors+invulnerability; fidelity caveats in README')
(L/'verify-summary.json').write_text(json.dumps(report,indent=2),encoding='utf-8')

