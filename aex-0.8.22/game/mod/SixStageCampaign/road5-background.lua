-- Original HSoB World05 full background, campaign road only.
local C=SixStageCampaign
local B={};SixRoad5Background=B
local path='mod/SixStageCampaign/road5-background/'
B.meshes=dofile(path..'meshes.lua')
for _,n in ipairs({'a','b','c','e','f','h','i'})do
 LoadTexture('six.road5.'..n,path..'world05'..n..'.png')
 SetTextureSamplerState('six.road5.'..n,'linear+wrap')
end
local rad=math.pi/180
local function sn(x)return math.sin(x*rad)end
local function cs(x)return math.cos(x*rad)end
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
-- Private cosmetic RNG: never consume the road/enemy RNG.
local function rnd(s,a,b)s.seed=s.seed*16807%2147483647;return a+(b-a)*s.seed/2147483647 end
function B.new(section)
 local phase=section==1 and'a'or section==2 and'b'or'c'
 return {phase=phase,age=0,frame=0,ea=0,models={},clouds={},seed=19790520,count=0,section=section}
end
local function mesh(s,id,x,y,z,vx,vy,life,scale,angle)
 s.models[#s.models+1]={id=id,x=x,y=y,z=z,vx=vx,vy=vy,life=life,scale=scale or 1,angle=angle or 90,age=0,seed=rnd(s,0,360)}
end
function B.step(s,scene)
 local t=s.frame
 if s.phase=='a'and scene>=1 then s.phase='b';s.age=0;s.changed=true;s.ea=t end
 if s.phase=='b'and scene>=2 then s.phase='warp';s.age=0;s.warpFrame=t end
 if s.phase=='warp'and s.age>=math.floor(39.435*64)-60 then s.phase='c';s.age=0;s.changed=true end
 if s.phase=='c'and scene>=3 then s.phase='end';s.age=0 end
 local phase=s.phase
 if phase=='a'then
  local m
  -- moveB stops on reaching90 degrees, not a repeating sine.
  m=sn(clamp((t-721)*.5,0,90))
  s.camera={192+64*sn(t/8),8*cs(t/4),16+8*m*sn(t/4)-18*(1-m),(1-m)*64}
  s.fog={0,math.max(1,sn(math.min(t,90))*1024),128,96,64}
  if t%240==0 then
   mesh(s,'b',-1792,-160,rnd(s,0,448),4,0,780)
   mesh(s,'b',-1536,-160,rnd(s,0,-448),4,0,780)
  end
 elseif phase=='b'then
  local m=sn(clamp(s.age*.1,0,90))
  local r=64+32*sn(t/8);local az=-8+8*cs(t/4)
  if s.changed then r=192-m*128+(64-m*32)*sn(t/8);az=-m*8+8*cs(t/4)end
  s.camera={r,az,16+8*sn(s.ea/4),0}
  s.fog={0,s.changed and(1024-m*256)or math.max(1,m*784),s.changed and(128-m*96)or(m*32),s.changed and(96-m*72)or(m*24),s.changed and(64-m*48)or(m*16)}
  if t%180==0 then
   mesh(s,'e',-1536,-192,-192,2,0,840)
   mesh(s,'e',-1536,-192,192,2,0,840)
  end
  s.ea=s.ea+(s.changed and(1-m/2)or .5)
 elseif phase=='warp'then
  local m=sn(clamp(s.age*90/480,0,90))
  s.camera={64+32*sn(t/8)*(1-m),-8+8*cs(t/4)*(1-m),16+8*sn(s.ea/4)*(1-m),0}
 elseif phase=='c'or phase=='end'then
  local m=sn(math.min(s.age,90))
  s.camera={64+32*sn(t/8),-8+8*cs(t/4),16+(s.changed and(8+m*8)or 16)*sn(s.ea/4),0}
  local fogFade=s.changed and 1 or m
  s.fog={0,math.max(1,1024*fogFade),32*fogFade,24*fogFade,16*fogFade};s.ea=s.ea+.5
  if phase=='c'and t%120==0 then
   local scale=rnd(s,.5,1);local z=s.count==0 and-rnd(s,192,256)or s.count==1 and rnd(s,192,256)or rnd(s,-64,64)
   local x=s.count==2 and-768 or-512
   local angle=rnd(s,0,360)
   mesh(s,'fa',x,768,z,0,-2,960,scale,angle)
   mesh(s,'fb',x,768,z,0,-2,960,scale,angle)
   -- Both halves of source Object06 share phase and angle.
   s.models[#s.models-1].seed=s.models[#s.models].seed
   s.count=(s.count+1)%3
  end
 end
 -- World05Object03: native billboard sand clouds, independent cosmetic RNG.
 if (phase=='a'and t%8==0)or(phase=='b'and t%4==0)then
  local early=phase=='a'
  s.clouds[#s.clouds+1]={x=-rnd(s,256,768),y=-rnd(s,early and 64 or 128,early and 128 or 192),z=rnd(s,-256,256),vx=early and 4 or 2,vy=0,vz=0,angle=rnd(s,0,360),alpha=rnd(s,early and 64 or 32,early and 128 or 64),age=0,warm=early}
 elseif phase=='c'and t%4==0 then
  s.clouds[#s.clouds+1]={x=-rnd(s,256,768),y=rnd(s,-512,256),z=rnd(s,-256,256),vx=0,vy=-rnd(s,1,4),vz=rnd(s,1,2),angle=rnd(s,0,360),alpha=rnd(s,32,128),age=0}
 end
 for i=#s.clouds,1,-1 do
  local c=s.clouds[i];c.age=c.age+1;c.x=c.x+c.vx;c.y=c.y+c.vy;c.z=c.z+c.vz
  if c.age>=136 then table.remove(s.clouds,i)end
 end
 for i=#s.models,1,-1 do
  local m=s.models[i];m.age=m.age+1;m.x=m.x+m.vx;m.y=m.y+m.vy
  if phase=='warp'and m.id=='e'then m.y=m.y-math.min(2,s.age*.005)end
  if phase=='end'then m.y=m.y-math.min(12,s.age*.1)end
  if m.age>=m.life then table.remove(s.models,i)end
 end
 s.frame=t+1;s.age=s.age+1
end
local function vertex(x,y,z,u,v,col)return {x,y,z,u,v,col}end
local function quad(tex,a,b,c,d,blend)RenderTexture('six.road5.'..tex,blend or'',a,b,c,d)end
local function drawMesh(m)
 local mesh=B.meshes[m.id];local an=m.angle
 local y=m.y
 if m.id=='fa'then y=y-64*sn(m.seed+m.age/2);an=m.seed-m.age/4
 elseif m.id=='fb'then y=y+64*sn(m.seed+m.age/2);an=m.seed+m.age/4 end
 local ca,sa=cs(an),sn(an);local sx=m.id=='b'or m.id=='e'
 local tw,th=GetTextureSize('six.road5.'..mesh.texture:match('world05(.-)%.png'))
 local tex=mesh.texture:match('world05(.-)%.png')
 for _,f in ipairs(mesh.faces)do
  local p={}
  for i,v in ipairs(f)do
   local x,z=v[1]*m.scale,v[3]*m.scale
   if sx then x=-x end
   p[i]=vertex(m.x+x*ca+z*sa,y+v[2],m.z-x*sa+z*ca,v[4]*tw,v[5]*th,Color(255,255,255,255))
  end
  quad(tex,p[1],p[2],p[3],p[4])
 end
end
function B.render(s)
 local camera=s.camera or{192,8,-2,64};local fog=s.fog or{0,1024,128,96,64}
 local r,az,el,fy=unpack(camera)
 local ex,ey,ez=r*cs(el)*cs(az),fy+r*sn(el),r*cs(el)*sn(az)
 Set3D('eye',ex,ey,ez);Set3D('at',0,fy,0);Set3D('up',0,1,0)
 Set3D('fovy',math.pi/4);Set3D('z',1,5000)
 Set3D('fog',fog[1],fog[2],Color(255,fog[3],fog[4],fog[5]))
 SetViewMode('3d');RenderClearViewMode(Color(255,fog[3],fog[4],fog[5]));SetZBufferEnable(1)
 local phase=s.phase
 if phase=='a'or phase=='b'or phase=='warp'then
  local alpha=phase=='warp'and 255*(1-sn(clamp(s.age*90/480,0,90)))or 255
  local col=phase=='a'and 255 or(phase=='b'and s.changed and(255-95*sn(clamp(s.age*.1,0,90)))or 160)
  local cc=Color(alpha,col,col,col);local scroll=s.frame*(phase=='a'and 4 or 2)
  -- Source1024 square, horizontal at y=-160; scrolling source rectangle.
  quad('a',vertex(-1024,-160,-512,0,scroll+1024,cc),vertex(0,-160,-512,0,scroll,cc),vertex(0,-160,512,1024,scroll,cc),vertex(-1024,-160,512,1024,scroll+1024,cc))
 end
 for _,m in ipairs(s.models)do drawMesh(m)end
 SetZBufferEnable(0)
 if phase=='warp'then
  local long=math.floor(39.435*64);local y=1536-2304*sn(clamp(s.age/(long-180)*90,0,90))
  Set3D('fog',0,100000,Color(255,32,24,16));SetViewMode('3d')
  for j=0,1 do
   local top=y-1024+j*1024;local a0=math.min(255,j*.5*360);local a1=math.min(255,(j+1)*.5*360)
   quad('h',vertex(-784,top,1008,0,j*768,Color(a0,255,255,255)),vertex(-784,top,-1040,1536,j*768,Color(a0,255,255,255)),vertex(-784,top+1024,-1040,1536,(j+1)*768,Color(a1,255,255,255)),vertex(-784,top+1024,1008,0,(j+1)*768,Color(a1,255,255,255)))
  end
  local cc=Color(255,255,255,255)
  quad('i',vertex(-783,y+832,-272,0,0,cc),vertex(-783,y+832,240,512,0,cc),vertex(-783,y+320,240,512,512,cc),vertex(-783,y+320,-272,0,512,cc),'mul+add')
 elseif phase=='c'or phase=='end'then
  Set3D('fog',0,100000,Color(255,32,24,16));SetViewMode('3d')
  local offset=s.frame-(phase=='end'and sn(clamp(s.age*.25,0,90))*1024 or 0)
  local alpha=phase=='end'and 128*math.min(1,2-sn(clamp(s.age*.25,0,90))*2)or 128
  quad('h',vertex(-1024,-512,1024,0,offset,Color(0,255,255,255)),vertex(-1024,-512,-1024,2048,offset,Color(0,255,255,255)),vertex(-1024,1536,-1024,2048,offset+2048,Color(alpha,255,255,255)),vertex(-1024,1536,1024,0,offset+2048,Color(alpha,255,255,255)))
 end
 -- Billboard axes from the source camera; clouds blend after solid geometry.
 Set3D('fog',fog[1],fog[2],Color(255,fog[3],fog[4],fog[5]));SetViewMode('3d')
 for _,c in ipairs(s.clouds)do
  local f=c.age<90 and sn(c.age)or 1-sn((c.age-90)*2)
  local color=Color(c.alpha*f,255,c.warm and 192 or 255,c.warm and 128 or 255)
  local v={}
  for i,p in ipairs({{-128,128,0,0},{128,128,256,0},{128,-128,256,256},{-128,-128,0,256}})do
   local x,y=p[1]*cs(c.angle)-p[2]*sn(c.angle),p[1]*sn(c.angle)+p[2]*cs(c.angle)
   v[i]=vertex(c.x+x*sn(az)-y*sn(el)*cs(az),c.y+y*cs(el),c.z-x*cs(az)-y*sn(el)*sn(az),p[3],p[4],color)
  end
  quad('c',v[1],v[2],v[3],v[4])
 end
 SetViewMode('world')
 -- Original Object101 mirage:24 horizontal strips, per-strip wave/alpha.
 if s.frame<720 then
  local t=s.frame;local fade=math.min(1,math.min(t/720*3,(1-t/720)*2));local radius=2+(1-fade)*6
  for i=0,23 do
   local vs={}
   for j=0,1 do
    local u=(i+j)/24;local dx=sn(u*u*1800+t*5)*radius*(1+sn(u*u*180))/2
    local col=Color(64*math.min(1,2-u*2)*fade,32+u*64,32+u*64,16+u*32)
    vs[j*2+1]=vertex(-128+dx,64+t/10-(u-.5)*256,.5,0,u*1024,col)
    vs[j*2+2]=vertex(128+dx,64+t/10-(u-.5)*256,.5,1024,u*1024,col)
   end
   quad('h',vs[1],vs[2],vs[4],vs[3])
  end
 end
end
local BG=Class(object)
function BG:init()
 self.group=GROUP_GHOST;self.layer=LAYER_BG+1;self.bound=false;self.colli=false
 self.state=B.new(HSoB5.section);B.current=self;self.last=HSoB5.tick
end
function BG:frame()
 if HSoB5.finished and not setting.hsob5_boss_only then C.boss5Background.start(self.state)end
 if HSoB5.bossActive or HSoB5.finished then return end
 local dt=math.max(0,HSoB5.tick-self.last);self.last=HSoB5.tick
 for _=1,dt do B.step(self.state,HSoB5.scene)end
end
function BG:render()
 if HSoB5.bossActive then return end
 if HSoB5.finished then C.boss5Background.draw()else B.render(self.state)end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=5 then return end
 local original=HSoB5.newBackground
 HSoB5.newBackground=function()
  -- Keep source warp overlay/counter timing, replace only Lite still rendering.
  local old=New
  New=function(cls,...)
   if cls.render and debug.getinfo(cls.render,'S').source:find('HSoBStage5Normal/background.lua',1,true)then
    -- First source New is Lite BG; second is original Warp overlay.
    if not HSoB5._road5BgCreated then HSoB5._road5BgCreated=true;return old(BG)end
   end
   return old(cls,...)
  end
  HSoB5._road5BgCreated=false
  local ok,err=pcall(original);New=old;if not ok then error(err)end
 end
end

-- Explicit test-only renderer samples during the normal Stage5 entry.
if setting.six_road5_background_probe then
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  if C.index~=5 or not B.current then return end
  local tick=stage.current_stage.timer
  local cases={[90]={'desert',1,0,600},[120]={'ruins',2,1,700},[150]={'tower',2,2,1800},[180]={'interior',3,2,700}}
  local c=cases[tick]
  if c then
   local st=B.new(c[2])
   if c[1]=='tower'then for i=1,700 do B.step(st,1)end end
   for i=1,c[4]do B.step(st,c[3])end
   B.current.state=st;C.snapshot='road5-live-'..c[1]
  end
  if tick==210 then print('ROAD5 BACKGROUND NATIVE PASS campaign entry/scene renderer/sidebar');stage.QuitGame()end
 end
end
