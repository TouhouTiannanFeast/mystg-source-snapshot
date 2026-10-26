-- TH10 Boss3 Easy: one blue direction and one red direction.
local P={duration=3600,period=200,first=180,steps=32,interval=5}
function P.events(t)
    local r=t-P.first
    if r<0 then return {} end
    local k=r%P.period
    if k>155 or k%5~=0 then return {} end
    local n=k/5
    return {
        {color='red',speed=3,angle=-(0.628319+n*0.314159)*180/math.pi,radius=16},
        {color='blue',speed=1,angle=-(2.356194-n*0.314159)*180/math.pi,radius=20},
    }
end
function P.move_age(t)
    if t<260 then return nil end
    local a=(t-260)%P.period
    if a<40 then return a end
end
MystiaAyaPattern=P
return P
