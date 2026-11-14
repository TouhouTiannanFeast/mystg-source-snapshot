-- Campaign-only visual feedback for real Stage4 road enemy defeats.
local C=SixStageCampaign
local Effect=Class(enemy_death_ef)
function Effect:init(x,y)
 self.img='bubble1';self.x,self.y=x,y;self.rot=45
 self.layer=LAYER_ENEMY+50;self.group=GROUP_GHOST
 self.bound=false;self.colli=false
 -- The route already plays the defeat sound. Do not call the base init.
 Th18Stage5Host.owned[self]=true
end
function Effect:del()Th18Stage5Host.owned[self]=nil end
Effect.kill=Effect.del
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=4 or not Th18Stage5Host then return end
 local H,R=Th18Stage5Host,Th18Stage5Runtime
 local begin=H.begin
 H.begin=function(...)
  local result=begin(...)
  local death=R.onDeath
  R.onDeath=function(a,...)
   if not a.controller and not a.midboss and (a.hp or 1)<=0 then
    New(Effect,a.x,224-a.y)
   end
   return death(a,...)
  end
  return result
 end
end
