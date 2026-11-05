from pathlib import Path
import math,json
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal');l=LuaRuntime(unpack_returned_tuples=True)
for p in [M/'root.lua',M/'fix02.lua']:l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
for n in ['runtime','projectiles','programs','encounter','encounter-nina','import10/pool','import10/runtime','import10/projectiles','import10/programs','import10/specs','import08/specs','fix02']:l.execute((M/(n+'.lua')).read_text(encoding='utf-8-sig'))
expected={'non1':5100,'spell1':5100,'non2':38700,'spell2':31200,'non3':54000,'spell3':34500,'non4':34200,'spell4':8100,'final':7500,'kanako':24600}
for group in ['NinaCoreSpecs','Nina10Specs','Nina08Specs']:
 for s in l.globals()[group].values():assert s.hp==expected[s.id],s.id
l.execute('''R=Nina10Runtime;R.onActor=function(a)end;births={};R.onShot=function(b)births[#births+1]={t=R.tick,x=b.x,y=b.y}end
R.start(Nina10Specs[4],123)
for i=1,154 do R.step(0,400,R.spec.hp);R.stepHazards()end''')
births=list(l.globals().births.values());first=[b for b in births if b.t==152];assert len(first)==5
for i,b in enumerate(first):
 f0=1.570796+i*1.256637;d=f0+6.2831855/10+5.026548/60
 x=math.cos(f0)*-48+math.cos(d)*48;y=160+math.sin(f0)*-48+math.sin(d)*48
 assert abs(x-b.x)<1e-4 and abs(y-b.y)<1e-4,(i,x,y,b.x,b.y)
l.execute('''local r=R.newActor('th10kanako',13,70);r.name='fixture'
R.command(r,{},'moveCircle',{0,.1,4,2});R.command(r,{},'moveCircleRel',{1,.2,6,3})
R.command(r,{},'moveCircle',{-999999,-999999,-999999,0})
R.command(r,{},'moveCircleRel',{-999999,-999999,-999999,0})
assert(r.orbit.radius==4 and r.orbit.omega==.1 and r.relativeOrbit.radius==6 and r.relativeOrbit.omega==.2)''')
for aim in [0,math.pi/3,math.pi,-math.pi/2]:
 angles,target=l.globals().NinaFix02.frogAngles(0,100,100*math.cos(aim),100+100*math.sin(aim),l.eval('NinaCorePool.rng(93)'))
 assert len(angles)==7 and abs(angles[1]-target)<1e-9
 for a in list(angles.values())[1:]:assert abs((a-target+math.pi)%(2*math.pi)-math.pi)>=math.pi/6-1e-8
assert l.globals().NinaFix02.heading(math.pi/2)==-180
print('PASS HP ten values x3;5 exact Mountain first birth positions; independent orbit channels/sentinels;7 frogs exactly1 aimed/6 avoid30deg;heading source-up')
