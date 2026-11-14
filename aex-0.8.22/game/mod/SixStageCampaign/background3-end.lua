-- Keep the final Stage3 spell scenery alive for its normal40f fade-out.
local C=SixStageCampaign
local Fade=Class(object)
function Fade:init(bg,alpha,age)
 self.group=GROUP_GHOST;self.layer=bg.layer;self.bound=false;self.colli=false
 self.age=age;self.alpha=alpha;self.startAlpha=alpha;self.fadeAge=0
 self.draw=bg.class.render;C.stage3EndFade=self
end
function Fade:frame()
 self.age=self.age+1;self.fadeAge=self.fadeAge+1
 self.alpha=self.startAlpha*math.max(0,1-self.fadeAge/40)
 if self.fadeAge>=40 then Del(self)end
end
function Fade:render()self.draw(self)end
function Fade:del()if C.stage3EndFade==self then C.stage3EndFade=nil end end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=3 then return end
 local spell=Y3Background.spell
 local frame,del=spell.frame,spell.del
 spell.frame=function(o,...)
  local result=frame(o,...)
  -- Boss deletion zeros alpha before deleting its spell background.
  -- Keep the last visible state so the independent fade starts without a flash.
  o.sixVisibleAlpha=o.alpha;o.sixVisibleAge=o.age
  return result
 end
 spell.del=function(o)
  if not stage.next_stage and Y3Host.current=='spell3'and Y3Host.ended>0
   and (o.sixVisibleAlpha or 0)>0 and not C.stage3EndFade then
   New(Fade,o,o.sixVisibleAlpha,o.sixVisibleAge)
  end
  if del then return del(o)end
 end
end
