"""Focused source/schedule contract for NINA6-01 TH08 import."""
from pathlib import Path
import json, hashlib
from lupa import LuaRuntime

ROOT=Path(r'G:/MySTG')
MOD=ROOT/'aex-0.8.22/game/mod/NinaStage6Normal/import08'
# Validate against this mod's checked-in original-script evidence, rather than
# an unrelated extracted archive variant.
SRC=ROOT/'aex-0.8.22/game/mod/NinaStage6Normal/source'

def load(lua, name):
    lua.execute((MOD/name).read_text(encoding='utf-8'))

lua=LuaRuntime(unpack_returned_tuples=True)
load(lua,'specs.lua');load(lua,'art.lua');load(lua,'runtime.lua')
g=lua.globals(); specs=g.Nina08Specs; R=g.Nina08Runtime
assert specs.non4.entry=='ecldata6/Sub17' and specs.non4.hp==34200 and specs.non4.frames==2100
assert specs.final.entry=='ecldata7sp/Sub61' and specs.final.hp==7500 and specs.final.frames==5400
assert g.Nina08Art.actor.frog.sprite==30 and 'stg7enm2.png' in g.Nina08Art.actor.frog.source

e=(SRC/'th08-ecldata6.txt').read_text(encoding='utf-8')
k=(SRC/'th08-ecldata7sp.txt').read_text(encoding='utf-8')
for s in ('sub Sub17()', 'lifeSet(13000)', 'timerThreshold(2100', 'lifeThreshold(0, 1600', 'iset($I4, 16)', 'fset(%F2, 0.3926991f)', 'sub Sub20()', 'iset($I4, 10)'):
    assert s in e, s
for s in ('sub Sub61()', 'spell(0, 168', 'timerThreshold(5400', 'sub Sub62()', 'flagSet(16)', 'flagSet(3)', 'flagClear(3)', 'etEx(0, 2048, 0, 0, -1, -999.9f, 0.0f)', 'etEx(1, 128, 0, 1, 1, 0.0f, -999.9f)', 'etEx(2, 16384, 0, 2, $I0, -1.0f, -1.0f)', 'iset($I7, 32)', 'etRingAimed(2, $I0, $I7', 'wait(360)', 'iadd($I7, 2)', 'ins_5(120, Sub62_696, $I4)', 'sub Sub63()', 'iset($I6, 10)'):
    assert s in k, s

R.start(specs.non4,37)
for _ in range(150): R.step(0,384,11400)
assert len(R.actors)==16, len(R.actors)
assert len(R.hazards)>0, len(R.hazards)
R.start(specs.final,37)
assert len(R.actors)==0, len(R.actors)
for _ in range(111): R.step(0,384,7500)
assert len(R.actors)==7, len(R.actors)
for i in range(1,len(R.actors)+1):
    a=R.actors[i]
    assert a.immortal and a.flags==19, (a.immortal,a.flags)
for _ in range(150): R.step(0,384,7500)
assert len(R.hazards)==7*32, len(R.hazards)
for i in range(1,len(R.actors)+1):
    a=R.actors[i]
    assert a.immortal and a.flags==16, (a.immortal,a.flags)
for i in range(1,len(R.hazards)+1):
    b=R.hazards[i]
    assert b.bounceExceptBottom and b.bounceLimit==1, (b.bounceExceptBottom,b.bounceLimit)
# Exercise a single source-ring bullet over a side boundary: exactly one
# reflection, retained speed, and no bottom reflection.
b=R.hazards[1]; b.x=191.8; b.y=224; b.angle=0; b.speed=1.2; b.bounces=0
R.stepHazards()
assert b.bounces==1 and b.angle < -3.0, (b.bounces,b.angle)
b.x=0; b.y=447.8; b.angle=1.57079632679; b.bounces=0
R.stepHazards()
assert b.bounces==0 and b.angle > 1.5, (b.bounces,b.angle)
# The source has I4=1: one 32-way ring then one 34-way ring after wait(360).
for _ in range(330): R.step(0,384,7500)
for i in range(1,len(R.actors)+1):
    a=R.actors[i]
    assert a.data.cycles==2 and a.data.ring==36, (a.data.cycles,a.data.ring)
for _ in range(150): R.step(0,384,7500)
colors={}
for i in range(1,len(R.hazards)+1): colors[R.hazards[i].color]=1
assert all(c in colors for c in (2,4,6,8,10,13,14)), colors
R.clearHazards();assert len(R.hazards)==0 and len(R.actors)==0

out={'status':'PASS','files':sorted(p.name for p in MOD.glob('*.lua')),'source_sha256':{'ecldata6':hashlib.sha256(e.encode()).hexdigest(),'ecldata7sp':hashlib.sha256(k.encode()).hexdigest()},'checks':['specs','source markers','eirin schedule','seven frog emitters','source familiar flags 19 to 16','normal aimed rings','one bounce except bottom','32 then 34 source rings','rainbow rings','cleanup']}
print(json.dumps(out,ensure_ascii=False,indent=2))
