from pathlib import Path
from lupa.lua51 import LuaRuntime
import hashlib,json,wave
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def runtime():
 l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
sounds={};shots={};draws={};quads={}
function PlaySound(id,vol,pan)sounds[#sounds+1]={id,SSG.tick}end
function SetImageState()end;function Color(...)return{...}end
function Render(...)draws[#draws+1]={...}end;function Render4V(...)quads[#quads+1]={...}end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end''')
 for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua']:
  l.execute((M/p).read_text(encoding='utf8'))
 l.execute('SSG.onBullet=function(b)shots[#shots+1]={SSG.tick,b.c,b.d,b.v,b.selected05Skin};lastBullet=b end')
 l.execute((M/'ssg-selected05.lua').read_text(encoding='utf8'))
 return l
l=runtime();l.execute('''SSGSelected05.start(20261106,'full');expectedCharge={}
for i=1,3780 do
 SSGSelected05.step(319,400,30000)
 assert(SSGSelected05.stage==(i<=1260 and'A2'or i<=2580 and'B1'or'B3'))
 if i<3780 then assert(not SSG.done)end
 for _,b in ipairs(SSG.beams)do
  if not b.dead and b.state=='line'and SSG.tick-b.selected11Created==30 then expectedCharge[SSG.tick]=true end
 end
end
assert(SSG.done and SSGSelected05.duration==3780)
assert(SSGSelected05.stats.stages[2].at==1261 and SSGSelected05.stats.stages[3].at==2581)
local n=0;for _ in pairs(expectedCharge)do n=n+1 end
local played=0;local seen={}
for _,s in ipairs(sounds)do if s[1]=='mm.selected12.charge'then assert(expectedCharge[s[2]]and not seen[s[2]]);seen[s[2]]=true;played=played+1 end end
assert(n>0 and played==n)
''')
base=runtime();base.execute('SSGInspect04.start(20261106,"B1");for i=1,1200 do SSG.step(319,400,30000)end')
test=runtime();test.execute('''SSGSelected05.start(20261106,'B1')
for i=1,1200 do SSGSelected05.step(319,400,30000)end
countAtStop=#shots;soundsAtStop=#sounds;local existing
for _,b in ipairs(SSG.bullets)do if not b.dead then existing=b end end
assert(existing,'expected live bullets at quiet window');local age=existing.age
SSGSelected05.step(319,400,30000);assert(#shots==countAtStop and #sounds==soundsAtStop)
assert(existing.age==age+1,'old bullets frozen during quiet window')
for i=1202,1320 do SSGSelected05.step(319,400,30000);assert(#shots==countAtStop and #sounds==soundsAtStop)end
assert(SSG.done and SSGSelected05.duration==1320)
''')
def signatures(l):return [tuple(s[i]for i in range(1,5))for _,s in sorted(l.globals().shots.items())]
assert signatures(base)==signatures(test)
assert all(s[5]=='smallstar'for _,s in test.globals().shots.items())
l.execute('''local b={selected05Laser=true,selected11Created=100,state='line',width=0,x=319,y=224,d=0}
SSG.tick=129;draws={};quads={};SSGSelected05.drawLaser(b);assert(#draws==0 and #quads==0)
SSG.tick=130;SSGSelected05.drawLaser(b);assert(#quads==2 and #draws==1)
assert(math.abs(quads[1][3]-quads[1][9])==3 and math.abs(quads[2][3]-quads[2][9])==1)
assert(b.width==0 and b.state=='line')
SSG.tick=159;draws={};quads={};SSGSelected05.drawLaser(b);assert(#quads==2)
b.state='open';b.width=8;draws={};quads={};SSGSelected05.drawLaser(b);assert(#quads==0 and #draws==2 and draws[1][5]==1)
''')
src=R/'work/marisa-mixed/change12/se_power0.wav';dst=M/'se/th08-se_power0.wav';assert src.read_bytes()==dst.read_bytes()
with wave.open(str(dst),'rb')as w:assert w.getnframes()>0
(M/'source/audio12.json').write_text(json.dumps(dict(archive='G:/TouHou/[th08] 东方永夜抄 (日文版)/th08.dat',entry='se_power0.wav',sha256=hashlib.sha256(dst.read_bytes()).hexdigest(),trigger='B3 guide onset age30, once per laser volley, volume0.4/centerpan'),ensure_ascii=False,indent=2),encoding='utf8')
for p in ['root.lua','ssg-selected05.lua']:l.execute('assert(loadstring(...))',(M/p).read_text(encoding='utf8'))
msg='PASS1260/1320/1200f total3780; B1 first1200f exact original shot signatures, final120f no new bullets/no shot sounds while old bullets move; guide3px cyan+1px white and collisionwidth0 for30f; originalTH08charge exactlyonce per guide onset; native laser fullwidth unchanged; sample/hash/WAV/Lua51.'
(R/'work/logs/marisa-mixed/change12/verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
