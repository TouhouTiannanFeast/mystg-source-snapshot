"""Compile Lua, exercise geometry/transforms, and preserve exact source identities."""
from pathlib import Path
import hashlib
import importlib
import json
import math
ROOT=Path(__file__).resolve().parents[2]
MOD=ROOT/'aex-0.8.22/game/mod/TH14Stage1Normal'
SOURCE=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th14_local-original-archive-candidate_57d84a5cbe82/raw')
LOG=ROOT/'work/logs/th14-stage1'
LOG.mkdir(parents=True,exist_ok=True)
results=[]
for backend in ('lua51','luajit21','lua54'):
    lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
    compiler=lua.eval('function(s,n) local f,e=(loadstring or load)(s,n); assert(f,e); return true end')
    for path in MOD.glob('*.lua'): compiler(path.read_text(encoding='utf-8'),'@'+str(path))
    g=lua.execute((MOD/'geometry.lua').read_text(encoding='utf-8'))
    assert g.position(0,128)==(0,96)
    assert g.position(-192,-16)==(-192,240)
    assert math.isclose(g.angle(math.pi/2),-90)
    assert list(g.fan(-90,2,45).values())==[-112.5,-67.5]
    assert list(g.ring(0,2).values())==[0,180]
    assert list(g.ring(30,16).values())[-1]==367.5
    assert g.speed(1.2,1,1,3)==1.2 and g.speed(1.2,1,3,3)==1
    assert g.motion(0.4,-90,59,60,60,0.8/60,0)==(0.4,-90)
    speed=0.4
    for age in range(120): speed,angle=g.motion(speed,-90,age,60,60,0.8/60,0)
    assert math.isclose(speed,1.2,abs_tol=1e-12)
    assert g.motion(speed,-90,120,60,60,0.8/60,0)==(speed,-90)
    movement=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
    movement.globals().package.path=str(MOD/'?.lua').replace('\\','/')+';'+movement.globals().package.path
    movement.execute((ROOT/'scripts/th14-stage1/movement-harness.lua').read_text(encoding='utf-8'))
    movement.execute((MOD/'host.lua').read_text(encoding='utf-8'))
    movement.execute((MOD/'enemies.lua').read_text(encoding='utf-8'))
    left_angle,left_speed=movement.globals().test_c(False,-224)
    right_angle,right_speed=movement.globals().test_c(False,224)
    mirrored_angle,mirrored_speed=movement.globals().test_c(True,224)
    assert math.isclose(left_angle,-160,abs_tol=0.01)
    assert math.isclose(right_angle,180-left_angle,abs_tol=0.01)
    assert right_angle==mirrored_angle
    assert left_speed==right_speed==mirrored_speed==1.4
    lua.globals().print=lambda *args: None
    lua.execute((ROOT/'scripts/th14-stage1/schedule-harness.lua').read_text(encoding='utf-8'))
    lua.execute((MOD/'stage.lua').read_text(encoding='utf-8'))
    events,bosses=lua.globals().th14.run()
    records=[dict(e.items()) for e in events.values()]
    # Independently read timings/counts from the pinned MainSub00/MainFront/main
    # source: 32 initial fairies; midboss at 60+480+400+60+230+300+240+480+170.
    assert len(records)==186
    assert records[0]['frame']==60 and records[0]['x']==-192
    assert any(e['frame']==180 and e['x']==192 for e in records)
    assert bosses[1]['frame']==2420
    assert [e['frame'] for e in records if e['kind']=='GirlC01']==[1230,1350]
    assert len([e for e in records if e['kind']=='Phantom02'])==46
    assert len([e for e in records if e['kind']=='GirlD01'])==4
    results.append({'backend':backend,'syntax_files':len(list(MOD.glob('*.lua'))),'geometry_and_transform_checks':10,'actual_movement_channel_checks':4,'actual_stage_schedule_checks':7,'scheduled_enemies':len(records),'passed':True})
sources={}
for name in ('st01','st01mbs','st01bs'):
    for suffix in ('.ecl','.named.utf8.txt'):
        path=SOURCE/(name+suffix)
        sources[path.name]={'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size}
manifest=json.loads((SOURCE.parents[1]/'manifest.json').read_text(encoding='utf-8'))
archive=next(a for a in manifest['archives'] if a['game']==14)
data={'schema':'th14-stage1-reference/0.1','difficulty':'Normal','sources':sources,'archive':archive,
      'scope':'independent behavioral reconstruction','original_assets_copied':False,
      'native_behavior_parity_verified':False,'native_collision_parity_verified':False,
      'approximations':['THlib sprites and spawn appearance','movement interpolation','Phantom ellipse motion','THlib damage/player/scoring','midboss step transform timing']}
(MOD/'provenance.json').write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
(LOG/'static-results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
print(json.dumps(results,indent=2))
