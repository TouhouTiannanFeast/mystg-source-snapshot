local R=Suwako5Runtime
local pi=math.pi
local modern={ [1]='boost',[2]='birth',[4]='vector',[8]='polar',[16]='step',[64]='bounce',[128]='invuln',[256]='cull',[512]='sprite',[1024]='delete',[2048]='sound',[4096]='wrap',[8192]='prepare',[16384]='shoot',[1048576]='bright',[2097152]='targetSpeed',[-2147483648]='wait'}
local old={ [2]='birth',[4]='vector',[8]='polar',[16]='relative',[32]='aimed',[64]='absolute',[256]='bounce',[512]='bounceNoBottom',[1024]='cull',[2048]='sprite',[4096]='wait',[8192]='delete',[268435456]='photoFlag'}
local th10={ [1]='boost',[2]='birth',[4]='birth',[16]='vector',[32]='polar',[64]='relative',[128]='aimed',[256]='absolute',[1024]='bounce',[2048]='bounceNoBottom',[4096]='invuln',[8192]='cull',[16384]='sprite',[32768]='wait',[65536]='delete'}
R.transformMaps={th10=th10,ds=old,isc=modern}
local function resolve(b,ang)
 if ang<=-990 then return b.angle elseif ang>=990 then return math.atan2(R.playerY-b.y,R.playerX-b.x) end
 return ang
end
local function velocity(b,speed)
 b.vx,b.vy=R.polar(b.angle,speed or b.speed)
end
function R.clearHazards(lasersOnly)
 for _,b in ipairs(R.hazards or {}) do if not lasersOnly or b.laser then b.dead=true end end
end
function R.fire(a,p)
 if a.group=='dsd' and p.laser and R.dsLaserWaveTick~=R.tick then
  R.dsLaserWaveTick=R.tick;R.dsLaserWaves=(R.dsLaserWaves or 0)+1
  R.photos=math.min(2,R.dsLaserWaves-1)
 end
 local base=p.angle or 0;local n,layers=p.n or 1,p.layers or 1
 local aim=math.atan2(R.playerY-a.y,R.playerX-a.x)
 for j=0,layers-1 do for i=0,n-1 do
  local angle=base;local speed=layers>1 and p.speed-(p.speed-p.speed2)*j/layers or p.speed
  local mode=p.aim or 0
  if mode==0 or mode==1 then
   local d=(n%2==1 and math.floor((i+1)/2) or math.floor(i/2)+0.5)*(p.step or 0)
   if i%2==1 then d=-d end;angle=angle+d+(mode==0 and aim or 0)
  elseif mode==2 or mode==3 then angle=angle+i*2*pi/n+j*(p.step or 0)+(mode==2 and aim or 0)
  elseif mode==4 or mode==5 then angle=angle+pi/n+i*2*pi/n+(mode==4 and aim or 0)
  elseif mode==6 or mode==8 then angle=R.random()*(base-(p.step or 0))+(p.step or 0)
  elseif mode==7 then angle=angle+i*2*pi/n+j*(p.step or 0) end
  if mode==7 or mode==8 then speed=p.speed2+R.random()*(p.speed-p.speed2) end
  local x=(p.absolute and 0 or a.x)+(p.ox or 0)+math.cos(angle)*(p.dist or 0)
  local y=(p.absolute and 0 or a.y)+(p.oy or 0)+math.sin(angle)*(p.dist or 0)
  local b={group=a.group,x=x,y=y,angle=angle,speed=speed,typ=p.typ,color=p.color,ex=R.copy(p.ex),pc=p.start or 0,active={},age=0,cull=10,laser=R.copy(p.laser),alive=true}
  velocity(b);R.hazards[#R.hazards+1]=b
  if b.laser then R.stats.lasers=R.stats.lasers+1 else R.stats.bullets=R.stats.bullets+1 end
  if R.onShot then R.onShot(b) end
 end end
end
local function kind(b,r)
 local map=b.group=='th10' and th10 or b.group:sub(1,2)=='ds' and old or modern
 return assert(map[r.kind],'unsupported transform '..b.group..'/'..tostring(r.kind))
end
local function begin(b,r,k)
 if k=='birth' then
  if b.age==0 then
   b.birth=b.group=='th10' and (r.kind==4 and 15 or 8) or (r.i==1 and 15 or r.i==2 and 25 or 8)
   b.x,b.y=b.x-4*b.vx,b.y-4*b.vy
  end
 elseif k=='sprite' then b.typ,b.color=r.i,r.j
 elseif k=='cull' then b.cull=r.i
 elseif k=='delete' then b.dead=true
 elseif k=='invuln' then b.bombProof=r.i
 elseif k=='sound' then return
 elseif k=='photoFlag' then b.photoFlag=r.i -- retained; camera interaction is removed by the host
 elseif k=='bright' then b.bright=r.i
 elseif k=='prepare' then b.child={aim=r.i,start=r.j,n=r.k,layers=r.l,angle=r.r,step=r.s,speed=r.u,speed2=r.v,ex=b.ex}
 elseif k=='shoot' then
  local p=assert(b.child,'child shot without preparation');p.typ,p.color=r.i,r.j
  R.fire({group=b.group,x=b.x,y=b.y},p)
  if r.k and r.k~=0 then b.dead=true end
 elseif k=='wait' then b.active[#b.active+1]={kind=k,age=0,n=r.i}
 elseif k=='vector' or k=='polar' or k=='targetSpeed' then
  b.active[#b.active+1]={kind=k,age=0,n=r.i,r=k=='targetSpeed' and (r.r-b.speed)/r.i or r.r,s=k=='polar' and r.s or resolve(b,r.s)}
 elseif k=='relative' or k=='aimed' or k=='absolute' then
  b.active[#b.active+1]={kind=k,age=0,n=r.i,count=r.j,r=resolve(b,r.r),s=r.s>-999 and r.s or b.speed}
 elseif k=='step' then error('step transform is outside selected source')
 elseif k=='boost' then b.active[#b.active+1]={kind=k,age=0,n=16}
 elseif k=='bounce' or k=='bounceNoBottom' or k=='wrap' then
  if b.laser and b.laser.nativeLine and k~='wrap' then
   -- Native line-laser templates consume a reflection at activation; reflected
   -- children copy the reduced template, preventing a second unintended bounce.
   if r.i<=0 then return end
   r.i=r.i-1
   b.active[#b.active+1]={kind=k,age=0,count=1,r=r.r>=0 and r.r or b.speed,nativeLine=true}
  else b.active[#b.active+1]={kind=k,age=0,count=r.i,mask=r.j,r=r.r} end
 else error('unimplemented transform '..k) end
end
function R.projectileStep(b)
 if b.dead then return end
 if b.birth and b.age==b.birth and b.group=='th10' then b.x,b.y=b.x+b.vx*0.5,b.y+b.vy*0.5 end
 if not b.birth or b.age>=b.birth then
  for _=1,36 do
   local r=b.ex[b.pc]
   if not r then break end
   if #b.active>0 and r.async==0 then break end
   b.pc=b.pc+1;begin(b,r,kind(b,r))
   if b.dead then return end
   if b.birth and b.age<b.birth then break end
  end
 end
 local active={}
 for _,s in ipairs(b.active) do
  local keep=true;local k=s.kind
  if k=='vector' or k=='targetSpeed' then
   if s.age<s.n then
    b.speed=b.speed+s.r;b.vx=b.vx+math.cos(s.s)*s.r;b.vy=b.vy+math.sin(s.s)*s.r
    b.angle=math.atan2(b.vy,b.vx)
   else keep=false end
  elseif k=='polar' then
   if s.age<s.n then b.speed=b.speed+s.r;b.angle=R.rad(b.angle+s.s);velocity(b) else keep=false end
  elseif k=='relative' or k=='absolute' or k=='aimed' then
   if s.age>=s.n then
    s.count=s.count-1
    if k=='relative' then b.angle=b.angle+s.r elseif k=='absolute' then b.angle=s.r else b.angle=math.atan2(R.playerY-b.y,R.playerX-b.x)+s.r end
    b.speed=s.s;velocity(b);s.age=0;if s.count<=0 then keep=false end
   else velocity(b,b.speed*(1-s.age/math.max(1,s.n))) end
  elseif k=='wait' then keep=s.age<s.n
  elseif k=='boost' then if s.age<=s.n then velocity(b,b.speed+5-s.age*0.3125) else keep=false end
  elseif k=='bounce' or k=='bounceNoBottom' or k=='wrap' then
   if s.nativeLine then
    -- TH10 type-0 reflection tests the leading tip, not the moving tail.
    local hx=b.x+math.cos(b.angle)*b.laser.length
    local hy=b.y+math.sin(b.angle)*b.laser.length
    local hitX=hx< -192 or hx>=192
    local hitY=hy<0 or (k=='bounce' and hy>=448)
    if hitX or hitY then
     local function reflect(angle)
      local l=R.copy(b.laser);l.length=l.initial
      R.fire({group=b.group,x=hx,y=hy},{typ=b.typ,color=b.color,angle=angle,speed=s.r,speed2=s.r,n=1,layers=1,aim=1,laser=l,ex=b.ex})
     end
     if hitX then reflect(R.rad(-b.angle-math.pi)) end
     if hitY then reflect(-b.angle) end
     -- The incoming segment retains its direction and exits naturally.
     keep=false
    end
   else
   local hitX=(b.x<=-192 and b.vx<0) or (b.x>=192 and b.vx>0)
   local hitY=(b.y<=0 and b.vy<0) or (k~='bounceNoBottom' and b.y>=448 and b.vy>0)
   if b.group~='th10' then
    local mask=s.mask or 15
    hitX=hitX and ((b.x<0 and math.floor(mask/4)%2==1) or (b.x>0 and math.floor(mask/8)%2==1))
    hitY=hitY and ((b.y<0 and mask%2==1) or (b.y>448 and math.floor(mask/2)%2==1))
   end
   if hitX or hitY then
    if k=='wrap' then if hitX then b.x=-b.x end;if hitY then b.y=448-b.y end
    else
     -- Native reflection mirrors the distance past the wall as well as velocity.
     -- Otherwise a circle's needles accumulate different boundary delays.
     local mirror=not b.laser and (b.group=='th10' or b.group=='dsc')
     if hitX then if mirror then b.x=(b.x<0 and -384 or 384)-b.x end;b.vx=-b.vx end
     if hitY then if mirror then b.y=(b.y<0 and 0 or 896)-b.y end;b.vy=-b.vy end
     b.angle=math.atan2(b.vy,b.vx)
     if s.r and s.r>-990 then b.speed=s.r;velocity(b) end
    end
    s.count=s.count-1;if s.count<=0 then keep=false end
   end
   end
  end
  s.age=s.age+1;if keep then active[#active+1]=s end
 end
 b.active=active
 local scale=b.birth and b.age<b.birth and 0.5 or 1
 if b.laser and b.laser.nativeLine and b.laser.length<b.laser.max and (b.group~='dsd' or b.laser.travel==0) then
  -- Native0x41D4CF: grow first from the fixed origin; move the tail only
  -- after maximum length is reached. Growth uses source speed, not its
  -- temporary deceleration vector (Seven Stones/Woods starts at y=0).
  b.laser.length=math.min(b.laser.max,b.laser.length+b.speed)
 else
  b.x,b.y=b.x+b.vx*scale,b.y+b.vy*scale
  if b.group=='dsd' and b.laser and b.laser.nativeLine then
   local l=b.laser;l.travel=l.travel+b.speed
   l.length=math.min(l.max,math.max(0,l.terminal-l.travel))
   if l.length<=0 then b.dead=true end
  end
 end
 b.age=b.age+1;b.cull=b.cull-1;b.collidable=not b.birth or b.age>=b.birth
 local w,h=16,16
 if b.group=='th10' and Suwako5Art and Suwako5Art[b.typ] then local v=Suwako5Art[b.typ][b.color] or Suwako5Art[b.typ][0];if v then w,h=v.w/2,v.h/2 end
 elseif b.typ==31 then w,h=64,64 end
 if b.laser then w,h=math.max(b.laser.length,b.laser.width),math.max(b.laser.length,b.laser.width) end
 if b.cull<=0 and (b.x+w<=-192 or b.x-w>=192 or b.y+h<=-64 or b.y-h>=448) then b.dead=true end
 if b.bombProof then b.bombProof=math.max(0,b.bombProof-1) end
end
function R.stepHazards()
 local n=#R.hazards
 for i=1,n do R.projectileStep(R.hazards[i]) end
 local live={};for _,b in ipairs(R.hazards) do if not b.dead then live[#live+1]=b end end;R.hazards=live
end
