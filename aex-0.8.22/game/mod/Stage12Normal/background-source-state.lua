local fogEvents={{{0,0,96,64,64,400.0,900.0},{0,600.0,192,176,176,500.0,900.0},{2424,840.0,192,176,176,500.0,900.0},{3264,360.0,96,96,192,300.0,600.0},{3624,360.0,192,96,96,300.0,600.0},{3984,450.0,192,176,128,300.0,600.0},{4434,660.0,192,144,144,500.0,900.0},{5094,0,192,144,144,500.0,900.0}},{{0,0,32,32,128,800.0,1700.0},{1300,340.0,80,208,208,1000.0,1700.0},{4038,434.0,0,80,240,800.0,1300.0},{5496,0,0,80,240,800.0,1300.0},{5496,434.0,0,80,240,800.0,1300.0}}}

Stage12BackgroundSource={}
local S=Stage12BackgroundSource
local function lerp(a,b,t)return a+(b-a)*t end
local function ease(t)return (1-math.cos(math.pi*math.max(0,math.min(1,t))))/2 end
function S.fog(stage,age)
 local t=age
 if stage==1 and t>=9094 then t=5094+(t-5094)%4000 end
 if stage==2 and t>=6520 then t=5496+(t-5496)%1024 end
 local value={0,0,0,400,900};local previous=value;local target=value;local begin,duration=0,0
 local function sample(at)
  local u=duration==0 and 1 or math.max(0,math.min(1,(at-begin)/duration));local out={}
  for i=1,5 do out[i]=lerp(previous[i],target[i],u)end;return out
 end
 for _,v in ipairs(fogEvents[stage])do
  if v[1]>t then break end
  value=sample(v[1]);previous=value;target={v[3],v[4],v[5],v[6],v[7]};begin,duration=v[1],v[2]
 end
 return sample(t)
end
function S.alpha(stage,tex,z,age)
 if stage==2 then
  if tex=='bg2.th16.st02a' then return 255 end
  if tex=='bg2.th16.st02b' then
   if age<80 then return lerp(64,128,ease(age/80))end
   local t=(age-80)%160
   return t<80 and lerp(128,160,ease(t/80)) or lerp(160,128,ease((t-80)/80))
  end
 end
 if tex=='bg1.st01d' then return 192 end
 local fade=math.max(0,math.min(1,(age-450)/60))
 if tex=='bg1.world02' then
  if z== -20 then
   if age<450 then return 0 end
   local t=(age-450)%240
   return t<120 and lerp(112,64,ease(t/120)) or lerp(64,112,ease((t-120)/120))
  end
  return 144*fade
 end
 if tex=='bg1.world02b' then return 255*fade end
 return 192*fade
end
function S.blend(stage,tex,z)
 if stage==1 and tex=='bg1.world02' then
  if z== -10 then return 'mul+add' elseif z== -20 then return 'mul+sub' end
 end
 return ''
end
function S.overlay_age(age)
 if age<4038 then return nil end
 if age<5496 then return age-4038 end
 return (age-5496)%1024
end
function S.overlay_alpha(age,maxalpha)
 local t=S.overlay_age(age)
 return t and maxalpha*math.max(0,math.min(1,(t-400)/150)) or 0
end
