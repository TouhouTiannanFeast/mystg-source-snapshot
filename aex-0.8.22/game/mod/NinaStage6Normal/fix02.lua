-- Keep absolute and relative motion as independent source channels.
local R=Nina10Runtime
local cmd,motion=R.command,R.motion
local function orbit(old,v)
 old=old or{angle=0,omega=0,radius=0,dr=0,x=0,y=0}
 for i,k in ipairs({'angle','omega','radius','dr'})do if v[i]>-990 then old[k]=v[i]end end
 return old
end
function R.command(a,e,k,v)
 if a.group=='th10kanako'then
  if k=='moveCircleRel'then a.relativeOrbit=orbit(a.relativeOrbit,v);return
  elseif k=='moveAddRel'then local o=assert(a.relativeOrbit);o.x,o.y=v[1],v[2];return
  elseif k=='moveCircle'then a.orbit=orbit(a.orbit,v);a.positionTween=nil;return end
 end
 return cmd(a,e,k,v)
end
function R.motion(a)
 a.x,a.y=a.x-(a.orbitOffsetX or 0),a.y-(a.orbitOffsetY or 0)
 motion(a)
 local o=a.relativeOrbit
 if o then
  o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
  a.orbitOffsetX=o.x+math.cos(o.angle)*o.radius;a.orbitOffsetY=o.y+math.sin(o.angle)*o.radius
  a.x,a.y=a.x+a.orbitOffsetX,a.y+a.orbitOffsetY
 end
end
NinaFix02={}
function NinaFix02.frogAngles(x,y,px,py,random)
 local aim=math.atan2(py-y,px-x);local out={aim}
 for i=2,7 do local offset=math.pi/6+random()*(2*math.pi-math.pi/3);out[i]=aim+offset end
 return out,aim
end
function NinaFix02.heading(angle)return -angle*180/math.pi-90 end
