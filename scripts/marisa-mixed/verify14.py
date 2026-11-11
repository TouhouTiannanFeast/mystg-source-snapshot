from pathlib import Path
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def runtime():
 l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
sounds={};function PlaySound(id,...)sounds[#sounds+1]={id,SSG.tick}end
function Color(...)return{...}end;function SetImageState()end
draws={};quads={};function Render(...)draws[#draws+1]={...}end;function Render4V(...)quads[#quads+1]={...}end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end''')
 for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua','ssg-selected05.lua']:
  l.execute((M/p).read_text(encoding='utf8'))
 v=(M/'visual.lua').read_text(encoding='utf8');a=v.index('function Beam:frame()');b=v.index('\nend',a)+4
 l.execute('Beam={};LAYER_ENEMY_BULLET=100;function Del()end');l.execute(v[a:b])
 return l
l=runtime();l.execute('''SSGSelected05.start(20261106,'B3');local first;local seen=0
for i=1,560 do
 SSGSelected05.step(319,400,30000);assert(SSG.bitRotationScale==.5)
 if not first and #SSG.beams>0 then first=SSG.beams[1]end
 if first then
  local age=i-first.selected11Created
  if age<60 then
   assert(first.state=='line'and SSGSelected05.laserLength(first)==0 and SSGSelected05.laserWarning(first));seen=seen+1
  elseif age<90 then
   local length=800*(age-60+1)/30;assert(math.abs(SSGSelected05.laserLength(first)-length)<.00001)
   assert(SSGSelected05.laserWarning(first)==(age<89))
  end
 end
end
assert(first.selected11Created==435 and first.selected14OpenTick==495 and seen==60)
local n=0;for _,s in ipairs(sounds)do if s[1]=='mm.selected12.charge'then assert(s[2]==435);n=n+1 end end;assert(n==1)
local b={selected05Laser=true,selected11Created=40,selected14OpenTick=100,state='open',width=8,x=319,y=224,d=0}
for i=0,29 do
 SSG.tick=100+i;draws={};quads={};SSGSelected05.drawLaser(b);local len=800*(i+1)/30
 assert(#draws==2 and math.abs(draws[1][2]-len/2)<.00001 and math.abs(draws[1][6]*14-len)<.00001)
 if i<29 then assert(#quads==3 and math.abs(quads[1][2]-len)<.00001 and quads[1][5]==800)else assert(#quads==0)end
 local o={data=b};Beam.frame(o);assert(math.abs(o.x-len/2)<.00001 and math.abs(o.a-len/2)<.00001 and o.colli)
end
b.state='line';SSG.tick=40
local prev=0
for i=0,59 do
 SSG.tick=40+i;draws={};quads={};SSGSelected05.drawLaser(b)
 local len=quads[1][5];assert(math.abs(len-800*(i+1)/60)<.00001 and len>prev);prev=len
 local o={data=b};Beam.frame(o);assert(not o.colli and o.a==0 and o.layer==105)
end
SSGSelected05.start(5,'B1');SSGSelected05.step(319,400,30000);assert(SSG.bitRotationScale==nil)
SSGSelected05.stop();SSGInspect04.start(5,'B3');assert(SSG.bitRotationScale==nil)
''')
# Isolate orbit motion and measure cumulative turn through wraparound.
turns=[]
for scale in [1,.5]:
 t=runtime();t.execute('SSGInspect04.start(5,"B3");SSG.makeBits();SSG.body.dead=true;SSG.bitSpeed=4;turn=0')
 t.globals().SSG.bitRotationScale=scale
 t.execute('''for i=1,600 do
 local a=SSG.baseAngle;local b=SSG.bits[1].bitAngle
 SSG.step(319,400,30000)
 assert(math.abs(((SSG.baseAngle-a)%512)-4*(SSG.bitRotationScale or 1))<.00001)
 turn=turn+(SSG.bits[1].bitAngle-b+128)%256-128
end''')
 turns.append(t.globals().turn)
assert abs(turns[0]/2-turns[1])<=3,turns
for p in ['root.lua','visual.lua','ssg.lua']:l.execute('assert(loadstring(...))',(M/p).read_text(encoding='utf8'))
msg=f'PASS exact60f progressively-growing guide; chargeonce at onset; originalfire495; active30f grows26.67->800 while residualguide shrinks, visiblebody/collision endpoints match everyframe; B3orbit half base increment and cumulativeturn{turns}, B1/raw unaffected; syntax.'
(R/'work/logs/marisa-mixed/change13/verify14.log').write_text(msg+'\n',encoding='utf8');print(msg)
