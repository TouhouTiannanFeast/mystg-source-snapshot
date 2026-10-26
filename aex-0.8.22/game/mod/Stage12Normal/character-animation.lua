Stage12Art={}
local A=Stage12Art
local definitions=dofile('mod/Stage12Normal/animation-data.lua')
function A.sample(seq,t)
 if t>=seq.duration and seq.loop then t=seq.loop+(t-seq.loop)%(seq.duration-seq.loop) end
 local sprite=seq.frames[1][2]
 for _,f in ipairs(seq.frames) do if f[1]<=t then sprite=f[2] else break end end
 return sprite
end
function A.update(o,id)
 local d=definitions[id];local s=o.stage12Anim
 if not s then s={state='idle',age=0,x=o.x,y=o.y,face=1};o.stage12Anim=s end
 local dx,dy=o.x-s.x,o.y-s.y;s.x,s.y=o.x,o.y
 local desired='idle'
 if math.abs(dx)>0.025 or math.abs(dy)>0.025 then
  if math.abs(dx)>0.025 then s.face=dx<0 and -1 or 1 end
  desired=s.face<0 and 'left' or 'right'
 end
 if desired=='idle' and (s.state=='left' or s.state=='right') and d.states['stop_'..s.state] then desired='stop_'..s.state end
 if desired=='idle' and s.state:find('stop_',1,true) and s.age<d.states[s.state].duration then desired=s.state end
 if desired~=s.state then s.state,s.age=desired,0 else s.age=s.age+1 end
 s.sprite=A.sample(d.states[s.state] or d.states.idle,s.age)
 return s
end
function A.attach(class,id)
 local old=class.frame
 class.frame=function(o) old(o);if IsValid(o) then A.update(o,id) end end
 class.render=function(o)
  o._bosssys:render()
  local s=o.stage12Anim or {state='idle',age=0,face=1,sprite=A.sample(definitions[id].states.idle,0)}
  local scale=definitions[id].scale
  local seq=definitions[id].states[s.state] or definitions[id].states.idle
  local mirror=seq.mirror and -1 or 1
  Render('u.'..id..'-'..s.sprite,o.x,o.y,0,scale*mirror,scale)
 end
end
function A.rotation(b)
 if b.stage12BulletFamily=='round' then return b.rot or 0 end
 local vx,vy=b.vx or 0,b.vy or 0
 local tangent=b.rot or 0
 if vx*vx+vy*vy>1e-8 then tangent=math.atan2(vy,vx)*180/math.pi end
 -- TH10 arrow/scale artwork points upwards in the unrotated image.
 return tangent-90
end
function A.installBulletRender(class)
 local previous=class.render
 class.render=function(b)
  if b.stage12BulletFamily then
   local rotation=A.rotation(b)
   if setting.stage12_combat_probe and b.stage12BulletFamily=='arrow' and not b.stage12RenderChecked then
    local vx,vy=b.vx or 0,b.vy or 0
    if vx*vx+vy*vy>1e-8 then
     local tangent=math.atan2(vy,vx)*180/math.pi
     assert(math.abs(((rotation+90-tangent+180)%360)-180)<1e-6,'chain sprite not tangent')
     b.stage12RenderChecked=true;print('BALANCE NATIVE TANGENT PASS angle='..tangent..' render='..rotation)
    end
   end
   Render(b.img,b.x,b.y,rotation,b.hscale or 1,b.vscale or 1)
  elseif previous then previous(b) end
 end
end
-- Replace sprite only; do not alter collision dimensions, velocity or HP.
function A.bullet(o,family,color)
 local a,b,rect=o.a,o.b,o.rect
 o.img='u.'..family..'-'..color;o.a,o.b,o.rect=a,b,rect
 o.stage12BulletFamily=family

end

Stage1GhostAnimation={['frames']={{0,136},{3,137},{6,138},{9,139},{12,140},{12,136},{15,137},{18,138},{21,139},{24,140},{27,141},{30,142},{33,143}},['duration']=36,['loop']=12}
