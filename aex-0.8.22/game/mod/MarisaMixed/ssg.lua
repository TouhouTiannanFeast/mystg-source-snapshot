-- Private interpreter for the extracted first HP segment and its reachable helpers.
-- Coordinates retain source pixels; direction is an unsigned 8-bit turn.
SSG={};local R=SSG
local floor,abs=math.floor,math.abs
local function trunc(x)return x<0 and math.ceil(x)or floor(x)end
local function cs(d,v)return trunc(math.cos(d*math.pi/128)*v)end
local function sn(d,v)return trunc(math.sin(d*math.pi/128)*v)end
local function angle(x,y)return floor((math.atan2(y,x)*128/math.pi)%256)end
local function rnd(n)return floor(R.random()*n)end
local function emitSound(id,a)if R.onSound then R.onSound(id,a)end end
function R.actor(pc,x,y,d)
 local a={pc=pc,x=x,y=y,d=d or 0,v=0,reg={},t={cmd=0,d=0,dw=0,n=1,ns=1,v=0,c=1,a=0,type=0,rep=0},l={d=0,dw=0,n=1},age=0,anim=0,animTick=0,animSpeed=10,visible=true,damage=true,hp=9999}
 for i=0,7 do a.reg[i]=0 end
 R.actors[#R.actors+1]=a;return a
end
function R.start(seed)
 R.timeLimit=nil
 R.bitRotationScale=nil
 local state=seed or 20261106
 R.random=function()state=state*16807%2147483647;return(state-1)/2147483646 end
 R.actors={};R.bullets={};R.beams={};R.homing={};R.bits={};R.tick=0;R.done=false;R.stats={shots=0,branches={},bitBranches={}}
 R.body=R.actor(0x10a,319,89);R.body.hp=12000
 R.radius=0;R.targetRadius=80;R.bitSpeed=2;R.baseAngle=0;R.laserEnabled=false
end
local function get(a,id)
 if id==134 then return a.t.d elseif id==145 then return a.d else return a.reg[id]or 0 end
end
local function put(a,id,v)
 if id==134 then a.t.d=v%256 elseif id==145 then a.d=v%256 else a.reg[id]=v end
end
function R.fire(a,extra,ranked)
 local t=a.t;local count=t.n*(floor(t.cmd/4)%2==1 and t.ns or 1)
 local base=(t.d+(floor(t.cmd/8)%2==1 and angle(R.px-a.x,R.py-a.y)or 0))%256
 local speed=(t.v%64)*16
 -- Normal TAMA leaves counts unchanged; rank's initial32/32 leaves base speed unchanged.
 for i=0,count-1 do
  local index=i%t.n;local mode=t.cmd%4;local d=base
  if mode==0 then local j=index+1;d=base+(t.n%2==0 and -floor(t.dw/2)or 0)+floor(j/2)*t.dw*(1-2*(j%2))
  elseif mode==1 then d=base+floor(index*256/t.n)
  elseif mode==2 then d=base+rnd(math.max(1,t.dw))-floor(t.dw/2)end
  d=d%256
  local flag=floor(t.v/64);local random=flag==0 and 0 or rnd(({16,32,64})[flag])-({8,16,32})[flag]
  local v=speed
  if extra then local delta=(t.d-d+128)%256-128;v=v-trunc(v*abs(delta)/23)
  elseif floor(t.cmd/4)%2==1 then v=v+floor(v/8)*floor(i/t.n)end
  v=v+random
  local b={x=a.x,y=a.y,d=d,v=v/64,v0=v/64,a=t.a/64,typ=t.type,rep=t.rep,c=t.c,age=0}
  R.bullets[#R.bullets+1]=b;R.stats.shots=R.stats.shots+1;if R.onBullet then R.onBullet(b)end
 end
end
function R.makeBits()
 if #R.bits>0 then return end
 R.radius=0;R.targetRadius=80;R.baseAngle=0;R.bitSpeed=rnd(2)==0 and -2 or 2;R.cx,R.cy=R.body.x,R.body.y
 for i=0,4 do
  local b=R.actor(0x909,R.body.x,R.body.y,i*51);b.bit=true;b.reg[0]=i;b.reg[1]=5;b.hp=95*({1,4,2,5,3})[i+1];b.bitAngle=b.d;b.force=0
  R.bits[#R.bits+1]=b;if R.onBit then R.onBit(b)end
 end
end
function R.bitLaser(cmd)
 if cmd==0 then for _,b in ipairs(R.beams)do b.state='open'end;emitSound(2,R.body);return end
 if cmd==1 then for _,b in ipairs(R.beams)do b.state='close'end;R.laserEnabled=false;return end
 R.laserEnabled=true;R.laserType=cmd
 for _,a in ipairs(R.bits)do
  local angles=cmd==3 and {a.d}or cmd==4 and {a.d+64,a.d+192}or{a.d+64+floor(256/#R.bits),a.d-64-floor(256/#R.bits)}
  for j,d in ipairs(angles)do
   local b={owner=a,d=d%256,width=0,state='line',color=cmd==3 and 2 or cmd==4 and 1 or 0,side=j}
   R.beams[#R.beams+1]=b;if R.onBeam then R.onBeam(b)end
  end
 end
end
function R.hlasers(a)
 local l=a.l
 for i=1,l.n do
  local d=l.d+(l.n%2==0 and -floor(l.dw/2)or 0)+floor(i/2)*l.dw*(1-2*(i%2))
  local b={x=a.x,y=a.y,d=d%256,v=4,age=0,points={},tracking=true}
  for j=1,28 do b.points[j]={x=a.x,y=a.y,d=d}end
  R.homing[#R.homing+1]=b;if R.onHoming then R.onHoming(b)end
 end
end
function R.run(a)
 if a.dead then return end
 if a==R.body and a.bitsInterrupt and #R.bits==0 then a.pc=0x2af;a.wait=nil;a.motion=nil;a.rep=0;a.bitsInterrupt=false end
 if a.wait then a.wait=a.wait-1;if a.wait>0 then return end;a.wait=nil end
 if a.motion then
  local m=a.motion
  if m.left>0 then
   if m.kind=='acc' then a.v=a.v+m.acc;a.x=a.x+cs(a.d,a.v)/64;a.y=a.y+sn(a.d,a.v)/64
   else a.x=a.x+m.vx;a.y=a.y+m.vy end
   m.left=m.left-1;return
  end;a.motion=nil
 end
 for budget=1,300 do
  if a==R.body and a.pc>=0x2c6 and a.pc<0x5c4 then R.done=true;return end
  local ins=assert(SSGCode[a.pc],'unmapped SSG instruction '..a.pc);local op,v,nextpc=ins[1],ins[2],ins[3];local here=a.pc;a.pc=nextpc
  if op=='NOP'then a.wait=v[1];return
  elseif op=='ACC'then a.motion={kind='acc',acc=v[1],left=v[2]};a.v=a.v+v[1];a.x=a.x+cs(a.d,a.v)/64;a.y=a.y+sn(a.d,a.v)/64;a.motion.left=a.motion.left-1;return
  elseif op=='MXYA'then a.motion={kind='xy',vx=trunc((v[1]-a.x)*64/(v[3]+1))/64,vy=trunc((v[2]-a.y)*64/(v[3]+1))/64,left=v[3]};local m=a.motion;a.x=a.x+m.vx;a.y=a.y+m.vy;m.left=m.left-1;return
  elseif op=='JMP'then a.pc=v[1]
  elseif op=='CALL'then
   a.ret=nextpc;a.pc=v[1]
   if a==R.body then if v[1]>=0x5c4 and v[1]<=0x675 then R.stats.branches[v[1]]=(R.stats.branches[v[1]]or 0)+1 elseif v[1]>=0x6e4 and v[1]<=0x8b9 then R.stats.bitBranches[v[1]]=(R.stats.bitBranches[v[1]]or 0)+1 end end
  elseif op=='RET'then a.pc=assert(a.ret)
  elseif op=='LOOP'then a.rep=a.rep or(v[2]+1);a.rep=a.rep-1;if a.rep>0 then a.pc=v[1]else a.rep=nil end
  elseif op=='RND'then put(a,v[1],rnd(65536)*rnd(65536))
  elseif op=='MOVC'then put(a,v[1],v[2])
  elseif op=='MOVR'then put(a,v[1],get(a,v[2]))
  elseif op=='MOD'then put(a,v[1],get(a,v[1])%v[2])
  elseif op=='ADD'then put(a,v[1],get(a,v[1])+get(a,v[2]))
  elseif op=='SUB'then put(a,v[1],get(a,v[1])-get(a,v[2]))
  elseif op=='INC'then put(a,v[1],get(a,v[1])+1)
  elseif op=='CMPC'then a.cmp=get(a,v[1])-v[2]
  elseif op=='JEQ'then if a.cmp==0 then a.pc=v[1]end
  elseif op=='JL'then if a.cmp>0 then a.pc=v[1]end -- Original opcode means greater-than.
  elseif op=='JS'then if a.cmp<0 then a.pc=v[1]end
  elseif op=='SPDA'then a.v=v[1]
  elseif op=='DEGX2'then
   local left,right,top,bottom=278,361,66,133
   local base
   if a.y<top then base=a.x<left and 16 or a.x>right and 80 or(16+rnd(2)*64)
   elseif a.y>bottom then base=a.x<left and -48 or a.x>right and 144 or 176
   else base=a.x<left and -16 or a.x>right and 112 or(rnd(2)==0 and -16 or 112)end
   a.d=(base+rnd(32))%256
  elseif op=='ANM'then a.anim,a.animSpeed,a.animTick=v[1],v[2],0
  elseif op=='ANMEX'then a.mask=v[1]
  elseif op=='DAMAGE_OFF'then a.damage=false
  elseif op=='DAMAGE_ON'then a.damage=true
  elseif op=='DRAW_OFF'then a.visible=false
  elseif op=='DRAW_ON'then a.visible=true
  elseif op=='SETUP'then if not a.bit then a.hp=v[1]end
  elseif op=='STI'then if v[2]==3 then a.bitsInterrupt=true end
  elseif op=='CLI'then if v[1]==3 then a.bitsInterrupt=false end
  elseif op=='INT'then if v[1]==3 then R.makeBits()elseif v[1]==5 then a.barrier=true end
  elseif op=='PSE'then emitSound(v[1],a)
  elseif op=='ENEMYSETD'then local child=R.actor(v[4]==18 and 0xb37 or 0xb88,floor(a.x)+v[1],floor(a.y)+v[2],get(a,v[3]));child.emitter=true
  elseif op=='END'then a.dead=true;return
  elseif op=='TCMD'then a.t.cmd=v[1]
  elseif op=='TDEGA'then a.t.d,a.t.dw=v[1],v[2]
  elseif op=='TDEGS'then a.t.d=angle(R.px-a.x,R.py-a.y)
  elseif op=='TDEGE'then a.t.d=a.d
  elseif op=='TNUMA'then a.t.n,a.t.ns=v[1],v[2]
  elseif op=='TNUMR'then a.t.n,a.t.ns=a.t.n+v[1],a.t.ns+v[2]
  elseif op=='TSPDA'then a.t.v,a.t.a=v[1],v[2]
  elseif op=='TCOL'then a.t.c=v[1]
  elseif op=='TTYPE'then a.t.type=v[1]
  elseif op=='TREP'then a.t.rep=v[1]
  elseif op=='TOPT'then a.t.opt=v[1]
  elseif op=='TAMA'or op=='TAMA2'or op=='TAMAEX'then R.fire(a,op=='TAMAEX',op=='TAMA')
  elseif op=='BITATTACK'then for _,b in ipairs(R.bits)do b.pc=v[1]==4 and 0x98f or 0x9fb;b.wait=nil;b.motion=nil;b.rep=nil end
  elseif op=='BITCMD'then
   if v[1]==1 then R.bitSpeed=(R.bitSpeed>0 and 1 or -1)*v[2]
   elseif v[1]==3 then R.targetRadius=v[2]/64
   elseif v[1]==4 then R.boom={v=640,d=angle(R.px-R.cx,R.py-R.cy)}end
  elseif op=='BITLASER'then R.bitLaser(v[1])
  elseif op=='LTYPE'or op=='LCOL'or op=='LXY'then -- Source homing type1 and color0; zero relative origin.
  elseif op=='LNUMA'then a.l.n=v[1]
  elseif op=='LDEGA'then a.l.d,a.l.dw=v[1],v[2]
  elseif op=='LDEGS'then a.l.d=angle(R.px-a.x,R.py-a.y)
  elseif op=='LDEGR'then a.l.d=(a.l.d+v[1])%256;a.l.dw=a.l.dw+v[2]
  elseif op=='HLASER'then R.hlasers(a)
  elseif op=='ITEM'or op=='HITSB_ON'or op=='HITSB_OFF'or op=='CLIP_ON'then
  else error('unsupported source instruction '..op..' at '..here)end
 end
 error('source instruction budget exceeded')
end
function R.step(px,py,hp)
 R.tick=R.tick+1;R.px,R.py=px,py;R.body.hp=hp+8000
 if hp<=0 or R.tick>(R.timeLimit or 3600)then R.done=true;return end
 for _,a in ipairs(R.actors)do if not a.dead then R.run(a);a.age=a.age+1;a.animTick=a.animTick+1 end end
 local i=1
 while i<=#R.bits do
  if R.bits[i].dead then
   local n=#R.bits;if i==1 then R.baseAngle=R.baseAngle+floor(256/n)end
   table.remove(R.bits,i);n=#R.bits
   if n>0 then
    local prev=(i-2+n)%n+1;local next=(i-1)%n+1
    R.bits[prev].force=R.bits[prev].force-30;R.bits[next].force=R.bits[next].force+30
   end
  else i=i+1 end
 end
 if #R.bits>0 then
  if R.boom then local b=R.boom;b.v=b.v-8;R.cx=R.cx+cs(b.d,b.v)/64;R.cy=R.cy+sn(b.d,b.v)/64;if b.v<=-640 then R.boom=nil end
  else R.cx,R.cy=R.body.x,R.body.y end
  local rotationScale=R.bitRotationScale or 1
  R.radius=R.radius+math.max(-2,math.min(2,R.targetRadius-R.radius));R.baseAngle=(R.baseAngle+R.bitSpeed*rotationScale)%512
  for i,b in ipairs(R.bits)do
   local previousAngle=b.bitAngle
   b.reg[1]=#R.bits;local target=(floor(R.baseAngle/2)+floor(256/#R.bits)*(i-1))%256;local diff=(target-b.bitAngle+128)%256-128;local extra=abs(trunc(R.bitSpeed/2))
   if diff>0 then b.bitAngle=b.bitAngle+math.max(math.min(diff,2),extra+(R.bitSpeed>0 and 0 or 1))
   elseif diff<0 then b.bitAngle=b.bitAngle-math.max(math.min(-diff,2),extra+(R.bitSpeed<0 and 0 or 1))end
   if b.force>0 then b.force=b.force-1;b.bitAngle=b.bitAngle+(R.bitSpeed>0 and 1 or extra+1)
   elseif b.force<0 then b.force=b.force+1;b.bitAngle=b.bitAngle-(R.bitSpeed<0 and 1 or extra+1)end
   b.bitAngle=(previousAngle+(b.bitAngle-previousAngle)*rotationScale)%256;b.d=b.bitAngle;b.x,b.y=R.cx+cs(b.d,R.radius*64)/64,R.cy+sn(b.d,R.radius*64)/64
  end
 end
 for _,b in ipairs(R.beams)do
  b.x,b.y=b.owner.x,b.owner.y
  if b.owner.dead then b.dead=true end
  if R.laserType==5 then b.d=(b.owner.d+(b.side==1 and 1 or -1)*(64+floor(256/math.max(1,#R.bits))))%256 end
  if b.state=='open'then b.width=math.min(8,b.width+1)elseif b.state=='close'then b.width=math.max(0,b.width-1);if b.width==0 then b.dead=true end end
 end
 for _,b in ipairs(R.bullets)do if not b.dead then
  if b.typ==1 and b.rep>0 then b.v=b.v+b.a;b.rep=b.rep-1 end
  local scale=b.motionScale or 1
  b.x,b.y=b.x+cs(b.d,b.v*64)/64*scale,b.y+sn(b.d,b.v*64)/64*scale;b.age=b.age+1
  if b.x<100 or b.x>540 or b.y<-32 or b.y>512 then b.dead=true;b.offscreen=true end
 end end
 for _,b in ipairs(R.homing)do if not b.dead then
  b.age=b.age+1
  if b.tracking then
   local delta=(angle(px-b.x,py-b.y)-b.d+128)%256-128
   if abs(delta)<8 then b.tracking=false;emitSound(17,b)
   else if b.v>2 then b.v=b.v-10/64 end;local d=trunc(delta*(1+floor(b.age/32))/32);b.d=(b.d+(d~=0 and d or delta))%256 end
   if b.age>120 then b.tracking=false end
  else b.v=b.v+20/64 end
  b.x,b.y=b.x+cs(b.d,b.v*64)/64,b.y+sn(b.d,b.v*64)/64
  table.insert(b.points,1,{x=b.x,y=b.y,d=b.d});table.remove(b.points)
  local tail=b.points[28];if tail.x<124 or tail.x>515 or tail.y<-4 or tail.y>483 then b.dead=true end
 end end
end
