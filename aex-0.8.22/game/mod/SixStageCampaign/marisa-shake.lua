-- TH08 Sub55 funcCall10 -> 0x4246e0: shake(4,120,190,60).
-- Use a private visual RNG, preserving the port's gameplay RNG sequence.
local C=SixStageCampaign
local Q=Class(object)
function Q:init()
 self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false
 self.offset=lstg.worldoffset;self.seed=173;self.age=0
 th08s4.own(self,true)
end
function Q:frame()
 if self.stopped or not IsValid(self)then return end
 self.age=self.age+1
 local t=self.age
 if t>=370 then Del(self);return end
 local amplitude=4*(t<120 and t/120 or(t<310 and 1 or(370-t)/60))
 self.seed=self.seed*16807%2147483647;local x=self.seed%3
 self.seed=self.seed*16807%2147483647;local y=self.seed%3
 self.offset.dx=(x==0 and 0 or(x==1 and amplitude or -amplitude))
 self.offset.dy=(y==0 and 0 or(y==1 and amplitude or -amplitude))
end
function Q:del()
 self.stopped=true
 self.offset.dx=0;self.offset.dy=0
 th08s4.owned[self]=nil;th08s4.phase_objects[self]=nil
end
Q.kill=Q.del
local install=C.install
function C.install(i,classes)
 install(i,classes);if i~=4 then return end
 local T=th08s4
 if T.six_shake13 then return end;T.six_shake13=true
 local init=T.Beam.init
 T.Beam.init=function(o,owner,x,y,angle,length,width,color,warning,active,off,turn)
  init(o,owner,x,y,angle,length,width,color,warning,active,off,turn)
  if MarisaMixed.phase=='final'and length==650 and warning==120 then New(Q)end
 end
end
