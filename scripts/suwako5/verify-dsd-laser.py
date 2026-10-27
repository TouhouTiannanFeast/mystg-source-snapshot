from pathlib import Path
from lupa.lua51 import LuaRuntime
B=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/suwako5')
l=LuaRuntime(unpack_returned_tuples=True)
for name in ['pool','runtime','projectiles','programs']:
    l.execute((B/(name+'.lua')).read_text(encoding='utf-8'))
l.execute('''
local R,P=Suwako5Runtime,Suwako5Pool
R.start(P.find('th125-d'),42)
local waves={};local red,green
R.onShot=function(b)
 if b.laser then
  assert(b.laser.length==0 and b.laser.terminal==1024)
  if not waves[R.tick]then waves[R.tick]=R.photos end
  if not red then red=b elseif not green then green=b end
 end
end
for t=0,720 do
 R.step(0,400,1000)
 if red and green then
  assert(red.color==1 and green.color==5)
  assert(math.abs((green.x-red.x)^2+(green.y-red.y)^2-1024)<.01)
  assert(red.laser.max==192 and green.laser.max==128)
  assert(red.laser.width==48 and green.laser.width==32)
  -- Observe one pair independently: both grow from their own fixed origin.
  local rx,ry,gx,gy=red.x,red.y,green.x,green.y
  R.projectileStep(red);R.projectileStep(green)
  assert(red.laser.length>0 and red.laser.length<192)
  assert(green.laser.length>0 and green.laser.length<128)
  assert(red.x==rx and red.y==ry and green.x==gx and green.y==gy)
  for i=1,400 do R.projectileStep(red);R.projectileStep(green)end
  assert(red.dead and green.dead,'terminal shrink must finish without regrowth')
  red,green=nil,nil
  R.onShot=function(b)if b.laser and not waves[R.tick]then waves[R.tick]=R.photos end end
 end
 assert(R.photos<=2)
end
local ticks={};for t in pairs(waves)do ticks[#ticks+1]=t end;table.sort(ticks)
assert(#ticks>=3);assert(waves[ticks[1]]==0 and waves[ticks[2]]==1 and waves[ticks[3]]==2)
for i=3,#ticks do assert(waves[ticks[i]]==2)end
assert(R.photos==2);print('PASS DS-d waves '..ticks[1]..'/'..ticks[2]..'/'..ticks[3]..'; stages0/1/2 then held2; laser0->192/128, fixed growth origins32 apart, terminal1024 shrink')
R.start(P.find('th125-d'),42);assert(R.photos==0 and R.dsLaserWaves==0)
R.start(P.find('th125-a'),42);R.actors={};R.tick=600;R.step(0,400,1000);assert(R.photos==5)
''')
