from pathlib import Path
import importlib,json,math,hashlib
root=Path('G:/MySTG');mod=root/'aex-0.8.22/game/mod/MomijiNon1';log=root/'work/logs/momiji-non1'
gun=(mod/'source/th143-day6-scene5.txt').read_text(encoding='utf-8')
echo=(mod/'source/th13-stage2-boss.txt').read_text(encoding='utf-8')
assert 'etAngle(15, %ANGLE_PLAYER + (%RANDF2 * 0.5235988f), 0.5235988f);' in gun
assert 'etCount(15, 8, 1);' in gun and 'wait(20);' in gun
assert 'etCountD(0, 24, 36, 72, 72, 1, 1, 1, 1);' in echo
results=[]
for backend in ('luajit21','lua51','lua54'):
    lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
    for path in mod.glob('*.lua'):
        out=lua.eval('loadstring or load')(path.read_text(encoding='utf-8'),'@'+str(path))
        assert not isinstance(out,tuple) or out[0],out
    lua.execute((mod/'pattern.lua').read_text())
    p=lua.globals().MomijiPattern
    waves=[];guns=0
    for t in range(3600):
        for e in p.events(t).values():
            if e.kind=='gun':guns+=8
            else:waves.append((t,e.wave,e.round))
    expected=[(60+r*422+w*60,w+1,r+1) for r in range(9) for w in range(3) if 60+r*422+w*60<3600]
    assert waves==expected and guns==1416
    for aim in (-179,-90,0,45,179):
        for kind,count,space in [('gun',8,30),('scale',72,3.5)]:
            angles,center=p.angles(kind,aim,0)
            vals=list(angles.values());assert len(vals)==count
            assert abs((vals[0]+vals[-1])/2-center)<1e-8
            assert all(abs(b-a-space)<1e-8 for a,b in zip(vals,vals[1:]))
            assert center==aim+(180 if kind=='scale' else 0)
    centers=[p.angles('scale',a,0)[1] for a in (-100,-90,-80)]
    assert centers==[80,90,100]
    assert 'P.reflect' not in (mod/'root.lua').read_text()
    results.append({'backend':backend,'gun':guns,'scale':len(waves)*72,'rounds':9,'waves':len(waves),'passed':True})
manifest={str(p.relative_to(mod)):hashlib.sha256(p.read_bytes()).hexdigest() for p in (mod/'source').glob('*.txt')}
(log/'static-result.json').write_text(json.dumps({'results':results,'sources':manifest},indent=2))
print('PASS: three Lua backends, source constants, full schedule, fan symmetry, independently updated reverse aim; no reflection.')
