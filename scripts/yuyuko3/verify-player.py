from pathlib import Path
import sys,hashlib,json
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/YuyukoStage3';S=R/'aex-0.8.22/game/mod/Stage12Normal'
original=(S/'player-data.lua').read_text('utf-8-sig').replace('Stage12ReimuBData','Y3ReimuBData')
assert (M/'player-data.lua').read_text('utf-8')==original
ref=json.loads((S/'source/player/reference.json').read_text('utf-8'))
assert hashlib.sha256(Path(ref['source_sht']).read_bytes()).hexdigest()==ref['sht_sha256']
assert hashlib.sha256((M/'art/player/pl00.png').read_bytes()).hexdigest()==ref['art_sha256']
before=json.loads((R/'work/logs/yuyuko3/player02-before.json').read_text())
for name,digest in before.items():assert hashlib.sha256((M/name).read_bytes()).hexdigest()==digest
print('PASS original TH10 SHT/art hashes; same Stage12 shot rows/positions; Boss spec/pattern files unchanged')
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
function Class(base)local c={base=base};for k,v in pairs(base or {})do if k~='base'then c[k]=v end end;return c end
enemybase={colli=function(o,b)o.hp=o.hp-b.dmg;if not b.killflag then b.deleted=true end end}
enemy=Class(enemybase);boss=Class(enemybase)
player_bullet_straight={init=function(o,img,x,y,speed,angle,dmg)o.x=x;o.y=y;o.dmg=dmg;o.speed=speed;o.img=img end}
reimu_player={init=function(o)o.support=4 end,frame=function()end}
lstg={var={power=400},world={boundt=224}}
setting={};player_lib={debug_data={keep_shooting=false},system={frame=function()end}}
LoadTexture=function()end;LoadImage=function()end;SetImageState=function()end;Color=function()end;PlaySound=function()end
Del=function(o)o.deleted=true end
spawned={}
function New(c,...)local o={class=c};c.init(o,...);spawned[#spawned+1]=o;return o end
''')
l.globals().Include=lambda p:l.execute((M/p).read_text('utf-8'))
l.execute((M/'player.lua').read_text('utf-8'))
l.execute('''
local a,b={hp=100},{hp=100};local shot=New(Y3Player.Shot,0,0,28,10,true)
enemybase.colli(a,shot);enemybase.colli(a,shot);boss.colli(b,shot)
assert(a.hp==90 and b.hp==90 and not shot.deleted)
local c={hp=100,protect=true};enemybase.colli(c,shot);assert(c.hp==100)
c.protect=false;enemybase.colli(c,shot);assert(c.hp==90)
local main=New(Y3Player.Shot,0,0,24,10,false);enemybase.colli(a,main);assert(main.deleted)
local p={class=reimu_player,x=0,y=-176,sp={{-32,0,1},{32,0,1},{-16,32,1},{16,32,1}},supportx=0,supporty=-176,__death_state=0}
player_lib.system.frame({player=p});assert(p.slist==Y3ReimuBData.positions)
for _,mode in ipairs({'high','slow'})do
 spawned={}
 for t=0,15 do p.y3FireClock=t;Y3Player.shoot(p)end
 local damage,piercing=0,0
 for _,o in ipairs(spawned)do damage=damage+o.dmg;if o.y3Piercing then piercing=piercing+1 end end
 assert(#spawned==60 and piercing==48 and damage==312)
 assert(damage*60/16==1170)
 print('PASS '..mode..' source cycle: 60 shots/16 frames, 48 piercing, nominal1170 damage/sec')
end
-- A late-loaded replacement character must also be rebound on its first frame.
reimu_player={};p.class=reimu_player;player_lib.system.frame({player=p});assert(reimu_player.shoot==Y3Player.shoot)
''')
print('PASS single-target duplicate prevention, front/rear piercing, protected contact and main-shot deletion')
