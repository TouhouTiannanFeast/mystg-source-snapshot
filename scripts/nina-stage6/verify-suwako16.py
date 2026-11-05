from pathlib import Path
from lupa.lua51 import LuaRuntime
base=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('object={};function Class()return{}end;function Include()end;function LoadTexture()end;function LoadImage()end')
for name in ['runtime','projectiles','programs','encounter','encounter-nina','intro12','suwako16']:
 lua.execute((base/(name+'.lua')).read_text(encoding='utf-8'))
lua.execute('''
local N=NinaIntro12
assert(N.departureEase(0)==0 and math.abs(N.departureEase(1)-1)<1e-9)
assert(math.abs((N.departureEase(.6)-N.departureEase(.5))-(N.departureEase(.3)-N.departureEase(.2)))<1e-9)
local R=NinaCoreRuntime;R.onActor=function()end;R.onShot=function()end
local spec=NinaCoreSpecs[1];R.start(spec,123)
local initial
for i=1,130 do
 R.step(0,400,spec.hp)
 local a=R.yoshika
 if a.ninaLandingTween then
  assert(a.ninaLandingTween.n==120)
  initial=initial or a.ninaLandingTween.from
 end
end
assert(initial and initial[1]==80 and initial[2]==112)
assert(R.yoshika.ninaFirstLanding and math.abs(R.yoshika.x)<1e-9 and math.abs(R.yoshika.y-260)<1e-9)
-- The same command later in non1 remains source240/mode4.
R.command(R.yoshika,{},'movePosTime',{240,4,0,260})
assert(R.yoshika.positionTween.n==240 and R.yoshika.positionTween.mode==4)
local other=R.newActor('th13',0,100)
R.command(other,{},'movePosTime',{240,4,0,260})
assert(other.positionTween.n==240 and other.positionTween.mode==4)
assert(N.pose(N.duration)==80) -- opening still hands off at the same side point
print('PASS actual non1 source command: first Suwako landing120f, later/other actor240f unchanged;80% constant travel then late deceleration; target0,260; opening endpoint80,112')
''')
lua.execute('assert(loadstring(...))',(base/'root.lua').read_text(encoding='utf-8'))
