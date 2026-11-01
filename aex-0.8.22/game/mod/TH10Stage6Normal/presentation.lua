TH10S6Presentation={}
local P=TH10S6Presentation
local function clamp(x)return math.max(0,math.min(1,x))end
function P.bullet(b)
 local a=assert(TH10S6BulletArt[b.typ..':'..b.color],'unmapped source bullet')
 if b.birth and b.age<b.birth then
  local u=clamp(b.age/b.birth);local e=1-(1-u)^2
  return TH10S6Sprites.bullet[a.birth],3-2.5*e,255*u,'mul+add'
 end
 return TH10S6Sprites.bullet[a.body],1,255,a.add and 'mul+add' or ''
end
function P.cancel(b,t)
 local a=TH10S6BulletArt[b.typ..':'..b.color];local u=clamp(t/a.deathFrames)
 if b.typ==0 then return TH10S6Sprites.bullet[a.cancel],.4+1.5*(1-(1-u)^2),255*(1-u),a.deathFrames end
 return TH10S6Sprites.bullet[a.cancel],1-u*u,255,a.deathFrames
end
-- TH10 enemy.anm's five-script walk groups: idle, enter right/left,
-- return right/left. Mirror sprite orientation is a rendering operation.
function P.enemy(a)
 local script=a.anm and a.anm[0] or 49
 if script>=49 and script<=52 then return TH10S6Sprites.enemy[108+script-49],a.age*18,1 end
 local base=script==40 and 96 or script==30 and 72 or script==25 and 60 or 48
 local moving=a.walkMain and math.abs(a.x-(a.previousX or a.x))>.12
 local direction=moving and (a.x>(a.previousX or a.x) and 1 or -1) or 0
 if direction~=a.walkDirection then a.walkDirection=direction;a.walkAge=0 end
 local t=a.walkAge or 0;a.walkAge=t+1
 local sid,flip=base+math.floor(a.age/5)%4,1
 if direction~=0 then
  sid=t<12 and base+4+math.floor(t/4) or base+8+math.floor((t-12)/5)%4
  flip=direction<0 and -1 or 1
 end
 return TH10S6Sprites.enemy[sid],0,flip
end
function P.ring(a)
 local script=a.anm and a.anm[1]
 if not script or script<45 or script>48 then return end
 local sprite=({[45]=114,[46]=112,[47]=113,[48]=115})[script]
 local t=a.age%40;local u=t<20 and t/20 or 1-(t-20)/20
 local e=u<.5 and 2*u*u or 1-2*(1-u)^2
 return TH10S6Sprites.enemy[sprite],-a.age*18,1+.4*e,128
end
