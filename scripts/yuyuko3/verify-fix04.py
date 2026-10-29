from pathlib import Path
import sys,re
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3')
l=LuaRuntime(unpack_returned_tuples=True)
for p in m.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
for n in ['runtime.lua','th07.lua','le04.lua']:l.execute((m/n).read_text('utf-8-sig'))
l.execute('''
Y3.start('spell2',42,192,112)
for i=0,100 do Y3.step(192,400)end
assert(Y3.counts.shots==120 and #Y3.birthEffects==120)
local e=Y3.birthEffects[1];local x,y=e.x,e.y
local s,a,active=Y3.birthGeometry(e);assert(s==4 and a==50 and active)
local b=Y3.shots[1];local bx,by=b.x,b.y
for i=1,9 do
 Y3.step(192,400)
 assert(e.x==x and e.y==y and e.age==i)
 s,a,active=Y3.birthGeometry(e)
 assert(math.abs(s-(4-.3*i))<1e-6 and a==math.min(255,50+15*i) and active)
end
assert(b.x~=bx or b.y~=by)
Y3.step(192,400);assert(#Y3.birthEffects==0)
for i=111,150 do Y3.step(192,400)end
assert(Y3.counts.shots==200 and #Y3.birthEffects==80)
local scales=0
for _,f in ipairs(Y3.birthEffects)do if f.typ==12 then scales=scales+1 end end
assert(scales==20)
Y3.start('non2',42,192,112);Y3.step(192,400)
assert(#Y3.birthEffects==0 and Y3.counts.shots==32)
for _,q in ipairs(Y3.shots)do assert(q.alpha==255)end
Y3.clear();assert(#Y3.birthEffects==0)
''')
print('PASS native effect 0xb: stationary position, scale4 minus .3/frame, alpha50 plus15/frame, lifetime10; live bullet moves independently; both spell2 volleys and scale births; clear/non2 isolation')
s=(m/'root.lua').read_text('utf-8-sig')
# Execute actual frame method against a minimal host to check sprite, collision and heading.
f=re.search(r'function Shot:frame\(\).*?\nend',s,re.S)[0]
l.execute('Shot={};function Del(o) o.deleted=true end')
l.execute(f)
l.execute('''
for _,typ in ipairs({3,10,12})do
 for _,angle in ipairs({0,math.pi/2,math.pi,-math.pi/2})do
  local b={typ=typ,nativeType=typ,nativeColor=4,le04=true,dead=false,x=200,y=100,scale=1,birth=0,angle=angle}
  local o={data=b};Shot.frame(o)
  assert(o.img==(typ==12 and 'y3.scale.4' or 'y3.b8.4'))
  assert(math.abs(o.heading-(-angle*180/math.pi-90))<1e-6)
  assert(o.a==(typ==10 and 8 or 2.5) and o.colli and not o.rect)
 end
end
''')
assert 'revealFrames' not in s and 'revealFrames' not in (m/'le04.lua').read_text('utf-8-sig')
print('PASS actual host frame: butterfly direction in four cardinal directions; both original radii; type12 scales retained; no reveal fade/gating; Lua syntax')

