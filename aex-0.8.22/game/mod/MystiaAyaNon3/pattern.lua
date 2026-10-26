-- TH10 stage04 Boss3 / Normal. Screen-down angles become AEX-up angles.
local P={duration=3600,period=200,first=180,steps=32,interval=5}
function P.events(t)
    local out={}
    local r=t-P.first
    if r>=0 then
        local k=r%P.period
        if k<=155 and k%5==0 then
            local n=k/5
            for _,offset in ipairs({0,-6.2831855/3,6.2831855/3}) do
                out[#out+1]={color='red',speed=3,angle=-(0.628319+n*0.314159+offset)*180/math.pi,radius=16}
            end
        end
        -- ECL goto @5 rewinds/sets VM time; it is not an initial wait.
        if k<=155 and k%5==0 then
            local n=k/5
            for j=0,1 do out[#out+1]={color='blue',speed=1,angle=-(2.356194-n*0.314159-j*3.1415927)*180/math.pi,radius=20} end
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
