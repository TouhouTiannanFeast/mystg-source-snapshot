from pathlib import Path
from lupa.lua51 import LuaRuntime
import hashlib,json,wave
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
def run(selected,mode='B1'):
 l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
sounds={};shots={};function PlaySound(id,vol,pan)sounds[#sounds+1]={id,SSG.tick,vol,pan}end''')
 for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua']:
  l.execute((M/p).read_text(encoding='utf8'))
 l.execute('SSG.onBullet=function(b)shots[#shots+1]={SSG.tick,b.c,b.d,b.v,b.selected05Skin}end')
 l.execute((M/'ssg-selected05.lua').read_text(encoding='utf8'))
 if selected:l.execute('SSGSelected05.start(20261106,...)',mode)
 else:l.execute('SSGInspect04.start(20261106,...)',mode)
 l.execute('for i=1,1200 do if SSGSelected05.active then SSGSelected05.step(319,400,30000)else SSG.step(319,400,30000)end end')
 return l,[v for _,v in sorted(l.globals().shots.items())],[v for _,v in sorted(l.globals().sounds.items())]
_,base,_=run(False);l,shots,sounds=run(True)
assert [tuple(s[i]for i in range(1,5))for s in shots]==[tuple(s[i]for i in range(1,5))for s in base]
assert all(s[5]=='yellowdot'for s in shots)
assert len(sounds)==len({s[1]for s in shots})>0
assert {s[2]for s in sounds}=={s[1]for s in shots}
assert all(s[1]=='mm.selected09.shot'and s[3]==.3 and s[4]==0 for s in sounds)
_,_,other=run(True,'A2');assert not other
l.execute('SSGSelected05.stop();local a=SSG.bits[1];if a then SSG.fire(a)end')
assert len(l.globals().sounds)==len(sounds)
src=R/'work/marisa-mixed/change09/se_tan00.wav';dst=M/'se/th08-se_tan00.wav'
assert src.read_bytes()==dst.read_bytes()
with wave.open(str(dst),'rb')as w:assert w.getnframes()>0
metadata={'archive':'G:/TouHou/[th08] 东方永夜抄 (日文版)/th08.dat','entry':'se_tan00.wav','target':'se/th08-se_tan00.wav','sha256':hashlib.sha256(dst.read_bytes()).hexdigest(),'scope':'B1 actual firing ticks, deduplicate five simultaneous familiars, volume0.3/centerpan; B1 yellowdots and A2 unchanged'}
(M/'source/audio09.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding='utf8')
logs=R/'work/logs/marisa-mixed/change09';logs.mkdir(parents=True,exist_ok=True)
msg=f'PASS B1 original{len(shots)}projectiles unchanged and yellowdots retained; TH08 shot sound exactlyonce per{len(sounds)}actual firingticks; no A2/leaked sound; original sample identical and valid WAV.'
(logs/'verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
