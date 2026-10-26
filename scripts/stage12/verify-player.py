from pathlib import Path
import importlib,json,re
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';F=R/'aex-0.8.22/game/packages/thlib-scripts/THlib/item/item.lua';src=F.read_text(encoding='utf-8');results=[]
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.execute('''
 function Class(base) local c={base=base};if base then for k,v in pairs(base)do if k~='base' then c[k]=v end end end;return c end
 object={};item={};enemybase={colli=function(o,b)o.hp=o.hp-b.dmg;if not b.killflag then Kill(b)end end};enemy=Class(enemybase);boss=Class(enemybase)
 player_bullet_straight={init=function(o,img,x,y,speed,angle,dmg)o.x=x;o.y=y;o.dmg=dmg;o.vy=speed;o.img=img end}
 reimu_player={init=function(o)o.support=math.floor(lstg.var.power/100) end,frame=function()end,shoot=function() oldShot=oldShot+1 end}
 lstg={var={power=100,lifeleft=2,bomb=1,score=0},world={scrr=400,boundt=224},tmpvar={},lstg_ui={drawInfo1=function()oldUI=oldUI+1 end,drawInfo2=function()oldUI=oldUI+1 end}}
 setting={};player_lib={debug_data={keep_shooting=false}};GROUP_PLAYER_BULLET=4;LAYER_PLAYER_BULLET=20
 min=math.min;max=math.max;int=math.floor;sqrt=math.sqrt;abs=math.abs;unpack=unpack or table.unpack
 cos=function(a)return math.cos(a*math.pi/180)end;sin=function(a)return math.sin(a*math.pi/180)end
 ran={Float=function(self,a,b)return a end};PlaySound=function()end
 LoadTexture=function()end;LoadImage=function()end;SetImageState=function()end;SetFontState=function()end;Color=function()end
 RenderScore=function()end
 Render=function(name,...)assert(name~='hint.power','Power label visible')end
 RenderText=function(font,text,...)assert(not text:find('/4') and font~='score1','Power number visible')end
 oldShot=0;oldUI=0;spawned={};killed=0
 function IsValid(o)return o and not o.deleted end
 function Del(o)o.deleted=true end
 function Kill(o)o.deleted=true;killed=killed+1 end
 function New(c,...)local o={class=c,timer=0};if c.init then c.init(o,...)end;spawned[#spawned+1]=o;return o end
 item.PointRateFunc=function()return 10000 end
 item_power={init=function(o)o.red=true end};item_power_large={init=function(o)o.red=true end};item_power_full={init=function(o)o.red=true end};item_faith={};item_point={}
 stage={current_stage={timer=600,number=1}}
 ''')
 lua.execute(src[src.index('function GetPower(v)'):src.index('item_power = Class(item)')])
 lua.execute(src[src.index('function item.DropItem('):src.index('item.sc_bonus_max')])
 for name,endmarker in [('PlayerInit','function item.PlayerReinit'),('PlayerMiss','function item.PlayerSpell')]:
  start=src.index('function item.'+name) if name=='PlayerInit' else src.index('function item:'+name)
  lua.execute(src[start:src.index(endmarker,start)])
 lua.globals().Include=lambda p: lua.execute((M/p).read_text(encoding='utf-8'))
 lua.execute((M/'player.lua').read_text(encoding='utf-8'))
 lua.execute('''
 item.PlayerInit();assert(lstg.var.power==400)
 local p={x=0,y=-176};reimu_player.init(p);assert(p.support==4)
 local life=lstg.var.lifeleft
 item.PlayerMiss(p);assert(lstg.var.lifeleft==life-1 and lstg.var.power==400 and p.support==4 and p.protect==360)
 assert(#spawned==0,'Death spawned a red item')
 GetPower(-200);assert(lstg.var.power==400)
 local drops={300,2,3};item.DropItem(0,0,drops);assert(drops[1]==300 and drops[4]==nil)
 assert(#spawned==5,'Faith/point drops changed')
 for _,o in ipairs(spawned)do assert(o.class==item_faith or o.class==item_point)end
 for _,c in ipairs({item_power,item_power_large,item_power_full})do assert(New(c,0,0).deleted)end
 local a,b={hp=100},{hp=100};local shot=New(Stage12Player.Shot,0,0,28,10,true)
 enemybase.colli(a,shot);enemybase.colli(a,shot);boss.colli(b,shot)
 assert(a.hp==90 and b.hp==90 and not shot.deleted,'Piercing repeat/second-target failure')
 local protected={hp=100,protect=true};enemybase.colli(protected,shot);assert(protected.hp==100)
 protected.protect=false;enemybase.colli(protected,shot);assert(protected.hp==90)
 local main=New(Stage12Player.Shot,0,0,24,10,false);enemybase.colli(a,main);assert(main.deleted)
 spawned={};p.sp={{-32,0,1},{32,0,1},{-16,32,1},{16,32,1}};p.supportx=0;p.supporty=-176
 local damage=0;local count=0
 for t=0,15 do p.stage12FireClock=t;reimu_player.shoot(p)end
 assert(#spawned==60,'Expected 6 bursts of 10 shots per 16 frames')
 for _,o in ipairs(spawned)do damage=damage+o.dmg;if o.stage12Piercing then count=count+1 end end
 assert(count==48 and math.abs(damage*60/16-1170*3/28)<1e-8,'Source cadence or scaled damage changed')
 assert(Stage12ReimuBData.positions[5][1][1]==-32 and Stage12ReimuBData.positions[5][1][3]==-16)
 lstg.lstg_ui.drawInfo1({score=123});lstg.lstg_ui.drawInfo2({});assert(oldUI==0)
 Stage12PlayerConfig.lock_power=false;item.PlayerInit();assert(lstg.var.power==100)
 item.PlayerMiss(p);assert(lstg.var.power==100)
 lstg.var.power=400;item.PlayerMiss(p);assert(lstg.var.power==350)
 lstg.lstg_ui.drawInfo1({});lstg.lstg_ui.drawInfo2({});assert(oldUI==2)
 spawned={};item.DropItem(0,0,{3,0,0});assert(#spawned==3)
 for _,o in ipairs(spawned)do assert(o.red and not o.deleted)end
 Stage12PlayerConfig.reimu_b=false;reimu_player.shoot(p);assert(oldShot==1)
 ''')
 results.append({'backend':backend,'full_power_and_miss':True,'red_drop_suppressed':True,'other_items_preserved':True,'once_per_enemy_piercing':True,'source_cadence':True,'hidden_ui':True,'restore_switch':True})
 print(backend+': locked/death/drop/piercing/source cadence/UI/restore PASS')
(R/'work/logs/stage12/player').mkdir(parents=True,exist_ok=True)
(R/'work/logs/stage12/player/unit.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
