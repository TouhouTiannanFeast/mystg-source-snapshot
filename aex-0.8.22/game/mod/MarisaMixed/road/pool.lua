MarisaRoadPool={}
local P=MarisaRoadPool
function P.rng(seed)
 local state=math.floor(tonumber(seed) or 1)%2147483647
 if state<=0 then state=1 end
 return function() state=(state*16807)%2147483647;return (state-1)/2147483646 end
end
