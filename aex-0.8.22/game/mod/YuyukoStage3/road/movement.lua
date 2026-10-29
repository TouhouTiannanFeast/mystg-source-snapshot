-- LE03 1.21a stage-four Normal movement callbacks.
-- Coordinates use the source's y-down pixel system. No firing approximation lives here.
local M={}
local C={half=.5,turn=.6666666865348816,rise=.21666666865348816,
 leave=.30000001192092896,curveX=.4000000059604645,curveY=.1666666716337204,
 phase=.03141592653589,quarter=.78539816339725,diagonal=2.3561944901917498,
 down=1.5707963267945,left=3.141592653589,up=-1.5707963267945}
M.ids={[22]=true,[23]=true,[47]=true,[48]=true,[49]=true,[50]=true,[90]=true,[91]=true,
 [92]=true,[93]=true,[96]=true,[97]=true,[105]=true,[106]=true,[107]=true}

-- Lua numbers are doubles; the host may provide f32 to reproduce JS/native float stores.
local function f32native(x)
 if x==0 or x~=x or x==math.huge or x==-math.huge then return x end
 local s=x<0 and -1 or 1;x=math.abs(x)
 local m,e=math.frexp(x)
 -- Round to IEEE-754 binary32 precision (nearest, ties to even).
 local q
 if e < -125 then q=2^-149 else q=2^(e-24) end
 local n=x/q;local lo=math.floor(n);local frac=n-lo
 if frac>0.5 or(frac==0.5 and lo%2==1)then lo=lo+1 end
 return s*lo*q
end
local f32=math.f32 or f32native
M.f32=function(fn)if fn then f32=fn end;return f32 end
local function finite(x)return type(x)=='number' and x==x and x<math.huge and x>-math.huge end
function M.create(c)
 assert(type(c)=='table' and #c==20,'expected 20 numeric source cells')
 for i=1,20 do assert(finite(c[i]),'source cell must be numeric')end
 local e={appear=c[1],move=c[2],kind=c[3],x=f32(c[4]),y=f32(c[5]),hp=c[6],speed=f32(c[7]),
  wait=c[8],invincible=c[9],shot=c[10],shotTime=c[11],bulletKind=c[12],color=c[13],addedSpeed=c[14],
  items={c[15],c[16],c[17],c[18],c[19],c[20]},age=0,shotAge=0,vx=0,vy=0,angle=0,pose=1,active=true}
 assert(M.ids[e.move],'unported movement '..tostring(e.move));return e
end
function M.move(e)
 local t,w,id=e.age,e.wait,e.move
 if id==22 or id==23 then
  if t==0 then e.vy=2 elseif t==45 then e.vy=0 end
  if t==w+45 then e.vx=id==22 and -1 or 1;e.vy=-1;e.pose=id==22 and 0 or 2 end
 elseif id==47 or id==48 then
  if t==0 then e.angle=C.down;e.speed=10 end
  if t<15 then e.angle=C.down;e.speed=f32(e.speed-C.turn) end
  if t>=20 and t<35 then e.pose=id==47 and 0 or 2;e.angle=id==47 and C.left or 0;e.speed=f32(e.speed+C.turn) end
  if t>=35 and t<50 then e.pose=1;e.angle=id==47 and C.left or 0;e.speed=f32(e.speed-C.turn) end
  if t>=w+50 then e.angle=C.up;e.speed=f32(e.speed+C.turn) end
 elseif id==49 or id==50 then
  if t==0 then e.angle=id==49 and C.quarter or C.diagonal;e.speed=10 end
  if t<=19 then e.speed=f32(e.speed-C.half) end
  if t>=w+20 then e.angle=id==49 and 0 or C.left;e.speed=f32(e.speed-C.turn) end
 elseif id==90 or id==91 then
  local s=id==90 and -1 or 1
  if t==0 then e.vy=-13;e.pose=id==90 and 0 or 2 end
  if t>=20 and t<40 then e.vx=f32(e.vx+s*C.half) end
  if t>=40 and t<60 then e.vx=f32(e.vx-s*C.half) end
  if t<60 then e.vy=f32(e.vy+C.rise) elseif t<w+60 then e.vx=0;e.vy=0;e.pose=1 end
  if t>=w+60 then e.vx=f32(e.vx-s*C.leave);e.pose=id==90 and 2 or 0 end
 elseif id==92 or id==93 then
  local s=id==92 and -1 or 1;local p=id==92 and 0 or 2
  if t==0 then e.vx=s*5;e.vy=-3;e.pose=p
  elseif t>=30 and t<w+30 then e.vx=0;e.vy=0;e.pose=1 end
  if t>=w+30 and t<w+60 then e.vx=s*5;e.vy=3;e.pose=p end
  if t>=w+60 and t<2*w+60 then e.vx=0;e.vy=0;e.pose=1 end
  if t>=2*w+60 then e.vx=s*5;e.vy=-3;e.pose=p end
 elseif id==96 or id==97 then
  local s=id==96 and -1 or 1
  if t<30 then e.vx=f32(e.vx+s*C.curveX);e.vy=f32(e.vy-C.curveY);e.pose=id==96 and 0 or 2
  elseif t<60 then e.vx=f32(e.vx-s*C.curveX);e.vy=f32(e.vy+C.curveY);e.pose=id==96 and 0 or 2 end
  if t==60 then e.vx=0;e.vy=0;e.pose=1 end
  if t>=100 then e.pose=id==96 and 2 or 0;e.vx=-s;e.vy=f32(math.sin((t-100)*C.phase)) end
 elseif id==105 or id==106 then
  if t==0 then e.pose=id==105 and 2 or 0;e.angle=id==105 and C.quarter or C.diagonal;e.speed=1.5 end
 elseif id==107 then
  if t==0 then e.vy=2 elseif t==45 then e.vy=0
  elseif t>=100 and t<w+100 then e.x=f32(e.x+f32(f32(math.cos(t*C.phase))*2));e.pose=1 end
  if t>=w+100 then e.x=f32(e.x+f32(f32(math.cos(t*C.phase))*2));e.vy=-1;e.pose=1 end
 else error('unported movement '..tostring(id)) end
end
function M.step(e,fire,inBounds)
 if not e.active then return end
 M.move(e)
 e.x=f32(e.x+f32(f32(math.cos(e.angle))*e.speed));e.y=f32(e.y+f32(f32(math.sin(e.angle))*e.speed))
 e.x=f32(e.x+e.vx);e.y=f32(e.y+e.vy)
 if inBounds and not inBounds(e) then e.active=false end
 if e.shot>=0 and e.age>=e.shotTime then assert(type(fire)=='function','missing firing callback '..tostring(e.shot));fire(e);e.shotAge=e.shotAge+1 end
 e.age=e.age+1
end
Le03Movement=M
return M
