-- Isolated copy of the existing seven-phase Torisumi Horou encounter.
Include('stages/zuu4/host.lua')
local R=HSoB5
local Entrance=Class(object)
function Entrance:init()
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false
 Zuu4R.animation.clock=0;Zuu4R.animation.wingClock=0
 Zuu4R.boss={x=192,y=-96,book=true,visible=true};Zuu4R.wings=false
 self.x,self.y=0,320
end
function Entrance:frame()
 local u=math.min(1,self.timer/90);local v=1-(1-u)^2
 self.y=320-224*v
 Zuu4R.boss.x,Zuu4R.boss.y=192,224-self.y
 if self.timer>=90 then Del(self)end
end
function Entrance:render()Zuu4R.animation.render(Zuu4R.boss)end
R.playBoss=function()
 StopMusic('hs5.road')
 local arrival=New(Entrance)
 while IsValid(arrival)do task.Wait(1)end
 local encounter=New(Zuu4Boss,setting.hsob5_boss_mode)
 R.bossActive=true
 while IsValid(encounter)do
  if setting.hsob5_invincible and IsValid(player)then player.protect=1000 end
  task.Wait(1)
 end
 R.bossActive=false;R.bossComplete=true
end
