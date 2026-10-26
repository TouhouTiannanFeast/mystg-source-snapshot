"""Focused source-ECL regression for reported TH10 card2/card6 line lasers."""
from pathlib import Path
import hashlib,json
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG');C=ROOT/'aex-0.8.22/game/mod/MySTG/stages/suwako5'
l=LuaRuntime(unpack_returned_tuples=True)
for f in ['runtime.lua','projectiles.lua','stage.lua']:l.execute('assert(loadstring(...))',(C/f).read_text(encoding='utf-8'))
for f in ['pool.lua','runtime.lua','projectiles.lua','programs.lua']:l.execute((C/f).read_text(encoding='utf-8'))
l.execute('''
local R,P=Suwako5Runtime,Suwako5Pool
local function near(a,b)assert(math.abs(a-b)<1e-4,tostring(a)..' vs '..tostring(b))end
R.start(P.find('th10-card6'),20261026)
local born={};R.onShot=function(b)if b.laser then born[#born+1]={b=b,tick=R.tick,x=b.x,y=b.y,length=b.laser.length}end end
for tick=0,132 do R.step(0,400,R.spec.hp);R.stepHazards()end
assert(#born==7)
for _,row in ipairs(born)do
 assert(row.tick==91 and row.y==0 and row.length==0)
 assert(row.b.laser.nativeLine and row.b.laser.max==320 and row.b.laser.width==16)
end
-- Exact growth clock from a real source-generated laser.
R.start(P.find('th10-card6'),20261026);born={}
for tick=0,90 do R.step(0,400,R.spec.hp);R.stepHazards()end
-- Source first shot is issued when script tick91.
R.step(0,400,R.spec.hp)
local b=born[1].b;near(b.laser.length,0);near(b.y,0)
for age=1,40 do R.projectileStep(b);near(b.y,0);near(b.laser.length,age*8)end
R.projectileStep(b);assert(b.y>0 and b.y<8);near(b.laser.length,320)
-- Parent keeps travelling outward; a zero-length reflected segment grows
-- from its leading tip. The child inherits the consumed bounce template.
R.start(P.find('th10-card2'),20261026);R.hazards={};R.onShot=nil
R.fire({group='th10',x=190,y=100},{typ=3,color=2,n=1,layers=1,aim=1,angle=0,speed=6,laser={nativeLine=true,initial=0,length=8,max=128,width=14},ex={[0]={kind=1024,async=0,i=1,j=-999999,r=-999,s=-999999}}})
b=R.hazards[1];R.projectileStep(b)
assert(#R.hazards==2);local child=R.hazards[2]
near(b.x,190);near(b.angle,0);near(b.laser.length,14)
near(child.x,198);near(child.y,100);near(child.laser.length,0);near(math.abs(child.angle),math.pi)
assert(child.ex[0].i==0 and #b.active==0)
R.projectileStep(child);assert(#R.hazards==2);near(child.x,198);near(child.laser.length,6)
-- Recover first real source reflection, including its birth frame and side.
R.start(P.find('th10-card2'),20261026);local serial=0;local first
R.onShot=function(b)
 serial=serial+1;b.traceId=serial
 if not first and R.tick>100 and b.laser and b.laser.nativeLine and math.abs(b.x)>192 then
  first={tick=R.tick,x=b.x,y=b.y,id=b.traceId};print(string.format('NEW first reflected continuation tick=%d tip=(%.3f,%.3f) color=%d initial=%.1f',R.tick,b.x,b.y,b.color,b.laser.length))
 end
end
for tick=0,220 do R.step(0,400,R.spec.hp);R.stepHazards()end
assert(first and first.tick==138);near(math.abs(first.x),(128+24*6)*math.cos(0.785398));near(first.y,128+(128+24*6)*math.sin(0.785398))
print('PASS: source7top origins at91;0->320 over40ticks at fixedtop;tip reflection creates growing child and retains parent direction;consumed template prevents repeated bounce.')
''')
# User values and generated source routines are preserved.
rows=json.loads((ROOT/'scripts/suwako5/practice-catalog.json').read_text(encoding='utf-8'))
P=l.globals().Suwako5Pool
for row in rows:
 s=P.find(row['id']);assert s['hp']==row['hp'] and s['frames']==1800
print('PASS: latest22 HP/time values and catalog match; generated source patterns not edited.')

