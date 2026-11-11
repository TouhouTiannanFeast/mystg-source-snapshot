-- TH08 Normal Sub41..46. Private to Stardust; other cards keep their existing host.
local T=th08s4
local S={colors={2,4,8,6,10,13,14},types={12,13,12,13,12,13,12}}
T.Stardust03=S
-- ETEX0x20000 is a blocking countdown. Native ProcessEx runs before the
-- countdown check/decrement, so the following vector starts on update N+1.
function S.fireState(age)
 if age<120 then return end
 if age<420 then return 'delayed',120,10,280,60,90 end
 if age<720 then return 'fan',420,4 end
 local cycle=math.floor((age-720)/480);local t=(age-720)%480
 if t<300 then return 'delayed',720+cycle*480,10,200,90,cycle%2==0 and -90 or 90 end
 if t<420 then return end -- callAsync(0,-1), expansion without shooting.
 return 'fan',1140+cycle*480,4
end
function S.update(f)
 f.s03PreviousX,f.s03PreviousY=f.x,f.y
 local age=f.timer;local base=T.rad(-0.009817477)
 if age<120 then f.angular=base*4
 elseif age<180 then f.angular=base*(4-3*(age-120)/60)
 elseif age<420 then f.radius=f.radius+0.53333336;f.angular=base
 elseif age<480 then f.angular=base*(1+0.4*(age-420)/60)
 elseif age<720 then f.angular=base*1.4
 else
  local cycle=math.floor((age-720)/480);local t=(age-720)%480
  local speed=base*1.4*((-1.04)^cycle)
  if t<240 then f.radius=math.max(0,f.radius-0.9);f.angular=speed
  elseif t<300 then f.angular=speed
  elseif t<420 then f.radius=f.radius+1.8;f.angular=speed
  else f.angular=speed+(speed*(-1.04)-speed)*(t-420)/60 end
 end
end
function S.emitFrame(f)
 local kind,start,cadence,wait,duration,offset=S.fireState(f.timer)
 if not kind or(f.timer-start)%cadence~=0 then return end
 local typ=f.opt.s03Type
 if kind=='fan'then
  T.volley(f,'fan',typ,f.color,7,1,1,0.9,f.angle,30)
 else
  -- SELF_ANGLE is the displacement heading (+0x2d94), not CIRCLE_ANGLE
  -- (+0x2d9c). Lock this sampled direction for the entire wait/acceleration.
  local dx,dy=f.x-f.s03PreviousX,f.y-f.s03PreviousY
  local heading=(dx~=0 or dy~=0)and math.atan2(dy,dx)*180/math.pi or(f.s03Heading or f.angle)
  f.s03Heading=heading;local a=heading+offset
  T.emit(f,0,heading,typ,f.color,{wait=wait+1,duration=duration,ax=0.016666668*cos(a),ay=0.016666668*sin(a)})
 end
end
function S.behavior(f)
 while true do S.emitFrame(f);task.Wait(1)end
end
function S.run(o)
 T.move(o,192,224,90,4)
 local base=T.rand(-180,180)
 for i=1,7 do
  New(T.Familiar,o,base+(i-1)*360/7,T.rad(-0.009817477)*4,0.8,S.colors[i],1000,S.behavior,{update=S.update,s03Type=S.types[i]})
 end
 while true do task.Wait(100)end
end
