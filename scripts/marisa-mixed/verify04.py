from pathlib import Path
from lupa.lua51 import LuaRuntime
import json
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def read(p):return p.read_text(encoding='utf-8-sig')
l=LuaRuntime(unpack_returned_tuples=True)
for p in [M/'root.lua',M/'ssg-inspect04.lua']:l.execute('assert(loadstring(...))',read(p))
l.execute(read(M/'ssg-code.lua'));l.execute(read(M/'ssg.lua'));l.execute(read(M/'ssg-inspect04.lua'))
l.execute('''
local I,R=SSGInspect04,SSG
for _,id in ipairs(I.order)do
 local spec=I.modes[id];I.start(20261106,id)
 local patched=0
 for addr,ins in pairs(I.original)do
  if SSGCode[addr]~=ins then
   assert((spec.kind=='body'and(addr==0x17c or addr==0x1f2))or(spec.kind=='bit'and(addr==0x14f or addr==0x22f)),'changed helper instruction')
   patched=patched+1
  end
 end
 assert(patched==2,'wrong number of routing patches')
 for frame=1,1100 do R.step(319,400,10000)end
 local hits=0
 for _,set in ipairs({R.stats.branches,R.stats.bitBranches})do
  for helper,n in pairs(set)do assert(helper==spec.helper,id..' selected unrelated helper '..helper);hits=hits+n end
 end
 assert(hits>=2,id..' failed to repeat')
 if spec.kind=='body'then assert(#R.bits==0 and R.stats.shots>0)
 else assert(#R.bits==5);if id=='B5'then assert(#R.beams>=20)elseif id=='B6'then assert(#R.homing>=16)else assert(R.stats.shots>0)end end
 print('PASS '..id..' helper='..spec.helper..' calls='..hits..' shots='..R.stats.shots..' beams='..#R.beams..' homing='..#R.homing)
end
I.start(20261106,'full');assert(SSGCode==I.original and I.current==nil)
for frame=1,1100 do R.step(319,400,10000)end
assert(next(R.stats.branches)and next(R.stats.bitBranches),'full routing lost original body/bit selection')
''')
rows=json.loads(read(M/'source/ssg-inspect04.json'))['modes'];folder=R/'秋霜玉魔理沙攻击检查'
for row in rows:
 files=list(folder.glob(row['id']+'-*.cmd'));assert len(files)==1
 command=read(files[0]);assert '-Practice ssg -SSGMode '+row['id']+' -Invincible'in command
assert '3601/60,10000,'in read(M/'root.lua')
print('PASS ten isolated repeating source helpers; only two routing instructions changed per inspection mode; full original table restored;10 launcher mappings and current HP10000')
