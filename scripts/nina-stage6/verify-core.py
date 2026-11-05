from pathlib import Path
from lupa.lua51 import LuaRuntime
import json
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
l=LuaRuntime(unpack_returned_tuples=True)
for n in ['runtime','projectiles','programs','encounter','encounter-nina','assets']:l.execute((M/(n+'.lua')).read_text(encoding='utf-8-sig'))
l.execute('R=NinaCoreRuntime;R.onActor=function(a)end;R.onShot=function(b) assert(b.laser or NinaCoreArt[b.group..":"..b.typ..":"..b.color],"missing sprite "..b.group..":"..b.typ..":"..b.color) end')
for i in range(1,5):
 l.execute('R.start(NinaCoreSpecs[...],123)',i)
 for t in range(1700):
  try:l.execute('R.step(0,400,R.spec.hp);R.stepHazards()')
  except Exception:
   print('FAILED',i,t);raise
 if i<=2:
  l.execute('R.yoshika.hp=0');down=False;revive=False
  for t in range(800):
   l.execute('R.step(0,400,R.spec.hp);R.stepHazards()')
   a=l.globals().R.yoshika
   if a.colorDownStart is not None:down=True
   elif down:revive=True
  assert down and revive,(i,down,revive)
 print(i,l.globals().R.stats.bullets,l.globals().R.stats.lasers)
 l.execute('R.clearHazards(false);R.stepHazards();assert(#R.hazards==0)')
print('PASS core source schedules/art/down+revive/cleanup; TH20 native art radius remains adapted')

