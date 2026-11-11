-- Coalesce volleys; continuous streams play at most once every six game frames.
-- Existing bespoke laser/impact sounds remain at their original call sites.
local previousStage, previousTick
local last={}
function Stage12FireSound(name,x)
    local current=stage.current_stage
    local tick=current.timer
    if current~=previousStage or (previousTick and tick<previousTick) then last={} end
    previousStage,previousTick=current,tick
    if last[name] and tick-last[name]<6 then return end
    last[name]=tick
    PlaySound(name,0.25,math.max(-1,math.min(1,(x or 0)/224)))
end
