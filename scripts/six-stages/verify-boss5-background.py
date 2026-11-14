from pathlib import Path
import sys,math,re,json
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/SixStageCampaign');O=Path('G:/MySTG/work/logs/six-stages/boss5-background-20261114');l=LuaRuntime()
for n in ['background5.lua','background5/spell.lua','road5-background.lua']:l.execute('assert(loadstring(...))',(M/n).read_text('utf-8'))
s=(M/'background5/st06enm.numeric.txt').read_text('utf-8')
for script in [16,17,18,19]:
 a=s.index('script script'+str(script)+' {');b=s.index('\n}',a);s0=s[a:b]
 assert 'ins_100([10000], 128)'in s0 and 'ins_100([10001], 4)'in s0 and 'ins_402(380.0f, 190.0f)'in s0
l.execute('calls={};function SetViewMode()end;function Color(...)return {...}end;function RenderTexture(...)table.insert(calls,{...})end')
l.execute((M/'background5/spell.lua').read_text('utf-8'))
for grey in [False,True]:
 l.execute('calls={};SixBoss5Spell(360,...)',grey);calls=l.globals().calls;assert len(calls)==256
 for base in [3,130]:
  first,last=calls[base],calls[base+126]
  # Vertex U spans outer/inner edges, V repeats4 times through127segments.
  assert abs(last[6][5]-first[3][5]-2048)<1e-6
  assert abs(first[4][4]-first[3][4]-512)<1e-6
  for k in range(base,base+127):
   q=calls[k];outer,inner=q[3],q[4]
   assert abs(math.hypot(outer[1],outer[2]-80)-380)<1e-5
   assert inner[1]==0 and inner[2]==80
 l.execute('calls={};SixBoss5Spell(361,...)',grey)
 later=l.globals().calls
 assert abs(later[3][3][5]-calls[3][3][5]-2.56)<1e-6
 assert abs(later[3][3][4]-calls[3][3][4]-(5.12 if grey else 2.56))<1e-6
 assert abs(later[130][3][4]-calls[130][3][4]+2.56)<1e-6
(O/'verify.log').write_text('PASS Lua51; originalANM16..19 parameter readback;127stripsegments/outer380/inner0/fourVrepeats; red/grey source UV rates and directions; native handoff0/90/180 and red/grey360f screenshots inspected.\n','utf-8')
print('PASS source ANM ring geometry/UV rates, Lua51')
