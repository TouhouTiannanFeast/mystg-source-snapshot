from pathlib import Path
import importlib,json,hashlib,math
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';results=[]
ref=json.loads((M/'source/background/stage2-th16-reference.json').read_text(encoding='utf-8'))
def plain(t):
 if not hasattr(t,'items'):return t
 d={k:plain(v)for k,v in t.items()};return [d[k]for k in range(1,len(d)+1)]if d and set(d)==set(range(1,len(d)+1))else d
for backend in ('luajit21','lua51','lua54'):
 l=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 l.globals().Stage2FileExists=lambda p:(M/p).is_file()
 l.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 l.execute((M/'player-config.lua').read_text(encoding='utf-8'))
 l.execute((M/'route.lua').read_text(encoding='utf-8'))
 l.execute((M/'schedule.lua').read_text(encoding='utf-8'))
 rows=[]
 for e in l.globals().Stage2Schedule.values():
  if e['name']=='Girl01':
   enemy=l.globals().Stage2Route.spawn(e)
   expected=math.ceil(e['hp']*3/28)/2;assert enemy.hp==expected
   rows.append({'source_tick':e['t'],'source_hp':e['hp'],'old_hp':math.ceil(e['hp']/4),'hp':enemy.hp})
 assert len(rows)==14 and sum(e['hp']==21.5 for e in rows)==8 and sum(e['hp']==16.5 for e in rows)==6
 # Other enemy constructors retain their existing scaling.
 for name,hp in [('BGirl00',60),('BGirl00B',30)]:
  e=l.table_from({'name':name,'hp':hp,'t':160,'x':0,'y':0});assert l.globals().Stage2Route.spawn(e).hp==math.ceil(hp/4)
 l.execute((M/'background-data.lua').read_text(encoding='utf-8'));scenes=plain(l.globals().Stage12BackgroundData)
 assert hashlib.sha256(json.dumps(scenes[0],sort_keys=True).encode()).hexdigest()==ref['stage1_data_hash']
 assert len(scenes[1]['meshes'])==36 and all('stage2-th16' in p for p in scenes[1]['textures'].values())
 for path in scenes[1]['textures'].values():assert (M/path).is_file()
 results.append({'backend':backend,'sunflowers':rows,'current_damage_ratio':3/28,'other_enemy_hp_preserved':True,'stage1_background_preserved':True,'stage2_th16_meshes':36})
 print(backend+': actual14sunflowers 43/33->21.5/16.5; otherHP/stage1 preserved; TH16 scene36meshes PASS')
(R/'work/logs/stage12/flow-context/sunflower.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
