-- Playback is deliberately limited to the instructions present in these two backgrounds.
Stage12BackgroundPlayer={}
local S=Stage12BackgroundPlayer
local function copy(v)local o={}for i,x in ipairs(v)do o[i]=x end;return o end
local function easing(x,m)
 x=math.max(0,math.min(1,x))
 if m==0 then return x elseif m==1 then return x*x elseif m==4 then return 1-(1-x)^2 elseif m==8 then return x*x*(3-2*x) elseif m==9 then return x<.5 and 2*x*x or 1-2*(1-x)^2 end
 error('unsupported source background interpolation '..tostring(m))
end
S.easing=easing
local function set(vm,k,v)vm.values[k]=copy(v);vm.tweens[k]=nil end
local function tween(vm,k,goal,duration,mode,age,first,last)
 vm.tweens[k]={from=copy(vm.values[k]),goal=copy(goal),duration=duration,mode=mode,age=age,first=first,last=last}
end
local function sample(vm,age)
 for k,v in pairs(vm.tweens)do
  local t=math.max(0,math.min(1,(age-v.age)/math.max(1,v.duration)));local out={}
  for i,a in ipairs(v.from)do
   if v.first then out[i]=(2*t^3-3*t^2+1)*a+(t^3-2*t^2+t)*v.first[i]+(-2*t^3+3*t^2)*v.goal[i]+(t^3-t^2)*v.last[i]
   else out[i]=a+(v.goal[i]-a)*easing(t,v.mode)end
  end
  vm.values[k]=out
  if t>=1 then vm.tweens[k]=nil end
 end
end
local function machine(program,labelop)
 local vm={code=program,pc=1,clock=0,values={},tweens={},cases={}}
 for i,v in ipairs(program)do if v[2]==labelop then vm.cases[v[3][1]]=i end end
 return vm
end
local function redirect(vm,label)
 local i=vm.cases[label];if not i then return false end
 vm.pc=i+1;vm.clock=vm.code[i][1];vm.stopped=false;return true
end
local run_anm,run_std
local function new_anm(state,id)
 local a=machine(assert(state.program.anm[id]),5);a.script=id;a.age=state.age;a.uv={0,0};a.uvspeed={0,0};a.anchor={0,0};a.blend=0;a.nozwrite=false
 a.values={pos={0,0,0},rot={0,0,0},alpha={255}};run_anm(state,a);return a
end
run_anm=function(state,a)
 local guard=0
 while not a.stopped and a.pc<=#a.code and a.code[a.pc][1]<=a.clock do
  guard=guard+1;assert(guard<100,'background ANM loop did not advance')
  local c=a.code[a.pc];local op,v=c[2],c[3];a.pc=a.pc+1
  if op==0 or op==5 then
  elseif op==3 then a.stopped=true
  elseif op==200 then a.pc=v[1];a.clock=v[2]
  elseif op==300 then a.sprite=v[1]
  elseif op==302 then a.renderType=v[1]
  elseif op==303 then a.blend=v[1]
  elseif op==304 then a.layer=v[1]
  elseif op==305 then a.nozwrite=v[1]~=0
  elseif op==400 then set(a,'pos',v)
  elseif op==401 then set(a,'rot',v)
  elseif op==403 then set(a,'alpha',v)
  elseif op==407 then tween(a,'pos',{v[3],v[4],v[5]},v[1],v[2],state.age)
  elseif op==409 then tween(a,'alpha',{v[3]},v[1],v[2],state.age)
  elseif op==421 then a.anchor=copy(v)
  elseif op==425 then a.uvspeed[1]=v[1]
  elseif op==426 then a.uvspeed[2]=v[1]
  else error('unhandled background ANM '..op)end
 end
end
local function all_anms(state,f)
 for _,a in ipairs(state.anms)do f(a)end
 for _,a in pairs(state.slots)do f(a)end
end
run_std=function(state)
 local a=state.std;local guard=0
 while not a.stopped and a.pc<=#a.code and a.code[a.pc][1]<=a.clock do
  guard=guard+1;assert(guard<100,'background STD loop did not advance')
  local c=a.code[a.pc];local op,v=c[2],c[3];a.pc=a.pc+1
  if op==1 then a.pc=v[1];a.clock=v[2];state.loops=state.loops+1
  elseif op==2 then set(a,'pos',v)
  elseif op==3 then tween(a,'pos',{v[3],v[4],v[5]},v[1],v[2],state.age)
  elseif op==4 then set(a,'facing',v)
  elseif op==5 then tween(a,'facing',{v[3],v[4],v[5]},v[1],v[2],state.age)
  elseif op==6 then set(a,'up',v)
  elseif op==7 then set(a,'fov',v)
  elseif op==8 or op==9 then
   local at=op==8 and 1 or 3;local color=v[at];local rgba={math.floor(color/65536)%256,math.floor(color/256)%256,color%256,v[at+1],v[at+2]}
   if op==8 then set(a,'fog',rgba)else tween(a,'fog',rgba,v[1],v[2],state.age)end
  elseif op==10 then tween(a,'pos',{v[6],v[7],v[8]},v[1],8,state.age,{v[3],v[4],v[5]},{v[9],v[10],v[11]})
  elseif op==13 then state.clear=v[1]
  elseif op==14 then local child=new_anm(state,v[2]);child.stdLayer=v[3];state.slots[v[1]]=child;state.spawns=state.spawns+1
  elseif op==16 then
  elseif op==19 then all_anms(state,function(anm)if redirect(anm,v[1]+7)then run_anm(state,anm)end end);state.broadcasts=state.broadcasts+1
  else error('unhandled background STD '..op)end
 end
end
function S.new(stage)
 local p=Stage12BackgroundProgram[stage];local state={program=p,stage=stage,age=0,anms={},slots={},loops=0,spawns=0,broadcasts=0}
 state.std=machine(p.std,16);state.std.values={pos={0,0,0},facing={0,0,1},up={0,1,0},fov={.5235988},fog={0,0,0,400,900}}
 for i,g in ipairs(p.groups)do state.anms[i]=new_anm(state,g.script)end
 run_std(state);return state
end
function S.advance(state,target)
 assert(target>=state.age,'background rewind requires new state')
 while state.age<target do
  state.age=state.age+1;local std=state.std;std.clock=std.clock+1;sample(std,state.age);run_std(state)
  all_anms(state,function(a)
   if a.age<state.age then
    a.clock=a.clock+1;sample(a,state.age);run_anm(state,a)
    a.uv[1]=a.uv[1]+a.uvspeed[1];a.uv[2]=a.uv[2]+a.uvspeed[2];a.age=state.age
   end
  end)
 end
end
function S.interrupt(state,label)
 if redirect(state.std,label)then run_std(state);return true end;return false
end
local function rotate(x,y,z,r)
 local c,s=math.cos(r[1]),math.sin(r[1]);y,z=y*c-z*s,y*s+z*c
 c,s=math.cos(r[2]),math.sin(r[2]);x,z=x*c+z*s,-x*s+z*c
 c,s=math.cos(r[3]),math.sin(r[3]);return x*c-y*s,x*s+y*c,z
end
local blends={[0]='',[1]='mul+add',[2]='mul+rev'}
local function vertices(state,a,width,height,cx,cy,cz,screen)
 local spr=state.program.sprites[a.sprite];local tex=state.program.textures[spr[1]];local uvx=spr[2]+a.uv[1]*tex[2];local uvy=spr[3]+a.uv[2]*tex[3]
 local uv={{uvx,uvy},{uvx+spr[4],uvy},{uvx+spr[4],uvy+spr[5]},{uvx,uvy+spr[5]}}
 local pos=a.values.pos;local r=a.values.rot;local points={};local alpha=math.max(0,math.min(255,math.floor(a.values.alpha[1])));local color=Color(alpha,255,255,255)
 local left=a.anchor[1]==1 and 0 or a.anchor[1]==2 and -width or -width/2
 local top=a.anchor[2]==1 and 0 or a.anchor[2]==2 and -height or -height/2
 for i,p in ipairs({{left,top},{left+width,top},{left+width,top+height},{left,top+height}})do
  local x,y,z
  if screen then
   local c,s=math.cos(r[3]),math.sin(r[3]);x=p[1]*c-p[2]*s;y=p[1]*s+p[2]*c;z=0
   points[i]={-192+pos[1]+x,224-pos[2]-y,0,uv[i][1],uv[i][2],color}
  else
   x,y,z=rotate(p[1],-p[2],0,r);points[i]={(cx+pos[1]+x)/128,(cy+pos[2]+y)/128,(cz+pos[3]+z)/128,uv[i][1],uv[i][2],color}
  end
 end
 return spr[1],assert(blends[a.blend],'unsupported source blend'),points
end
function S.render(state)
 local camera=state.std.values;local eye,face,up=camera.pos,camera.facing,camera.up;local fog=camera.fog
 Set3D('eye',eye[1]/128,eye[2]/128,eye[3]/128);Set3D('at',(eye[1]+face[1])/128,(eye[2]+face[2])/128,(eye[3]+face[3])/128)
 Set3D('up',up[1],up[2],up[3]);Set3D('fovy',camera.fov[1]);Set3D('z',30/128,8000/128)
 Set3D('fog',fog[4]/128,fog[5]/128,Color(255,math.floor(fog[1]),math.floor(fog[2]),math.floor(fog[3])))
 SetViewMode('3d');RenderClearViewMode(Color(255,math.floor(state.clear/65536)%256,math.floor(state.clear/256)%256,state.clear%256))
 -- STD entry field is the drawing layer: lake bed(0), water(1..3), plants(4..5), mist(6).
 -- All no-write planes in these sources are closer than the depth-writing planes.
 ClearZBuffer()
 local groups={}
 for i,g in ipairs(state.program.groups)do groups[#groups+1]={g=g,a=state.anms[i],order=i}end
 table.sort(groups,function(a,b)if a.g.layer==b.g.layer then return a.order<b.order end;return a.g.layer<b.g.layer end)
 for _,v in ipairs(groups)do
  local g,a=v.g,v.a
  if a.values.alpha[1]>0 then
   SetZBufferEnable(a.nozwrite and 0 or 1)
   for _,f in ipairs(g.faces)do
    local cx,cy,cz=g.pos[1]+f[1],g.pos[2]+f[2],g.pos[3]+f[3]
    local dx,dy,dz=cx-eye[1],cy-eye[2],cz-eye[3]
    if dx*dx+dy*dy+dz*dz<=9160000 then
     local tex,blend,p=vertices(state,a,g.width,g.height,cx,cy,cz,false);RenderTexture(tex,blend,unpack(p))
    end
   end
  end
 end
 SetZBufferEnable(0)
 SetViewMode('world');local slots={}
 for slot,a in pairs(state.slots)do slots[#slots+1]={a=a,slot=slot}end
 table.sort(slots,function(a,b)if a.a.stdLayer==b.a.stdLayer then return a.slot<b.slot end;return a.a.stdLayer<b.a.stdLayer end)
 for _,v in ipairs(slots)do
  local a=v.a;if a.values.alpha[1]>0 then local spr=state.program.sprites[a.sprite];local tex,blend,p=vertices(state,a,spr[4],spr[5],0,0,0,true);RenderTexture(tex,blend,unpack(p))end
 end
end
