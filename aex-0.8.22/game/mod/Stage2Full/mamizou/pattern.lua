-- Bounded, independent port of the pinned source routines in reference.json.
-- Native ECL @ calls (opcode 11) are synchronous; explicit async calls are not.
local P={durations={3600,4200,3600,7800,7200},health={800,1500,900,1050,1575},radius_scale=2/3}
function P.ring_count(index)
    -- Balanced integer allocation: each three native 28-particle rings -> 56.
    return math.ceil(index*56/3)-math.ceil((index-1)*56/3)
end
function P.non(phase,t)
    local first=phase==1 and 70 or 170
    if t<first then return end
    local r=(t-first)%640
    local starts={0,60,320,380}
    local spins=phase==1 and {3.883222,-4.6598663,-3.883222,4.6598663} or {5.436511,4.6598663,-5.436511,-4.6598663}
    for i,start in ipairs(starts) do
        if r>=start and r<start+60 then return {age=r-start,spin=spins[i],color=phase==1 and 1 or 6,count=3,speed=4.1} end
    end
end
function P.non_move(phase,t)
    local first=phase==1 and 70 or 170
    return t>=first and ((t-first)%640==170 or (t-first)%640==490)
end
function P.bird(t)
    if t<240 then return end
    local r=(t-240)%280
    if r<80 and r%5==0 then return {x=-192+r/5*24} end
    if r>=140 and r<220 and r%5==0 then return {x=192-(r-140)/5*24} end
end
function P.frog(t) return t>=420 and (t-420)%240==0 end
function P.market_wait(t)
    return math.floor(180-80*math.min(1,math.max(0,(t-60)/2400)))
end
function P.final_wait(t,hp)
    if t>=5400 then return 40 end
    if hp<800 then return 60 end
    if hp<2000 then return 100 end
    if hp<3000 then return 140 end
    if hp<4000 then return 160 end
    return 230
end
-- etAim modes 3 and 5 are full rings; mode 5 uses a half-step offset.
function P.ring_angle(base,k,n,away) return base+2*math.pi*(k+(away and 0.5 or 0))/n end
function P.random_keep(index) return index%4~=0 end
MamizouPattern=P
return P
