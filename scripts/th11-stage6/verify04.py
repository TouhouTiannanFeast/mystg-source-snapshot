"""Narrow current-HP, entry guard, chain heading and original actor regression."""
from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change04'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
before=json.loads((L/'before-hashes.json').read_text())
for n in ['programs.lua','projectiles.lua','milk/pattern.lua','background.lua','background-assets.lua','player.lua','player-data.lua','player-config.lua','power-lock.lua','music.lua']:
 assert sha(M/n)==before[n],n
ref=json.loads((M/'source/suwako04-reference.json').read_text())
for row in ref['art']:assert sha(M/row['output'])==row['sha256']
l=LuaRuntime(unpack_returned_tuples=True)
for p in M.rglob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
def run(s):return l.execute(s)
run('''
Class=function(base)local c={};for k,v in pairs(base or{})do c[k]=v end;c.base=base;return c end
object={};item={};item_point={collect=function()end};item_faith_minor={};enemy={};img_class={};ball_small={};COLOR_RED=1
enemybase={init=function(o,hp)o.hp,o.maxhp=hp,hp end,frame=function()end}
bullet={init=function()end,skip_fade_in=function()end}
setting={};ran={Float=function(self,a,b)return a+(b-a)*.37 end};LAYER_ENEMY=40;GROUP_GHOST=0;GROUP_NONTJT=7
LoadTexture=function()end;LoadImage=function()end;GetTextureSize=function()return 16,16 end
SetImageState=function()end;Color=function()end;draws={};Render=function(...)draws[#draws+1]={...}end
New=function(c,...)local o=setmetatable({class=c,ani=0},{__index=c});c.init(o,...);return o end
IsValid=function(o)return o and not o.invalid end;Del=function(o)o.invalid=true end
Damage=function(o,n)return o.class.base.take_damage(o,n)end
boss={card={New=function(name,t1,t2,t3,hp,drop,sc)return {name=name,hp=hp,t3=t3*60,is_sc=sc}end}}
''')
for n in ['runtime.lua','programs.lua','assets.lua','presentation.lua','host.lua']:run((M/n).read_text(encoding='utf-8'))
run('''
local R,H=TH11S6Runtime,TH11S6Host;R.start();R.onActor=nil
local parent=R.controller
for _,hp in ipairs({50,100,200,6000})do
 R.command(parent,{},'enmCreate',{'Crow01',0,128,hp,1000,2})
 local a=R.actors[#R.actors];assert(a.hp==hp*2)
end
local a=R.actors[#R.actors];local o=New(H.Enemy,a)
assert(o.hp==12000 and o.maxhp==12000 and o.protect)
for age=0,19 do a.age=age;H.Enemy.frame(o);Damage(o,10);assert(o.hp==12000 and o.protect,'entry20f')end
a.age=20;H.Enemy.frame(o);Damage(o,10);assert(o.hp==11990 and not o.protect,'release at20')
a.age=21;a.invuln=30;H.Enemy.frame(o);Damage(o,10);assert(o.hp==11990,'source invulnerability retained')
for _,angle in ipairs({0,math.pi/2,math.pi,-math.pi/2,.37,2.14})do
 local b={x=30,y=40,typ=4,color=6,angle=angle,collidable=true,vx=3*math.cos(angle),vy=3*math.sin(angle)}
 local shot=New(H.Shot,b);H.Shot.frame(shot)
 local r=shot.heading*math.pi/180
 local dot=(-math.sin(r))*math.cos(angle)+math.cos(r)*(-math.sin(angle))
 assert(dot>.999999 and shot.rot==0 and shot.rect and shot.a==2,'chain head/collision')
 assert(b.x==30 and b.y==40 and b.vx==3*math.cos(angle)and b.vy==3*math.sin(angle),'heading changed trajectory')
end
''')
for n in ['milk/pattern.lua','milk/actor-assets.lua','milk/actor.lua','milk/nonspell.lua','milk/boss.lua']:run((M/n).read_text(encoding='utf-8'))
run('''
local M,A,N=TH11S6Milk,TH11S6Suwako,MilkHoneyNonspell
assert(M.nonspell.hp==12000 and M.nonspell.t3==2400 and N.duration==2400)
assert(M.card.hp==24000 and M.card.t3==3000 and MilkHoneyPattern.duration==3000)
assert(N.colorFrames==20 and N.speeds[1]==3.75 and N.speeds[2]==3.10 and N.speeds[3]==2.44 and N.speeds[4]==1.78)
local owner={x=0,y=100,ani=0};draws={};A.body(owner);assert(draws[1][1]=='milk.original.sprite0')
local state={tick=79};A.startSpell(owner,state);local f=A.frog
assert(f.group==GROUP_GHOST and not f.colli and not f.bound and f.layer<LAYER_ENEMY)
draws={};A.Frog.render(f);assert(#draws==0)
state.tick=100;A.Frog.render(f);assert(draws[1][1]=='milk.original.sprite30'and draws[1][5]==1.5)
owner.x=80;A.Frog.frame(f);assert(f.x==80)
A.clean();assert(f.invalid and not A.frog)
''')
print('PASS HP50/100/200/6000 x2 once; actual Damage rejects0..19/accepts20 and retains source invuln; chain head forward6directions with unchanged velocity/rect; nonspell12000HP40s/spell24000HP50s; original Suwako/frog art,spell-only first80f/layer/no-collision/follow/cleanup. Other gameplay hashes unchanged. No fullstage.')
(L/'verify.json').write_text(json.dumps(dict(status='PASS',road_hp=[100,200,400,12000],immunity_frames=20,nonspell=[12000,40],spell=[24000,50],chain_rotation=180),indent=2))
