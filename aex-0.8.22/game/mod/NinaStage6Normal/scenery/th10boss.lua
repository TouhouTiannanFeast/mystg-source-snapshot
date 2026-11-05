TH10S6Background={}
local B=TH10S6Background;local D=TH10S6BackgroundData
local function copy(t)local o={};for k,v in pairs(t)do o[k]=type(v)=='table'and copy(v)or v end;return o end
local function fog(v,k)local c=v[k].source_argb_u32;return {math.floor(c/65536)%256,math.floor(c/256)%256,c%256,v[k+1],v[k+2]}end
function B.new()
 return {t=-1,pc=1,values={pos={0,1024,-280},face={0,360,250},up={0,0,-1},fov={.62831855},fog={0,0,255,500,1200}},tweens={},leaves={},leafSeed=106,groups={}}
end
function B.step(s)
 s.t=s.t+1
 for key,q in pairs(s.tweens)do
  q.age=q.age+1;local u=math.min(1,q.age/q.n)
  for i,x in ipairs(q.from)do s.values[key][i]=x+(q.to[i]-x)*u end
  if u>=1 then s.tweens[key]=nil end
 end
 local function set(key,v)s.values[key]=copy(v);s.tweens[key]=nil end
 local function tween(key,v,n)s.tweens[key]={from=copy(s.values[key]),to=v,n=n,age=0}end
 while D.program[s.pc]and D.program[s.pc].time<=s.t do
  local p=D.program[s.pc];local op,v=p.opcode,p.arguments;s.pc=s.pc+1
  if op==2 then set('pos',v)elseif op==3 then tween('pos',{v[3],v[4],v[5]},v[1])
  elseif op==4 then set('face',v)elseif op==5 then tween('face',{v[3],v[4],v[5]},v[1])
  elseif op==6 then set('up',v)elseif op==7 then set('fov',v)
  elseif op==8 then set('fog',fog(v,1))elseif op==9 then tween('fog',fog(v,3),v[1])
  elseif op==14 then s.sky=true
  elseif op==1 then s.pc=p.target_instruction_index+1;s.t=p.target_time;s.loops=(s.loops or 0)+1
  else assert(op==0,'unhandled road STD opcode '..op)end
 end
 -- MapleEnemy's source cadence, sprite330, scale1.5, alpha0->64->0,
 -- and200-frame lifetime. Camera-relative scattering adapts the ANM's
 -- native random/camera registers without consuming the ECL random stream.
 local function random()s.leafSeed=(s.leafSeed*16807)%2147483647;return s.leafSeed/2147483647 end
 if s.t>0 and ((s.t<=3366 and s.t%3==0)or(s.t>3366 and(s.t-3366)%6==0))then
  local eye=s.values.pos
  s.leaves[#s.leaves+1]={age=0,x=eye[1]+(random()*2-1)*300,y=eye[2]+100+random()*500,z=eye[3]+random()*220,
   vx=(random()*2-1)*.25,vy=-1-random(),rot=random()*math.pi*2,spin=(random()*2-1)*.1,green=random()*255}
 end
 local live={};for _,p in ipairs(s.leaves)do p.age=p.age+1;p.x=p.x+p.vx;p.y=p.y+p.vy;p.rot=p.rot+p.spin;if p.age<200 then live[#live+1]=p end end;s.leaves=live
end
local function rotate(x,y,z,r)
 local c,t=math.cos(r[1]),math.sin(r[1]);y,z=y*c-z*t,y*t+z*c
 c,t=math.cos(r[2]),math.sin(r[2]);x,z=x*c+z*t,-x*t+z*c
 c,t=math.cos(r[3]),math.sin(r[3]);return x*c-y*t,x*t+y*c,z
end
function B.groups()
 local out={}
 for _,e in ipairs(D.entries)do for _,instance in ipairs(e.instances)do for _,q in ipairs(e.quads)do
  local anm=D.scripts[q.animation_script_id]
  if q.animation_script_id~=13 then
   local pts={}
   for i,v in ipairs({{-q.width/2,-q.height/2},{q.width/2,-q.height/2},{q.width/2,q.height/2},{-q.width/2,q.height/2}})do
    local x,y,z=rotate(v[1],v[2],0,anm.rot)
    pts[i]={x+instance.position[1]+q.position[1],y+instance.position[2]+q.position[2],z+instance.position[3]+q.position[3]}
   end
   out[#out+1]={id=q.animation_script_id,img=D.sprites[anm.sprite],rgb=anm.rgb,points=pts}
  end
 end end end
 return out
end
B.Object=Class(background)
function B.Object:init()background.init(self,false);self.state=B.new();self.groups=B.groups();B.current=self end
function B.Object:frame()B.step(self.state)end
function B.Object:render()
 if self.ninaHidden then return end
 local s=self.state;local v=s.values;local eye,face=v.pos,v.face;local f=v.fog
 Set3D('eye',eye[1],eye[2],eye[3]);Set3D('at',eye[1]+face[1],eye[2]+face[2],eye[3]+face[3])
 Set3D('up',unpack(v.up));Set3D('fovy',v.fov[1]);Set3D('z',1,8000)
 Set3D('fog',f[4],f[5],Color(255,f[1],f[2],f[3]));SetViewMode('3d');RenderClear(Color(255,f[1],f[2],f[3]))
 for _,g in ipairs(self.groups)do
  local a=1;local r,gc,b=unpack(g.rgb)
  if g.id==11 or g.id==12 then a=s.t>=3368 and 192/255 or 0
  elseif s.t>=3368 then
   if g.id==1 or g.id==2 then a=math.max(0,1-(s.t-3368)/120)
   else local u=math.max(0,1-(s.t-3368)/120);r,gc,b=r*u,gc*u,b*u end
  end
  if a>0 then
   SetImageState(g.img,'',Color(a*255,r,gc,b));local p=g.points
   Render4V(g.img,p[1][1],p[1][2],p[1][3],p[2][1],p[2][2],p[2][3],p[3][1],p[3][2],p[3][3],p[4][1],p[4][2],p[4][3])
  end
 end
 local leaf='nina.scenery.th10leaf'
 for _,p in ipairs(s.leaves)do
  local alpha=64*math.min(1,p.age/30)*math.min(1,(200-p.age)/100)
  SetImageState(leaf,'',Color(alpha,255,p.green,0));Render(leaf,p.x,p.y,p.rot*180/math.pi,1.5,1.5,p.z)
 end
 SetViewMode('world')
 if s.sky then
  local u=math.min(1,(s.t-3368)/240);local img=D.sprites[0]
  SetImageState(img,'',Color(255,255*u,255*u,255*u));Render(img,0,0,0,1,1)
  img=D.sprites[3];SetImageState(img,'',Color(255,255*u,255*u,255*u));Render(img,0,144,0,1,1)
 end
end
function B.Object:del()if B.current==self then B.current=nil end end
B.BossObject=Class(B.Object)
function B.BossObject:init()
 background.init(self,false);self.state=B.new();self.groups=B.groups();B.current=self
 while self.state.t<3368 do B.step(self.state)end
end
