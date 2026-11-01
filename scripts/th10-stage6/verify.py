from pathlib import Path
from collections import Counter
import json,hashlib
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/TH10Stage6Normal');LOG=Path('G:/MySTG/work/logs/th10-stage6')
l=LuaRuntime(unpack_returned_tuples=True)
def run(s):return l.execute(s)
for p in M.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
ref=json.loads((M/'reference.json').read_text(encoding='utf-8'))
assert hashlib.sha256(Path(ref['source']).read_bytes()).hexdigest()==ref['source_sha256']
for row in ref['art']:assert hashlib.sha256((M/row['output']).read_bytes()).hexdigest()==row['sha256']
for row in ref['sounds']:assert hashlib.sha256((M/'se'/row['file']).read_bytes()).hexdigest()==row['sha256']
run('''LoadTexture=function()end;LoadImage=function()end
ran={Float=function(self,a,b)return a+(b-a)*.376123 end}
''')
for n in ['runtime.lua','road-runtime.lua','projectiles.lua','programs.lua','assets.lua','presentation.lua']:run((M/n).read_text(encoding='utf-8'))
run('''
local R=TH10S6Runtime
spawns={};shots={};R.start()
R.onActor=function(a)spawns[#spawns+1]={name=a.name,t=R.tick,x=a.x,y=a.y,hp=a.hp,mirror=a.mirror}end
R.onShot=function(b)shots[#shots+1]=b end
for t=0,3667 do R.step(0,400,1);R.stepHazards()end
assert(#spawns==210,'road closure '..#spawns)
assert(spawns[1].t==160,'first source birth')
local counts={};local green=0
for _,a in ipairs(spawns)do
 counts[a.name]=(counts[a.name]or 0)+1
 if a.name:sub(1,4)=='GCir'then green=green+1 end
 assert(not a.name:find('Boss'),'Boss leaked into road')
 if a.name=='Girl01'then assert(a.t==1350 and a.hp==400)end
 if a.name=='Girl02'then assert(a.t==2440 and a.hp==1500)end
 if a.name=='BGirl00'then assert(a.hp==120)elseif a.name:find('Cir')then assert(a.hp==20)end
end
assert(green==28,'green source instances '..green)
assert(counts.BGirl00==12 and counts.Girl01==1 and counts.Girl02==1)
assert(R.stats.bullets>3000 and R.stats.lasers==0)
sourceCounts=counts;sourceShots=R.stats.bullets
-- Source first emitter: 3 full-circle spokes at4 speed; ring48 at1 speed;
-- two rotating8-spoke blue/red streams at2.8, and final point pairs at1.2.
R.start();local events={};R.onShot=function(b)events[#events+1]=b end
local a=R.newActor('th10',0,0)
R.command(a,{},'etCountD',{0,3,3,7,11,1,1,1,1})
R.command(a,{},'etSpeedD',{0,2.4,4,5,6,1,1,1,1})
R.fire(a,a.patterns[0]);assert(#events==3 and events[1].speed==4)
R.command(a,{},'etCountD',{0,24,48,48,48,1,1,2,3})
R.command(a,{},'etSpeedD',{0,1,1,2,3,1,1,1,1})
events={};R.fire(a,a.patterns[0]);assert(#events==48 and events[1].speed==1)
-- Independent movement boundary checks, mirror and source -999999 sentinel.
local e=R.newActor('th10',0,0);e.angle=0;e.speed=4;e.mirror=true;R.motion(e);assert(e.x==-4)
R.command(e,{},'moveVelTime',{40,0,-.3926991,-999999})
for i=1,40 do R.motion(e)end;assert(e.speed==4)
local c=R.newActor('th10',20,40);c.f[0]=0;c.f[1]=.05
R.command(c,{},'moveCircleRel',{0,.05,0,1.5})
for i=1,40 do R.motion(c)end;assert(math.abs(c.relativeOrbit.radius-60)<1e-8)
R.command(c,{},'moveCircleRel',{-999999,.05,-999999,0})
R.command(c,{},'moveVel',{1.57,2});R.motion(c)
assert(c.relativeOrbit and c.relativeOrbit.radius==60,'relative orbit survives absolute motion')
-- Actual source-specific presentation and white highlight preservation.
local P=TH10S6Presentation
for _,typ in ipairs({0,1,3,5})do for _,col in ipairs({2,4,6})do
 local b={typ=typ,color=col,birth=15,age=0};local img,scale,alpha=P.bullet(b);assert(img and scale==3 and alpha==0)
 b.age=14;img,scale,alpha=P.bullet(b);assert(scale<.6 and alpha>230)
 b.age=15;img,scale,alpha=P.bullet(b);assert(scale==1 and alpha==255)
 local _,s,a,n=P.cancel(b,0);local _,s2,a2=P.cancel(b,n);assert(s>0 and(s2==0 or a2==0))
end end
local e={age=10,anm={[0]=49,[1]=45}};local img,rot=P.enemy(e);assert(rot==180 and img=='s6.enemy.108')
local img,rot,scale,alpha=P.ring(e);assert(img=='s6.enemy.114' and alpha==128 and scale>1)
''')
print('PASS source schedule210 births/28green/12minions, Normal fire rows, source HP/times, mirror/sentinel/relative orbit, 12ANM mappings and source asset hashes')
rows=[]
for _,a in l.globals().spawns.items():rows.append({k:v for k,v in a.items()})
(LOG/'schedule.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
print('Model bullets:',l.globals().sourceShots)
# Host checks with minimal object primitives; actual native integration is a separate bounded probe.
run('''
objects={};GROUP_GHOST=0;GROUP_ENEMY=1;GROUP_NONTJT=2;GROUP_ENEMY_BULLET=3;GROUP_ITEM=4
LAYER_ENEMY_BULLET_EF=1;LAYER_ENEMY_BULLET=2;COLOR_RED=1
function Class(base)local c={base=base};if base then for k,v in pairs(base)do if k~='base'then c[k]=v end end end;return c end
object={};bullet={init=function(o)o.class=o.class end,skip_fade_in=function()end};ball_small={}
item={init=function(o,x,y)o.x=x;o.y=y end,frame=function(o)if o.attract and o.attract>0 then assert(o.target and o.target.valid)end end}
enemybase={init=function(o,hp)o.hp=hp;o.maxhp=hp end,frame=function()end,del=function()end}
enemy={kill=function(o)New(enemy_death_ef,o.death_ef,o.x,o.y)end}
enemy_death_ef={};item_faith_minor={init=function(o)o.target=player end,frame=function(o)assert(o.target and IsValid(o.target))end}
function IsValid(o)return type(o)=='table'and o.valid~=false end
function New(c,...)local o={class=c,timer=0,valid=true};if c.init then c.init(o,...)end;objects[#objects+1]=o;return o end
function Del(o)if o.valid then o.valid=false;if o.class.del then o.class.del(o)end end end
function Kill(o)if o.valid then o.valid=false;if o.class.kill then o.class.kill(o)end end end
function PlaySound()end;TH10S6Sound={play=function()end}
player={valid=true};item_power={collect=function()end};item_point=item_power;item_power_large=item_power;item_faith=item_power
''')
run((M/'host.lua').read_text(encoding='utf-8'))
run('''
local H=TH10S6Host
local function actor()return {hp=20,name='BCir00',x=0,y=50,age=0,dropMain=2,dropExtra={[1]=2}}end
local a=actor();local o=New(H.Enemy,a);H.Enemy.frame(o);o.class.base.take_damage(o,21);H.Enemy.frame(o)
assert(a.defeated and H.kills==1 and H.drops==3)
H.Enemy.kill(o);assert(H.kills==1 and H.drops==3)
local a=actor();local o=New(H.Enemy,a);a.dead=true;a.offscreenRemoval=true;H.Enemy.frame(o)
assert(H.kills==1 and H.drops==3 and H.culls==1)
local a=actor();local o=New(H.Enemy,a);a.invuln=10;H.Enemy.frame(o);o.class.base.take_damage(o,100);assert(o.hp==20)
local b={x=0,y=100,angle=0,typ=0,color=2,dead=false}
local o=New(H.Shot,b);b.dead=true;b.offscreenRemoval=true;local before=#objects;Del(o);assert(#objects==before,'natural cull spawned FX')
local b={x=0,y=100,angle=0,typ=0,color=2,dead=false};local o=New(H.Shot,b);local before=#objects;Kill(o);assert(#objects==before+2,'cancel FX/item missing')
local o=New(H.Drop,0,0,2);o.attract=8;o.target=nil;H.Drop.frame(o);assert(o.target==player)
o.target={valid=false};H.Drop.frame(o);assert(o.target==player)
local saved=player;player=nil;o.target={valid=false};H.Drop.frame(o);assert(o.attract==0);player=saved
local m=New(H.Minor,0,0);m.target=nil;H.Minor.frame(m);assert(m.target==player)
m.target={valid=false};H.Minor.frame(m);assert(m.target==player)
local saved=player;player=nil;m.target=nil;H.Minor.frame(m);assert(not m.valid);player=saved
H.clean();assert(next(H.owned)==nil and next(H.enemies)==nil)
''')
print('PASS actual host damage dispatch, entry protection, once-only defeat/drops, silent cull, cancel FX+item, nil/stale attraction targets, cleanup')
# Background source camera and geometry with render APIs stubbed.
run('background={};LoadTexture=function()end;LoadImage=function()end')
for n in ['background-assets.lua','background.lua']:run((M/n).read_text(encoding='utf-8'))
run('''local B=TH10S6Background;local s=B.new();for i=0,3667 do B.step(s)end;assert(s.sky);assert(#B.groups()==832,'geometry count '..#B.groups());assert(s.values.pos[1]==472,'camera x '..s.values.pos[1])''')
print('PASS source STD camera through road end, transition and geometry closure')
