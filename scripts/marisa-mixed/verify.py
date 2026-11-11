from pathlib import Path
from lupa.lua51 import LuaRuntime
import json,hashlib
from integrate02 import host02
from integrate03 import boss03
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed')
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.rglob('*.lua'):
 l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
print('PASS all private Lua syntax on Lua51')
l.execute((M/'ssg-code.lua').read_text());l.execute((M/'ssg.lua').read_text())
l.execute('''
local body,bit={},{}
for seed=1,12 do
 SSG.start(seed*20261106)
 for i=1,3601 do SSG.step(319,400,4000)end
 assert(SSG.done and SSG.tick==3601 and SSG.stats.shots>0)
 for k in pairs(SSG.stats.branches)do body[k]=true end
 for k in pairs(SSG.stats.bitBranches)do bit[k]=true end
end
for _,k in ipairs({0x5c4,0x60b,0x629,0x675})do assert(body[k],'missing body branch '..k)end
for _,k in ipairs({0x6e4,0x735,0x73e,0x819,0x89d,0x8b9})do assert(bit[k],'missing bit branch '..k)end
SSG.start(1);SSG.px,SSG.py=319,400;SSG.makeBits()
for i=1,5 do SSG.bits[i].dead=true end
SSG.body.pc=0x208;SSG.body.bitsInterrupt=true
SSG.step(319,400,4000);SSG.step(319,400,4000)
assert(not SSG.body.bitsInterrupt and SSG.body.pc~=0x208,'all bits destroyed interrupt failed')
''')
print('PASS four body/six bit source branches, full source first-phase timeout across12 seeds and bit-clear interrupt')
l.execute('''
SSG.start(7);SSG.px,SSG.py=319,400;SSG.makeBits();SSG.bitLaser(5)
assert(#SSG.beams==10 and SSG.laserEnabled)
for _,b in ipairs(SSG.beams)do assert(b.width==0 and b.state=='line')end
SSG.bitLaser(0);for i=1,8 do SSG.step(319,400,4000)end
for _,b in ipairs(SSG.beams)do assert(b.width==8 and b.state=='open')end
SSG.bitLaser(1);for i=1,8 do SSG.step(319,400,4000)end
for _,b in ipairs(SSG.beams)do assert(b.dead and b.width==0)end
assert(not SSG.laserEnabled)
local a=SSG.body;a.l={n=2,d=64,dw=48};SSG.hlasers(a);assert(#SSG.homing==2)
for i=1,150 do SSG.step(319,400,4000)end
assert(not SSG.homing[1].tracking and #SSG.homing[1].points==28)
''')
print('PASS star laser widths/open/close and homing source28point history/turn termination')
l.execute('''
SSG.start(7);SSG.px,SSG.py=319,400;SSG.makeBits();SSG.bits[3].dead=true
SSG.step(319,400,4000)
assert(#SSG.bits==4 and SSG.bits[2].force==-29 and SSG.bits[3].force==29)
''')
print('PASS destroyed-bit removal and opposite neighboring source formation forces')
refs=json.loads((M/'source/reuse.json').read_text(encoding='utf8'))
for dst,row in refs.items():
 src=Path(row['source'])
 if src.is_absolute():assert hashlib.sha256(src.read_bytes()).hexdigest()==row['sha256'],src
for name in ['host.lua','boss.lua']:
 original=(M.parent/'MySTG/stages/th08_stage4'/name).read_text(encoding='utf8')
 assert (M/'th08'/name).read_text(encoding='utf8')==(host02(original)if name=='host.lua'else boss03(original))
for name in ['runtime.lua','projectiles.lua','programs.lua','pool.lua']:
 assert (M/'ds'/name).read_bytes()==(M.parent/'TH125Extra'/name).read_bytes()
print('PASS all source snapshots preserved; inherited TH08 logic/current comet exact copies')
root=(M/'root.lua').read_text(encoding='utf8');assert "{'ssg','stardust','non1','milky','non3','comet','final'}"in root
assert "c.after=nil"in root and "self.dmg_factor=(not R.body.damage or shield)and 0 or 1"in root
print('PASS requested seven-phase order and source invulnerability applied after boss frame')
