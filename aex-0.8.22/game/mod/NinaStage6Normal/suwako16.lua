-- Only the first non1 Yoshika/Suwako landing; source attack/wait clocks unchanged.
local R=NinaCoreRuntime
local command,motion=R.command,R.motion
function R.command(a,e,k,v)
 if R.spec and R.spec.id=='non1'and a==R.yoshika and k=='movePosTime'
   and v[1]==240 and v[2]==4 and v[3]==0 and v[4]==260 and not a.ninaFirstLanding then
  a.ninaFirstLanding=true;v=R.copy(v);v[1]=120;v[2]=0
  command(a,e,k,v);a.ninaLandingTween=a.positionTween
  return
 end
 return command(a,e,k,v)
end
function R.motion(a)
 local t=a.ninaLandingTween
 if not t or t~=a.positionTween then a.ninaLandingTween=nil;return motion(a)end
 motion(a)
 local u=NinaIntro12.departureEase(math.min(1,t.age/t.n))
 a.x=t.from[1]+(t.to[1]-t.from[1])*u
 a.y=t.from[2]+(t.to[2]-t.from[2])*u
 if t.age>=t.n then a.ninaLandingTween=nil end
end
