-- Cosmetic source tasks. No collision, combat RNG, HP, projectile or timer edits.
-- References: source/audio-fx07/{lib_Con,lib_EffectLib,lib_SpellEffect,06b_Background}.
local R=Zuu4R
local F={items={},clock=0,seed=7307};R.fx=F
local sin,cos=R.sin,R.cos
local function rand(a,b)F.seed=F.seed*16807%2147483647;return a+(b-a)*(F.seed-1)/2147483646 end
local function add(kind,life,p)
 p=p or{};p.kind=kind;p.life=life;p.age=0;F.items[#F.items+1]=p;return p
end
function F.reset(id)
 F.items={};F.clock=0;F.id=id;F.spell=false
 F.base=id=='non1' and 1 or id=='final' and 0 or 2
end
function F.step()
 F.clock=F.clock+1
 F.eraseCount=math.max(0,(F.eraseCount or 0)-3)
 local live={}
 for _,p in ipairs(F.items)do
  if p.step then p.step(p)end
  p.age=p.age+1;if p.age<p.life then live[#live+1]=p end
 end
 F.items=live
end
function F.load()
 local pre='stages/zuu4/art/fx/'
 for _,n in ipairs({'white','power_effect','particle','expcloud','explode2','explode3','circle','bulleteffect','horou1','BG06b_a','BG06b_b','BG06b_c','BG06b_d','BG06a0_lite','BG06a1_lite','BG06a2_lite'})do
  LoadTexture('horou.fx.'..n,pre..n..'.png')
  local w,h=GetTextureSize('horou.fx.'..n);LoadImage('horou.fx.'..n,'horou.fx.'..n,0,0,w,h)
 end
 LoadImage('horou.fx.spark','horou.fx.particle',128,0,64,64)
 LoadImage('horou.fx.power','horou.fx.power_effect',0,0,256,256)
 LoadImage('horou.fx.cloud','horou.fx.expcloud',0,0,128,128)
 LoadImage('horou.fx.deathA','horou.fx.explode2',0,0,128,128)
 LoadImage('horou.fx.deathB','horou.fx.explode3',0,0,256,256)
 LoadTexture('horou.fx.break','stages/zuu4/art/fx/BulletBreak.png')
 for i=0,7 do LoadImage('horou.fx.break'..i,'horou.fx.break',i*128,0,128,128)end
 LoadTexture('horou.fx.maple','stages/zuu4/art/fx/th20-maple.png');LoadImage('horou.fx.maple','horou.fx.maple',32,0,32,32)
end
local function draw(img,x,y,a,sx,sy,alpha,col,blend)
 col=col or{255,255,255};SetImageState(img,blend or'mul+add',Color(math.max(0,math.min(255,alpha)),col[1],col[2],col[3]))
 Render(img,x-192,224-y,-a,sx,sy)
end
local function particle(x,y,col)
 add('spark',30,{x=x,y=y,col=col,a=rand(0,360)})
end
function F.point(x,y,target,col,count,timer,size,wt)
 size=size or 180;wt=wt or 3
 R.spawn(function()
  for i=1,count do
   local ea,oa=rand(0,360),rand(0,360);local da=rand(0,2)>1 and -3 or 3
   local ex,ey=x,y
   add('point',timer,{step=function(p)
    if target.dead then p.life=0;return end
    local t=p.age;local u,er
    if t<timer/3 then u=t/(timer/3);er=((1-cos(u*180))/2)*size
    else u=1-cos((t-timer/3+1)/(timer*2/3)*90);er=(1-u)*size;ex=x*(1-u)+target.x*u;ey=y*(1-u)+target.y*u end
    local dx,dy=er*cos(ea),er/2*sin(ea)
    particle(ex+dx*cos(oa)-dy*sin(oa),ey+dx*sin(oa)+dy*cos(oa),col)
    ea=ea+da*(t<timer/3 and 1 or 1-u)
   end})
   R.wait(wt)
  end
 end)
end
function F.charge(target,timer)
 timer=timer or 90
 R.spawn(function()
  local t=math.max(timer/2,timer-60);local life=t<60 and t+30 or 60
  for i=1,math.ceil(t/2)do
   add('charge',life,{target=target,a=rand(0,360),spin=rand(-360,360),ax=rand(-60,60),ay=rand(-60,60)})
   R.wait(2)
  end
 end)
end
function F.cloud(x,y)
 R.spawn(function()for i=1,15 do add('cloud',60,{x=x,y=y,a=rand(0,360)});R.wait(1)end end)
end
function F.arrow(x,y,angle,timer)
 -- Source emits a subtract/add beam pair every3 frames, each survives30.
 R.spawn(function()
  for i=0,timer/3-1 do add('arrow',30,{x=x,y=y,a=angle,len=160*math.max(1,3-i*0.25)});R.wait(3)end
 end)
end
function F.square(x,y,angle)
 R.spawn(function()
  for i=0,7 do add('square',45,{x=x,y=y,a=angle+45,r=0,step=function(p)p.r=p.r+2.5*(45-p.age)/45*0.707 end});R.wait((i+1)*2)end
 end)
end
local eraseColors={{255,255,255},{255,64,64},{64,255,64},{64,64,255},{255,255,64},{255,46,255},{64,255,255},{255,140,64}}
function F.newErase(b)
 if (F.eraseCount or 0)>=60 then return end
 local n=b.radius>8 and 3 or 1;F.eraseCount=(F.eraseCount or 0)+n
 local d={col=eraseColors[b.id%8+1],parts={}}
 for i=1,n do d.parts[i]={x=b.x+(n==3 and rand(-16,16)or 0),y=b.y+(n==3 and rand(-16,16)or 0),
  size=(16+b.radius*4)/(n==3 and 2 or 1),vx=rand(-2,2),vy=rand(-2,2),a=rand(0,360),start=(i-1)*6}end
 return d
end
function F.eraseStep(d,t)
 for _,p in ipairs(d.parts)do local age=t-p.start;if age>=0 and age<32 then local u=1-age/32;p.x,p.y=p.x+p.vx*u,p.y+p.vy*u end end
end
function F.eraseRender(d,t)
 for _,p in ipairs(d.parts)do local age=t-p.start;if age>=0 and age<32 then
  local img='horou.fx.break'..math.floor(age/4);local c=d.col;local s=p.size/64
  draw(img,p.x,p.y,p.a,s,s,64,{255-c[1],255-c[2],255-c[3]},'mul+rev');draw(img,p.x,p.y,p.a,s,s,128,c)
 end end
end
function F.th20Charge(target,expand)
 add('th20Ring',40,{target=target,expand=expand})
 R.spawn(function()
  for i=1,30 do
   local a=rand(0,360)
   add('th20Leaf',40,{target=target,expand=expand,dx=256*cos(a),dy=256*sin(a),sc=rand(2,5),a=rand(0,360),ax=rand(-180,180),ay=rand(-180,180)})
   R.wait(1)
  end
 end)
end
function F.deathStart(origin)return {origin=origin,items={}}end
function F.deathStep(d,t)
 if t<60 and t%3==0 then
  d.items[#d.items+1]={kind='deathA',age=0,life=45,size=4+t/3/19*10,a=rand(0,360),spin=rand(-1,1)}
 end
 if t>=90 and t<135 then
  d.items[#d.items+1]={kind='deathB',age=0,life=120,size=math.sqrt(rand(0,36)),a=rand(0,360),col={rand(128,255),rand(128,255),128}}
 end
 local live={};for _,p in ipairs(d.items)do p.age=p.age+1;if p.age<p.life then live[#live+1]=p end end;d.items=live
end
function F.deathRender(d)
 for _,p in ipairs(d.items)do
  local u=(p.life-p.age)/p.life
  if p.kind=='deathA'then
   local sc=p.size*sin(u*180)*(1+u)/2;draw('horou.fx.deathA',d.origin.x,d.origin.y,p.a+p.age*p.spin,sc,sc,(1-u)*128)
  else local v=sin(u*90);local sc=(1-v)^0.33*p.size;draw('horou.fx.deathB',d.origin.x,d.origin.y,p.a,sc,sc,math.min(108,192*v),p.col)end
 end
end
function F.spellStart()
 F.spell=true;F.spellTick=F.clock;R.sound('spell')
 -- Horou uses CUTMOTION_NORMAL: curved entrance,75f hold,36f exit.
 local p=add('cutin',135,{x=448,y=108,a=135,speed=18})
 p.step=function(q)
  local t=q.age;local vx,vy
  if t<24 then q.speed=q.speed-17/24;q.a=q.a+15/24
  elseif t<99 then q.x=q.x+q.speed*cos(q.a);q.y=q.y+q.speed*sin(q.a);q.a=q.a+30/75
  else q.speed=q.speed+10/36 end
  vx,vy=q.speed*cos(q.a),q.speed*sin(q.a);q.x,q.y=q.x+vx,q.y+vy
  local alpha=t<24 and sin((t+1)*90/24)*255 or t<99 and 255 or sin((135-t)*90/36)*255
  q.alpha=alpha
  add('cutinShadow',45,{x=q.x,y=q.y,vx=cos(q.a),vy=sin(q.a),alpha=alpha,step=function(s)
   local v=(s.age+1)/45*2;s.x,s.y=s.x+s.vx*v,s.y+s.vy*v
  end})
 end
end
local function tex(name,blend,rect,uv,alpha,col)
 col=col or{255,255,255};local c=Color(alpha,col[1],col[2],col[3]);local x1,y1,x2,y2=unpack(rect);local u1,v1,u2,v2=unpack(uv)
 RenderTexture('horou.fx.'..name,blend,{x1-192,224-y1,0,u1,v1,c},{x2-192,224-y1,0,u2,v1,c},{x2-192,224-y2,0,u2,v2,c},{x1-192,224-y2,0,u1,v2,c})
end
function F.background()
 local a=sin(math.min(90,F.clock*90/60))*255
 tex('BG06a'..F.base..'_lite','',{0,0,384,448},{0,0,384,448},a)
 if not F.spell then return end
 local t=F.clock-F.spellTick;local fade=sin(math.min(90,t*2))
 tex('BG06b_a','',{-64,0,448,448},{0,0,512,448},fade*255,{192,192,192})
 tex('BG06b_b','mul+mul',{-115.2,-83.2,499.2,531.2},{0,t/4,512,512+t/4},fade*255)
 tex('BG06b_c','mul+add',{-64,-32,448,480},{0,t,512,512+t},fade*64)
 -- Original two rotating24-sided textured fans, translated to degenerate quads.
 for j,r in ipairs({512,768})do
  for i=0,23 do
   local pc=i*15;local aa=pc+t*(j==1 and 0.1 or 0.2);local bb=aa+15
   local rd1=768+512*sin(pc*2+t/4);local rd2=768+512*sin((pc+15)*2+t/4)
   local c=Color(fade*192,64,128,255);local scr=math.ceil(t/2)*2
   RenderTexture('horou.fx.BG06b_d','mul+rev',
    {0,64,0,-scr,0,c},
    {r*cos(aa),64-r*sin(aa),0,rd1*cos(pc)-scr,rd1*sin(pc),c},
    {r*cos(bb),64-r*sin(bb),0,rd2*cos(pc+15)-scr,rd2*sin(pc+15),c},
    {0,64,0,-scr,0,c})
  end
 end
end
function F.render(which)
 for _,p in ipairs(F.items)do
  local t=p.age;local u=math.min(1,(t+1)/p.life)
  if which=='cutin' then
   if p.kind=='cutin'then draw('horou.fx.horou1',p.x,p.y,0,0.65,0.65,p.alpha or 0,nil,'')
   elseif p.kind=='cutinShadow'then local sc=0.65*(1.1+u/2);draw('horou.fx.horou1',p.x,p.y,0,sc,sc,(1-u)*p.alpha/24)end
  elseif which=='front' then
   if p.kind=='spark'then draw('horou.fx.spark',p.x,p.y,p.a,0.5*(1-u),0.5*(1-u),255,p.col)
   elseif p.kind=='charge'and not p.target.dead then
    local v=sin(u*90);local sc=(1-v)^0.33*2.5;local a=p.a+p.spin*(1-v)^0.33;local alpha=math.min(108,192*v)
    draw('horou.fx.power',p.target.x,p.target.y,a,sc*cos(p.ax),sc*cos(p.ay),alpha*0.75,{128,128,128},'mul+rev')
    draw('horou.fx.power',p.target.x,p.target.y,a,sc*cos(p.ax),sc*cos(p.ay),alpha,{255,255,255})
   elseif p.kind=='cloud'then local v=(1-cos(u*180))/2;draw('horou.fx.cloud',p.x,p.y,p.a,v*20,v*20,255*(1-v),{24,16,64})
   elseif p.kind=='arrow'then
    local v=sin(u*90);local len=p.len*(1-v)
    for i=0,1 do
     local w=64*v*v*(i==0 and 2 or 1);local img=Zuu4Art.shots[377].image
     local col=i==0 and{64,128,128}or{128,64,64}
     draw(img,p.x+len/2*cos(p.a),p.y+len/2*sin(p.a),p.a+90,w/16,len/16,255,col,i==0 and'mul+rev'or'mul+add')
    end
   elseif p.kind=='th20Ring'then
    local r=256*(p.expand and u*1.5 or 1-u);local alpha=p.expand and 255*math.max(0,1-(t+1)/20)or 255*math.min(1,(t+1)/20)*math.min(1,math.max(0,(30-t)/10))
    local x,y=p.target.x-192,224-p.target.y
    for i=0,35 do
     local a,b=i*10,(i+1)*10;local c0=Color(alpha,255,0,0);local c1=Color(alpha,255,80,80)
     RenderTexture('horou.fx.white','mul+add',{x,y,0,0,0,c0},{x+r*cos(a),y-r*sin(a),0,0,0,c1},{x+r*cos(b),y-r*sin(b),0,0,0,c1},{x,y,0,0,0,c0})
    end
   elseif p.kind=='th20Leaf'then
    local k=1-(1-u)^2;local d=p.expand and k or 1-k;local sc=p.sc*(p.expand and 1 or 1-math.max(0,(t-20)/20))
    local alpha=t<20 and 128*sin((t+1)/20*90)or 128*(1-(t-20)/20)^2
    draw('horou.fx.maple',p.target.x+p.dx*d,p.target.y+p.dy*d,p.a,sc*cos(p.ax),sc*cos(p.ay),alpha)
   elseif p.kind=='square'then
    for i=0,3 do
     local a=p.a+i*90;local x1=p.x+p.r*(cos(a)-sin(a));local y1=p.y+p.r*(sin(a)+cos(a))
     local x2=p.x+p.r*(cos(a)+sin(a));local y2=p.y+p.r*(sin(a)-cos(a))
     local dx,dy=0.5*cos(a),0.5*sin(a)
     SetImageState('horou.fx.white','mul+add',Color(255,192,64,64))
     Render4V('horou.fx.white',x1-dx-192,224-y1+dy,0,x2-dx-192,224-y2+dy,0,x2+dx-192,224-y2-dy,0,x1+dx-192,224-y1-dy,0)
    end
   end
  end
 end
end
