-- Damage and timing from retail TH18 v1.00a, pl00.sht and 45ea00/45f0f0.
Th18Fire={budgets=setmetatable({},{__mode='k'})}
local F,D=Th18Fire,Th18FireData
function F.clock() return stage.current_stage.timer end
function F.damage(target,amount)
 if not IsValid(target) or target.protect then return 0 end
 local tick=F.clock();local b=F.budgets[target]
 if not b or b.tick~=tick then b={tick=tick,total=0};F.budgets[target]=b end
 local value=math.min(amount,math.max(0,90-b.total));b.total=b.total+value
 if value>0 then Damage(target,value) end
 return value
end
function F.rows(p,slow,emit)
 local level=math.min(4,math.max(0,math.floor(lstg.var.power/100)))
 for _,r in ipairs(D.groups[level+(slow and 5 or 0)]) do
  local timer,rate,delay=p.fireShort,r.rate,r.delay
  if r.rate2~=0 then timer,rate,delay=p.fireLong,r.rate2,r.delay2 end
  if rate==0 or timer>=0 and timer%rate==delay then emit(r,level,slow) end
 end
end
function F.advance(p,held)
 if p.fireShort>=0 then p.fireShort=p.fireShort<14 and p.fireShort+1 or (held and 0 or -1) end
 if p.fireLong>=0 then p.fireLong=p.fireLong<119 and p.fireLong+1 or (held and 0 or -1) end
end
function F.start(p)
 if p.fireShort<0 then p.fireShort=0;if p.fireLong<0 then p.fireLong=0 end end
end
function F.nearest(x,y,radius)
 local best,dist=nil,radius*radius
 for _,group in ipairs({GROUP_ENEMY,GROUP_NONTJT}) do
  for _,e in ObjList(group) do
   if not e.protect and e.colli and e.hp and e.hp>0 then
    local d=(e.x-x)^2+(e.y-y)^2
    if d<dist then best,dist=e,d end
   end
  end
 end
 return best
end
function F.home(b,target)
 if target and b.timer<60 then
  local diff=(Angle(b,target)-b.heading+540)%360-180
  b.heading=b.heading+diff*.08
  if math.abs(diff)<15 then b.speed=math.min(16,b.speed+.2)
  elseif math.abs(diff)>=45 then b.speed=math.max(4,b.speed-.2) end
 else b.speed=math.min(16,b.speed+(target and .2 or .1)) end
end
