-- Opt-in short native scene/player check; excluded from normal play.
local R=TH11S6Runtime
local P=Y3Player
local checks={main=0,homing=0,pierce=0,bomb=0,damage=0}
local Target=Class(enemy)
function Target:init()
 enemybase.init(self,1000000,true);self.x,self.y=0,32;self.a,self.b=24,24;self.bound=false
end
function Target:frame()enemybase.frame(self)end
function Target:colli(b)
 if b.class==P.Homing then checks.homing=checks.homing+1
 elseif b.y3Piercing then
  if not b.y3Hits[self]then checks.pierce=checks.pierce+1 end
 elseif b.class==P.Shot then checks.main=checks.main+1
 elseif b.class==reimu_kekkai or b.class==reimu_sp_ef1 then checks.bomb=checks.bomb+1 end
 local before=self.hp;enemybase.colli(self,b);checks.damage=checks.damage+(before-self.hp)
end
function Target:render()end
local update=player_lib.system.updateKeyState
function player_lib.system:updateKeyState(...)
 local out=update(self,...);local p=self.player
 p.__shoot_flag=true;p.__slow_flag=(R.tick or 0)>=240
 return out
end
local after=AfterFrame;local target;local done={}
AfterFrame=function()
 after()
 if not R.tick or not player or not IsValid(player)then return end
 if R.tick==30 and not target then target=New(Target)end
 if R.tick==420 and not done.bomb then
  done.bomb=true;player.slow=1;player.class.spell(player)
 end
 if R.tick==490 and not done.loop then
  done.loop=true;local b=TH11S6Background.current
  while b.state.t<5555 do TH11S6Background.step(b.state)end
 end
 if R.tick==580 and not done.pass then
  done.pass=true
  assert(player.class.shoot==P.shoot and lstg.var.power==400 and player.support==4,'native reference player binding/4P')
  assert(checks.main>0 and checks.homing>0 and checks.pierce>0 and checks.bomb>0 and checks.damage>0,'native source shot/Shift/Bomb contacts missing')
  assert(TH11S6Background.current.state.loops>=1,'native Extra loop')
  print(string.format('TH11S6 CHANGE02 PASS main=%d homing=%d pierce=%d bomb=%d damage=%.2f',checks.main,checks.homing,checks.pierce,checks.bomb,checks.damage))
 end
end
local render=RenderFunc;local captured={}
RenderFunc=function()
 render()
 for _,t in ipairs({180,320,455,570})do if R.tick and R.tick>=t and not captured[t]then
  captured[t]=true;lstg.Snapshot('userdata/snapshot/th11s6-change02-'..t..'.jpg')
 end end
end
