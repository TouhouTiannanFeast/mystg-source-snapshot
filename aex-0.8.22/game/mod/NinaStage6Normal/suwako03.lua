-- Silent, shootable Suwako for non2/spell2. Source-stage actors stay separate.
NinaSuwako03={}
local N=NinaSuwako03
function N.new(pose,seed)
 pose=pose or{x=80,y=112}
 local a={name='Yoshika',group='silent-suwako',x=pose.x,y=pose.y,age=pose.age or 0,hp=4000,maxhp=4000,hurtW=48,hurtH=48,hitW=48,hitH=48,flags=0,flightTick=0,random=NinaCorePool.rng(seed)}
 if pose.hp and pose.hp>0 then a.hp=math.min(4000,pose.hp)end
 return a
end
function N.step(a)
 a.age=a.age+1;a.flightTick=a.flightTick+1
 if not a.down and a.hp<=0 then a.down=true;a.hp=0;a.downAge=0;a.target=nil end
 if a.down then
  a.downAge=a.downAge+1;a.colorDownStart=1;a.colorDownAge=a.downAge
  if a.downAge>=240 then
   a.down=false;a.hp=a.maxhp;a.colorDownStart=nil;a.colorDownAge=nil;a.glow=30;a.target=nil
   if N.onRevive then N.onRevive(a)end
  end
 else
  if not a.target then
   -- Bounded slow wandering; its RNG is separate from the attack program.
   local x,y=-144+a.random()*288,72+a.random()*188
   local dx,dy=x-a.x,y-a.y;local d=math.sqrt(dx*dx+dy*dy)
   a.target={x=x,y=y,left=math.max(180,math.ceil(d/.45))}
  end
  local t=a.target;local n=t.left
  a.x=a.x+(t.x-a.x)/n;a.y=a.y+(t.y-a.y)/n;t.left=n-1
  if t.left<=0 then a.target=nil end
 end
 if a.glow then a.glow=a.glow-1;if a.glow<=0 then a.glow=nil end end
end
function N.downSprite(age)
 if age<16 then return 22+math.floor(age/4)end
 -- Palette phase accelerates continuously: derivative rises from 1/4 to 1.
 return 26+math.floor((age-16)/4+3*(age-16)^2/(8*224))%4
end
