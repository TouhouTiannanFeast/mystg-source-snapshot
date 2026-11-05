from pathlib import Path
import sys,json
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
mod=Path('G:/MySTG/aex-0.8.22/game/mod/RingoSeiran')
v=LuaRuntime(unpack_returned_tuples=True)
for p in mod.glob('*.lua'):v.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
v.execute("player_lib={system={frame=function()end}};lstg={var={}};function PlaySound()end;reimu_bullet_red={};reimu_bullet_blue={};reimu_bullet_orange={};function New(cls,...)local a={...};total=total+a[#a]end")
v.execute((mod/'player.lua').read_text(encoding='utf-8'))
v.execute(Path('G:/MySTG/aex-0.8.22/game/mod/HSoBStage5Normal/player-data.lua').read_text(encoding='utf-8'))
v.execute('''
for power=0,4 do
 local target=0;for _,row in ipairs(Y3ReimuBData.shooters[power+1])do target=target+row.damage*6/16*60 end
 assert(target==RingoSeiranPlayer.dps[power+1])
 for slow=0,1 do
  lstg.var.power=power*100;total=0
  local p={x=0,y=0,support=power,supportx=0,supporty=0,sp={},slow=slow,anglelist={{},{90},{110,70},{110,70,90},{110,70,100,80}}}
  for i=1,power do p.sp[i]={0,0,1}end
  for t=0,479,4 do p.timer=t;RingoSeiranPlayer.shoot(p);assert(p.nextshoot==4)end
  assert(math.abs(total/8-target)<1e-6)
 end
end
''')
v.execute((mod/'pattern.lua').read_text(encoding='utf-8'))
v.execute('''
local P=RingoSeiranPattern;local w=P.new('spell',function()error('used Ringo RNG')end)
w.px,w.py=0,224;P.seiranStep(w);w.t=119;P.seiranStep(w)
assert(w.stats.pellet==8 and w.stats.gun==18)
local stars={};local seed=20261102
local function random()seed=seed*16807%2147483647;return(seed-1)/2147483646 end
for _,b in ipairs(w.bullets)do if b.kind=='impactPellet' then
 random();local oldSpeed=6+6*random();local oldStop=8+math.floor(random()*13)
 assert(b.stopRadius==math.floor(oldSpeed*(oldStop+1)/2*2/3+.5))
 assert(b.stopFrames==40 and b.spinFrames==60 and b.spinSpeed==12)
 stars[#stars+1]=b
end end
for age=1,89 do
 P.advance(w)
 for _,b in ipairs(stars)do
  assert(not b.dead)
  if age==40 then assert(b.speed==0);b.testX,b.testY=b.x,b.y;assert(math.abs(math.sqrt(b.x*b.x+(b.y-224)^2)-b.stopRadius)<1e-6)
  elseif age>40 then assert(b.speed==0 and b.x==b.testX and b.y==b.testY)end
  if age<60 then assert(b.spinSpeed>0)elseif age==60 then assert(b.spinSpeed==0);b.testRot=b.rotation
  else assert(b.rotation==b.testRot and b.spinSpeed==0)end
 end
end
P.advance(w);for _,b in ipairs(stars)do assert(b.dead and b.age==90)end
''')
result={'damage':'all5 powers,both modes match reference675/855/945/1125/1170 DPS','stars':'8; prior stop radius*2/3 rounded; stop40f; spin stops60f; expiry90f','lua51':'PASS'}
Path('G:/MySTG/work/logs/ringo-seiran/verify05.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print('PASS',json.dumps(result))
