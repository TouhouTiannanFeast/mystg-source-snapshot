-- TH18 st02.std and st02wl.anm, including source interrupt and rocking mode1.
Th18Stage5Background={}
local B,A,D=Th18Stage5Background,Th18Stage5Animation,Th18Stage5Data
local function fog(v,k)local c=v[k];return {math.floor(c/65536)%256,math.floor(c/256)%256,c%256,v[k+1],v[k+2]}end
function B.run(s)
 local a=s.std;local guard=0
 while a.pc<=#a.code and a.code[a.pc][1]<=a.clock do
  guard=guard+1;assert(guard<100,'STD did not advance');local c=a.code[a.pc];a.pc=a.pc+1;local op,v=c[2],c[3]
  if op==1 then a.pc=v[1];a.clock=v[2];s.loops=s.loops+1
  elseif op==2 then A.set(a,'pos',v) elseif op==3 then A.tween(a,'pos',{v[3],v[4],v[5]},v[1],v[2])
  elseif op==4 then A.set(a,'facing',v) elseif op==5 then A.tween(a,'facing',{v[3],v[4],v[5]},v[1],v[2])
  elseif op==6 then A.set(a,'up',v) elseif op==7 then A.set(a,'fov',v)
  elseif op==8 then A.set(a,'fog',fog(v,1)) elseif op==9 then A.tween(a,'fog',fog(v,3),v[1],v[2])
  elseif op==12 then assert(v[1]==0 or v[1]==1,'unneeded rocking mode');s.rock=v[1];s.rockTime=0
  elseif op==13 then s.clear=v[1]
  elseif op==16 then -- interrupt label
  elseif op==19 then for _,anm in pairs(s.anms)do A.case(anm,v[1]+7)end;s.broadcasts=s.broadcasts+1
  else error('unsupported stage2 STD '..op)end
 end
end
function B.new()
 local s={age=0,anms={},groups={},loops=0,broadcasts=0,clear=0,rock=0,rockTime=0}
 s.std={pc=1,clock=0,code=D.scene.std,values={pos={0,0,-800},facing={0,90,60},up={0,1,0},fov={.62831855},fog={0,96,0,100,800}},tweens={}}
 for _,e in ipairs(D.scene.entries)do for _,q in ipairs(e.quads)do
  local id=q.animation_script_id;if not s.anms[id]then s.anms[id]=A.new('background',id)end
  for _,instance in ipairs(e.instances)do s.groups[#s.groups+1]={order=#s.groups+1,instanceOrder=instance.source_offset,quadOrder=q.source_offset,layer=e.layer_source_field,quad=q,pos=instance.position,anm=s.anms[id]}end
 end end
 table.sort(s.groups,function(a,b)if a.layer==b.layer then if a.instanceOrder==b.instanceOrder then return a.quadOrder<b.quadOrder end;return a.instanceOrder<b.instanceOrder end;return a.layer<b.layer end);B.run(s);return s
end
function B.step(s)
 s.age=s.age+1;local a=s.std;a.clock=a.clock+1
 for k,t in pairs(a.tweens)do t.age=t.age+1;local u=A.ease(t.age/math.max(1,t.n),t.mode);local v={}for i,x in ipairs(t.from)do v[i]=x+(t.to[i]-x)*u end;a.values[k]=v;if t.age>=t.n then a.tweens[k]=nil end end
 B.run(s);for _,anm in pairs(s.anms)do A.step(anm)end
 if s.rock==1 then s.rockTime=s.rockTime+1;if s.rockTime>=2048 then s.rockTime=1024 end end
end
function B.interrupt(s,n)
 for i,c in ipairs(s.std.code)do if c[2]==16 and c[3][1]==n then s.std.pc=i+1;s.std.clock=c[1];B.run(s);return true end end;return false
end
-- Stage4 route is longer than the source Stage2 intro. Repeat its seamless forest section until midboss.
local function replaceState(s,fresh)
 for k in pairs(s)do s[k]=nil end;for k,v in pairs(fresh)do s[k]=v end
end
function B.armMidboss(s)s.awaitMidboss=true end
function B.stageStep(s)
 if s.awaitMidboss and s.age>=2047 then
  local fresh=B.new();while fresh.age<1535 do B.step(fresh)end
  fresh.awaitMidboss=true;replaceState(s,fresh)
 end
 B.step(s)
end
function B.beginValley(s)
 if not s.awaitMidboss then return end
 local oldY=s.std.values.pos[2]+(s.scrollOffset or 0)
 local fresh=B.new();while fresh.age<2176 do B.step(fresh)end
 -- Keep the scrolling phase continuous while starting the original transition section at midboss entry.
 fresh.scrollOffset=oldY-fresh.std.values.pos[2];fresh.valleyStarted=true;replaceState(s,fresh)
end
local function rotate(x,y,z,r)
 local c,t=math.cos(r[1]),math.sin(r[1]);y,z=y*c-z*t,y*t+z*c;c,t=math.cos(r[2]),math.sin(r[2]);x,z=x*c+z*t,-x*t+z*c;c,t=math.cos(r[3]),math.sin(r[3]);return x*c-y*t,x*t+y*c,z
end
local function norm(v)local n=math.sqrt(v[1]^2+v[2]^2+v[3]^2);return {v[1]/n,v[2]/n,v[3]/n}end
local function cross(a,b)return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}end
function B.camera(s)
 local camera=s.std.values;local pos,face,up=camera.pos,camera.facing,camera.up;local ex,ez,fx,fz,ux=0,0,0,0,up[1]
 if s.rock==1 then
  local t=s.rockTime;local ramp=math.min(t/512,1);local angle=t*math.pi*2/1024;local sn=math.sin(angle);ex=-10*sn*ramp;ez=-10*math.sin(angle*2)*ramp;fx=-ex*.5;fz=-ez*.5;ux=-sn*.01*ramp
 end
 local eye={pos[1]+ex,pos[2]+(s.scrollOffset or 0),pos[3]+ez};local forward=norm({face[1]+fx,face[2],face[3]+fz})
 local upHint={ux,up[2],up[3]};local right=norm(cross(upHint,forward));local vertical=cross(forward,right)
 return eye,forward,right,vertical,upHint
end
function B.vertices(g,forward,right,vertical)
 local a,q=g.anm,g.quad;local p,r=a.values.pos,a.values.rot
 local center={g.pos[1]+q.position[1]+p[1],g.pos[2]+q.position[2]+p[2],g.pos[3]+q.position[3]+p[3]}
 local result={}
 for i,v in ipairs({{-q.width/2,-q.height/2},{q.width/2,-q.height/2},{q.width/2,q.height/2},{-q.width/2,q.height/2}})do
  local x,y,z
  if a.renderType==4 then
   -- TH18 47f29f applies an extra0.5 before centered anchors: effective512x435 ->256x217.5.
   local c,t=math.cos(r[3]),math.sin(r[3]);local bx,by=(v[1]*c-v[2]*t)*.5,(v[1]*t+v[2]*c)*.5
   x,y,z=right[1]*bx-vertical[1]*by,right[2]*bx-vertical[2]*by,right[3]*bx-vertical[3]*by
  else
   assert(a.renderType==8,'unexpected stage2 ANM render mode')
   -- TH18 480160: true 3D sprite. Keep native pre-rotation Y, including source rotation X=pi.
   x,y,z=rotate(v[1],v[2],0,r)
  end
  result[i]={center[1]+x,center[2]+y,center[3]+z}
 end
 return result,center
end
function B.render(s)
 local camera=s.std.values;local eye,forward,right,vertical=B.camera(s);local f=camera.fog
 local one,two=s.anms[1].values,s.anms[2].values
 SetViewMode('world');SetZBufferEnable(0);SetFog()
 -- Original depth tests/writes and alpha rejection run per pixel, independently of AEX sprite state.
 lstg.PostEffect('th18s5.bg.native','th18s5.bg.blank',6,'',{
  {eye[1],eye[2],eye[3],math.tan(camera.fov[1]/2)},
  {forward[1],forward[2],forward[3],408/472},
  {right[1],right[2],right[3],30},
  {vertical[1],vertical[2],vertical[3],8000},
  {f[1]/255,f[2]/255,f[3]/255,f[4]},
  {f[5],f[1]/255,f[2]/255,f[3]/255}, -- native41c461: inner viewport clears to camera fogColor
  {one.pos[1],one.color[1]/255,one.color[2]/255,one.color[3]/255},
  {two.pos[1],two.color[1]/255,two.color[2]/255,two.color[3]/255}
 },{{D.background.sprites[0][1],6},{D.background.sprites[1][1],6},{D.background.sprites[2][1],6}})
end

B.Object=Class(background)
function B.Object:init()background.init(self,false);A.load();LoadFX('th18s5.bg.native','stages/th18_stage5/background-native.hlsl');CreateRenderTarget('th18s5.bg.blank');self.state=B.new();B.current=self;self.bound=false;self.colli=false end
function B.Object:frame()
 B.stageStep(self.state)
 if setting.th18_stage5_test_scenery then
  local target=({[30]=180,[60]=3100,[120]=4300,[180]=6000})[self.timer]
  if target then while self.state.age<target do B.step(self.state)end end
 end
end
function B.Object:render()B.render(self.state)end
function B.Object:del()if B.current==self then B.current=nil end end

if setting.th18_stage5_background_test then Include('stages/th18_stage5/background-probe.lua')end
