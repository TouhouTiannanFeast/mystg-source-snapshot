from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG');MOD=ROOT/'aex-0.8.22/game/mod/MySTG'
l=LuaRuntime(unpack_returned_tuples=True)
for p in (MOD/'systems/th18-fire').glob('*.lua'):
    l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
l.execute('stage={current_stage={timer=0}};lstg={var={power=400}};function IsValid(e)return e~=nil end;function Damage(e,n)e.hp=e.hp-n end;function Angle(a,b)return math.deg(math.atan2(b.y-a.y,b.x-a.x))end')
for name in ['data','core']:
    l.execute((MOD/f'systems/th18-fire/{name}.lua').read_text(encoding='utf-8'))
assert l.globals().Th18FireData.sha256==hashlib.sha256((ROOT/'work/resources14/sht/pl00.sht').read_bytes()).hexdigest()
l.execute('''
local F=Th18Fire
for _,slow in ipairs({false,true})do
 local p={fireShort=-1,fireLong=-1};local count,total=0,0
 for i=1,120 do F.start(p);F.rows(p,slow,function(r)count=count+1;total=total+r.damage end);F.advance(p,true)end
 assert(count==(slow and 400 or 152));assert(total==(slow and 3520 or 2560))
end
local p={fireShort=-1,fireLong=-1};F.start(p);F.advance(p,false)
for i=1,14 do F.advance(p,false)end
assert(p.fireShort==-1 and p.fireLong==15)
local e={hp=1000};assert(F.damage(e,70)==70);assert(F.damage(e,70)==20);assert(e.hp==910)
stage.current_stage.timer=1;e.protect=true;assert(F.damage(e,70)==0)
e.protect=false;assert(F.damage(e,14)==14)
local b={x=0,y=0,heading=0,speed=4,timer=0};F.home(b,{x=0,y=100});assert(b.heading==7.2 and b.speed==4)
b.timer=60;F.home(b,{x=0,y=100});assert(b.heading==7.2 and b.speed==4.2)
''')
l.execute((MOD/'stages/suwako5/pool.lua').read_text(encoding='utf-8'))
p=l.globals().Suwako5Pool
expected={1:2800,2:3600,3:2800,4:3600,5:3500,6:3500,8:10000,9:10000,10:10000}
catalog=json.loads((ROOT/'scripts/suwako5/practice-catalog.json').read_text(encoding='utf-8-sig'))
for row in catalog:
    phase=p.find(row['id']);assert phase.hp==row['hp'] and phase.frames==1800 and row['seconds']==30
    if row['id'].startswith('th10-card'):assert phase.hp==expected[int(row['id'][9:])]
    elif row['id'].startswith('th10-non'):assert phase.hp==8000
    else:assert phase.hp==({'th125-a':1000,'th125-b':1000,'th125-c':1000,'th125-d':1000,'th143-0902':320,'th143-0906':190}[row['id']])
route=(MOD/'stages/th18_stage5/route.lua').read_text(encoding='utf-8')
assert 'ordinaryHPScale' not in route and 'child.hp=v[4];' in route
print('PASS source SHT hash; high/low 120-frame count and damage; release timers; 90/frame cap; protection; homing; TH10 HP/catalog and unchanged30s/DS/ISC; original ordinary HP')
