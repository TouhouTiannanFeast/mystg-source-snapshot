SSGSelected05={};local X=SSGSelected05;local R=SSG;local I=SSGInspect04
X.order={'A2','B1','B3'};X.active=false
X.lengths={A2=1260,B1=1320,B3=1200}
function X.frames(mode)return mode=='full'and 3780 or X.lengths[mode]end
function X.accept(mode)return mode=='full'or mode=='A2'or mode=='B1'or mode=='B3'end
function X.stop()X.active=false;X.entryProtected=false end
function X.start(seed,mode)
 X.active=true;X.clock=0;X.index=1;X.mode=mode or'full';X.duration=X.frames(X.mode)
 X.entryProtected=X.mode=='full'or X.mode=='A2'
 X.b3Wave=0;X.a2EmitterCount=0;X.b1SoundTick=nil
 X.stageStart=1;X.stageAge=0;X.chargeSoundTick=nil
 X.sequence=X.mode=='full'and X.order or{X.mode}
 local state=(seed or 20261106)%2147483647;if state<=0 then state=1 end
 X.colorRandom=function(n)state=state*16807%2147483647;return math.floor((state-1)/2147483646*n)end
 X.stats={births={},skins={},sounds=0,laserDraws=0,stages={}}
 X.stage=X.sequence[1];I.start(seed,X.stage)
 R.timeLimit=X.duration
 if X.stage=='A2'then SSGCode[0x157]={'NOP',{60},I.original[0x157][3]}end
 X.stats.stages[1]={id=X.stage,at=1}
end
function X.transition(id)
 -- Keep the live Boss position/HP, existing bullets and the same five bits.
 -- Stop only previous source emitters/bit firing programs before the next helper.
 local a=R.body;a.wait=nil;a.motion=nil;a.rep=nil;a.ret=nil;a.bitsInterrupt=false;a.pc=0x208
 for _,b in ipairs(R.actors)do
  if b.emitter then b.dead=true
  elseif b.bit then b.pc=0x909;b.wait=nil;b.motion=nil;b.rep=nil;b.ret=nil end
 end
 I.select(id);if #R.bits==0 then R.makeBits()end
 X.stage=id;X.b3Wave=0;X.a2EmitterCount=0;X.b1SoundTick=nil;X.stats.stages[#X.stats.stages+1]={id=id,at=X.clock}
 X.stageStart=X.clock;X.chargeSoundTick=nil
 print('SSG SELECTED05 '..id..' frame='..X.clock)
end
function X.step(px,py,hp)
 X.clock=X.clock+1
 local index=1;local endFrame=X.lengths[X.sequence[1]]
 while index<#X.sequence and X.clock>endFrame do index=index+1;endFrame=endFrame+X.lengths[X.sequence[index]]end
 if index~=X.index then X.index=index;X.transition(X.sequence[index])end
 X.stageAge=X.clock-X.stageStart+1
 R.bitRotationScale=X.stage=='B3'and 0.5 or nil
 R.step(px,py,hp)
 if X.stage=='B3'then
  for _,b in ipairs(R.beams)do
   if not b.dead and b.selected05Laser and b.state=='line'and R.tick-b.selected11Created==0 and X.chargeSoundTick~=R.tick then
    X.chargeSoundTick=R.tick;PlaySound('mm.selected12.charge',0.4,0)
   end
  end
 end
 if X.clock>=X.duration then R.done=true end
end
for key,row in pairs(SSGSelectedArt05)do row.image='mm.selected05.'..key;LoadTexture(row.image,row.path);LoadImage(row.image,row.image,0,0,row.w,row.h)end
LoadSound('mm.selected05.laser','se/th08-se_lazer00.wav')
LoadSound('mm.selected09.shot','se/th08-se_tan00.wav')
LoadSound('mm.selected12.charge','se/th08-se_power0.wav')
local onBullet=R.onBullet
local actor=R.actor
R.actor=function(pc,...)
 local a=actor(pc,...)
 if X.active and X.stage=='A2'and pc==0xb37 then
  X.entryProtected=false
  X.a2EmitterCount=X.a2EmitterCount+1
  a.selected08Wave=math.floor((X.a2EmitterCount-1)/13)+1
  a.selected08Color=({2,4,6})[(a.selected08Wave-1)%3+1]
 end
 return a
end
local run=R.run
R.run=function(a)
 if X.active and X.stage=='A2'and a==R.body and a.pc==0x621
  and a.motion and a.motion.left==0 and a.selected08Pause~=a.motion then
  a.selected08Pause=a.motion
  local i=X.a2EmitterCount%13
  if i~=0 then a.wait=({2,1,2})[(i-1)%3+1]+1 end
 end
 return run(a)
end
local fire=R.fire
R.fire=function(a,...)
 if X.active and X.stage=='B1'and X.stageAge>1200 then return end
 local previous=X.a2Color;X.a2Color=a.selected08Color
 local previousB1=X.b1Color
 if a.bit then X.b1Color=({2,4,6,8,12})[(a.reg[0]or 0)+1]end
 local before=R.stats.shots
 local result=fire(a,...);X.a2Color=previous;X.b1Color=previousB1
 if X.active and X.stage=='B1'and a.bit and R.stats.shots>before and X.b1SoundTick~=R.tick then
  X.b1SoundTick=R.tick;PlaySound('mm.selected09.shot',0.3,0)
 end
 return result
end
R.onBullet=function(b)
 if X.active then
  if X.stage=='A2'and b.c==51 then b.dead=true;return end
  if X.stage=='B3'and X.b3Wave>0 and X.b3Wave%2==0 then b.dead=true;return end
  b.motionScale=0.5;b.selected05Stage=X.stage
  local kind,color
  if X.stage=='A2'and b.c==48 then kind='bigstar';color=6
  elseif X.stage=='A2'and b.c==50 then kind='smallstar';color=X.a2Color or 2
  elseif X.stage=='B1'and b.c==1 then kind='smallstar';color=X.b1Color or 2
  elseif X.stage=='B3'and b.c==21 then kind='smallstar';color=14 end
  b.selected05Skin,b.selected05Color=kind,color
  X.stats.births[X.stage]=(X.stats.births[X.stage]or 0)+1
  if kind then X.stats.skins[kind]=(X.stats.skins[kind]or 0)+1 end
 end
 if onBullet then onBullet(b)end
end
local onBeam=R.onBeam
local bitLaser=R.bitLaser
R.bitLaser=function(cmd)
 if X.active and X.stage=='B3'and cmd==3 then X.b3Wave=X.b3Wave+1 end
 if X.active and X.stage=='B3'and cmd==0 then
  for _,b in ipairs(R.beams)do if b.selected05Laser and b.state=='line'and not b.dead then b.selected14OpenTick=R.tick end end
 end
 return bitLaser(cmd)
end
R.onBeam=function(b)
 if X.active and X.stage=='B3'then b.selected05Laser=true;b.selected11Created=R.tick end
 if onBeam then onBeam(b)end
end
local onSound=R.onSound
R.onSound=function(id,a)
 if X.active and X.stage=='B3'and id==2 then
  PlaySound('mm.selected05.laser',0.4,((a.x or 319)-319)/192);X.stats.sounds=X.stats.sounds+1
 elseif onSound then onSound(id,a)end
end
function X.drawBullet(b)
 local kind=b.selected05Skin;if not kind then return false end
 local art,spin,scale
 if kind=='yellowdot'then art=SSGSelectedArt05.yellowdot;scale=1;spin=0
 elseif kind=='glow'then art=SSGSelectedArt05['glow'..b.selected05Color];scale=1;spin=0
 else local big=kind=='bigstar';art=TH08Art02[tostring((big and 262 or 246)+b.selected05Color)];scale=1;spin=big and 1.8 or 3 end
 SetImageState(art.image,kind=='glow'and'mul+add'or'',Color(255,255,255,255))
 Render(art.image,b.x-319,224-b.y,spin*b.age,scale,scale);return true
end
function X.laserLength(b)
 if b.state=='line'then return 0 end
 return 800*math.min(1,math.max(0,(R.tick-(b.selected14OpenTick or R.tick)+1)/30))
end
function X.laserWarning(b)
 return b.selected05Laser and not b.dead and(b.state=='line'or(b.state=='open'and X.laserLength(b)<800))
end
function X.drawLaser(b)
 if not b.selected05Laser then return false end
 local age=R.tick-(b.selected11Created or R.tick)
 local art,glow=SSGSelectedArt05.laser11,SSGSelectedArt05.laser11glow
 local warning=b.state=='line';local width=warning and 4 or b.width*2
 if width<=0 then return true end
 local d=-b.d*360/256;local x,y=b.x-319,224-b.y
 if X.laserWarning(b)then
  local start=warning and 0 or X.laserLength(b)
  local length=warning and 800*math.min(1,math.max(0,(age+1)/60))or 800
  local function guide(w,c)
   local sx,sy=x+start*cos(d),y+start*sin(d)
   local nx,ny=-sin(d)*w/2,cos(d)*w/2;local ex,ey=x+length*cos(d),y+length*sin(d)
   SetImageState('white','',c)
   Render4V('white',sx+nx,sy+ny,0.5,ex+nx,ey+ny,0.5,ex-nx,ey-ny,0.5,sx-nx,sy-ny,0.5)
  end
  guide(6,Color(210,12,8,0));guide(4,Color(255,255,192,32));guide(1.5,Color(255,255,255,232))
  X.stats.guideDraws=(X.stats.guideDraws or 0)+1
 end
 if not warning then
  local length=X.laserLength(b)
  SetImageState(art.image,'mul+add',Color(255,255,255,255))
  Render(art.image,x+length/2*cos(d),y+length/2*sin(d),d+90,width/16,length/14)
 end
 SetImageState(glow.image,'mul+add',Color(warning and 192 or 255,255,255,255))
 local scale=warning and(0.25+0.25*math.min(1,age/60))or width/16
 Render(glow.image,x,y,0,scale,scale)
 X.stats.laserDraws=X.stats.laserDraws+1;return true
end
