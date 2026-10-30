from pathlib import Path
import json,math
from lupa.lua51 import LuaRuntime
root=Path('G:/MySTG');mod=root/'aex-0.8.22/game/mod/RingoDango';log=root/'work/logs/ringo-dango'
lua=LuaRuntime(unpack_returned_tuples=True)
for path in mod.glob('*.lua'):
 result=lua.eval('loadstring')(path.read_text(encoding='utf-8'),'@'+str(path))
 assert not isinstance(result,tuple) or result[0],result
lua.execute((mod/'pattern.lua').read_text(encoding='utf-8'))
lua.execute('''
local P=RingoDangoPattern
assert(P.hp==2400 and P.duration==2400)
local w=P.new(function() return 0.5 end)
local rings,bigs={},{}
for t=0,2399 do
 w.t=t;local nr,nb=w.stats.rings,w.stats.mentos
 P.emit(w,0,96,0,-160)
 if w.stats.rings>nr then rings[#rings+1]=t end
 if w.stats.mentos>nb then bigs[#bigs+1]=t end
  if w.stats.mentos>nb then
   for _,b in ipairs(w.bullets) do if b.kind=='mentos' then assert(b.y==96 and b.speed==2) end end
  end
 -- Schedule-only probe does not retain emitted objects.
 w.bullets={}
end
assert(#rings==42 and #bigs==7)
for i,t in ipairs(rings) do assert(t==90+math.floor((i-1)/6)*334+((i-1)%6)*14) end
for i,t in ipairs(bigs) do assert(t==264+(i-1)*334) end
w=P.new(function() return 0.5 end);w.t=90;P.emit(w,0,96,0,-160)
assert(#w.bullets==140)
local b=w.bullets[1]
assert(b.x==20 and b.y==104 and b.speed==0.6 and b.turn==-0.012)
for i=1,60 do P.advance(w) end
assert(math.abs(b.angle+0.72)<1e-8)
P.advance(w);assert(math.abs(b.angle+0.72)<1e-8)
-- Native squared radius400 inclusive; only tag0 changes, once.
w=P.new(function() return 0.5 end)
local large=P.spawn(w,'mentos',0,0,-math.pi/2,2)
local near=P.spawn(w,'pellet',20,0,0,0.6)
local far=P.spawn(w,'pellet',20.001,0,0,0.6)
P.influence(w)
assert(near.tag==2 and near.speed==2 and near.vy==-2 and far.tag==0)
assert(near.kind=='pellet' and near.bounces==1)
P.influence(w);assert(w.stats.influenced==1)
near.x=0;near.y=-223
P.advance(w)
assert(w.stats.bounces==1 and near.y==-223 and near.vy==2 and near.scatter==0)
assert(near.kind=='pellet','sprite must wait until bounce/steps finish')
P.advance(w);assert(near.speed==1 and near.scatter==1 and near.kind=='pellet')
P.advance(w);assert(near.speed==1 and near.scatter==2)
P.advance(w);assert(near.kind=='outline' and near.bounces==0)
-- Bounce mirror and no second bounce.
near.x=193;near.vx=1;near.vy=0;P.advance(w);assert(near.x==194 and w.stats.bounces==1)
-- Actual full spell simulation: influence and transformed projectiles survive.
w=P.new(function() return 0.5 end);local x,y=0,96
for t=0,1100 do x,y=P.step(w,x,y,60*math.sin(t*0.4*math.pi/180),-160) end
assert(w.stats.rings==19 and w.stats.pellet==2660 and w.stats.mentos==9)
assert(w.stats.influenced>0 and w.stats.bounces>0)
RESULT=w.stats
''')
result=dict(lua.globals().RESULT.items())
source=(mod/'source/BossCard2.txt').read_text(encoding='utf-8')
for token in ['etCount(0, 140, 1)','etSpeed(0, 0.6f, 1.0f)','diffI($C, 1, 3, 4, 5)','etExSet(0, 9, 0, 64, 1, 15','spell(14, 2400','funcSet(1)']:
 assert token in source,token
result['lua51_syntax']='PASS';result['source_schedule']='42 rings / 5880 pellets / 21 mentos over 2400frames'
result['influence']='radius20 inclusive, copy velocity, one-shot tag, bounce before scatter, radius2.4 ->4'
(log/'verify.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print('PASS',json.dumps(result))
