from pathlib import Path
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
sounds={};function PlaySound(id,...)sounds[#sounds+1]={id,SSG.tick}end;function Color(...)return{...}end;function SetImageState()end
function Render()end;quads={};function Render4V(...)quads[#quads+1]={...}end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end''')
for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua','ssg-selected05.lua']:
 l.execute((M/p).read_text(encoding='utf8'))
l.execute('''SSGSelected05.start(20261106,'B3');local warned={};local frames=0
for i=1,560 do
 SSGSelected05.step(319,400,30000)
 for _,b in ipairs(SSG.beams)do
  local age=i-b.selected11Created;assert(SSGSelected05.laserWarning(b)==(b.state=='line'and age>=0))
  if SSGSelected05.laserWarning(b)then
   assert(i>=435 and i<495 and b.width==0);warned[i]=true;frames=frames+1
   quads={};SSGSelected05.drawLaser(b);assert(#quads==3)
  end
 end
end
local n=0;for _ in pairs(warned)do n=n+1 end;assert(n==60 and frames==300)
local charged=0;for _,s in ipairs(sounds)do if s[1]=='mm.selected12.charge'then assert(s[2]==435);charged=charged+1 end end;assert(charged==1)
local b={selected05Laser=true,selected11Created=100,state='line',width=0,x=319,y=224,d=0};SSG.tick=130;quads={};SSGSelected05.drawLaser(b)
assert(math.abs(quads[1][3]-quads[1][9])==6)
assert(math.abs(quads[2][3]-quads[2][9])==4)
assert(math.abs(quads[3][3]-quads[3][9])==1.5)
assert(b.width==0)
local previous=0
for age=0,59 do
 SSG.tick=100+age;quads={};SSGSelected05.drawLaser(b)
 local length=quads[1][5]-quads[1][2]
 assert(math.abs(length-800*(age+1)/60)<0.000001 and length>previous)
 previous=length
end
assert(previous==800)
''')
# Exercise the actual Beam.frame with a warning object and an active laser.
v=(M/'visual.lua').read_text(encoding='utf8');a=v.index('function Beam:frame()');b=v.index('\nend',a)+4
l.execute('Beam={};LAYER_ENEMY_BULLET=100;function Del()error("unexpected delete")end')
l.execute(v[a:b])
l.execute('''local b={selected05Laser=true,selected11Created=100,state='line',width=0,x=319,y=224,d=0}
local o={data=b};SSG.tick=99;Beam.frame(o);assert(o.layer==100 and not o.colli)
SSG.tick=100;Beam.frame(o);assert(o.layer==105 and not o.colli)
SSG.tick=160;b.state='open';b.width=8;Beam.frame(o);assert(o.layer==100 and o.colli and o.a==400 and o.b==16/3)
''')
for p in ['root.lua','visual.lua']:l.execute('assert(loadstring(...))',(M/p).read_text(encoding='utf8'))
msg='PASS unaccelerated B3 source: all5 guides visible435..494 exactly60f and grow linearly to800, laser opens495;300 beam-warning frames; 6px dark/4px gold/1.5px white geometry; actualBeam.frame warninglayer+5/nohitbox then normal active layer/collision restored; no timing changes; Lua51.'
(R/'work/logs/marisa-mixed/change13/verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
