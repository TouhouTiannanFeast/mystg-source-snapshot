-- Original ANM programs: the used modern instructions, plus TH10 character animation.
Th18Stage5Animation={}
local A,D=Th18Stage5Animation,Th18Stage5Data
local pi=math.pi
function A.ease(t,m)
 t=math.max(0,math.min(1,t))
 if m==1 then return t*t elseif m==2 then return t^3 elseif m==3 then return t^4 elseif m==4 then return 1-(1-t)^2 elseif m==5 then return 1-(1-t)^3 elseif m==6 then return 1-(1-t)^4 elseif m==8 then return t*t*(3-2*t) elseif m==9 then return t<.5 and 2*t*t or 1-2*(1-t)^2 end
 return t
end
local function copy(t)local v={}for i,x in ipairs(t)do v[i]=x end;return v end
function A.set(a,k,v)a.values[k]=copy(v);a.tweens[k]=nil end
function A.tween(a,k,v,n,m)a.tweens[k]={from=copy(a.values[k]),to=v,n=n,mode=m,age=0}end
local loaded=false
function A.load()
 if loaded then return end;loaded=true
 for name,t in pairs(D.textures)do LoadTexture(name,'stages/th18_stage5/'..t[1]);SetTextureSamplerState(name,'linear+wrap')end
 for name,bank in pairs(D)do if type(bank)=='table' and bank.sprites then
  for id,s in pairs(bank.sprites)do local image='th18s5.'..name..'.sprite'..id;LoadImage(image,s[1],s[2],s[3],s[4],s[5]);s.image=image end
 end end
end
local function val(a,v)
 if type(v)~='string' then return v end
 local k=tonumber(v:match('%[([%d%.]+)f?%]'))
 if k==10010 then return (a.random()*2-1)*pi elseif k==10011 then return a.random() elseif k==10012 then return a.random()*2-1 end
 return assert(a.vars[k],'unknown ANM expression '..v)
end
local function args(a,t)local v={}for i,x in ipairs(t)do v[i]=val(a,x)end;return v end
function A.new(bank,id,random)
 local a={bank=bank,script=id,code=assert(D[bank].scripts[id],bank..' ANM '..id),clock=0,age=0,pc=1,values={pos={0,0,0},rot={0,0,0},scale={1,1},alpha={255},color={255,255,255}},tweens={},children={},vars={},cases={},random=random or math.random,blend=0}
 for i=10000,10009 do a.vars[i]=0 end
 for i,c in ipairs(a.code)do if c[2]==5 then a.cases[c[3][1]]=i end end
 if bank=='suwako' then a.old=true;a.pc=1 end
 A.run(a);return a
end
function A.case(a,n)
 local p=a.cases[n];if p then a.pc=p+1;a.clock=a.code[p][1];a.stopped=false;A.run(a)end
end
local function variable(a,key,v)
 local k=type(key)=='string' and tonumber(key:match('%[([%d%.]+)f?%]')) or key
 a.vars[k]=v
end
function A.run(a)
 local guard=0
 while not a.stopped and not a.dead and a.pc<=#a.code and a.code[a.pc][1]<=a.clock do
  guard=guard+1;assert(guard<160,'ANM did not yield '..a.bank..'/'..a.script)
  local c=a.code[a.pc];local op,raw=c[2],c[3];local v=args(a,raw);a.pc=a.pc+1
  if a.old then
   if op==0 then a.dead=true elseif op==1 or op==63 then a.stopped=true
   elseif op==3 then a.sprite=v[1] elseif op==4 then a.pc=v[1];a.clock=v[2]
   elseif op==48 then A.set(a,'pos',v) elseif op==56 then A.tween(a,'pos',{v[3],v[4],v[5]},v[1],v[2])
   elseif op==61 then a.flip=true elseif op==68 then a.layer=v[1]
   elseif op==51 then A.set(a,'scale',v) elseif op==58 then A.tween(a,'scale',{v[3],v[4]},v[1],v[2])
   end
  else
   if op==0 or op==5 then
   elseif op==1 then a.dead=true elseif op==2 or op==3 then a.stopped=true
   elseif op==6 then a.clock=a.clock-v[1]
   elseif op==200 then a.pc=v[1];a.clock=v[2]
   elseif op==201 then variable(a,raw[1],v[1]-1);if v[1]-1>0 then a.pc=v[2];a.clock=v[3]end
   elseif op==100 or op==101 then variable(a,raw[1],v[2])
   elseif op==103 then variable(a,raw[1],v[1]+v[2])
   elseif op==124 then variable(a,raw[1],math.sin(v[2]))
   elseif op==125 then variable(a,raw[1],math.cos(v[2]))
   elseif op==105 then variable(a,raw[1],v[1]-v[2])
   elseif op==117 then variable(a,raw[1],v[2]*v[3])
   elseif op==119 then variable(a,raw[1],v[2]/v[3])
   elseif op==300 then a.sprite=v[1]
   elseif op==301 then a.sprite=v[1]+math.floor(a.random()*v[2])
   elseif op==302 then a.renderType=v[1] elseif op==303 then a.blend=v[1] elseif op==304 then a.layer=v[1] elseif op==315 then a.colorizeChildren=v[1]~=0
   elseif op==311 then a.resample=v[1] elseif op==424 then a.autoRotate=v[1]~=0 elseif op==438 then a.origin=v[1]
   elseif op==400 then A.set(a,'pos',v) elseif op==401 then A.set(a,'rot',v) elseif op==402 then A.set(a,'scale',v)
   elseif op==403 then A.set(a,'alpha',v) elseif op==404 then A.set(a,'color',v)
   elseif op==407 then A.tween(a,'pos',{v[3],v[4],v[5]},v[1],v[2])
   elseif op==408 then A.tween(a,'color',{v[3],v[4],v[5]},v[1],v[2])
   elseif op==409 then A.tween(a,'alpha',{v[3]},v[1],v[2])
   elseif op==410 then A.tween(a,'rot',{v[3],v[4],v[5]},v[1],v[2])
   elseif op==415 then a.angleVelocity=v
   elseif op==412 then A.tween(a,'scale',{v[3],v[4]},v[1],v[2])
   elseif op==500 or op==504 then local child=A.new(a.bank,v[1],a.random);child.root=op==504;child.base=copy(a.values.pos);a.children[#a.children+1]=child
   else error('unsupported ANM '..a.bank..'/'..a.script..' opcode '..op)end
  end
 end
end
function A.step(a)
 a.age=a.age+1;a.clock=a.clock+1
 for k,t in pairs(a.tweens)do
  t.age=t.age+1;local out={}
  if t.mode==7 then for i,x in ipairs(a.values[k])do out[i]=x+t.to[i]end
  else local u=A.ease(t.age/math.max(1,t.n),t.mode);for i,x in ipairs(t.from)do out[i]=x+(t.to[i]-x)*u end end
  a.values[k]=out;if t.n>=0 and t.age>=t.n then a.tweens[k]=nil end
 end
 if a.angleVelocity then for i=1,3 do a.values.rot[i]=a.values.rot[i]+a.angleVelocity[i]end end
 A.run(a)
 for i=#a.children,1,-1 do local c=a.children[i];A.step(c);if c.dead then table.remove(a.children,i)end end
end
function A.render(a,x,y,parentColor)
 if a.dead then return end
 local pos,rot,scale=a.values.pos,a.values.rot,a.values.scale;local color=a.values.color;local alpha=a.values.alpha[1]
 if parentColor then color={color[1]*parentColor[1]/255,color[2]*parentColor[2]/255,color[3]*parentColor[3]/255};alpha=alpha*parentColor[4]/255 end
 x,y=x+pos[1],y-pos[2]
 local spr=D[a.bank].sprites[a.spriteMap and a.spriteMap(a.sprite)or a.sprite]
 if spr then
  local tint=Color(math.max(0,math.min(255,alpha)),math.max(0,math.min(255,color[1])),math.max(0,math.min(255,color[2])),math.max(0,math.min(255,color[3])))
  SetImageState(spr.image,a.blend==1 and 'mul+add' or '',tint)
  Render(spr.image,x,y,-rot[3]*180/pi+(a.heading or 0),scale[1]*math.cos(rot[2])*(a.flip and -1 or 1),scale[2]*math.cos(rot[1]))
 end
 local tint=a.colorizeChildren and {color[1],color[2],color[3],alpha}or nil
 for _,child in ipairs(a.children)do A.render(child,child.root and x-pos[1]+child.base[1] or x,child.root and y+pos[2]-child.base[2] or y,tint)end
end
