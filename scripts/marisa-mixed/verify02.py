from pathlib import Path
import hashlib,json,re,sys
from lupa.lua51 import LuaRuntime
from integrate02 import host02
from integrate03 import boss03
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed');B=Path('G:/MySTG/work/marisa-mixed/change02/before')
def read(p):return p.read_text(encoding='utf-8-sig')
lua=LuaRuntime(unpack_returned_tuples=True)
for p in [M/'root.lua',M/'visual.lua',M/'th08/host.lua',M/'th08-visual02.lua',M/'th08-art02.lua']:
 lua.execute('assert(loadstring(...))',read(p))
source=M.parent/'MySTG/stages/th08_stage4'
assert read(M/'th08/host.lua')==host02(read(source/'host.lua'))
assert read(M/'th08/boss.lua')==boss03(read(source/'boss.lua'))
assert (M/'ssg.lua').read_bytes()==(B/'ssg.lua').read_bytes()
assert '3601/60,10000,' in read(M/'root.lua')
print('PASS Lua51; opening HP10000; exact allowed host delta; source movement/count/trajectory/HP/time and SSG logic untouched')
lua.execute(read(M/'th08-visual02.lua'))
lua.execute('''
for c=0,15 do
 local k,r=TH08Visual02.star(12,c,10);assert(k==tostring(246+c)and math.abs(r+30)<0.00001)
 local q,t=TH08Visual02.star(13,c,20);assert(q==k and math.abs(t-60)<0.00001)
end
for c=0,7 do
 local k,r=TH08Visual02.star(14,c,10);assert(k==tostring(262+c)and math.abs(r+18)<0.00001)
 local _,r2=TH08Visual02.star(15,c,10);assert(math.abs(r2-18)<0.00001)
end
local s=TH08Visual02.spark(120);assert(#s==4)
for i,v in ipairs(s)do assert(v.x==295 and v.sx==2.3 and v.sy==3-(i-1)*0.5 and v.a==255)end
local s=TH08Visual02.spark(0);assert(s[1].sx==0 and s[1].x==0 and s[1].sy==0.1 and s[1].a==96)
local s=TH08Visual02.spark(30);assert(s[1].x==73.75 and s[1].sx==0.575)
local s=TH08Visual02.spark(60);assert(s[1].x==295 and s[1].sy==0.1)
assert(TH08Visual02.spark(340)[1].a==127.5 and TH08Visual02.spark(370)[1].a==0)
''')
ref=json.loads(read(M/'source/visual02.json'))
for row in ref['star_crops']:assert hashlib.sha256(Path(row['source']).read_bytes()).hexdigest()==row['sha256']
assert len(set(r['sha256']for r in ref['star_crops'][:16]))==16
print('PASS source ANM star spin +/-3 and +/-1.8 deg/frame,16 distinct original small colors/8 big colors; four source Spark layers/295px offset/scale/alpha events')
lua.execute('''
object={};enemybase={};enemy={};bullet={};laser={};allclasses={}
function Class(base)local c={base=base};setmetatable(c,{__index=base});allclasses[#allclasses+1]=c;return c end
function enemy.init(o,style,hp)o.hp=hp;o._wisys={frame=function()end};o.ani=0;o.timer=0;o.class=enemy end
function enemybase.frame(o)end;function enemy.frame(o)end
function bullet.init(o,...)o.img='fallback';o.hscale=1;o.vscale=1 end
function bullet.skip_fade_in()end;function bullet.render(o)end
function laser.render(o)end
task={New=function()end,Wait=function()end}
ran={Float=function(_,a,b)return(a+b)/2 end}
function cos(d)return math.cos(d*math.pi/180)end
function sin(d)return math.sin(d*math.pi/180)end
function IsValid(o)return o~=nil and not o.dead end
function New(c,...)local o={};setmetatable(o,{__index=c});o.class=c;c.init(o,...);return o end
function LoadTexture()end;function LoadImage()end;function LoadSound()end
function SetImageState()end;function Color(...)return{...}end
draws={};function Render(...)draws[#draws+1]={...}end
function Render4V()end
SSG={laserEnabled=false};MarisaArt={};TH08Art02={}
GROUP_GHOST=0;GROUP_ENEMY=1;LAYER_ENEMY=10;LAYER_ENEMY_BULLET=20;LAYER_TOP=30
''')
enemy_source=read(Path('G:/MySTG/aex-0.8.22/game/packages/thlib-scripts/THlib/enemy/enemy.lua'))
damage=re.search(r'function enemy:take_damage\(dmg\)(.*?)\nend',enemy_source,re.S)[0]
lua.execute(damage)
lua.execute(read(M/'th08/host.lua'));lua.execute(read(M/'visual.lua'))
lua.execute('''
local f=New(th08s4.Familiar,{x=0,y=96},0,0.5,0.8,2,1000,nil,{})
for _,t in ipairs({0,199,200,500,4000})do f.timer=t;th08s4.Familiar.frame(f);enemy.take_damage(f,1000000);assert(f.hp==1000 and f.protect and f.homingExcluded)end
local bit
for _,c in ipairs(allclasses)do if c.base==enemy and c~=th08s4.Familiar then bit=c end end
assert(bit);local a={x=319,y=89,hp=95,bit=true,damage=true};local f=New(bit,a)
for _,t in ipairs({0,200,1000})do f.timer=t;bit.frame(f);enemy.take_damage(f,1000000);assert(f.hp==95 and not a.dead and f.protect and f.homingExcluded)end
''')
print('PASS actual private familiar/bit frame callbacks vs real enemy.take_damage: million-damage immunity at spawn and after200/1000/4000f; homing exclusion')
lua.execute(read(M/'th08-art02.lua'))
lua.execute('''
for k,v in pairs(TH08Art02)do v.image=k end
local a={sourceType=12,sourceColor=14,age=5,x=10,y=20,hscale=1,vscale=1};TH08Visual02.renderStar(a)
a.age=15;TH08Visual02.renderStar(a);assert(draws[#draws][1]=='260' and math.abs(draws[#draws][4]+45)<0.00001)
assert(a.x==10 and a.y==20)
draws={};th08s4.Beam.render({track_player=true,timer=120,x=0,y=64,rot=-90})
assert(#draws==4 and draws[1][1]=='spark'and math.abs(draws[1][3]+231)<0.00001 and draws[1][5]==2.3 and draws[1][6]==3)
''')
print('PASS real star render self-rotation and real Beam render four original sprite layers; position/trajectory data untouched')
