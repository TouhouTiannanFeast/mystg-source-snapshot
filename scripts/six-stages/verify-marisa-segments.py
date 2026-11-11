from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG'); M=R/'aex-0.8.22/game/mod/MarisaMixed'; C=M.parent/'SixStageCampaign'
l=LuaRuntime()
l.execute('''setting={}; SixStageCampaign={}; function LoadTexture()end;function LoadImage()end;function LoadSound()end;function PlaySound()end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end
GROUP_ENEMY_BULLET=1; GROUP_INDES=2; lstg={var={score=0}}; boss={}; S={phase='ssg'}; MarisaMixed=S
MarisaVisual={owned={}};function IsValid(o)return not o.removed end
function Kill(o)o.removed=true;o.killed=true end;function Del(o)o.removed=true end
''')
for name in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua','ssg-selected05.lua']:
 l.execute((M/name).read_text(encoding='utf8'),name='@'+str(M/name).replace('\\','/'))
def fn(s,name):
 a=s.index('function '+name);return s[a:s.index('\nend',a)+4]
host=(R/'aex-0.8.22/game/packages/thlib-scripts/THlib/enemy/boss.lua').read_text(encoding='utf8')
root=(M/'root.lua').read_text(encoding='utf8')
l.execute(fn(host,'boss:take_damage'))
l.execute('MarisaBase={};R=SSG')
l.execute(fn(root,'MarisaBase:take_damage'),name='@mod/MarisaMixed/root.lua')
l.execute('''boss.card={New=function(name,t1,t2,t3,hp)return{hp=hp}end}
B={base=MarisaBase};function B.init(o)o.card=boss.card.New('',0,0,63,30000)end
''',name='@mod/MarisaMixed/root.lua')
l.execute((C/'marisa-segments.lua').read_text(encoding='utf8'))
l.execute('SixStageCampaign.installMarisaSegments({B})')
l.execute('''
function reset()
 S.phase='ssg'; S.boss={hp=24000,mmEntryMove=false,dmg_factor=1,DMG_factor=1,spell_damage=0}
 SSGSelected05.start(20261106,'full');return S.boss
end
function runTo(n)
 while SSGSelected05.clock<n do SSGSelected05.step(319,400,S.boss.hp)end
end
local o={};B.init(o);assert(o.card.hp==24000)
local o=reset();o.mmEntryMove=true;MarisaBase.take_damage(o,1000000);assert(o.hp==24000)
o.mmEntryMove=false;MarisaBase.take_damage(o,1000000);assert(o.hp==24000)
runTo(400);assert(not SSGSelected05.entryProtected)
local bitCount=#SSG.bits
local b={dead=false};local beam={dead=false};local h={dead=false}
SSG.bullets[#SSG.bullets+1]=b;SSG.beams[#SSG.beams+1]=beam;SSG.homing[#SSG.homing+1]=h
local shotHost={data=b,group=1,colli=true};local beamHost={data=beam,group=2,colli=true}
MarisaVisual.owned={[shotHost]=true,[beamHost]=true}
MarisaBase.take_damage(o,8002);assert(o.hp==16000 and SSGSelected05.stage=='B1' and SSGSelected05.clock==400)
assert(b.dead and beam.dead and h.dead and shotHost.killed and beamHost.removed and not shotHost.colli)
assert(#SSG.bits==(bitCount>0 and bitCount or 5));SSG.bullets={};SSG.beams={};SSG.homing={}
runTo(1261);assert(SSGSelected05.stage=='B1' and #SSGSelected05.stats.stages==2)
MarisaBase.take_damage(o,102);assert(o.hp==15900)
runTo(2580);assert(SSGSelected05.stage=='B1')
runTo(2581);assert(SSGSelected05.stage=='B3' and o.hp==8000)
assert(SSGSelected05.stats.stages[3].at==2581 and SSGSelected05.stageAge==1)
runTo(3780);assert(SSG.done)
print('PASS early first depletion, immediate projectile/host clear, no rewind, fixed B3 deadline and timeout')
o=reset();runTo(1260);assert(o.hp==24000 and SSGSelected05.stage=='A2')
runTo(1261);assert(o.hp==16000 and SSGSelected05.stage=='B1')
runTo(1350);MarisaBase.take_damage(o,1000000);assert(o.hp==8000 and SSGSelected05.stage=='B3')
runTo(2581);assert(o.hp==8000 and #SSGSelected05.stats.stages==3)
MarisaBase.take_damage(o,1000000);assert(o.hp<=0)
print('PASS scheduled first switch, early second overkill discarded, third kill, original damage path')
o=reset();runTo(400);MarisaBase.take_damage(o,1000000);assert(o.hp==16000)
MarisaBase.take_damage(o,1000000);assert(o.hp==8000 and SSGSelected05.stage=='B3')
runTo(1261);assert(SSGSelected05.stage=='B3' and #SSGSelected05.stats.stages==3)
print('PASS consecutive early switches remain monotonic through old deadlines')
''')
for name in ['adapters.lua','marisa-segments.lua']:
 l.execute('assert(loadstring(...))',(C/name).read_text(encoding='utf8'))
print('PASS Lua51 syntax; 24000 card factory; entry protection preserved')


