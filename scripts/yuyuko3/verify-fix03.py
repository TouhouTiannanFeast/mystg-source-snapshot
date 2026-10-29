from pathlib import Path
import sys,re,hashlib
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
l=LuaRuntime(unpack_returned_tuples=True)
for p in m.glob('*.lua'): l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
for n in ['runtime.lua','th07.lua','le04.lua']: l.execute((m/n).read_text('utf-8-sig'))
l.execute('''
Y3.start('non2',42,192,112)
local b={state=1,age=0,alpha=20,angle=0,parity=0,x=1000,y=1000}
Y3.soulUpdate(b);assert(b.alpha==255 and b.angle>0)
b.age=101;local a=b.angle;Y3.soulUpdate(b);assert(b.alpha==255 and b.angle==a)
Y3.start('spell2',42,192,112)
local circles,scales=0,0;local emitted={}
Y3.onShot=function(b) emitted[#emitted+1]=b end
local function check(b)
 if b.nativeType==3 then assert(b.revealFrames==20);circles=circles+1 end
 if b.nativeType==12 then assert(not b.revealFrames);scales=scales+1 end
end
for i=0,150 do Y3.step(192,400)end
for _,b in ipairs(emitted)do check(b)end;assert(circles==180 and scales==20)
Y3.onShot=nil
Y3.start('spell3',42,192,112)
local deflected=false
for i=0,700 do
 Y3.step(192,400)
 for _,b in ipairs(Y3.shots)do
  assert(b.typ==8,'Unexpected needle in final')
  if b.state2==-1 then deflected=true end
 end
end
assert(deflected,'Deflection not exercised')
''')
print('PASS non2 opaque/early curve; spell2 180 circle reveals + 20 scales; spell3 deflection retains butterfly')
s=(m/'root.lua').read_text('utf-8-sig')
f=re.search(r'function Damage:take_damage\(dmg\).*?\nend',s,re.S)[0]
l.execute('Damage={};S={current="spell1",damage=0};R=Y3;boss={take_damage=function(o,d)o.hp=o.hp-d end}')
l.execute(f)
l.execute('''
local o={hp=5000};Y3.tick=121;Damage.take_damage(o,1170);assert(o.hp==3830)
o.hp=5000;Y3.tick=0;Damage.take_damage(o,900);assert(o.hp==4900)
''')
assert "b.nativeType==12 then self.img='y3.scale.'" in s
assert 'b.age>=b.revealFrames' in s and 'b.age/b.revealFrames' in s
for i in range(16):
 assert (m/f'art/scale-{i}.png').read_bytes()==(m.parent/f'Stage12Normal/art/unified/arrow-{i+1}.png').read_bytes()
print('PASS spell1 full damage after hold, /9 during hold; scale art all 16 colors; reveal alpha/collision gating; Lua syntax')

