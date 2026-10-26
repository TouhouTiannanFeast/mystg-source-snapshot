from pathlib import Path
import hashlib,json,math
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MilkHoney'
l=LuaRuntime(unpack_returned_tuples=True);l.execute((M/'pattern.lua').read_text(encoding='utf-8'));P=l.globals().MilkHoneyPattern
for path in M.glob('*.lua'):l.execute('assert(loadstring(...))',path.read_text(encoding='utf-8'))
def fixed(a,b):return a+(b-a)*0.5
counts={'main':0,'secondary':0};frames={'main':[],'secondary':[]}
for t in range(720):
 for e in P.events(t,fixed).values():
  kind=e['kind'];counts[kind]+=8;frames[kind].append(t)
  a=list(P.angles(e['angle']).values());assert len(a)==8
  assert abs(max(a)-min(a)-157.500008)<0.0001
assert counts=={'main':1280,'secondary':1080}
assert frames['main'][0]==80 and frames['secondary'][0]==180
assert all(b-a==4 for fs in frames.values() for a,b in zip(fs,fs[1:]))
# Source phase samples: center up, left, up, right, up over 240 frames.
for t,target in [(80,90),(140,60),(200,90),(260,120),(320,90)]:
 e=P.events(t,fixed)[1];assert abs(e['angle']-target)<0.001
# Analytic integration independent of runtime helper: upward launch at speed2.5.
x,y,vx,vy=0,-10,0,2.5
for age in range(200):
 dx,dy=P.velocity(vx,vy,age);x+=dx;y+=dy
 if age==7:assert abs(y)<1e-8
 if age==8:assert abs(dy-(1.5*2.5-0.032))<1e-8
 if age==127:assert abs(y-(120*2.5+1.25-0.032*120*121/2))<1e-8
 if age==199:assert abs(dy-(2.5-120*0.032))<1e-8
assert P.outside(210,0,32,32) and not P.outside(200,0,32,32)
assert P.outside(0,-241,32,32) and not P.outside(0,-239,32,32)
assert P.moveAge(139) is None and P.moveAge(140)==0 and P.moveAge(199)==59 and P.moveAge(200) is None and P.moveAge(260)==0
assert abs(P.moveSpeed(59))<1e-12
ref=json.loads((M/'source/reference.json').read_text(encoding='utf-8'))
for s in ref['assets']:
 sid=s['id'].split('sprite')[-1];assert hashlib.sha256((M/f'art/sprite{sid}.png').read_bytes()).hexdigest()==s['sha256']
print('PASS Lua5.1 syntax;720-frame source schedule main1280/secondary1080;fan width;phase;birth/120-frame gravity;boundary/cycle;6 original sprite hashes.')
