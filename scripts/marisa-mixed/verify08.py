from pathlib import Path
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def run(selected):
 l=LuaRuntime();l.execute('function LoadTexture()end;function LoadImage()end;function LoadSound()end;function PlaySound()end;births={};shots={}')
 for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua']:
  l.execute((M/p).read_text(encoding='utf8'))
 l.execute('''SSG.onBullet=function(b)shots[#shots+1]={c=b.c,t=SSG.tick,d=b.d,v=b.v,color=b.selected05Color,scale=b.motionScale}end''')
 l.execute((M/'ssg-selected05.lua').read_text(encoding='utf8'))
 l.execute('''local actor=SSG.actor;SSG.actor=function(pc,...)
 local a=actor(pc,...);if pc==0xb37 then births[#births+1]=SSG.tick end;return a end''')
 if selected:l.execute('SSGSelected05.start(20261106,"A2")')
 else:l.execute('SSGInspect04.start(20261106,"A2")')
 l.execute('for i=1,1200 do if SSGSelected05.active then SSGSelected05.step(319,400,30000)else SSG.step(319,400,30000)end end')
 return l,[v for _,v in sorted(l.globals().births.items())],[v for _,v in sorted(l.globals().shots.items())]
base,bt,bs=run(False);mod,mt,ms=run(True)
assert len(bt)==len(mt)==65,(bt,mt)
assert len(ms)==len([s for s in bs if s.c!=51])
assert sum(s.c==48 for s in ms)==65 and sum(s.c==50 for s in ms)==65*12
for wave in range(5):
 old=bt[wave*13:(wave+1)*13];new=mt[wave*13:(wave+1)*13]
 assert new[0]==old[0]-20,(old,new)
 assert [new[i+1]-new[i]for i in range(12)]==[7,6,7]*4,new
 assert new[-1]==old[-1]
 if wave:assert new[0]-mt[(wave-1)*13]==205
 small=[s for s in ms if s.c==50 and new[0]<=s.t<=new[-1]+1]
 assert len(small)==13*12 and {s.color for s in small}==[{2},{4},{6}][wave%3]
assert all(s.color==6 for s in ms if s.c==48)
assert all(s.scale==.5 for s in ms)
assert mod.globals().SSGSelected05.duration==1200
mod.execute('SSGSelected05.stop();SSGInspect04.start(20261106,"A2");assert(SSGCode[0x157][2][1]==80)')
mod.execute('assert(loadstring(...))',(M/'root.lua').read_text(encoding='utf8'))
msg='PASS exact original65big+780small stars/5waves in1200f; intra-wave gaps7/6/7 (mean20/3), wave period205 unchanged, reduced wait80->60; coherent red/purple/blue wave colors; yellowbig/halfspeed/deletedtiny retained; raw reference timing restored on stop/restart; Lua51 syntax.'
p=R/'work/logs/marisa-mixed/change08';p.mkdir(parents=True,exist_ok=True);(p/'verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
