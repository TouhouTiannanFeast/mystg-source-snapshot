local C=SixStageCampaign
local after=AfterFrame
local killed,age
AfterFrame=function(...)
 after(...)
 if C.index~=4 or not Th18Stage5Runtime then return end
 if not killed then
  for _,a in ipairs(Th18Stage5Runtime.actors)do
   if not a.dead and not a.controller and not a.midboss and a.host and IsValid(a.host)and a.y>50 and a.y<220 then a.hp=0;killed=a;age=0;break end
  end
 else
  age=age+1
  if age==6 then
   local found=false
   for o in pairs(Th18Stage5Host.owned)do if IsValid(o)and o.img=='bubble1'and o.group==GROUP_GHOST then found=true end end
   assert(found,'road defeat animation absent');C.snapshot='road4-death-preview'
  end
  if age==10 then print('ROAD4 DEATH NATIVE PASS actual HP kill creates visible effect');stage.QuitGame()end
 end
 assert(stage.current_stage.timer<2400,'road defeat probe deadline')
end
