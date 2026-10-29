from pathlib import Path
import sys,re,json,hashlib,math
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
h=(m/'source/th07-EclManager.hpp').read_text()
c=(m/'source/th07-EclManager.cpp').read_text()
assert re.search(r'ECL_RUN_EX_INS\s*=\s*121',h)
assert re.search(r'ECL_SPAWN_ITEM\s*=\s*124',h)
assert 'case ECL_SPAWN_ITEM:\n                g_ItemManager.SpawnItem' in c
src=(m/'source/th07-selected.ecl.txt').read_text('utf-8')
for n in (70,71):
 sub=re.search(r'sub Sub'+str(n)+r'\(\).*?\n}',src,re.S)[0]
 assert 'ins_124([10000])' in sub and not re.search(r'ins_12[12]\(',sub)
print('PASS source: opcode124=SPAWN_ITEM; EX one-shot=121; Sub70/71 have no EX call')
l=LuaRuntime(unpack_returned_tuples=True)
for p in m.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
for n in ['runtime.lua','th07.lua','le04.lua']:l.execute((m/n).read_text('utf-8-sig'))
l.execute('''
Y3.start('spell3',20261029,192,112)
local previous={};local checked=0;local maxdelta=0
for t=0,Y3.specs.spell3.time*60-1 do
 Y3.step(192,400)
 if t==180 then assert(Y3.counts.shots==60 and Y3.counts.lasers==6)end
 if t==230 then assert(Y3.counts.shots==300)end
 for _,b in ipairs(Y3.shots)do
  assert(b.typ==8 and b.state2==0,'Unexpected external transformation')
  local p=previous[b]
  if p then
   local d=math.abs(math.atan2(math.sin(b.angle-p.angle),math.cos(b.angle-p.angle)))
   maxdelta=math.max(maxdelta,d)
   assert(d<0.011,'Sudden turn at '..t..': '..d)
   assert(math.abs(b.speed-p.speed)<0.061,'Sudden speed reset')
   checked=checked+1
  end
  previous[b]={angle=b.angle,speed=b.speed}
 end
end
assert(checked>100000)
print('PASS final ticks='..Y3.tick..' bullets='..Y3.counts.shots..' lasers='..Y3.counts.lasers..' checked_steps='..checked..' max_turn='..maxdelta)
''')
before=json.loads(Path('G:/MySTG/work/logs/yuyuko3/final05-before.json').read_text())
for n,digest in before.items():assert hashlib.sha256((m/n).read_bytes()).hexdigest()==digest,n+' changed'
print('PASS Lua syntax; HP/time/hold, other stages, host, shooter unchanged (SHA256)')
