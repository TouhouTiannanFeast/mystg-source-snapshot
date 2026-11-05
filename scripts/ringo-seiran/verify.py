from pathlib import Path
import hashlib, json, sys
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime

ROOT=Path('G:/MySTG');MOD=ROOT/'aex-0.8.22/game/mod/RingoSeiran'
LOG=ROOT/'work/logs/ringo-seiran'
lua=LuaRuntime(unpack_returned_tuples=True)
for p in MOD.glob('*.lua'):
    compiled=lua.eval('loadstring')(p.read_text(encoding='utf-8'),'@'+str(p))
    assert not isinstance(compiled,tuple) or compiled[0], compiled
lua.execute((MOD/'pattern.lua').read_text(encoding='utf-8'))
lua.execute('''
local P=RingoSeiranPattern
local function close(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' != '..tostring(b))end
assert(P.specs.nonspell.name=='' and P.specs.nonspell.time==30 and P.specs.nonspell.hp==10000)
assert(P.specs.spell.time==70 and P.specs.spell.hp==8000)
assert(P.specs.spell.name=='西八「打你就像打蚂蚁」')
-- Execute source cadence: four complete450f flower cycles, seven bursts each.
local w=P.new('nonspell',function()return 0.5 end)
local events={};w.onShot=function(b)if b.kind=='red' then events[w.t]=(events[w.t]or 0)+1 end end
for t=0,1799 do P.step(w,0,374);assert(not w.seiran)end
assert(w.stats.triples==1440 and w.stats.dango==4320 and w.stats.gun==0)
for k=0,3 do
 assert(events[k*450+30]==24 and events[k*450+70]==36)
 for j=0,4 do assert(events[k*450+200+j*30]==60)end
end
local n=0;for _ in pairs(events)do n=n+1 end;assert(n==28)
-- ec_0204: 100 random triples at4f, then two40-triple fans at2f.
w=P.new('spell',function()return 0.5 end);events={}
w.onShot=function(b)if b.kind=='red' then events[w.t]=(events[w.t]or 0)+1 end end
for t=0,629 do P.step(w,20,374)end
assert(w.stats.triples==180 and w.stats.dango==540)
for t=0,396,4 do assert(events[t]==1)end
for t=430,588,2 do assert(events[t]==1)end
for t=400,429 do assert(not events[t])end
for t=590,629 do assert(not events[t])end
-- Actual velocity-add plus polar rotation. No accumulated forward acceleration.
w=P.new('nonspell');P.triple(w,0,1.4,1)
local blue,red,pink=w.bullets[1],w.bullets[2],w.bullets[3]
close(blue.x,-12.8);close(red.x,0);close(pink.x,12.8)
close(blue.speed,0.32);close(blue.turn,math.pi/96)
P.advance(w)
close(red.x,1.4);close(red.y,128)
close(blue.x,-12.8+1.4+0.32*math.cos(-math.pi/2+math.pi/96))
local r0=red.x
for i=1,95 do P.advance(w)end
close(red.x,134.4);close(red.y,128)
-- One sampled target per120f, never bending toward a later player position.
w=P.new('spell');assert(w.seiran.x<w.x and w.seiran.y==w.y)
w.t=0;w.px,w.py=60,374;P.seiranStep(w)
assert(w.stats.locks==1);close(w.seiran.targetX,90);close(w.seiran.targetY,392)
for t=1,118 do w.t=t;w.px,w.py=-140,400;P.seiranStep(w);assert(w.stats.gun==0)end
close(w.seiran.targetX,90);close(w.seiran.targetY,392)
assert(w.seiran.active)
local emitted={};w.onShot=function(b)if b.kind=='gun' then emitted[#emitted+1]=b end end
w.t=119;P.seiranStep(w)
close(w.seiran.x,90);close(w.seiran.y,392)
close(w.seiran.headX,60);close(w.seiran.headY,374)
assert(w.seiran.sprite==17 and w.seiran.spriteShift==-10)
assert(#emitted==18 and w.stats.gun==18 and w.stats.impacts==1)
for group=0,5 do
 local first=emitted[group*3+1];local cx,cy=0,0
 for corner=1,3 do
  local b=emitted[group*3+corner]
  cx=cx+b.x/3;cy=cy+b.y/3;close(b.speed,2);close(b.angle,first.angle)
  local next=emitted[group*3+corner%3+1]
  close((b.x-next.x)^2+(b.y-next.y)^2,75)
 end
 close(cx,60);close(cy,374)
 if group>0 then close(first.angle-emitted[(group-1)*3+1].angle,math.pi/3)end
end
-- The center of each whole group stays at the former single projectile location.
for tick=1,20 do P.advance(w)end
for group=0,5 do
 local first=emitted[group*3+1];local cx,cy=0,0
 for corner=1,3 do local b=emitted[group*3+corner];cx=cx+b.x/3;cy=cy+b.y/3 end
 close(cx,60+40*math.cos(first.angle));close(cy,374+40*math.sin(first.angle))
end
assert(P.pursuit.bodyA==16 and P.pursuit.bodyB==28 and P.pursuit.shakeTime==10 and P.pursuit.shakeSize==2)
w.t=120;P.seiranStep(w)
assert(w.stats.locks==2 and not w.seiran.active)
close(w.seiran.targetX,-170);close(w.seiran.targetY,418)
-- Source ANM 7f frame times, native14f x-shift, recovery across pursuit boundary.
w=P.new('spell');w.px,w.py=0,374
local expected={[89]=13,[96]=14,[103]=15,[110]=16,[117]=17,[124]=16,[131]=15}
for t=0,131 do
 w.t=t;P.seiranStep(w)
 if expected[t]then assert(w.seiran.sprite==expected[t],tostring(t))end
 if t==102 then assert(w.seiran.spriteShift==0)elseif t==103 then assert(w.seiran.spriteShift==-10)end
end
local dead=emitted[1];P.clear(w)
assert(not w.seiran and #w.bullets==0 and #w.effects==0)
''')
prov=json.loads((MOD/'source/provenance.json').read_text(encoding='utf-8'))
for f in prov['files']:
    assert hashlib.sha256((MOD/f['path']).read_bytes()).hexdigest()==f['sha256'], f['path']
flower=(MOD/'source/ec_0803.named.utf8.txt').read_text(encoding='utf-8')
sisters=(MOD/'source/ec_0204.named.utf8.txt').read_text(encoding='utf-8')
for token in ('$C = 12;', '$D = 18;', '$E = 5;', '$F = 30;', 'etSpeed(0, 0.32f', '0.8f', 'lifeSet(10000)'):
    assert token in flower,token
for token in ('$C = 50;', '$D = 20;', '$E = 20;', 'wait(4)', 'wait(2)', 'lifeSet(8000)', '4200'):
    assert token in sisters,token
result={'lua51':'PASS','source_schedule':'flower1440 triples/30s; sisters180 triples/630f',
        'velocity':'constant drift + rotating polar velocity',
        'pursuit':'120f snapshot, left spawn, sampled endpoint, hammer119/239/359;18 guns in6 rigid equilateral triangles; centroids follow original6 paths',
        'cleanup':'PASS','source_asset_hashes':len(prov['files'])}
host=(MOD/'root.lua').read_text(encoding='utf-8')
assert "b.kind=='gun' and gun_bullet" in host
assert 'function Hammer:render()end' in host and 'hammerLength' not in host
assert 'self.group=GROUP_INDES;self.layer=LAYER_ENEMY;self.colli=true' in host
assert 'misc.ShakeScreen(P.pursuit.shakeTime,P.pursuit.shakeSize)' in host
result['seiran_art']='native ANM13,14,15,16,17,16,15 /7f, original14f x-offset; no custom hammer drawing'
(LOG/'verify.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS',json.dumps(result,ensure_ascii=False))
