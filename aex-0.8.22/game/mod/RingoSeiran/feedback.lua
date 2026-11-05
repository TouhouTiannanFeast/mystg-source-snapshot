RingoSeiranFeedback={}
local F=RingoSeiranFeedback
local function pan(x)return math.max(-1,math.min(1,x/192))end
function F.shot(state,b,t)
 local kind=b.kind=='gun' and 'gun' or(b.kind=='impactPellet' and 'star' or 'dango')
 if state[kind]==t then return end
 state[kind]=t
 local sounds={dango={'tan00',.2},gun={'gun00',.2},star={'tan01',.16}}
 local sound=sounds[kind];PlaySound(sound[1],sound[2],pan(b.x))
end
function F.swing(s)PlaySound('slash',.14,pan(s.x))end
function F.impact(s)PlaySound('don00',.35,pan(s.headX))end
function F.reward(o,id)
 if id~='nonspell' or o.timeout or o.hp>0 or o.rsNonspellReward then return false end
 o.rsNonspellReward=true
 New(item_bomb,o.x,o.y)
 return true
end
