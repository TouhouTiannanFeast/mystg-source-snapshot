from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime

mods=Path('G:/MySTG/aex-0.8.22/game/mod')
road=mods/'Le03Stage4Normal'; bossmod=mods/'YuyukoStage3'
l=LuaRuntime(unpack_returned_tuples=True)
for p in [road/'runtime.lua',road/'host.lua',road/'enemy-art.lua',bossmod/'root.lua']:
    l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
for name in ['constants','movement','bullet-style','firing','enemy-health','runtime','schedule']:
    l.execute((road/(name+'.lua')).read_text('utf-8-sig'))
l.execute('R=Le03; rewards={};R.onReward=function(k,e)rewards[#rewards+1]=k end')
frames=sorted({r[1] for _,r in l.globals().Le03Schedule.items()})
assert frames[29]==4700
l.execute('''
R.start(42)
local target
for _,e in ipairs(R.enemies)do if e.appear==4700 then target=e end end
assert(target);target.active=true;target.invincible=0
R.damageEnemy(target,target.hp);R.damageEnemy(target,10000)
assert(#rewards==1 and rewards[1]=='life')
R.start(42);rewards={}
for _,e in ipairs(R.enemies)do if e.appear==4700 then target=e end end
target.active=true
local original=Le03Movement.step
Le03Movement.step=function(e) e.active=false end
R.step(192,400);R.step(192,400)
Le03Movement.step=original
assert(#rewards==1 and rewards[1]=='life')
R.start(42);rewards={};R.tick=R.spawnTick(4700)+100
for i,e in ipairs(R.enemies)do if e.spawnTick<R.tick then R.spawned[i]=true end end
R.step(192,400);assert(#rewards==0)
''')
print('PASS wave30=source4700: defeat and natural exit each one life; repeated damage/steps and skipped checkpoint no extra reward')
l.execute('LoadTexture=function()end;LoadImage=function()end')
l.execute((road/'enemy-art.lua').read_text('utf-8-sig'))
entry=l.globals().Le03EnemyArt.entry
for age,expected in [(0,(0,.4)),(10,(127,.7)),(20,(255,1)),(40,(255,1))]:
    alpha,scale=entry(l.table_from(dict(opening=True,age=age)))
    assert alpha==expected[0] and abs(scale-expected[1])<1e-9
assert entry(l.table_from(dict(age=0)))==(255,1)
print('PASS opening-only20-frame appearance: alpha/scale at start, midpoint and completion; ordinary fairies unchanged')
root=(bossmod/'root.lua').read_text('utf-8-sig')
card=root[root.index('local function card(id)'):root.index('local Damage=Class(boss)')]
l.execute('''
R={specs={},counts={shots=0,lasers=0},tick=100};S={ended=0,damage=0,owned={}};setting={}
clean=function()end;item_extend={};boss={card={New=function()return {}end}}
New=function(kind,x,y)assert(kind==item_extend);lifeCount=lifeCount+1 end
''')
make=l.execute(card+'\nreturn card')
for phase in ['spell2','spell1','non2']:
    l.globals().R.specs[phase]=l.table_from(dict(name=phase,time=50,hp=10000))
    for hp,timeout in [(0,False),(0,True),(100,True),(100,False)]:
        l.globals().lifeCount=0
        c=make(phase);o=l.table_from(dict(hp=hp,timeout=timeout,x=0,y=100))
        c['del'](o);c['del'](o)
        assert l.globals().lifeCount==int(phase=='spell2' and (hp<=0 or timeout))
print('PASS actual Boss card callback: spell2 defeat/timeout one life, no reward on other cards or unfinished cleanup; Lua51 syntax')
