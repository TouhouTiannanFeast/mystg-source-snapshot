-- TH10 stage04 Boss2 Normal: two opposite rings in each stream.
-- Original red3/blue1.5, scaled50percent(total after additional2/3 reduction); palette changes once per blue-family ring.
local P={duration=2100,period=200,first=180,steps=32,interval=5}
local palette={'purple','blue','cyan','blue'}
function P.events(t)
 local r=t-P.first
 if r<0 then return {} end
 local k=r%P.period
 if k>155 or k%5~=0 then return {} end
 local n=k/5
 local out={}
 for j=0,1 do out[#out+1]={color='red',noteColor='red',speed=1.5,angle=-(0.628319+n*0.314159-j*3.1415927)*180/math.pi,radius=16} end
 for j=0,1 do
  local sequence=(math.floor(r/P.period)*P.steps+n)*2+j
  out[#out+1]={color='blue',noteColor=palette[sequence%4+1],speed=0.75,angle=-(2.356194-n*0.314159-j*3.1415927)*180/math.pi,radius=16}
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
