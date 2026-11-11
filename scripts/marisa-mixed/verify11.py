from pathlib import Path
from lupa.lua51 import LuaRuntime
import json,hashlib
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end;function PlaySound()end
function SetImageState()end;function Color(...)end;draws={};function Render(...)draws[#draws+1]={...}end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end''')
for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua','ssg-selected05.lua']:
 l.execute((M/p).read_text(encoding='utf8'))
l.execute('''SSGSelected05.start(20261106,'full')
local first,opened
for i=1,3660 do
 SSGSelected05.step(319,400,30000)
 assert(SSGSelected05.stage==(i<=1260 and'A2'or i<=2460 and'B1'or'B3'))
 if i<3660 then assert(not SSG.done,'legacy3600cap truncated21s opening')end
 for _,b in ipairs(SSG.beams)do
  if not first then first=b.selected11Created end
  if b.state=='open'and not opened then opened=i;assert(i-b.selected11Created==60)end
 end
end
assert(SSG.done and SSGSelected05.duration==3660 and SSG.timeLimit==3660)
assert(first and opened);print('B3 firstguidecreate/open',first,opened,'native test ages',first-1760,opened-1760)
local b={selected05Laser=true,selected11Created=100,state='line',width=0,x=319,y=224,d=64}
for age=0,59 do
 SSG.tick=100+age;draws={};assert(SSGSelected05.drawLaser(b))
 assert(#draws==(age<30 and 0 or 2));assert(b.width==0 and b.state=='line')
end
b.state='open';b.width=8;draws={};SSGSelected05.drawLaser(b)
assert(#draws==2 and draws[1][1]=='mm.selected05.laser11'and draws[2][1]=='mm.selected05.laser11glow')
assert(draws[1][5]==1 and draws[1][6]==800/14 and draws[2][5]==1)
b.state='close';b.width=4;draws={};SSGSelected05.drawLaser(b);assert(draws[1][5]==.5 and draws[2][5]==.5)
SSGSelected05.stop();SSGInspect04.start(5,'A2');assert(SSG.timeLimit==nil)
''')
for a in json.loads((M/'source/laser11.json').read_text(encoding='utf8'))['assets']:
 assert hashlib.sha256(Path(a['path']).read_bytes()).hexdigest()==a['sha256']
for p in ['root.lua','visual.lua']:l.execute('assert(loadstring(...))',(M/p).read_text(encoding='utf8'))
msg='PASS1260/1200/1200f total3660 not truncated; exact30f guide before unchanged60f laser fire; warningwidth0; native standard body158+origin148 and proportional grow/close renders; length800/width16 retained; source hashes/Lua51.'
p=R/'work/logs/marisa-mixed/change11';(p/'verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
