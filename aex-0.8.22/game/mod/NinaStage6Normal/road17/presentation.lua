TH11S6Presentation={}
local P=TH11S6Presentation
P.frog={}
for i,n in ipairs({22,23,21})do
 local name='th11s6.frog09.'..n
 LoadTexture(name,'road17/art/frog09/th12-'..n..'-y.png');LoadImage(name,name,0,0,32,32)
 P.frog[i]=name
end
local function clamp(u)return math.max(0,math.min(1,u))end
function P.bullet(b)
 local a=assert(TH11S6BulletArt[b.typ..':'..b.color])
 if b.birth and b.age<b.birth then
  local u=clamp(b.age/b.birth);local e=1-(1-u)^2
  return TH11S6Sprites.bullet[a.birth],a.birthScale+(0.5-a.birthScale)*e,255*u,'mul+add'
 end
 return TH11S6Sprites.bullet[a.body],1,255,a.add and 'mul+add' or ''
end
function P.cancel(b,t)
 local a=TH11S6BulletArt[b.typ..':'..b.color];local u=clamp(t/a.deathFrames)
 if b.typ==12 then return TH11S6Sprites.bullet[a.cancel],1+.5*(1-(1-u)^2),255*(1-u),a.deathFrames end
 return TH11S6Sprites.bullet[a.cancel],1-u*u,255,a.deathFrames
end
function P.enemy(a)
 if a.name=='RPhantom01' then
  return P.frog[math.floor(math.max(0,a.age-(a.poseStart or 0))/3)%3+1],0,1
 end
 if a.name:sub(1,4)=='Crow' then
  local frame=({25,26,27,28,27,26})[math.floor(a.age/3)%6+1]
  return TH11S6Sprites.crow[frame],0,a.mirror and -1 or 1
 end
 local s=a.anm and a.anm[0]or 98
 local base=({[94]=155,[96]=163,[98]=171,[100]=179})[s]or 171
 return TH11S6Sprites.enemy[base+math.floor(math.max(0,a.age-(a.poseStart or 0))/3)%5],0,1
end
function P.ring(a)
 -- The halo ANM is shared by crows and the corresponding-color phantoms.
 local sid=a.anm and a.anm[1];local sprite=({[45]=139,[46]=137,[47]=138,[48]=140})[sid]
 if a.name=='RPhantom01'and sprite then sprite=140 end
 if not sprite then return end
 local u=(a.age%40)/20;if u>1 then u=2-u end
 local e=u<.5 and 2*u*u or 1-2*(1-u)^2
 local scale=a.age<20 and 1.4*(1-(1-a.age/20)^2)or 1+.4*e
 return TH11S6Sprites.enemy[sprite],-a.age*18,scale,128
end
