from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def read(p):return p.read_text(encoding='utf-8-sig')
l=LuaRuntime()
for folder in [M/'road',M/'rabbit']:
 for p in folder.glob('*.lua'):l.execute('assert(loadstring(...))',read(p))
for p in [M/'root.lua',M/'stage14.lua']:l.execute('assert(loadstring(...))',read(p))
for name in ['pool','data','anm','runtime','projectiles','programs','route']:l.execute(read(M/'road'/f'{name}.lua'))
l.execute('''
setting={};ran={Seed=function()end};task={Wait=function(n)coroutine.yield(n)end};player={x=0,y=-150};function IsValid(o)return o and not o.dead end
MarisaRabbit14={Boss={},state={ended=0},clean=function()end}
Th18Stage5Background={Object={}}
function Th18Stage5Background.armMidboss()end;function Th18Stage5Background.beginValley()end;function Th18Stage5Background.interrupt()end
Th18Stage5Host={};local H,R=Th18Stage5Host,Th18Stage5Runtime
created={};function H.begin(seed)
 R.startRoute(seed);R.onActor=function(a)created[a.name]=(created[a.name]or 0)+1 end
end
function H.step()
 R.stepRoute(0,400)
 for _,a in ipairs(R.actors)do if not a.controller then R.cullActor(a,32,32)end end
 local s=MarisaRoad14.state
 if s.rabbit and not s.rabbit.dead then s.rabbit.left=s.rabbit.left-1;if s.rabbit.left==0 then s.rabbit.dead=true;MarisaRabbit14.state.ended=2 end end
end
function H.cleanup()end
function New(cls)
 if cls==Th18Stage5Background.Object then return{state={}}end
 assert(cls==MarisaRabbit14.Boss);return{left=600}
end
''')
stage=read(M/'stage14.lua');l.execute(stage[stage.index('MarisaRoad14={'):])
l.execute('''local c=coroutine.create(MarisaRoad14.run);local frames=0
while coroutine.status(c)~='dead'do
 local ok,n=coroutine.resume(c);assert(ok,n)
 if n then assert(n==1);frames=frames+1 end
 assert(frames<20000,'route never drains naturally')
end
local s=MarisaRoad14.state
assert(s.phase=='entry'and s.entryFrame-s.clearFrame==120 and s.wait==120)
assert(MarisaRoad14.empty())
assert(created.MBoss==nil and created.GirlD02 and created.Cir00)
assert(MarisaRabbit14.state.ended==2)
assert(s.clearFrame>=s.routeEnd and s.frame==frames)
print('MARISA14 HEADLESS COMPLETE frame='..frames..' clear='..s.clearFrame..' routeEnd='..s.routeEnd)
-- A source actor or an offscreen-but-live projectile must postpone the timer.
Th18Stage5Runtime.actors={{controller=true},{dead=false}}
assert(not MarisaRoad14.empty());Th18Stage5Runtime.actors[2].dead=true
Th18Stage5Runtime.hazards={{dead=false,x=1000,y=1000}};assert(not MarisaRoad14.empty())
Th18Stage5Runtime.hazards[1].dead=true;assert(MarisaRoad14.empty())
''')
refs=json.loads(read(M/'source/stage14-reuse.json'))['files']
for a in refs:
 assert hashlib.sha256(Path(a['source']).read_bytes()).hexdigest()==a['source_sha256'],a['source']
 assert hashlib.sha256((M/a['target']).read_bytes()).hexdigest()==a['target_sha256'],a['target']
root=read(M/'root.lua');assert "{'ssg','stardust','non1','milky','non3','comet','final'}"in root
assert "boss.init(self,-224,256"in root and 'frames/60,30000,'in root
assert (M/'rabbit/pattern.lua').read_bytes()==(R/'aex-0.8.22/game/mod/RingoSeiran/pattern.lua').read_bytes()
assert (M/'road/programs.lua').read_bytes()==(R/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5/programs.lua').read_bytes()
msg=f'PASS original full front/latter programs with actual source scheduler naturally drain, no MBoss spawned, rabbit slot completes before latter, last actors AND projectiles must be dead then exactly120 frames; same7phase order/HP30000/offscreenstart; {len(refs)}source/target hashes; privateLua51 syntax.'
(R/'work/logs/marisa-mixed/stage14/verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
