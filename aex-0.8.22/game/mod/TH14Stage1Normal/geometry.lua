-- Bounded TH14 stage-one math. Source uses radians and a downward Y axis.
local M = {}
M.top = 224
function M.position(x,y) return x,M.top-y end
function M.angle(rad) return -rad*180/math.pi end
function M.fan(base,count,spread)
    local out={}
    for i=1,count do out[i]=base+(i-1-(count-1)/2)*spread end
    return out
end
function M.ring(base,count)
    local out={}
    for i=1,count do out[i]=base+(i-1)*360/count end
    return out
end
function M.speed(first,last,i,count)
    if count==1 then return first end
    return first+(last-first)*(i-1)/(count-1)
end
-- Approximation to source movement interpolation; not TH14 binary parity.
function M.ease(t,mode)
    t=math.max(0,math.min(1,t))
    if mode==1 then return t*t end
    if mode==4 then return 1-(1-t)^2 end
    return t
end
-- Polar acceleration begins AFTER the requested wait; duration is inclusive.
function M.motion(speed,angle,age,wait,duration,accel,turn)
    if age>=wait and age<wait+duration then
        return speed+accel,angle+turn
    end
    return speed,angle
end
return M
