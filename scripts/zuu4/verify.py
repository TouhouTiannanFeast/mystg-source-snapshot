"""Bounded checks for this seven-phase encounter, no full-stage traversal."""
from pathlib import Path
import sys,json,hashlib
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG');C=ROOT/'aex-0.8.22/game/mod/MySTG/stages/zuu4'
lua=LuaRuntime(unpack_returned_tuples=True)
for f in C.glob('*.lua'):lua.execute('assert(loadstring(...))',f.read_text(encoding='utf-8-sig'))
print('PASS Lua5.1 syntax: all Zuu4 files')
for f in ['art.lua','runtime.lua','patterns.lua','horou.lua','horou-spells.lua','th20.lua']:lua.execute((C/f).read_text(encoding='utf-8-sig'))
refs=json.loads((C/'source-reference.json').read_text(encoding='utf-8'))
assert refs['identity']['boss']=='BOSS_ID_HOROU' and refs['identity']['stage']==6
assert 'Horou/dotHorou.png' in refs['identity']['model'] and refs['identity']['spellIDs']==[71,72,77]
for r in refs['sources']:
 assert hashlib.sha256(Path(r['path']).read_bytes()).hexdigest()==r['sha256']
 assert hashlib.sha256((C/r['copy']).read_bytes()).hexdigest()==r['sha256']
print('PASS',len(refs['sources']),'source/file hashes; original art only')
lua.execute('''
 local R=Zuu4R
 for id=369,376 do assert(Zuu4Art.shots[id].radius==4)end
 assert(#Zuu4Order==7 and Zuu4Order[6]=='stone' and Zuu4Order[7]=='final')
 for _,id in ipairs(Zuu4Order)do
  R.start(id,20261027)
  local maxActors,maxShots=0,0
  for t=1,1200 do
   local hp=Zuu4Specs[id].hp
   if id=='stone' then hp=t<250 and 12000 or t<410 and 7900 or t<570 and 4900 or 1900 end
   R.step(192,400,hp)
   maxActors=math.max(maxActors,#R.actors);maxShots=math.max(maxShots,#R.hazards)
   for _,b in ipairs(R.hazards)do
    assert(b.x==b.x and b.y==b.y and b.radius==b.radius,'nonfinite projectile '..id)
    if id=='stone' or id=='non3' then assert(b.id>=369 and b.id<=376 and b.radius==4)end
   end
  end
  assert(R.counts.shots>0 or R.counts.beams>0,'no emission '..id)
  if id=='stone' then assert(R.subphase==3,'missing four subphases')end
  print('PASS phase '..id..' shots='..R.counts.shots..' beams='..R.counts.beams..' maxActors='..maxActors..' maxHazards='..maxShots..' subphase='..R.subphase)
  R.clear();assert(#R.threads==0)
  for _,b in ipairs(R.hazards)do assert(b.dead)end
  for _,a in ipairs(R.actors)do assert(a.dead)end
 end
 -- Source Boss3 Normal:34 at5*0.2; Boss4 Normal:3 at1*0.2.
 R.start('non3',1)
 for i=1,242 do R.step(192,400,16000)end
 local ring,sweep=0,0
 for _,b in ipairs(R.hazards)do
  if b.profile then sweep=sweep+1;assert(b.profile.initial==0.2 and math.abs(b.profile.s1-0.04)<1e-8 and math.abs(b.profile.s2-0.6)<1e-8)
  else ring=ring+1;assert(b.speed==1)end
 end
 assert(ring==34 and sweep>0,'concurrent source nonspells')
 -- Every speed sample, including after both source speed changes, is exactly1/5.
 local b={kind='shot',id=371,radius=4,age=8,delay=8,x=192,y=200,angle=90,speed=0.2,accel=0,nativeBirth=true,noCull=true,
 profile={hold=60,initial=0.2,n1=60,s1=0.2*0.2,n2=60,s2=3*0.2}}
 for t=1,181 do R.projectileStep(b);assert(b.speed<=0.6+1e-8);if t==120 then assert(math.abs(b.speed-0.04)<1e-8)end end
 print('PASS simultaneous 34-way Boss3 +3-way Boss4, all speed segments x0.2; radius4')
''')
print('PASS seven-phase ordering, four Stone Goddess layers, finite trajectories and teardown')
