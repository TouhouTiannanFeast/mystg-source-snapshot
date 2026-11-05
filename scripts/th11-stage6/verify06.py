"""Targeted HP readback and real H crow attack emissions; no stage playthrough."""
from pathlib import Path
import json,hashlib,re
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change06'
before=json.loads((L/'before-hashes.json').read_text(encoding='utf-8'))
for n,digest in before.items():
 if n not in ['runtime.lua','README.md']:assert hashlib.sha256((M/n).read_bytes()).hexdigest()==digest,n
source=(M/'source/stage06.named.utf8.txt').read_text(encoding='utf-8-sig')
for name in ['Crow00_at','Crow01_at']:
 body=re.search(r'^void '+name+r'\([^\n]*\)\n\{\n(.*?)^\}',source,re.M|re.S)[1]
 assert '!' not in body and 'DIFF' not in body,'additional H branch needs lowering'
 assert set(re.findall(r'\b(\w*D|diffWait)\(',body))=={'etCountD','etSpeedD','diffWait'}
adapter=(R/'scripts/th11-stage6/prepare-adapter.py').read_text(encoding='utf-8')
ns={};exec(adapter.split("save('runtime.lua',s)",1)[0],ns)
def lua_code(s):return [line.split('--',1)[0].strip()for line in s.splitlines()if line.split('--',1)[0].strip()]
assert lua_code(ns['s'])==lua_code((M/'runtime.lua').read_text(encoding='utf-8')),'adapter would overwrite current runtime logic'
l=LuaRuntime(unpack_returned_tuples=True)
l.execute("ran={Float=function(self,a,b)return a+(b-a)*.376123 end}")
for n in ['runtime.lua','road-runtime.lua','projectiles.lua','programs.lua']:l.execute((M/n).read_text(encoding='utf-8'))
l.execute('''
local R=TH11S6Runtime
R.start()
for _,row in ipairs({{'BPhantom00',100,400},{'BPhantom00',50,200},{'Crow00',50,100},{'Crow01',200,400},{'Crow02',200,400},{'Crow03',50,100},{'RPhantom01',6000,12000}})do
 R.command(R.controller,{},'enmCreate',{row[1],0,128,row[2],1000,2})
 assert(R.actors[#R.actors].hp==row[3],row[1]..' HP')
end
-- Run only each actual attack coroutine at a fixed position for 100 ticks.
function attack(name,routine,count,layers,speed,speed2,interval)
 R.start();R.controller.dead=true
 local a=R.newActor('th11',0,128);a.name=name;R.spawn(a,routine,{},-1)
 local bursts={};R.onShot=function(b)
  local row=bursts[#bursts]
  if not row or row.t~=R.tick then row={t=R.tick,shots={}};bursts[#bursts+1]=row end
  row.shots[#row.shots+1]=b
 end
 for i=1,100 do R.step(0,400,1)end
 local p=a.patterns[0];assert(p.n==count and p.layers==layers and p.speed==speed and p.speed2==speed2,name..' attack parameters')
 assert(#bursts>=3,name..' attack did not repeat')
 for i,row in ipairs(bursts)do
  assert(#row.shots==count*layers,name..' density')
  if i>1 then assert(row.t-bursts[i-1].t==interval,name..' cadence')end
  for j,b in ipairs(row.shots)do
   local layer=math.floor((j-1)/count)
   local expected=layers>1 and speed-(speed-speed2)*layer/layers or speed
   assert(math.abs(b.speed-expected)<1e-9,name..' projectile speed')
  end
 end
end
attack('Crow00','Crow00_at',1,3,4,1.5,30)
attack('Crow01','Crow01_at',5,1,4,1.5,5)
attack('Crow02','Crow02_at',5,1,3,1.5,6)
-- All other actors still resolve the same difficulty-dependent opcodes as N.
for _,name in ipairs({'Crow03','BPhantom00','RPhantom01'})do
 R.start();local a=R.newActor('th11',0,128);a.name=name
 R.command(a,{},'etCountD',{0,11,12,13,14,21,22,23,24})
 R.command(a,{},'etSpeedD',{0,1,2,3,4,5,6,7,8})
 assert(a.patterns[0].n==12 and a.patterns[0].layers==22 and a.patterns[0].speed==2 and a.patterns[0].speed2==6)
 local co=coroutine.create(function()R.command(a,{},'diffWait',{10,20,30,40})end)
 local ok,delay=coroutine.resume(co);assert(ok and delay==20)
end
''')
print('PASS Lua51 actual factory HP: bluephantoms400/200,crows100/400 retained,red12000 retained. Actual attacks: Crow00 H3shots/30f (was2/60f),Hspeed4;Crow01 H5shots/5f (was5/6f),Hspeed4. Postboss Crow02 N5shots/6f speed3;all other actor difficulty N. Source has no additional H-only branch. All other existing mod files byte-identical.')
(L/'verify.json').write_text(json.dumps(dict(status='PASS',blue_hp=[400,200],crow_hp=[100,400],attacks=dict(Crow00=dict(difficulty='H',count=1,layers=3,speed=4,interval=30),Crow01=dict(difficulty='H',count=5,layers=1,speed=4,interval=5)),normal_retained=['Crow02','Crow03','BPhantom00','RPhantom01']),indent=2),encoding='utf-8')
