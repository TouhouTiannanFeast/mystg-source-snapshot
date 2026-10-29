-- Visual mapping only. No collision/HP/motion/firing values belong in this file.
Le03EnemyArt={}
local A=Le03EnemyArt
local maps={
 [0]={file='th18-enemy.png',x=320,y=144,w=48,h=48,n=4,rows={1,0,2}},
 [1]={file='th10-enemy.png',x=0,y=192,w=32,h=32,n=1,rows={0,0,0}},
 [2]={file='th07-stg1enm.png',x=256,y=0,w=32,h=32,n=8,rows={0,0,0}},
}
for kind,m in pairs(maps)do
 local tex='le03.th.enemy.tex'..kind
 LoadTexture(tex,(Le03AssetRoot or 'art/')..'touhou-enemies/'..m.file)
 for pose=0,2 do for frame=0,m.n-1 do
  LoadImage('le03.th.enemy'..kind..'.'..pose..'.'..frame,tex,m.x+frame*m.w,m.y+m.rows[pose+1]*m.h,m.w,m.h)
 end end
end
-- TH10 small fairies: four original palette rows, with idle/left/right poses.
LoadTexture('le03.th.small.tex',(Le03AssetRoot or 'art/')..'touhou-enemies/th10-enemy.png')
for color=0,3 do for pose=0,2 do for frame=0,3 do
 local start=({4,0,8})[pose+1]
 LoadImage('le03.th.small.'..color..'.'..pose..'.'..frame,'le03.th.small.tex',(start+frame)*32,color*32,32,32)
end end end
-- Source TH10 sprite108..111 (kedama), and sprite112 (red orb's matching ring).
for color=0,3 do
 LoadImage('le03.th.kedama.'..color,'le03.th.enemy.tex1',64+(color%2)*32,128+math.floor(color/2)*32,32,32)
end
LoadImage('le03.th.orb10.ring','le03.th.enemy.tex1',0,224,32,32)
LoadTexture('le03.th.orb13.tex',(Le03AssetRoot or 'art/')..'touhou-enemies/th13-enemy.png')
for color=0,3 do
 LoadImage('le03.th.orb13.body.'..color,'le03.th.orb13.tex',128+color*32,256,32,32)
 LoadImage('le03.th.orb13.ring.'..color,'le03.th.orb13.tex',128+color*32,288,32,32)
end
function A.keepOrb(e)return e.kind==1 and(e.appear==2700 or e.appear==3100 or e.appear==3500)end
function A.image(e)
 if e.extraArt=='kedama' then return 'le03.th.kedama.'..((e.artColor or 0)%4)end
 if e.extraArt=='orb13' then return 'le03.th.orb13.body.'..((e.artColor or 0)%4)end
 if (e.kind==1 or e.kind==2)and not A.keepOrb(e)then
  local color=((e.sourceIndex or 0)+math.floor((e.appear or 0)/100))%4
  return 'le03.th.small.'..color..'.'..((e.pose or 1)%3)..'.'..(math.floor((e.age or 0)/10)%4)
 end
 local kind=math.max(0,math.min(2,e.kind or 0));local m=maps[kind]
 local pose=(e.pose or 1)%3;local frame=math.floor((e.age or 0)/10)%m.n
 return 'le03.th.enemy'..kind..'.'..pose..'.'..frame
end
local function ease9(u)return u<.5 and 2*u*u or 1-(-2*u+2)^2/2 end
function A.entry(e)
 if not e.opening then return 255,1 end
 local u=math.max(0,math.min(1,(e.age or 0)/20))
 return math.floor(255*u),.4+.6*ease9(u)
end
function A.rings(e)
 local age=e.age or 0
 if e.extraArt=='orb13' then
  -- TH13 stage2 ECir00 -> enemy.anm script53 -> child54/55, sprites116..119.
  -- Native y-down rotations become opposite signs in the host's y-up rendering.
  local img='le03.th.orb13.ring.'..((e.artColor or 0)%4)
  return {{img=img,rotation=-age*11.25,scale=1,alpha=255},
          {img=img,rotation=age*5.625,scale=1.5,alpha=255}}
 end
 if A.keepOrb(e)then
  -- TH10 enemy.anm script46: matching ring, alpha128,18deg/frame,20-frame scale tween.
  local scale
  if age<20 then scale=1.4*ease9(age/20)
  else local q=(age-20)%40/20;scale=q<1 and 1.4-.4*ease9(q)or 1+.4*ease9(q-1)end
  return {{img='le03.th.orb10.ring',rotation=-age*18,scale=scale,alpha=128}}
 end
 return {}
end
function A.rotation(e)
 if e.extraArt=='kedama'then return ((e.age or 0)*18)%360 end -- TH10 script49, native -pi/10 in y-down coordinates.
 if A.keepOrb(e)then return ((e.age or 0)*3)%360 end
 return 0
end
