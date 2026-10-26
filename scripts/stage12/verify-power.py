from pathlib import Path
from collections import Counter
import importlib,re,json
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';framework=R/'aex-0.8.22/game/packages/thlib-scripts/THlib/item/item.lua';src=framework.read_text(encoding='utf-8');outputs=[]
for backend in ('luajit21','lua51','lua54'):
 Lua=importlib.import_module('lupa.'+backend).LuaRuntime
 route=Lua(unpack_returned_tuples=True)
 harness=(R/'scripts/th14-stage1/schedule-harness.lua').read_text(encoding='utf-8').replace('mirror=mirror}','mirror=mirror,hp=hp}')
 route.execute(harness)
 route.execute("Stage12Music={play=function()end,stop=function()end};Stage1Momiji={Boss='momiji',clean=function()end};Stage1Context={clean=function()end};local n=New;New=function(c,...)if c=='momiji' then return n('boss',true)end return n(c,...)end")
 route.execute((M/'stage1/stage.lua').read_text(encoding='utf-8'));events,bosses=route.globals().th14.run();records=[dict(v.items()) for v in events.values()];assert len(records)==186
 counts=Counter(r['kind'] for r in records);assert counts['GirlB01']==6 and counts['GirlC01']==2 and counts['GirlD01']==4
 lua=Lua(unpack_returned_tuples=True)
 lua.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 lua.execute('''
 int=math.floor;min=math.min;sqrt=math.sqrt;PlaySound=function()end
 th14={rad=function(a)return -a*180/math.pi end,stats={waves=0},track=function(o)return o end,g={position=function(x,y)return x,224-y end}}
 enemy.init=function(o,style,hp)enemybase.init(o,hp);o._wisys={frame=function()end,render=function()end}end
 item_power={};item_power_large={};item_power_full={};item_faith={};item_point={}
 lstg.var.power=100;lstg.var.score=0;SmallP=0;LargeP=0
 local originalNew=New
 New=function(c,...)
  if c==item_power then SmallP=SmallP+1;item_power.collect({});return {} end
  if c==item_power_large then LargeP=LargeP+1;item_power_large.collect({});return {} end
  if c==item_faith or c==item_point then return {} end
  return originalNew(c,...)
 end
 ''')
 lua.execute(src[src.index('function GetPower(v)'):src.index('item_power = Class(item)')])
 for name in ('item_power','item_power_large'):
  match=re.search(r'function '+name+r':collect\(\)(.*?)\nend',src,re.S);lua.execute('function '+name+':collect()'+match[1]+'\nend')
 lua.execute(src[src.index('function item.DropItem('):src.index('item.sc_bonus_max')])
 lua.execute((M/'stage1/enemies.lua').read_text(encoding='utf-8'))
 units=0
 for row in records:
  enemy=lua.globals().New(lua.globals().th14.Enemy,row['kind'],row['x'],row['y'],row['hp'],row.get('mirror'))
  units+=enemy.drop[1];lua.globals().item.DropItem(0,0,enemy.drop)
 assert units==300 and lua.globals().SmallP==300 and lua.globals().LargeP==0
 assert lua.globals().lstg.var.power==400
 assert 'power=100' in (M/'stage1/stage.lua').read_text(encoding='utf-8')
 assert "60,800,{0,0,0}" in (M/'stage1/momiji.lua').read_text(encoding='utf-8')
 outputs.append(dict(backend=backend,enemies=186,big_counts=dict(counts),before_power=2.86,small_P=300,after_power=4.0,actual_drop_collect=True))
 print(backend+':186 enemies / actual300smallP / Power100->400 PASS')
(R/'work/logs/stage12/power.json').write_text(json.dumps(outputs,indent=2),encoding='utf-8')
