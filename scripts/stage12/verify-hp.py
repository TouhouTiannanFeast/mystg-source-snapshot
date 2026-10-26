from pathlib import Path
import importlib,json
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal';rows=[]
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.globals().Stage2FileExists=lambda p:(m/p).exists()
 lua.execute((r/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 lua.globals().Include=lambda p:lua.execute((m/p).read_text(encoding='utf-8'))
 lua.globals().dofile=lambda p:lua.execute((r/'aex-0.8.22/game'/p).read_text(encoding='utf-8'))
 lua.execute("CopyImage=function()end;th14={rad=function(a)return -a*180/math.pi end,stats={waves=0},track=function(o)return o end,g={position=function(x,y)return x,224-y end}};enemy.init=function(o,style,hp)enemybase.init(o,hp);o._wisys={frame=function()end,render=function()end} end")
 for name in ('anchor','boss','momiji-pattern','momiji','context','enemies'):
  lua.execute((m/f'stage1/{name}.lua').read_text(encoding='utf-8'))
 lua.execute('''
 boss.init=function(o,x,y,name,cards)o.cards=cards end
 local mom={};Stage1Momiji.Boss.init(mom)
 Stage1DamageCards={mom.cards[1],th14.card('non1'),Stage1Context.card(),th14.card('non2'),th14.card('scale')}
 DamageBudgets={}
 for _,c in ipairs(Stage1DamageCards)do
  local o={class={base=boss},hp=c.hp,protect=false};local t=0
  while o.hp>0 and t<c.duration do
   if t>=120 and t%4==0 then enemybase.colli(o,{dmg=2*math.min(1,(t-120)/120)}) end
   t=t+1
  end
  assert(o.hp<=0 and t<c.duration*0.8,'insufficient boss damage margin')
  DamageBudgets[#DamageBudgets+1]={hp=c.hp,seconds=t/60,limit=c.duration/60}
 end
 for _,hp in ipairs({80,100,140,400,600,800,1000})do
  local o=New(th14.Enemy,'GirlRedA01',0,-16,hp)
  assert(o.hp==math.ceil(hp*3/28),'small enemy HP')
  local before=o.hp;o.class.colli(o,{dmg=2});assert(o.hp==before-2,'native damage callback absent')
 end
 ''')
 rows.append({'backend':backend,'budgets':[dict(x.items()) for x in lua.globals().DamageBudgets.values()],'ordinary_hit_callback':True})
(r/'work/logs/stage12/hp-budget.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
print(json.dumps(rows,indent=2))
