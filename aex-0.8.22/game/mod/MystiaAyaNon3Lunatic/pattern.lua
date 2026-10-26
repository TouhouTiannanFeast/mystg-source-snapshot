-- TH10 stage04 Boss3 / Lunatic, replacing each 12-ring group by its center.
local P={duration=3600,period=200,first=180,steps=32,interval=5}
function P.events(t)
    local out={}
    local r=t-P.first
    if r>=0 then
        local k=r%P.period
        if k<=155 and k%5==0 then
            local n=k/5
            -- Boss3_at3 L: five red directions, +0.20944 rad per five frames.
            for _,offset in ipairs({0,-6.2831855/5,-2.513274,-3.769911,-5.026548}) do
                out[#out+1]={color='red',speed=5,angle=-(0.628319+n*0.20944+offset)*180/math.pi,radius=16}
            end
            -- Boss3_at2: two blue directions, -0.314159 rad per five frames.
            for j=0,1 do out[#out+1]={color='blue',speed=2,angle=-(2.356194-n*0.314159-j*3.1415927)*180/math.pi,radius=20} end
        end
    end
    return out
end
function P.move_age(t)
    if t<260 then return nil end
    local a=(t-260)%P.period
    if a<40 then return a end
end
MystiaAyaPattern=P
return P
