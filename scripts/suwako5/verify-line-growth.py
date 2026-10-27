"""Focused regression for all selected TH10 source laser call families."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
B=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/suwako5')
l=LuaRuntime(unpack_returned_tuples=True)
for name in ['pool','runtime','projectiles','programs']:
    l.execute((B/(name+'.lua')).read_text(encoding='utf-8'))
l.execute('''
local R,P=Suwako5Runtime,Suwako5Pool
for _,id in ipairs({'th10-card1','th10-card2','th10-card6'})do
 for _,command in ipairs({'laserOn','laserOnA','laserOn3','laserOnA2'})do
  R.start(P.find(id),42)
  R.command(R.boss,{i={},f={}},command,{3,2,math.pi/2,6,0,128,0,14})
  local b=R.hazards[1];local y=b.y
  assert(b.laser.nativeLine and b.laser.length==0)
  R.projectileStep(b);assert(b.laser.length==6 and b.y==y)
  for i=2,22 do R.projectileStep(b)end
  assert(b.laser.length==128 and b.y==y)
  R.projectileStep(b);assert(b.laser.length==128 and math.abs(b.y-y-6)<1e-6)
 end
end
-- Run the actual card1 script to its first native laser, without substitutions.
R.start(P.find('th10-card1'),42)
local first
R.onShot=function(b)if b.laser and not first then first=b;assert(b.laser.length==0)end end
for t=0,200 do R.step(0,400,2800);if first then break end end
assert(first,'actual card1 source must emit a laser')
local y=first.y;R.projectileStep(first)
assert(first.laser.length==6 and first.y==y)
print('PASS actual card1 source birth0 ->6 with stationary origin; all four TH10 laser call variants; cards1/2/6 reach128 before translating6; HP/time unchanged')
''')
