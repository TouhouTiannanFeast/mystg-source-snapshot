from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG');C=ROOT/'aex-0.8.22/game/mod/MySTG/stages/suwako5';LOG=ROOT/'work/logs/suwako5'
lua=LuaRuntime(unpack_returned_tuples=True)
for f in C.glob('*.lua'):lua.execute('assert(loadstring(...))',f.read_text(encoding='utf-8-sig'))
for f in ['pool.lua','runtime.lua','projectiles.lua','programs.lua','art.lua']:lua.execute((C/f).read_text(encoding='utf-8'))
audit=json.loads((C/'source-audit.json').read_text(encoding='utf-8'))
for row in audit['sources'].values():assert hashlib.sha256(Path(row['path']).read_bytes()).hexdigest()==row['sha256']
lua.execute('''
 local P=Suwako5Pool
 assert(#P.spells==15 and #P.nonspells==7)
 for seed=1,10000 do
  local a,b=P.draw(seed,4),P.draw(seed,4);local seen={};local last=0
  assert(#a==8)
  for i,v in ipairs(a) do
   assert(v.id==b[i].id and not seen[v.id]);seen[v.id]=true
   assert(v.id~='th10-card7' and v.id~='th10-non7')
   if i%2==1 then assert(v.sourceIndex>last);last=v.sourceIndex else assert(v.name~='') end
  end
 end
''')
P=lua.globals().Suwako5Pool;R=lua.globals().Suwako5Runtime
lua.execute('''
 local R,P=Suwako5Runtime,Suwako5Pool
 -- TH10 source Boss1_at: 28 spokes * 4 speed layers, 30-frame separation.
 local ticks={};local speeds={}
 R.onShot=function(b) ticks[R.tick]=(ticks[R.tick] or 0)+1;if R.tick==81 then speeds[#speeds+1]=b.speed end end
 R.start(P.find('th10-non1'),42)
 for t=0,199 do R.step(0,400,8000) end
 for _,t in ipairs({81,111,141,171}) do assert(ticks[t]==112,'source non1 volley schedule') end
 assert(speeds[1]==3.5 and speeds[29]==3 and speeds[57]==2.5 and speeds[85]==2)
 -- ECL opcode83 subtracts script time; wait10 then a timed +20 event => tick30.
 local stamp
 Suwako5Programs.test={wait={params={},ops={
  {t=0,run=function(a,e)R.command(a,e,'wait',{10})end},
  {t=20,run=function()stamp=R.tick;return 0 end}}}}
 local a=R.newActor('test',0,0);R.actors={a};R.tick=0;R.spawn(a,'wait',{},-2)
 for t=0,31 do R.step(0,400,100) end;assert(stamp==30,'ECL wait/timeline semantics')
 R.onShot=nil
 -- Birth retreat + half-speed frames + half/full activation fallthrough.
 R.start(P.find('th10-non1'),42);R.fire(R.boss,{typ=3,color=0,n=1,layers=1,aim=1,angle=0,step=0,speed=2,speed2=2,ex={
  [0]={async=1,kind=2,i=0,j=0,r=0,s=0},
  [1]={async=0,kind=16,i=2,j=0,r=0.5,s=math.pi/2}}})
 local b=R.hazards[1];local x,y=b.x,b.y
 for i=1,8 do R.projectileStep(b) end
 assert(math.abs(b.x-x)<1e-8 and b.y==y,'TH10 birth movement')
 R.projectileStep(b);assert(math.abs(b.x-x-3)<1e-8 and math.abs(b.y-y-0.5)<1e-8,'TH10 activation/vector integration')
 -- Relative sine movement is a second motion channel, never an accumulated drift.
 local a=R.newActor('th10',10,100);a.angle=-math.pi/2;a.speed=2
 local e={clock=0}
 R.command(a,e,'movePosRelTime',{1,0,3,0});R.motion(a)
 R.command(a,e,'movePosRelTime',{1,0,4,0});R.motion(a)
 assert(a.x==14 and a.y==96,'independent relative-motion channel')
 -- Interpolation mode7 is additive, used by the red-frog emitters.
 R.command(a,e,'moveSpeedTime',{100,7,0.01});R.motion(a)
 assert(math.abs(a.speed-2.01)<1e-8,'mode7 additive interpolation')
 assert(R.integer(3+1/5)==3 and R.integer(-3.8)==-3,'ECL integer truncation')
 for k=0,5 do
  assert(P.photoIndex(k*120)==k,'DS time stage threshold')
 end
 assert(P.photoIndex(600)==5 and P.photoIndex(1800)==5 and P.photoIndex(-1)==0)
''')
rows=[]
for pool in [P.nonspells,P.spells]:
 for i in range(1,len(pool)+1):
  spec=pool[i];print('TRACE',spec.id,flush=True);R.start(spec,100+i)
  for t in range(min(1500,spec.frames)):
   R.step(32,400,spec.hp);R.stepHazards()
  assert R.stats.bullets+R.stats.lasers>0,spec.id
  rows.append({'id':spec.id,'ticks':R.tick,'bullets':R.stats.bullets,'lasers':R.stats.lasers,'alive':len(R.hazards)})
  R.clearHazards(False);R.stepHazards();assert len(R.hazards)==0
for i in range(10,14):
 spec=P.spells[i];R.start(spec,900+i)
 for t in range(1800):
  stage=min(5,t//300)
  R.step(32,400,spec.hp*(1-stage/6));R.stepHazards()
 assert R.photos==(2 if spec.group=='dsd' else 5)
 print('DS TIME PROGRESSION PASS',spec.id,'bullets',R.stats.bullets,'lasers',R.stats.lasers,flush=True)
 R.clearHazards(False);R.stepHazards();assert len(R.hazards)==0
(LOG/'traces.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS: source hashes; Lua5.1 syntax; 10000 reproducible draws, exclusions and nonspell order; source volley/speed/wait/birth/vector/relative-motion/mode7 assertions; 22 bounded firing traces and cleanup.')
