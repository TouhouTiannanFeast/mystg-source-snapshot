from pathlib import Path
import json,hashlib,re
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change10'
allowed={'root.lua','host.lua','presentation.lua','projectiles.lua','assets.lua','README.md'}
for n,h in json.loads((L/'before-hashes.json').read_text()).items():
 if n not in allowed:assert hashlib.sha256((M/n).read_bytes()).hexdigest()==h,n
l=LuaRuntime(unpack_returned_tuples=True)
for n in ['root.lua','host.lua','presentation.lua','projectiles.lua','assets.lua']:l.execute('assert(loadstring(...))',(M/n).read_text(encoding='utf-8'))
l.execute('''
ran={Float=function(self,a,b)return a+(b-a)*.376123 end}
LoadTexture=function()end;LoadImage=function()end;Class=function(base)local c={base=base};for k,v in pairs(base or{})do c[k]=v end;return c end
object={};item={};item_point={collect=function()end};item_faith_minor={};item_extend={};enemy={kill=function()end};enemybase={init=function(o,hp)o.hp=hp end};bullet={};img_class={}
GROUP_NONTJT=7;COLOR_RED=1;lifeDrops={};New=function(c,x,y)if c==item_extend then lifeDrops[#lifeDrops+1]={x=x,y=y}end;return {}end
''')
for n in ['runtime.lua','road-runtime.lua','assets.lua','presentation.lua','programs.lua']:l.execute((M/n).read_text(encoding='utf-8'))
l.execute((L/'before-projectiles.lua').read_text(encoding='utf-8'));l.execute('oldFire=TH11S6Runtime.fire')
l.execute((M/'projectiles.lua').read_text(encoding='utf-8'))
l.execute('''
local R,P=TH11S6Runtime,TH11S6Presentation;R.start()
local p={typ=3,color=3,angle=.31,speed=2,speed2=1.7,n=6,layers=1,aim=5,ox=0,oy=0,dist=64,ex={}}
local a={name='RPhantom01',group='th11',x=0,y=128}
oldFire(a,p);local old=R.hazards;R.hazards={}
R.fire(a,p);R.fire(a,p)
assert(#R.hazards==12)
for i,b in ipairs(R.hazards)do
 local o=old[(i-1)%6+1];assert(b.color==(i%2==1 and 13 or 9))
 for _,k in ipairs({'x','y','angle','speed','typ','vx','vy','cull'})do assert(b[k]==o[k],k..' changed')end
 local art=TH11S6BulletArt['3:'..b.color];assert(art.width==4 and art.deathFrames==16 and art.birthScale==3)
 P.bullet(b);P.cancel(b,3)
end
local a={name='RPhantom01',age=80,anm={[1]=46}}
assert(P.ring(a)==TH11S6Sprites.enemy[140])
assert(TH11S6BulletArt['3:13'].body==77 and TH11S6BulletArt['3:9'].body==73)
''')
l.execute((M/'host.lua').read_text(encoding='utf-8'))
l.execute('''
local H=TH11S6Host
for i,spin in ipairs({.006283,-.012566})do
 local a={name='RPhantom01',hp=12000,x=0,y=128,f={[0]=spin},age=30}
 local o={};H.Enemy.init(o,a);assert(o.death_ef==4 and o.hp==12000)
 H.Enemy.kill(o);H.Enemy.kill(o)
 assert(#lifeDrops==i-1,'only final frog,once even repeated kill')
end
local n=#lifeDrops;H.finalFrogLife(0,128);assert(#lifeDrops==n,'road completion must not duplicate kill reward')
H.frogLife=false;H.finalFrogLife(0,128);H.finalFrogLife(0,128);assert(#lifeDrops==n+1,'road-end fallback once')
''')
root=(M/'root.lua').read_text(encoding='utf-8')
assert 'if R.roadEnd then H.finalFrogLife(0,128)end' in root and 'H.frogLife=false'in root
wave=root[root.index('  if not crowLife and R.tick>790 then'):root.index('  if setting.th11s6_test then',root.index('  if not crowLife and R.tick>790 then'))]
l.execute("local crowLife=false;R={tick=790,actors={}};function testWave()\n"+wave+'\nend')
l.execute('''
local n=#lifeDrops;testWave();assert(#lifeDrops==n)
R.tick=791;local a={name='Crow01'};R.actors={a};testWave();assert(#lifeDrops==n)
a.dead=true;testWave();testWave();assert(#lifeDrops==n+1,'crow reward once after all gone')
''')
body=root.split('M.card.del=function(o)\n',1)[1].split('\nend\nR.onMidboss',1)[0]
l.execute("originalDel=function()end;clearRoad=function()end;R={tick=1};H={midbossEnds=0};TH11S6Voice={play=function()end};function testCard(o)\n"+body+'\nend')
l.execute('local n=#lifeDrops;local o={x=20,y=30};testCard(o);testCard(o);assert(#lifeDrops==n+1,"spell reward once")')
host=(M/'host.lua').read_text(encoding='utf-8')
assert "if a.name=='RPhantom01' then base=179 end" in host
print('PASS yellow halo140/trail179..186/death4;neutral host effect logic retained. Actual12needles alternate13/9 with identical count/path/speed/width/lifetime;original birth+cancel equivalents. Actual host finalfrog-only life pickup once;actual root Crow01-clear and spell-end blocks each one life pickup. Other mod hashes unchanged. Original2frog schedule520apart,first exits720 unchanged.')
