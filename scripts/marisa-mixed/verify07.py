from pathlib import Path
from lupa.lua51 import LuaRuntime

R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def run(mode,selected):
    l=LuaRuntime(unpack_returned_tuples=True)
    l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
function PlaySound()end
shots={};lasers={};wave=0
''')
    for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua']:
        l.execute((M/p).read_text(encoding='utf8'))
    l.execute('''SSG.onBullet=function(b)
 shots[#shots+1]={tick=SSG.tick,c=b.c,d=b.d,v=b.v,wave=wave,skin=b.selected05Skin}
end''')
    l.execute((M/'ssg-selected05.lua').read_text(encoding='utf8'))
    l.execute('''local original=SSG.bitLaser
SSG.bitLaser=function(cmd)
 if cmd==3 then wave=wave+1 end
 lasers[#lasers+1]={tick=SSG.tick,cmd=cmd,wave=wave}
 return original(cmd)
end''')
    if selected:l.execute('SSGSelected05.start(20261106,...)',mode)
    else:l.execute('SSGInspect04.start(20261106,...)',mode)
    l.execute('for i=1,1200 do if SSGSelected05.active then SSGSelected05.step(319,400,30000)else SSG.step(319,400,30000)end end')
    def rows(name,keys):return [tuple(v[k]for k in keys)for _,v in sorted(l.globals()[name].items())]
    return l,rows('shots',['tick','c','d','v','wave']),rows('lasers',['tick','cmd','wave'])

base,a,al=run('A2',False);mod,b,bl=run('A2',True)
counts={};expected=[]
for s in a:
    if s[1]==51:continue
    counts[s[1]]=counts.get(s[1],0)+1
    if counts[s[1]]%4:expected.append(s)
assert b==expected and al==bl and set(counts)=={48,50}
assert len(b)==sum(n-n//4 for n in counts.values())
base,a,al=run('B3',False);mod,b,bl=run('B3',True)
assert al==bl and len(al)>6,'laser timing/number changed or insufficient waves'
assert b==[s for s in a if s[4]%2==1]
assert {s[4]for s in a}>={1,2,3}
assert all(s[4]%2==1 for s in b)
assert mod.globals().SSGSelected05.duration==1200
assert mod.globals().SSGSelected05.b3Wave==sum(cmd==3 for _,cmd,_ in bl)
mod.execute('SSGSelected05.start(5,"B3");assert(SSGSelected05.b3Wave==0)')
mod.execute('assert(loadstring(...))',(M/'root.lua').read_text(encoding='utf8'))
assert 'frames/60,30000,'in(M/'root.lua').read_text(encoding='utf8')
msg='PASS A2 retains exactly3/4 per star stream; B3 odd volleys original bullets, even volleys laser-only; all laser commands/ticks unchanged; source shot directions/speeds preserved; wave reset/1200f/HP30000/Lua51 verified.'
logs=R/'work/logs/marisa-mixed/change07';logs.mkdir(parents=True,exist_ok=True)
(logs/'verify.log').write_text(msg+'\n',encoding='utf8')
print(msg)
