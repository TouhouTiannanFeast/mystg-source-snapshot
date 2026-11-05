"""Only the changed scene/player integration; no road resimulation."""
from pathlib import Path
import hashlib,json
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change02'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
bg=json.loads((M/'source/background-selection.json').read_text());pr=json.loads((M/'source/player-reference.json').read_text())
assert sha(Path(bg['source']))==bg['source_sha256'] and sha(Path(bg['anm_source']))==bg['anm_sha256']
for row in bg['textures']:assert sha(M/row['output'])==row['sha256']
for row in pr['files']:
 assert sha(Path(row['source']))==row['source_sha256'] and sha(M/row['output'])==row['output_sha256']
 if row.get('adaptation')=='byte-identical':assert(M/row['output']).read_bytes()==Path(row['source']).read_bytes()
l=LuaRuntime(unpack_returned_tuples=True)
for name in ['root.lua','background.lua','background-assets.lua','player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 l.execute('assert(loadstring(...))',(M/name).read_text(encoding='utf-8'))
h=(Path('G:/Modified_STG/scripts/hsob-stage5/verify-homing.py')).read_text(encoding='utf-8')
h=h.split("l.execute('''",1)[1].split("''')",1)[0]
l.globals().includeFile=lambda f:l.execute((M/f).read_text(encoding='utf-8-sig'))
l.execute(h)
l.execute('hits=0;enemybase.colli=function(self,b)hits=hits+1;self.hp=self.hp-(b.dmg or 0)end')
l.execute((M/'player.lua').read_text(encoding='utf-8'))
l.execute('''
local P=Y3Player
local p={x=0,y=-160,supportx=0,supporty=-160,sp={{-32,0,1},{32,0,1},{-16,32,1},{16,32,1}}}
dps={}
for slow=0,1 do
 p.slow=slow;spawned={}
 for t=0,479 do p.y3FireClock=t%16;P.shoot(p)end
 local damage,homing,piercing=0,0,0
 for _,v in ipairs(spawned)do
  damage=damage+v.data.dmg
  if v.class==P.Homing then homing=homing+1 else if v.data.y3Piercing then piercing=piercing+1 end end
 end
 assert(damage/8==1170,'current reference P4 DPS')
 if slow==0 then assert(homing/8==30 and piercing==0)else assert(homing==0 and piercing>0)end
 dps[slow+1]=damage/8
end
local e1,e2={hp=100,colli=true,x=100,y=100},{hp=100,colli=true,x=0,y=1}
targets[1]={e1};local b={x=0,y=0,heading=90,speed=4,timer=0}
P.Homing.frame(b);assert(b.target==e1);targets[1]={e1,e2};P.Homing.frame(b);assert(b.target==e1)
e1.invalid=true;P.Homing.frame(b);assert(not b.target);P.Homing.frame(b);assert(b.target==e2)
local shot={dmg=10,y3Piercing=true,y3Hits={},killflag=true}
enemybase.colli(e2,shot);enemybase.colli(e2,shot)
local e3={hp=100};enemybase.colli(e3,shot);assert(e2.hp==90 and e3.hp==90 and hits==2,'piercing once per target')
max=math.max;stage={current_stage={stage_name='Subterranean Animism 6@Normal'}}
GetPower=function(n)lstg.var.power=lstg.var.power+n end
item={PlayerMiss=function()error('old miss called')end,frame=function()end}
''')
l.execute((M/'power-lock.lua').read_text(encoding='utf-8'))
l.execute('''
lstg.var.power=100;GetPower(5);assert(lstg.var.power==400)
lstg.var.lifeleft=8;lstg.var.bomb=0;local p={};item.PlayerMiss(p)
assert(lstg.var.power==400 and lstg.var.lifeleft==7 and lstg.var.bomb==3 and p.protect==360)
player_lib.system.frame({player={class=reimu_player}});assert(lstg.var.power==400)
''')
l.execute('background={init=function()end}')
l.execute((M/'background-assets.lua').read_text(encoding='utf-8'))
l.execute((M/'background.lua').read_text(encoding='utf-8'))
l.execute('''
local B=TH11S6Background;local s=B.new();local groups=B.groups();assert(#groups==455)
for t=0,6610 do
 B.step(s)
 if t==200 then assert(s.values.fog[1]==255 and s.values.fog[2]==240 and s.values.fog[3]==207)end
 if t==640 then assert(s.values.pos[2]==512)end
 if t==5556 then assert(s.loops==1 and s.clock==5300 and s.values.pos[2]==128)end
end
assert(s.loops==5 and s.clock>=5300 and s.clock<5556,'source late-loop clock')
assert(#s.leaves<=34 and #s.leaves>30 and s.values.up[2]==1,'Extra leaves / camera-up')
''')
print('PASS copied current reference player/art and original Extra hashes; Lua51 syntax; actual P4 high/slow 1170 DPS,30homing/s,lock/reacquire,pierce once per target,fixed4P/noPowerLoss/miss rules;455quads,source camera/fog and5556 loop through6610,12f/400f leaves. No whole-road test.')
(L/'verification.json').write_text(json.dumps(dict(status='PASS',player_dps=[1170,1170],reference_mod=pr['reference_mod'],background='TH10 Extra stage07',quad_count=455),indent=2))
