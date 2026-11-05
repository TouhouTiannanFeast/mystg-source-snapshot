-- Native TH20 EffectChargePoint::tick 0x45c360, ANM149/150.
-- Four root VMs from the two EffChargePoint2 calls in st07bs::Boss.
NinaIntro14={emitFrames=50,travel=60,particleLife=141,displayScale=2.5}
local M=NinaIntro14
local pi=math.pi
local roots={{pi/2,-pi/4,{128,255,255}},{0,-pi/4,{255,255,128}},
             {pi/2,pi/4,{255,255,128}},{pi,pi/4,{128,255,255}}}
local function vec(a,r)return {math.cos(a)*r,math.sin(a)*r}end
local function add(a,b)return{a[1]+b[1],a[2]+b[2]}end
local function sub(a,b)return{a[1]-b[1],a[2]-b[2]}end
local function norm(a)
 local n=math.sqrt(a[1]^2+a[2]^2)
 if n<.000001 then return{a[1],a[2]}end
 return{a[1]/n,a[2]/n}
end
local function length(a,n)local v=norm(a);return{v[1]*n,v[2]*n}end
function M.hermite(p0,p1,m0,m1,u)
 u=math.max(0,math.min(1,u));local u2,u3=u*u,u*u*u
 local a,b,c,d=2*u3-3*u2+1,-2*u3+3*u2,u3-2*u2+u,u3-u2
 return p0[1]*a+p1[1]*b+m0[1]*c+m1[1]*d,
        p0[2]*a+p1[2]*b+m0[2]*c+m1[2]*d
end
function M.build(random)
 local particles={}
 local function disk(radius)local r=random()*radius;local a=random()*2*pi-pi;return vec(a,r)end
 for birth=0,M.emitFrames-1 do
  for _,root in ipairs(roots)do
   local start,finish=vec(root[1],300),vec(root[1]+root[2],150)
   for kind=1,4 do
    local p0,p1=add(start,disk(150)),add(finish,disk(50))
    local direction=norm(sub(p1,p0));local inward=norm({-p1[1],-p1[2]})
    local tangent=length(add(direction,inward),200+random()*200)
    local endTangent=length(sub(p1,p0),100+random()*100)
    local p2,m2=disk(20),disk(20)
    local color=root[3]
    if kind==4 then color={(300-color[1])%256,(300-color[2])%256,(300-color[3])%256}end
    particles[#particles+1]={birth=birth,p0=p0,p1=p1,p2=p2,m0=tangent,m1=endTangent,m2=m2,
      light=kind==4,color=color,rotation=random()*2*pi-pi}
   end
  end
 end
 return particles
end
function M.sample(p,age)
 local t=age-p.birth
 if t<0 or t>=M.particleLife then return end
 local x,y
 if t<=60 then x,y=M.hermite(p.p0,p.p1,p.m0,p.m1,t/60)
 else x,y=M.hermite(p.p1,p.p2,p.m0,p.m2,(t-60)/60)end
 local alpha,scale
 if p.light then
  alpha=96*math.min(1,t/40);scale=2-t/140
 else alpha=80*math.min(1,t/10);scale=.6+1.8*math.min(1,t/120)end
 if t>=131 then alpha=alpha*(141-t)/10 end
 return x,y,alpha,scale
end
function M.render(particles,age,x,y)
 -- Original ANM150 layer6 add, ANM149 layer7 subtract; both above Nina.
 for pass=1,2 do
  for _,p in ipairs(particles)do
   if (pass==1)==p.light then
    local px,py,alpha,scale=M.sample(p,age)
    if px then
     local c=p.color
     local image='nina.intro12.mist'
     SetImageState(image,p.light and'mul+add'or'mul+rev',Color(alpha,c[1],c[2],c[3]))
     Render(image,x+px*M.displayScale,224-y-py*M.displayScale,p.rotation*180/pi,scale*M.displayScale,scale*M.displayScale)
    end
   end
  end
 end
end
