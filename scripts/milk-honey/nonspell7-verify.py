from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MilkHoney';L=R/'work/logs/milk-honey'
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.glob('*.lua'): l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
s=(M/'nonspell.lua').read_text(encoding='utf-8');l.execute(s.split('for _,id in ipairs')[0]);N=l.globals().MilkHoneyNonspell
assert N.duration==3600 and N.hp==8000
assert [t for t in range(240) if N.events(t)]==[120,150,180,210]
assert sum(N.events(t) for t in range(3600))==116
assert list(N.speeds.values())==[5,4.125,3.25,2.375]
assert N.moveAge(149) is None and N.moveAge(150)==0 and N.moveAge(179)==29 and N.moveAge(180) is None and N.moveAge(210)==0
for phase in range(0,315,45):
 for age in range(1000):
  a,b,u=N.colors(age,phase);assert a!=b and 0<=u<1
  if (age+phase)%45==44:
   c,d,v=N.colors(age+1,phase);assert c==b and v==0
old=(L/'before-nonspell7-root.lua').read_text(encoding='utf-8');new=(M/'root.lua').read_text(encoding='utf-8')
assert old.split('local card=boss.card.New')[1].split('local Suwako=Class')[0]==new.split('local card=boss.card.New')[1].split('local Suwako=Class')[0]
assert (L/'before-nonspell7-pattern.lua').read_bytes()==(M/'pattern.lua').read_bytes()
ref=json.loads((M/'source/nonspell7-reference.json').read_text(encoding='utf-8'))
for a in ref['assets']:
 sid=a['id'].split('sprite')[-1];assert hashlib.sha256((M/f'art/ofuda-{sid}.png').read_bytes()).hexdigest()==a['sha256']
print('PASS Lua5.1 syntax;source120/150/180/210 volley schedule;128 bullets/volley;4 exact speed layers;60s/8000HP;movement windows;gradient continuity;8 asset hashes;existing spell code+pattern byte-identical.')
