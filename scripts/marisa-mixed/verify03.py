from pathlib import Path
import hashlib,json,math,re
from lupa.lua51 import LuaRuntime
from integrate02 import host02
from integrate03 import boss03
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed');B=Path('G:/MySTG/work/marisa-mixed/change03/before')
def read(p):return p.read_text(encoding='utf-8-sig')
assert (M/'th08/host.lua').read_bytes()==(B/'host.lua').read_bytes()
assert read(M/'th08/boss.lua')==boss03(read(B/'boss.lua'))
ref=json.loads(read(M/'source/visual02.json'))
for p in [M/'th08-visual02.lua',M/'visual.lua',M/'ssg.lua']:
 # Files from the previous task are outside this change; no edits required.
 assert p.exists()
lua=LuaRuntime(unpack_returned_tuples=True)
for p in [M/'root.lua',M/'th08/boss.lua',M/'stardust03.lua']:
 lua.execute('assert(loadstring(...))',read(p))
lua.execute('''
int=math.floor;max=math.max;min=math.min;object={};bullet={};laser={};enemy={};enemybase={};objects={};shots={};frameAge=0
function Class(b)local c={base=b};return setmetatable(c,{__index=b})end
function New(c,...)local o={class=c,timer=0,ani=0};setmetatable(o,{__index=c});c.init(o,...);objects[#objects+1]=o;return o end
function enemy.init(o,style,hp)o.hp=hp end
function enemy.frame(o)task.Do(o)end
function bullet.init(o,...)o.img='old';o.hscale=1;o.vscale=1 end
function bullet.skip_fade_in()end
function IsValid(o)return o and not o.dead end
function Del(o)o.dead=true end
function cos(d)return math.cos(d*math.pi/180)end
function sin(d)return math.sin(d*math.pi/180)end
ran={Float=function(_,a,b)return(a+b)/2 end}
GROUP_GHOST=0;GROUP_ENEMY=1;LAYER_ENEMY=10;LAYER_ENEMY_BULLET=20;LAYER_TOP=30
''')
lua.execute(read(Path('G:/MySTG/aex-0.8.22/game/packages/thlib-scripts/lib/Ltask.lua')))
lua.execute(read(M/'th08/host.lua'));lua.execute(read(M/'stardust03.lua'))
lua.execute('''
local T=th08s4;local S=T.Stardust03
local oldEmit=T.emit
T.emit=function(f,speed,angle,typ,color,opt)
 local b=oldEmit(f,speed,angle,typ,color,opt)
 shots[#shots+1]={age=f.timer,kind=opt and opt.ax and'delayed'or'fan',typ=typ,color=color,b=b,wait=opt and opt.wait,duration=opt and opt.duration,ax=opt and opt.ax,ay=opt and opt.ay}
 return b
end
local owner={x=0,y=0};task.New(owner,function()S.run(owner)end)
for i=1,91 do task.Do(owner)end
assert(#objects==7,'source familiar count changed')
familiars={};for i=1,7 do familiars[i]=objects[i];assert(familiars[i].color==S.colors[i]and familiars[i].opt.s03Type==S.types[i])end
for age=0,1680 do
 for _,f in ipairs(familiars)do f.timer=age;T.Familiar.frame(f)end
end
''')
shots=lua.globals().shots
by_age={}
for _,v in shots.items():by_age.setdefault(v.age,[]).append(v)
# Source Sub42:30 single shots; Sub45:75 seven-way volleys; each of seven actors.
for a in range(0,1681):
 if 120<=a<420:kind,start,gap,amount='delayed',120,10,7
 elif 420<=a<720:kind,start,gap,amount='fan',420,4,49
 elif 720<=a<1020:kind,start,gap,amount='delayed',720,10,7
 elif 1140<=a<1200:kind,start,gap,amount='fan',1140,4,49
 elif 1200<=a<1500:kind,start,gap,amount='delayed',1200,10,7
 elif 1620<=a<1680:kind,start,gap,amount='fan',1620,4,49
 elif a==1680:kind,start,gap,amount='delayed',1680,10,7
 else:kind,start,gap,amount=None,0,1,0
 expected=amount if kind and(a-start)%gap==0 else 0
 assert len(by_age.get(a,[]))==expected,(a,len(by_age.get(a,[])),expected)
 if expected:
  assert all(v.kind==kind for v in by_age[a])
print('PASS real host/task scheduler: exact seven Normal color/type pairs and every emission through two reversals, both120f silent expansion windows')
lua.execute('''
local T=th08s4;local S=T.Stardust03
local function close(a,b)assert(math.abs(a-b)<0.000001,tostring(a)..' ~= '..tostring(b))end
-- Deliberately choose a motion heading different from its orbit angle.
local f={timer=120,x=2,y=3,s03PreviousX=1,s03PreviousY=3,angle=173,color=2,th08_phase_owned=true,opt={s03Type=12}}
S.emitFrame(f);local b=shots[#shots].b
assert(b.wait==281 and b.duration==60);close(b.accel_x,0);close(b.accel_y,0.016666668)
local x,y=b.x,b.y
for i=0,280 do T.Bullet.frame(b);b.x=b.x+b.vx;b.y=b.y+b.vy;close(b.x,x);close(b.y,y)end
T.Bullet.frame(b);close(b.vy,0.016666668)
for i=2,60 do T.Bullet.frame(b)end
close(b.vy,60*0.016666668);local v=b.vy;for i=1,20 do T.Bullet.frame(b)end;close(b.vy,v)
f.timer=720;S.emitFrame(f);local b=shots[#shots].b
assert(b.wait==201 and b.duration==90);close(b.accel_y,-0.016666668)
f.timer=1200;S.emitFrame(f);local b=shots[#shots].b;close(b.accel_y,0.016666668)
f.timer=1020;local n=#shots;S.emitFrame(f);assert(#shots==n)
f.timer=1140;S.emitFrame(f);assert(#shots==n+7)
''')
print('PASS actual Bullet.frame:281/201 blocking updates, exactly60/90 vector acceleration, birth motion-heading snapshot and opposite cycle sides, constant subsequent velocity')
root=read(M/'root.lua');assert '3601/60,10000,'in root
assert read(M/'th08/host.lua')==host02(read(M.parent/'MySTG/stages/th08_stage4/host.lua'))
print('PASS firstHP10000, shared host/familiar immunity/star02 rendering/other phase program sections unchanged')
