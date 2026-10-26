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
  for _,instance in ipairs(e.instances)do s.groups[#s.groups+1]={order=#s.groups+1,layer=e.layer_source_field,quad=q,pos=instance.position,anm=s.anms[id]}end
 end end
 table.sort(s.groups,function(a,b)if a.layer==b.layer then return a.order<b.order end;return a.layer<b.layer end);B.run(s);return s
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
local function rotate(x,y,z,r)
 local c,t=math.cos(r[1]),math.sin(r[1]);y,z=y*c-z*t,y*t+z*c;c,t=math.cos(r[2]),math.sin(r[2]);x,z=x*c+z*t,-x*t+z*c;c,t=math.cos(r[3]),math.sin(r[3]);return x*c-y*t,x*t+y*c,z
end
function B.render(s)
 local camera=s.std.values;local pos,face,up=camera.pos,camera.facing,camera.up;local ex,ez,fx,fz,ux=0,0,0,0,up[1]
 if s.rock==1 then -- native 41dd4a, STD opcode12 at41d876; offsets preserve source camera.
  local t=s.rockTime;local ramp=math.min(t/512,1);local angle=t*math.pi*2/1024;local sn=math.sin(angle);ex=-10*sn*ramp;ez=-10*math.sin(angle*2)*ramp;fx=-ex*.5;fz=-ez*.5;ux=-sn*.01*ramp
 end
 local eye={pos[1]+ex,pos[2],pos[3]+ez};local f=camera.fog
 Set3D('eye',eye[1]/128,eye[2]/128,eye[3]/128);Set3D('at',(eye[1]+face[1]+fx)/128,(eye[2]+face[2])/128,(eye[3]+face[3]+fz)/128)
 Set3D('up',ux,up[2],up[3]);Set3D('fovy',camera.fov[1]);Set3D('z',30/128,8000/128)
 Set3D('fog',f[4]/128,f[5]/128,Color(255,math.floor(f[1]),math.floor(f[2]),math.floor(f[3])))
 SetViewMode('3d');RenderClearViewMode(Color(255,math.floor(s.clear/65536)%256,math.floor(s.clear/256)%256,s.clear%256));ClearZBuffer();SetZBufferEnable(0)
 -- All st02 planes are parallel, ordered far-to-near by source layer.
 -- Painter compositing preserves native LESSEQUAL (41c353) for coplanar alpha quads.
 for _,g in ipairs(s.groups)do
  local a,q=g.anm,g.quad;local sprite=D.background.sprites[a.sprite]
  if sprite and a.values.alpha[1]>0 then
   local uv={{sprite[2],sprite[3]},{sprite[2]+sprite[4],sprite[3]},{sprite[2]+sprite[4],sprite[3]+sprite[5]},{sprite[2],sprite[3]+sprite[5]}}
   local points={};local color=a.values.color;local tint=Color(math.floor(a.values.alpha[1]),math.floor(color[1]),math.floor(color[2]),math.floor(color[3]));local p,r,sc=a.values.pos,a.values.rot,a.values.scale
   for i,v in ipairs({{-q.width/2,-q.height/2},{q.width/2,-q.height/2},{q.width/2,q.height/2},{-q.width/2,q.height/2}})do
    local x,y,z=rotate(v[1]*sc[1],-v[2]*sc[2],0,r)
    points[i]={(g.pos[1]+q.position[1]+p[1]+x)/128,(g.pos[2]+q.position[2]+p[2]+y)/128,(g.pos[3]+q.position[3]+p[3]+z)/128,uv[i][1],uv[i][2],tint}
   end
   RenderTexture(sprite[1],a.blend==1 and 'mul+add' or '',unpack(points))
  end
 end
 SetZBufferEnable(0);SetViewMode('world')
end
B.Object=Class(background)
function B.Object:init()background.init(self,false);A.load();self.state=B.new();B.current=self;self.bound=false;self.colli=false end
function B.Object:frame()
 B.step(self.state)
 if setting.th18_stage5_test_scenery then
  local target=({[30]=180,[60]=3100,[120]=4300,[180]=6000})[self.timer]
  if target then while self.state.age<target do B.step(self.state)end end
 end
end
function B.Object:render()B.render(self.state)end
function B.Object:del()if B.current==self then B.current=nil end end
