-- Degrees, AEX coordinates. ECL source snapshots are in source/.
MomijiPattern={gunInterval=20,gunCount=8,gunSpacing=30,gunSpeed=2,
    echoInterval=281,echoWaveInterval=30,echoCount=48,echoSpacing=300/47,
    echoSpeed=2.8,start=60,duration=2100}
MomijiPattern.ricePeriod=180;MomijiPattern.riceSteps=110;MomijiPattern.riceEmissions=48
MomijiPattern.rearHalf=150
local P=MomijiPattern
function P.events(t)
    local e={}
    if t>=P.start then
        local age=t-P.start
        local riceAge=age%P.ricePeriod
        if riceAge<P.riceSteps and math.floor((riceAge+1)*P.riceEmissions/P.riceSteps)>math.floor(riceAge*P.riceEmissions/P.riceSteps) then e[#e+1]={kind='rice',step=riceAge,burst=math.floor(age/P.ricePeriod)} end
        local n=age%P.echoInterval
        if n==0 or n==30 or n==60 then e[#e+1]={kind='scale',wave=n/30+1,round=math.floor(age/P.echoInterval)+1} end
    end
    return e
end
function P.angles(kind,aim,jitter)
    local count=kind=='gun' and P.gunCount or P.echoCount
    local spacing=kind=='gun' and P.gunSpacing or P.echoSpacing
    local center=aim+(kind=='scale' and 180 or (jitter or 0))
    local a={}
    for i=0,count-1 do a[#a+1]=center+(i-(count-1)/2)*spacing end
    return a,center
end

function P.front(boss,player)
 if MomijiAimConfig.aimFans then return Angle(boss,player) end
 return MomijiAimConfig.fixedFront
end
function P.wrap(a) return (a+180)%360-180 end
function P.inside(x,y,ox,oy,center,half)
 local dx,dy=x-ox,y-oy
 if dx*dx+dy*dy<1e-8 then return true end
 return math.abs(P.wrap(math.atan2(dy,dx)*180/math.pi-center))<=half+1e-6
end
function P.fold(a,half) return P.wrap(a)*half/180 end
function P.laserAngles(center,aim,random,count)
 local a={};local half=P.rearHalf
 -- Independent random directions, confined to the rear cone.

 for i=1,(count or 11) do a[#a+1]=center+random(-half+1,half-1) end
 if MomijiAimConfig.directLaser and math.abs(P.wrap(aim-center))<=half then a[#a+1]=aim end
 return a
end

-- Source moveRand(40,4,3) follows rice launch by80 frames every180-frame cycle.
function P.move_age(t)
 local a=t-P.start-80;if a<0 then return nil end
 a=a%P.ricePeriod;if a<40 then return a end
end
