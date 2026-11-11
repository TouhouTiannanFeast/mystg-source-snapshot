-- Noncombat movement keeps the original attack clocks and HP intact.
function Stage12BossEntrance(cards,x,y)
    local result={boss.move.New(x,y,60,4)}
    for i,source in ipairs(cards) do
        local card={}
        for k,v in pairs(source) do card[k]=v end
        if i>1 then
            local before=card.before
            card.before=function(o)
                local sx,sy=o.x,o.y
                local tx,ty=0,card.stage12TransitionY or sy
                for frame=1,30 do
                    local u=frame/30;u=u*u*(3-2*u)
                    o.x,o.y=sx+(tx-sx)*u,sy+(ty-sy)*u
                    task.Wait(1)
                end
                if before then before(o) end
            end
        end
        result[#result+1]=card
    end
    return result
end
