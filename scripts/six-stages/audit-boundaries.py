from pathlib import Path
import re,sys,json
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG/aex-0.8.22/game')
OUT=Path('G:/MySTG/work/logs/six-stages/revision')
l=LuaRuntime()
l.execute('''bullet={};BulletBreak={};breaks=0
lstg={world={boundl=-224,boundr=224,boundb=-256,boundt=256}}
function BoxCheck(o,a,b,c,d)return o.x>=a and o.x<=b and o.y>=c and o.y<=d end
function New(c)if c==BulletBreak then breaks=breaks+1 end end''')
source=(ROOT/'packages/thlib-scripts/THlib/bullet/bullet.lua').read_text(encoding='utf-8-sig')
a=source.index('function bullet:del()');b=source.index('function bullet:render()',a)
l.execute(source[a:b])
cases=[
 ('stage1','Stage12Normal/stage1/host.lua','T.Bullet','local T={owned={},Bullet={}}',257,0,None,0),
 ('stage2 road','Stage12Normal/route.lua','Shot','local R={owned={}};local Shot={}',271,0,None,0),
 ('stage2 Mystia','Stage12Normal/mystia/attack.lua','Shot','local D={owned={}};local Shot={}',225,0,None,0),
 ('stage2 Mamizou','Stage12Normal/mamizou/attack.lua','Shot','local D={owned={}};local Shot={}',241,0,None,0),
 ('stage3 road stale coordinate','Le03Stage4Normal/host.lua','Shot','local owned={};local Shot={}',-220,0,None,1),
 ('stage3 Boss stale coordinate','YuyukoStage3/root.lua','Shot','local S={owned={}};local Shot={}',-220,0,None,1),
 ('stage4 Marisa','MarisaMixed/visual.lua','Shot','local V={owned={}};local Shot={}',-220,0,None,0),
 ('stage4 road','MarisaMixed/road/host.lua','Shot','local H={owned={}};local Shot={}',-220,0,True,0),
 ('stage5 road','HSoBStage5Normal/host.lua','Shot','local R={owned={}};local Shot={}',-220,0,None,0),
 ('stage5 Horou','HSoBStage5Normal/stages/zuu4/host.lua','Shot','local S={owned={}};local Shot={}',-220,0,None,0),
 ('stage6 Boss','NinaStage6Normal/root.lua','Shot','local S={owned={}};local Shot={}',-220,0,True,0),
]
rows=[]
for label,path,cls,pre,x,y,off,expected in cases:
    s=(ROOT/'mod'/path).read_text(encoding='utf-8-sig')
    match=re.search(r'function '+re.escape(cls)+r':del\(\)[^\r\n]*',s)
    assert match,(path,cls)
    # All selected del callbacks are one-line source functions.
    l.execute(pre+chr(10)+match[0]+chr(10)+'AuditDelete='+cls+'.del')
    o=l.table_from({'x':x,'y':y,'_index':1,'imgclass':l.table_from({'size':1}),
                    'data':l.table_from({'x':-70,'y':224,'active':False,'dead':True,'offscreenRemoval':off})})
    l.globals().breaks=0;l.globals().AuditDelete(o)
    n=l.globals().breaks;assert n==expected,(label,n,expected)
    rows.append({'path':path,'callback_line':s[:match.start()].count(chr(10))+1,'case':label,'break_effects':n,
                 'limitation':'Stage3 case constructs an already-outside model with an in-bound previous host position; it proves a callback risk, not occurrence at ordinary projectile speeds.' if expected else 'Scoped boundary callback check; not a full manual playthrough.'})
    print(label,'BreakFX=',n)
# Sixth road uses its own native Cancel object, with the same explicit guard.
s=(ROOT/'mod/NinaStage6Normal/road17/host.lua').read_text(encoding='utf8')
assert 'if not H.cleaning and not b.offscreenRemoval then New(Cancel,b)end'in s
assert 'b.dead=true;b.offscreenRemoval=true'in(ROOT/'mod/NinaStage6Normal/road17/projectiles.lua').read_text(encoding='utf8')
print('stage6 road: explicit offscreenRemoval guard PASS')
(OUT/'boundary-callbacks.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf8')
