"""Focused check for the stage-3 boundary fix (SIX-STAGE-BOUNDARY-FIX-20261107).

Two model culls must mark b.offscreenRemoval, and the two Shot:del callbacks
must skip framework bullet.del only for that marker. Ordinary Del (cancel)
keeps the original BulletBreak behavior.

Lua 5.1 only; no engine run.
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, 'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime

ROOT = Path('G:/MySTG/aex-0.8.22/game')
OUT = Path('G:/MySTG/work/logs/six-stages/revision')
l = LuaRuntime()
l.execute('''bullet={};BulletBreak={};breaks=0
lstg={world={boundl=-224,boundr=224,boundb=-256,boundt=256}}
function BoxCheck(o,a,b,c,d)return o.x>=a and o.x<=b and o.y>=c and o.y<=d end
function New(c)if c==BulletBreak then breaks=breaks+1 end end''')
source = (ROOT / 'packages/thlib-scripts/THlib/bullet/bullet.lua').read_text(encoding='utf-8-sig')
a = source.index('function bullet:del()')
b = source.index('function bullet:render()', a)
l.execute(source[a:b])

loadstring = l.eval('loadstring')


def read(path):
    return (ROOT / 'mod' / path).read_text(encoding='utf-8-sig')


def check_syntax(path):
    result = loadstring(read(path))
    if isinstance(result, tuple):
        fn, err = result
        assert fn is not None, (path, err)
    else:
        assert result is not None, path
    print('syntax PASS', path)


def del_callback(path, pre, host_x, off, expected):
    s = read(path)
    match = re.search(r'function Shot:del\(\)[^\r\n]*', s)
    assert match, path
    l.execute(pre + chr(10) + match[0] + chr(10) + 'AuditDelete=Shot.del')
    o = l.table_from({'x': host_x, 'y': 0, '_index': 1,
                      'imgclass': l.table_from({'size': 1}),
                      'data': l.table_from({'active': False, 'dead': True,
                                            'offscreenRemoval': off})})
    l.globals().breaks = 0
    l.globals().AuditDelete(o)
    n = l.globals().breaks
    assert n == expected, (path, off, n, expected)
    print('del PASS', path, 'offscreenRemoval=%s' % off, 'break=%d' % n)


# 1. Model culls actually set the marker.
road = read('Le03Stage4Normal/runtime.lua')
road_cull = re.search(
    r'if b\.age>=b\.cullDelay and not bulletInside\(b\)then b\.offscreenRemoval=true;b\.active=false end', road)
assert road_cull, 'road cull marker missing'
l.execute('function bulletInside(b)return false end')
l.execute('b={age=1,cullDelay=0,active=true};' + road_cull.group(0))
assert l.globals().b.offscreenRemoval is True and l.globals().b.active is False
l.execute('function bulletInside(b)return true end')
l.execute('b={age=1,cullDelay=0,active=true};' + road_cull.group(0))
assert l.globals().b.offscreenRemoval is None and l.globals().b.active is True
print('cull PASS Le03Stage4Normal/runtime.lua inside/outside')

y3 = read('YuyukoStage3/runtime.lua')
y3_lines = y3.splitlines()
out_line = next(i for i, s in enumerate(y3_lines) if 'local out=b.age>b.cullDelay' in s)
cull_chunk = y3_lines[out_line] + chr(10) + y3_lines[out_line + 1]
assert 'b.offscreenRemoval=true' in cull_chunk
l.execute('b={age=1,cullDelay=0,x=-65,y=0,alpha=255};' + cull_chunk)
assert l.globals().b.dead is True and l.globals().b.offscreenRemoval is True
l.execute('b={age=1,cullDelay=0,x=0,y=0,alpha=0};' + cull_chunk)
assert l.globals().b.dead is True and l.globals().b.offscreenRemoval is None
l.execute('b={age=1,cullDelay=0,x=0,y=0,alpha=255};' + cull_chunk)
assert l.globals().b.dead is None and l.globals().b.offscreenRemoval is None
print('cull PASS YuyukoStage3/runtime.lua outside/alpha/inside')

# 2. Boundary deletion skips BulletBreak; ordinary Del keeps it.
del_callback('Le03Stage4Normal/host.lua', 'local owned={};local Shot={}', -220, True, 0)
del_callback('Le03Stage4Normal/host.lua', 'local owned={};local Shot={}', -220, None, 1)
del_callback('YuyukoStage3/root.lua', 'local S={owned={}};local Shot={}', -220, True, 0)
del_callback('YuyukoStage3/root.lua', 'local S={owned={}};local Shot={}', -220, None, 1)

# 3. All four edited files still compile under Lua 5.1.
for path in ('Le03Stage4Normal/runtime.lua', 'Le03Stage4Normal/host.lua',
             'YuyukoStage3/runtime.lua', 'YuyukoStage3/root.lua'):
    check_syntax(path)

print('BOUNDARY GUARD PASS')
