from pathlib import Path
import importlib,json
m=Path('G:/MySTG/aex-0.8.22/game/mod/Stage12Normal')
entries=json.loads((m/'practice-entries.json').read_text(encoding='utf-8'))
for backend in ('luajit21','lua51','lua54'):
 for row in entries:
  lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
  lua.execute('''setting={};th14={};_init_item=function(s)initializedWithPractice=lstg.var.is_practice end;stage={group={Start=function(g)originalGroup=g end,PracticeStart=function(s)target=s;lstg.var.is_practice=true end}}
stage_init={};lstg={var={}};player_list={{'Reimu','reimu','rep'}}''')
  lua.globals().setting.stage12_entry=row['id']
  lua.execute((m/'practice.lua').read_text(encoding='utf-8'))
  g=lua.globals();g.stage_init.frame(lua.table_from({'timer':30}))
  expected='Misty Lake@Normal' if row['id'].startswith('s1-') else 'Stage Two@Normal'
  assert g.target==expected and g.lstg.var.is_practice is False
  g.target=None;g.stage.group.Start('Normal')
  assert g.target==expected and g.lstg.var.is_practice is False
  g.stage.group.Start('Other');assert g.originalGroup=='Other'
  g._init_item(lua.table_from({'name':expected}));assert g.initializedWithPractice is True and g.lstg.var.is_practice is False
  g._init_item(lua.table_from({'name':'Stage Two@Normal'}));assert g.initializedWithPractice is False
 print(backend+': all15 startpoint routes / normal continuation flag / restart PASS')
