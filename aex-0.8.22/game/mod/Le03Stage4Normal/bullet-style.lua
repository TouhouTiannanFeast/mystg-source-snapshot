-- User-requested appearance/speed selection, indexed by SOURCE spawn frame.
Le03BulletStyle={birthFrames=8}
local S=Le03BulletStyle
function S.assign(b,e)
 b.sourceAppear=e.appear or e.sourceAppear
 b.sourceShot=e.shot or e.sourceShot
 b.motionMultiplier=(b.sourceAppear==300 and b.sourceShot==58)and 2 or 1
 if b.typ==8 then b.style='rice' end
 if e.pointBurst then b.style='point' end
 if b.typ==3 then
  if b.sourceAppear==1100 or b.sourceAppear==3900 then b.style='scale'
  elseif b.sourceAppear==2700 or b.sourceAppear==3100 or b.sourceAppear==3500 then b.style='butterfly' end
  if b.sourceAppear==3500 then b.tint={255,100,190} end
  if b.sourceShot==54 and b.sourceAppear>=7300 and b.sourceAppear<=7700 then
   b.style='butterfly';b.tint={255,100,190}
  end
  if b.sourceAppear==9500 and b.sourceShot==60 then b.style='butterfly';b.rainbow=true end
 end
end
local palette={{255,255,255},{255,70,70},{210,90,255},{80,120,255},{80,245,255},{80,240,100},{255,240,80},{255,100,190}}
function S.rgb(b)
 if b.rainbow then
  -- All six roads in a volley have the same age and start blue together.
  local h=(2/3+(b.age or 0)/240)%1
  local q=h*6;local i=math.floor(q);local x=q-i
  local rgb=({{1,x,0},{1-x,1,0},{0,1,x},{0,1-x,1},{x,0,1},{1,0,1-x}})[i+1]
  return math.floor(rgb[1]*255+.5),math.floor(rgb[2]*255+.5),math.floor(rgb[3]*255+.5)
 end
 local c=b.tint or palette[(b.col or 0)%8+1];return c[1],c[2],c[3]
end
function S.image(b)
 if b.style=='rice' or b.style=='point' then return 'le03.th.b.'..b.style..'.'..((b.col or 0)%8)end
 if b.style=='scale' or b.style=='butterfly' then
  local col=(b.col or 0)%8
  if b.tint then col=7 end
  if b.rainbow then col=0 end
  return 'le03.th.b.'..b.style..'.'..col
 end
 if b.style then return 'le03.th.b.'..b.style end
 return 'le03.b'..(b.typ==8 and 8 or 3)..'.'..((b.col or 0)%8)
end
function S.birth(age)
 local u=math.max(0,math.min(1,(age or 0)/S.birthFrames))
 return u,2-1.5*u,1-u
end
function S.rainbowImages(b)
 local colors={3,2,7,1,6,5,4}
 local q=((b.age or 0)/240*7)%7;local i=math.floor(q)
 local stem='le03.th.b.butterfly.'
 return stem..colors[i+1],stem..colors[(i+1)%7+1],q-i
end
function S.bodyRGB(b)
 if (b.style=='rice' or b.style=='point' or b.style=='scale' or b.style=='butterfly') then return 255,255,255 end
 return S.rgb(b)
end
function S.load()
 for _,n in ipairs({'rice','point','scale','butterfly'})do for col=0,7 do
  local k='le03.th.b.'..n..'.'..col
  LoadTexture(k,(Le03AssetRoot or 'art/')..'touhou-bullets/'..n..'-'..col..'.png')
  local w,h=GetTextureSize(k);LoadImage(k,k,0,0,w,h)
 end end
 for _,n in ipairs({'rice','scale','butterfly','birth'})do
  local k='le03.th.b.'..n;LoadTexture(k,(Le03AssetRoot or 'art/')..'touhou-bullets/'..n..'.png')
  local w,h=GetTextureSize(k);LoadImage(k,k,0,0,w,h)
 end
end
