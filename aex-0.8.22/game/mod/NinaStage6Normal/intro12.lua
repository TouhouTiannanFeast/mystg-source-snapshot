-- Opening choreography, isolated from combat runtime and attack RNG.
-- Texture: TH20 effect.anm sprite74, EffChargePoint2 / ANM149..160.
-- Source-derived TH20 charge curves/emitters in intro14.lua; one playback.
Include('intro14.lua')
NinaIntro12={duration=473,pulseStarts={136},revealStart=306,sideStart=383}
local N=NinaIntro12
LoadTexture('nina.intro12.mist','art/intro12-charge.png')
LoadImage('nina.intro12.mist','nina.intro12.mist',0,0,32,32)
local function ease(u)u=math.max(0,math.min(1,u));return u*u*(3-2*u)end
-- Constant travel speed for80%; decelerate only in the final20%.
function N.departureEase(u)
 u=math.max(0,math.min(1,u))
 if u<=.8 then return u/.9 end
 local v=u-.8;return(.8+v-v*v/.4)/.9
end
function N.pose(t)
 local x,y=0,96
 if t<120 then local u=ease(t/120);x=232*(1-u);y=-48+144*u
 elseif t>=N.sideStart then local u=N.departureEase((t-N.sideStart)/90);x=80*u;y=96+16*u end
 return x,y,t>=N.revealStart,t>=120 and t<N.sideStart
end
function N.reveal(t)return math.max(0,math.min(1,(t-N.revealStart)/40))end
local Intro=Class(object)
N.Object=Intro
 function Intro:init(state,drawBody)
  self.state=state;self.drawBody=drawBody
  self.particles=NinaIntro14.build(NinaCorePool.rng((tonumber(setting.nina_seed)or 20261104)+814))
  self.group=GROUP_GHOST;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false
  self.actor={name='Yoshika',group='silent-suwako',x=232,y=-48,age=0}
  NinaSuwako11.init(self.actor);state.current='intro';state.intro=self
 end
 function Intro:frame()
  local t=self.timer;local a=self.actor;local x,y,visible,colored=N.pose(t)
  a.x,a.y,a.age=x,y,t;self.ninaVisible=visible
  a.colorDownStart=colored and 1 or nil;a.colorDownAge=colored and(t-120)or nil
  NinaSuwako11.step(a)
  if setting.nina_test and t==N.revealStart+40 then print('NINA APPEAR FULL stageframe='..stage.current_stage.timer)end
  if t==N.revealStart+41 and self.state.onNinaArrival then self.state.onNinaArrival()end
  for i,start in ipairs(N.pulseStarts)do if t==start then print('NINA INTRO MIST '..i)end end
 end
 function Intro:render()
  local a=self.actor;self.drawBody(a,'suwako')
  if self.ninaVisible then self.drawBody({x=0,y=96,age=self.timer-N.revealStart,visualAlpha=255*N.reveal(self.timer)},'nina')end
  NinaIntro14.render(self.particles,self.timer-N.pulseStarts[1],0,96)
 end
function N.run(state,drawBody)
 local o=New(Intro,state,drawBody)
 for t=1,N.duration do task.Wait(1)end
 state.lastPos={x=0,y=96};state.suwakoPose={x=80,y=112,age=N.duration}
 Del(o);state.intro=nil;state.current=nil
 print('NINA INTRO HANDOFF Nina=0,96 Suwako=80,112')
end
