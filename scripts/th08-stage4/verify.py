"""Bounded source, syntax and actual THlib laser collision regression checks."""
from pathlib import Path
import hashlib
import importlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MOD = ROOT / 'aex-0.8.22/game/mod/MySTG'
CONTENT = MOD / 'stages/th08_stage4'
LOG = ROOT / 'work/logs/th08-stage4'
LOG.mkdir(parents=True, exist_ok=True)
reference = json.loads((CONTENT / 'reference.json').read_text(encoding='utf-8'))
for source in reference['sources'].values():
    assert hashlib.sha256(Path(source['path']).read_bytes()).hexdigest() == source['sha256']
laser_source = (ROOT / 'aex-0.8.22/game/packages/thlib-scripts/THlib/laser/laser.lua').read_text(encoding='utf-8-sig')
laser_core = laser_source[laser_source.index('function laser:init'):laser_source.index('function laser:render')]
laser_switch = laser_source[laser_source.index('function laser:TurnOn'):laser_source.index('laser_death_ef =')]
results = []
for backend in ('lua51', 'luajit21', 'lua54'):
    lua = importlib.import_module('lupa.' + backend).LuaRuntime()
    lua.execute('loadstring=loadstring or load')
    files = [MOD / 'root.lua', *CONTENT.glob('*.lua')]
    for f in files:
        lua.execute('assert(loadstring(...))', f.read_text(encoding='utf-8-sig'))
    lua.execute((CONTENT / 'schedule.lua').read_text(encoding='utf-8'))
    schedule = lua.globals().th08_schedule
    assert len(schedule) == 247
    rows = []
    for i in range(1, len(schedule)+1):
        e = schedule[i]
        rows.append(dict(frame=e.at, kind=e.kind, x=e.x, y=e.y, hp=e.hp, mirror=e.mirror, drop=e.drop))
    assert rows == [{k:e[k] for k in rows[0]} for e in reference['events']]
    assert sum(e['kind'] in ('Sub0','Sub3','Sub5','Sub7','Sub12') for e in rows) == 241
    assert next(e['frame'] for e in rows if e['kind']=='Sub16') == 4962
    assert next(e['frame'] for e in rows if e['kind']=='Sub27') == 6923
    assert reference['resumes'] == [1600,2000,5423,5783]
    lua.execute('''
        object={}; enemy={}; bullet={init=function() end,skip_fade_in=function() end}; laser={}
        Class=function() return {} end
        max=math.max; min=math.min; int=math.floor; abs=math.abs
        cos=function(a) return math.cos(a*math.pi/180) end
        sin=function(a) return math.sin(a*math.pi/180) end
        task={Do=function() end}; GROUP_INDES=1; LAYER_ENEMY_BULLET=1
        IsValid=function(o) return o and not o.dead end
        Del=function(o) o.dead=true end
        hits={}; player={x=100,y=0,class={colli=function(p,b) hits[#hits+1]=b.timer end},
            grazer={class={colli=function() end}}}
    ''')
    lua.execute(laser_core + laser_switch)
    lua.execute((CONTENT / 'host.lua').read_text(encoding='utf-8'))
    checks = lua.execute('''
        local T=th08s4
        local x,y=T.xy(192,224); assert(x==0 and y==0)
        assert(math.abs(T.rad(math.pi/2)+90)<1e-9)
        local b={timer=0}; T.Beam.init(b,nil,0,0,0,650,180,6,120,190,60,0)
        for t=0,370 do b.timer=t; T.Beam.frame(b) end
        assert(#hits==180 and hits[1]==130 and hits[#hits]==309)
        assert(b.dead and not b.colli)
        hits={}; player.y=100
        local miss={timer=0}; T.Beam.init(miss,nil,0,0,0,650,180,6,120,190,60,0)
        for t=0,370 do miss.timer=t; T.Beam.frame(miss) end
        assert(#hits==0,'outside-width player was hit')
        player.x=100; player.y=0; hits={}
        local vertical={timer=0}; T.Beam.init(vertical,nil,0,0,90,650,180,6,120,190,60,0)
        for t=0,370 do vertical.timer=t; T.Beam.frame(vertical) end
        assert(#hits==0,'rotated-beam collision used unrotated geometry')
        local p={}; T.Bullet.init(p,0,0,0,0,12,1,{duration=60,ax=1/60,ay=0},true)
        for i=1,60 do T.Bullet.frame(p) end
        assert(math.abs(p.vx-1)<1e-9 and p.vy==0)
        T.Bullet.frame(p); assert(math.abs(p.vx-1)<1e-9)
        local q={}; T.Bullet.init(q,0,0,1,0,12,1,{wait=10,duration=20,accel=0.1},true)
        for i=1,10 do T.Bullet.frame(q) end; assert(q.speed==1)
        for i=1,20 do T.Bullet.frame(q) end; assert(math.abs(q.speed-3)<1e-9)
        T.Bullet.frame(q); assert(math.abs(q.speed-3)<1e-9)
        return 12
    ''')
    results.append(dict(backend=backend, syntax_files=len(files), checks=checks, source_events=len(rows), enemies=241))
    print(f'{backend}: syntax/source/coordinate/movement/native laser geometry PASS ({checks} checks)')
(LOG / 'static-results.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
