-- TH10 Extra stage07 STD camera and ANM geometry, local rendering adapter.
TH11S6Background={}
local B,D=TH11S6Background,TH11S6BackgroundData
local function copy(t)local o={};for k,v in pairs(t)do o[k]=type(v)=='table'and copy(v)or v end;return o end
local function fog(v,k)local c=v[k].source_argb_u32;return {math.floor(c/65536)%256,math.floor(c/256)%256,c%256,v[k+1],v[k+2]}end
local function ease(u,m)if m==1 then return u*u elseif m==4 then return 1-(1-u)^2 end;return u end
function B.new()
 return {t=-1,clock=-1,pc=1,values={pos={0,512,-320},face={0,360,240},up={0,1,0},fov={.62831855},fog={255,255,255,200,300}},tweens={},leaves={},leafSeed=1007,loops=0}
end
function B.step(s)
 s.t=s.t+1;s.clock=s.clock+1
 for key,q in pairs(s.tweens)do
  q.age=q.age+1;local u=ease(math.min(1,q.age/q.n),q.mode)
  for i,x in ipairs(q.from)do s.values[key][i]=x+(q.to[i]-x)*u end
  if q.age>=q.n then s.tweens[key]=nil end
 end
 local function set(k,v)s.values[k]=copy(v);s.tweens[k]=nil end
 local function tween(k,v,n,m)s.tweens[k]={from=copy(s.values[k]),to=v,n=n,age=0,mode=m}end
 local budget=0
 while D.program[s.pc]and D.program[s.pc].time<=s.clock do
  budget=budget+1;assert(budget<100,'Extra STD did not yield')
  local p=D.program[s.pc];local op,v=p.opcode,p.arguments;s.pc=s.pc+1
  if op==2 then set('pos',v)elseif op==3 then tween('pos',{v[3],v[4],v[5]},v[1],v[2])
  elseif op==4 then set('face',v)elseif op==5 then tween('face',{v[3],v[4],v[5]},v[1],v[2])
  elseif op==6 then set('up',v)elseif op==7 then set('fov',v)
  elseif op==8 then set('fog',fog(v,1))elseif op==9 then tween('fog',fog(v,3),v[1],v[2])
  elseif op==1 then s.pc=p.target_instruction_index+1;s.clock=p.target_time;s.loops=s.loops+1
  elseif op==14 then s.sky=true
  else assert(op==0,'unhandled Extra STD opcode '..op)end
 end
 -- Extra MapleEnemy emits432 416 times every12f, then433 every12f.
 local function rand(a,b)s.leafSeed=s.leafSeed*16807%2147483647;return a+(b-a)*s.leafSeed/2147483647 end
 if s.t%12==0 then
  local e=s.values.pos;local late=s.t>=4992
  local x,y,z=e[1]-200+rand(0,400),e[2]+rand(0,400),e[3]-100+rand(0,400)
  x=x+rand(-1,1)*(late and 100 or 200);y=y+rand(-1,1)*(late and 100 or 300)+(late and 800 or 200)
  s.leaves[#s.leaves+1]={age=0,x=x,y=y,z=z,tx=x+rand(-150,150)+300,ty=y-rand(-60,60),tz=z/80,rot=rand(-180,180),spin=rand(-5.625,5.625),green=rand(0,255)}
 end
 local live={};for _,p in ipairs(s.leaves)do p.age=p.age+1;if p.age<400 then live[#live+1]=p end end;s.leaves=live
end
local function rotate(x,y,z,r)
 local c,s=math.cos(r[1]),math.sin(r[1]);y,z=y*c-z*s,y*s+z*c
 c,s=math.cos(r[2]),math.sin(r[2]);x,z=x*c+z*s,-x*s+z*c
 c,s=math.cos(r[3]),math.sin(r[3]);return x*c-y*s,x*s+y*c,z
end
function B.groups()
 local out={}
 for _,e in ipairs(D.entries)do for _,ins in ipairs(e.instances)do for _,q in ipairs(e.quads)do
  local a=assert(D.scripts[q.animation_script_id]);if not a.deleted and a.sprite then
   local p={}
   for i,v in ipairs({{-q.width/2,-q.height/2},{q.width/2,-q.height/2},{q.width/2,q.height/2},{-q.width/2,q.height/2}})do
    local x,y,z=rotate(v[1],v[2],0,a.rot)
    p[i]={x+ins.position[1]+q.position[1],y+ins.position[2]+q.position[2],z+ins.position[3]+q.position[3]}
   end
   out[#out+1]={img=D.sprites[a.sprite],rgb=a.rgb,alpha=a.alpha,points=p}
  end
 end end end;return out
end
B.Object=Class(background)
function B.Object:init()background.init(self,false);self.state=B.new();self.groups=B.groups();B.current=self end
function B.Object:frame()B.step(self.state)end
function B.Object:render()
 local s=self.state;local v=s.values;local e,f=v.pos,v.face;local fog=v.fog
 Set3D('eye',unpack(e));Set3D('at',e[1]+f[1],e[2]+f[2],e[3]+f[3]);Set3D('up',unpack(v.up));Set3D('fovy',v.fov[1]);Set3D('z',1,8000)
 Set3D('fog',fog[4],fog[5],Color(255,fog[1],fog[2],fog[3]));SetViewMode('3d');RenderClear(Color(255,fog[1],fog[2],fog[3]))
 ClearZBuffer();SetZBufferEnable(1)
 for _,g in ipairs(self.groups)do
  SetImageState(g.img,'',Color(g.alpha,g.rgb[1],g.rgb[2],g.rgb[3]));local p=g.points
  Render4V(g.img,p[1][1],p[1][2],p[1][3],p[2][1],p[2][2],p[2][3],p[3][1],p[3][2],p[3][3],p[4][1],p[4][2],p[4][3])
 end
 SetZBufferEnable(0)
 for _,p in ipairs(s.leaves)do
  local u=p.age/400;local alpha=64*math.min(1,p.age/30)*math.min(1,(400-p.age)/100)
  SetImageState(D.leaf,'',Color(alpha,255,p.green,0));Render(D.leaf,p.x+(p.tx-p.x)*u,p.y+(p.ty-p.y)*u,p.rot+p.spin*p.age,1.5,1.5,p.z+(p.tz-p.z)*u)
 end
 SetViewMode('world')
end
function B.Object:del()if B.current==self then B.current=nil end end
