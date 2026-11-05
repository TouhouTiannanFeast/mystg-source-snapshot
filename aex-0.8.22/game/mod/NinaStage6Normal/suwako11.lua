-- TH10 stgenm07.anm scripts0..4. Cosmetic state only; never drives movement.
NinaSuwako11={}
local N=NinaSuwako11
function N.init(a)
 a.suwakoAnimation={x=a.x,direction=0,age=0,idleAge=a.age or 0,mirror=1}
end
function N.step(a)
 if not a.suwakoAnimation then N.init(a)end
 local s=a.suwakoAnimation;local dx=a.x-s.x;s.x=a.x
 if a.down or a.colorDownStart then
  s.direction=0;s.age=0;s.idleAge=0;s.returning=false
  return
 end
 local direction=dx>0.000001 and 1 or dx< -0.000001 and -1 or 0
 if direction~=s.direction then
  if direction~=0 then s.mirror=direction;s.returning=false
  else s.returning=s.direction~=0 end
  s.direction=direction;s.age=0;s.idleAge=0
 else s.age=s.age+1;s.idleAge=s.idleAge+1 end
 if s.returning and s.age>=8 then s.returning=false;s.idleAge=s.age-8 end
end
function N.frame(a)
 local s=a.suwakoAnimation
 if not s then return math.floor((a.age or 0)/7)%4,1 end
 if s.direction~=0 then return 4+math.min(2,math.floor(s.age/4)),s.mirror end
 if s.returning then return 6-math.floor(s.age/4),s.mirror end
 return math.floor(s.idleAge/7)%4,1
end
