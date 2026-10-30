-- Fixed HSoB stage5 host. Coordinates are source 384x448, down-positive.
HSoB5={tick=0,section=0,objects={},threads={},events={},counts={enemies=0,shots=0,beams=0},px=192,py=400}
local R=HSoB5
local E={};R.env=E
setmetatable(E,{__index=function(_,k)
 if k=='GetPlayerX' then return R.px elseif k=='GetPlayerY' then return R.py end
 return _G[k]
end})
E.HSoB5=R
function E.truth(v)return v~=nil and v~=false and v~=0 end
function E.arr(...)local t={...};t.n=select('#',...);return t end
function E.at(t,i)if type(i)=='boolean'then i=i and 1 or 0 end;return t[i+1]end
function E.length(t)return t.n or #t end
function E.slice(t,a,b)local v={n=b-a};for i=a,b-1 do v[i-a+1]=E.at(t,i)end;return v end
function E.concat(a,b)local v={};for _,t in ipairs({a,b})do for i=1,E.length(t)do v[#v+1]=t[i]end end;v.n=#v;return v end
E.trunc=function(x)return x<0 and math.ceil(x)or math.floor(x)end
E.min,E.max,E.absolute,E.ator=math.min,math.max,math.abs,tonumber
E.cos=function(a)return math.cos(a*math.pi/180)end
E.sin=function(a)return math.sin(a*math.pi/180)end
E.atan2=function(y,x)return math.atan2(y,x)*180/math.pi end
E.GetCurve_d=function(v)return E.sin(v*90)end
E.GetCurve_a=function(v)return 1-E.cos(v*90)end
function E.rand(a,b)R.seed=R.seed*16807%2147483647;return a+(b-a)*(R.seed-1)/2147483646 end
function E.Rotate2D_XY(x,y,a)return E.arr(x*E.cos(a)-y*E.sin(a),x*E.sin(a)+y*E.cos(a))end
function E.wait(n)if n>0 then coroutine.yield(math.max(1,E.trunc(n)))end end
E.waitEx=E.wait;E.WaitRoad=E.wait
function R.resume(t)
 local ok,n=coroutine.resume(t.co)
 assert(ok,debug.traceback(t.co,tostring(n)))
 t.dead=coroutine.status(t.co)=='dead';t.wake=R.tick+(n or 1)
end
function R.spawn(fn)
 local t={co=coroutine.create(fn),wake=R.tick,section=R.section}
 R.threads[#R.threads+1]=t;R.resume(t);return t
end
function E.asTask(fn)return function(...)local args={...};local n=select('#',...);return R.spawn(function()fn(unpack(args,1,n))end)end end
local function alive(o)return type(o)=='table' and not o.dead end
E.Obj_IsDeleted=function(o)return not alive(o)end
E.CanShotBullet=alive
function E.waitObj(o,n)
 for i=1,math.max(0,E.trunc(n))do if not alive(o)then coroutine.yield('cancel')end;E.wait(1)end
end
-- A cancelled object's coroutine is removed by resume, rather than leaking until stage end.
local resume=R.resume
function R.resume(t)
 local ok,n=coroutine.resume(t.co)
 assert(ok,debug.traceback(t.co,tostring(n)))
 t.dead=n=='cancel' or coroutine.status(t.co)=='dead';t.wake=R.tick+(type(n)=='number' and n or 1)
end
function E.Obj_Delete(o)if alive(o)then o.dead=true end end
E.EraseEnemy=E.Obj_Delete
function E.Obj_GetValueD(o,k,d)if type(o)~='table'then return d end;local v=o.values[k];if v==nil then return d else return v end end
function E.Obj_SetValue(o,k,v)if type(o)=='table'then o.values[k]=v end end
E.ObjMove_GetX=function(o)return o.x end;E.ObjMove_GetY=function(o)return o.y end
E.ObjMove_GetSpeed=function(o)return o.speed or 0 end;E.ObjMove_GetAngle=function(o)return o.angle or 0 end
E.ObjMove_SetX=function(o,x)o.x=x end;E.ObjMove_SetY=function(o,y)o.y=y end
function E.ObjMove_SetPosition(o,x,y)o.x,o.y=x,y end
function E.GetAngleToPlayer(o)return E.atan2(R.py-o.y,R.px-o.x)end
function E.GetObjectDistance(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
function E.GetGapAngle(a,b)return E.atan2(b[2]-a[2],b[1]-a[1])end
function E.CheckDispIN(o,s)return alive(o)and o.x>=-s and o.x<=384+s and o.y>=-s and o.y<=448+s end
E.IsTimeStopObj=function()return false end
E.GetPlayerLife=function()return R.getLife and R.getLife()or 8 end
local function object(x,y,kind)
 local o={x=x,y=y,kind=kind,age=0,speed=0,angle=0,values={},visible=true,alpha=255,sx=1,sy=1,color={255,255,255},section=R.section}
 R.objects[#R.objects+1]=o;return o
end
function E.MakeEnemy(x,y,hp,size)
 hp=hp*5 -- Requested HSoB road enemy HP multiplier, applied once before native creation.
 local o=object(x,y,'enemy');o.hp=hp;o.maxhp=hp;o.size=size;o.damageRate=1
 o.radius=({[0]=0,64,40,32,24,16,10})[size];o.playerRadius=({[0]=0,24,24,14,8,0,0})[size]
 R.counts.enemies=R.counts.enemies+1
 if R.onEnemy then R.onEnemy(o)end;return o
end
function E.ObjEnemy_SetLife(o,hp)o.hp=hp end
function E.ObjEnemy_SetDamageRate(o,s,b)o.damageRate=s/100;o.bombRate=b/100 end
function E.WaitForKilled(o)while alive(o)and o.hp>0 do E.wait(1)end end
function E.CheckKillType(o)return o.killed and 2 or 1 end
function E.ZakoFinalize(o)if o.killed then E.CallSound(E.sndVanish)end;E.Obj_Delete(o)end
function E.SetEnemyVisible(o,v)o.visible=E.truth(v)end
function E.SetEnemyDropItem(o,center,around)o.dropCenter=center;o.dropAround=around end
function E.DrawFairy(o,img,typ)o.art=img;o.fairy=typ end
function E.DrawOnmyou(o,col)o.art='onmyou';o.artColor=col end
function E.DrawHitodama2(o,col)o.art='soul';o.artColor=col end
function E.SetHitodama2Size(o,s,a)o.sx,o.sy,o.alpha=s,s,a end
E.GetEnemyImageID=function(o)return o end;E.GetEnemyImageIDEx=function(o)return E.arr(o)end
E.ObjRender_SetAlpha=function(o,a)o.alpha=a end
E.ObjRender_SetColor=function(o,r,g,b)o.color={r,g,b}end
E.ObjRender_SetScaleXYZ=function(o,x,y)o.sx,o.sy=x,y end
E.Obj_SetRenderPriorityI=function(o,n)o.priority=n end
E.Obj_SetVisible=function(o,v)o.renderVisible=E.truth(v)end
E.SetShotDisabled=function(o)
 o.collidable=false;o.bombProof=true;o.itemChange=false
 if R.onShotDisabled then R.onShotDisabled(o)end
end
E.ObjShot_SetIntersectionEnable=function(o,v)o.collidable=E.truth(v)end
E.ObjShot_SetAutoDelete=function(o,v)o.autoDelete=E.truth(v)end
function E.TCheckDispINOut(o,s)
 R.spawn(function()while alive(o)do if E.CheckDispIN(o,s)then E.Enemy_WaitForDispOUT(o,s,60);return end;E.wait(1)end end)
end
function E.Enemy_WaitForDispOUT(o,s,delay)
 R.spawn(function()E.wait(delay);while alive(o)and E.CheckDispIN(o,s)do E.wait(1)end;E.Obj_Delete(o)end)
end
function E.ZakoEnterEffect_Onmyou(o,n)
 R.spawn(function()o.visible=false;for t=1,n do if not alive(o)then return end;o.sx,o.sy=0.2+0.8*E.sin(t/n*90),0.2+0.8*E.sin(t/n*90);o.alpha=math.min(255,E.sin(t/n*90)*765);E.wait(1)end;o.visible=true end)
end
local function schedule(o,n,fn)
 R.spawn(function()E.wait(n);if alive(o)then fn()end end)
end
E.NO_CHANGE=-99999999
local function polar(o,s,a,acc,turn,limit)
 o.motion=nil;o.vx=nil;o.vy=nil
 if s~=E.NO_CHANGE then o.speed=s end;if a~=E.NO_CHANGE then o.angle=a end
 o.accel,o.turn,o.limit=acc or 0,turn or 0,limit
end
function E.Enemy_SetPatternA2(o,n,s,a,acc,turn,limit)schedule(o,n,function()polar(o,s,a,acc,turn,limit)end)end
E.ObjMove_AddPatternA2=E.Enemy_SetPatternA2
function E.ObjMove_AddPatternA1(o,n,s,a)schedule(o,n,function()polar(o,s,a,0,0)end)end
function E.Enemy_SetPatternB2(o,n,vx,vy,ax,ay,mx,my)
 schedule(o,n,function()o.motion=nil;o.vx,o.vy,o.ax,o.ay,o.mx,o.my=vx,vy,ax,ay,mx,my end)
end
function E.Enemy_SetPatternB1(o,n,vx,vy)E.Enemy_SetPatternB2(o,n,vx,vy,0,0)end
function E.MoveToSlowdown(o,x,y,n)
 o.motion={x=o.x,y=o.y,tx=x,ty=y,n=n,t=0,slow=true};o.speed=0;o.accel=0;o.vx=nil
end
function E.MoveTo(o,x,y,n)
 o.motion={x=o.x,y=o.y,tx=x,ty=y,n=n,t=0};o.speed=0;o.accel=0;o.vx=nil
end
function E.CreateShotA1(x,y,s,a,id,delay)
 local o=object(x,y,'shot');o.speed,o.angle,o.id,o.delay=s,a,id,delay or 0
 o.radius=assert(R.art[id],'Unknown HSoB shot '..tostring(id)).radius
 R.counts.shots=R.counts.shots+1;if R.onShot then R.onShot(o)end;return o
end
function E.My_CreateShotA2(x,y,s,a,acc,limit,id,delay)
 local o=E.CreateShotA1(x,y,s,a,id,delay);o.accel,o.limit=acc,limit;return o
end
E.My_CreateShotA2Ex=E.My_CreateShotA2
local function beam(x,y,a,len,w,life,id,delay)
 local o=object(x,y,'beam');o.angle,o.beamAngle,o.length,o.width,o.life,o.id,o.delay=a,a,len,w,life,id,delay or 0
 R.counts.beams=R.counts.beams+1;if R.onBeam then R.onBeam(o)end;return o
end
E.My_CreateSimpleLaserA1=beam
function E.My_CreateStraightLaserA1(x,y,a,len,w,life,id,delay,thin)
 local o=beam(x,y,a,len,w,life+(delay or 0),id,delay);o.straight=true;return o
end
E.ObjLaser_GetLength=function(o)return o.length end;E.ObjLaser_SetLength=function(o,n)o.length=n end
E.ObjStLaser_GetAngle=function(o)return o.beamAngle end;E.ObjStLaser_SetAngle=function(o,a)o.beamAngle=a end
function E.DeleteShotAll()for _,o in ipairs(R.objects)do if o.kind~='enemy'then o.dead=true end end end
function E.SetAreaCommonData(_,k,v)R.common[k]=v end
function E.GetAreaCommonData(_,k,d)local v=R.common[k];if v==nil then return d else return v end end
function E.NextStageScene()
 R.scene=R.scene+1
 if R.scene==2 then
  -- BackgroundWorld05 SetWorld05b: normal warp_frame - 180.
  R.spawn(function()E.wait(math.floor(39.435*64)-180);R.common.STG5R_CHP5=1 end)
 end
end
function E.ResetPlayerInvincibility(n)if R.protect then R.protect(n)end end
function E.SetItemCollect(n)if R.collect then R.collect(n)end end
function E.SetItem(x,y,id)if R.onItem then R.onItem(x,y,id)end end
function E.WaitRoad_Time()error('Boss-only real-time hold must be removed by build')end
E.ChapterStart=function(_,n)R.chapter=n+1 end
E.DisplayStage=function()end
function E.CallSound(id)if R.onSound then R.onSound(id)end end
-- Source status-effect hooks have no counterpart in the AEX player.
E.SetEffectResist=function(o,v)o.effectResist=v end;E.SetTimeResist=function(o,v)o.timeResist=v end
E.MinX,E.MaxX,E.MinY,E.MaxY,E.CenX,E.CenY=0,384,0,448,192,224
E.GetClipWidth,E.GetClipHeight,E.GetStgFrameWidth,E.GetStgFrameHeight=384,448,384,448
E.Difficult,E.D_EASY,E.D_NORM,E.STAGE_ID,E.FLG_TEST_CHP=1,0,1,5,0
E.CAREA_STAGE,E.CHAPTER_ROAD,E.TYPE_ALL,E.TYPE_FADE,E.DELAY_DEFAULT=1,1,1,1,0
E.EFF_BLUE,E.EFF_YELLOW=5,2;E.priorityZako,E.priorityZakoBack=40,30
E.imgZakoFairyYellow,E.imgZakoFairyEgypt='fairy','egypt'
E.MY_ITEM_TIME_1,E.MY_ITEM_TIME_3,E.MY_ITEM_TIME_5,E.MY_ITEM_SPELL=1,3,5,100
E.SHOT_COLOR=E.arr(0,6,3,1,5,2,4,7)
function R.clear()
 for _,o in ipairs(R.objects)do o.dead=true end
 R.threads={}
end
function R.award(section)
 if R.rewarded[section]then return end
 R.rewarded[section]=true;R.events[#R.events+1]={kind='reward',section=section,tick=R.tick}
 if R.onReward then R.onReward(section)end
end
function R.beginSection(n)
 R.section=n;R.events[#R.events+1]={kind='start',section=n,tick=R.tick}
 R.spawn(function()
  local ranges={{1,3},{4,6},{7,8}}
  for c=ranges[n][1],ranges[n][2]do R.chapters[c]()end
  -- Let source wave tasks finish before cancelling their section.
  R.scheduleDone=true
 end)
end
function R.start(seed,from)
 R.clear();R.tick=0;R.section=0;R.objects={};R.events={};R.rewarded={};R.counts={enemies=0,shots=0,beams=0}
 R.seed=seed or 20261030;R.scene=0;R.finished=false;R.scheduleDone=false;R.nextAt=nil;R.damage=0
 if R.resetPhase then R.resetPhase()end
 R.common={STG5R_CHP3=0,STG5R_CHP4=-1,STG5R_CHP4_2=-1,STG5R_CHP5=0}
 from=math.max(1,math.min(3,math.floor(tonumber(from)or 1)))
 if from>=2 then R.scene=1;R.common.STG5R_CHP3=1 end
 if from==3 then R.scene=2;R.common.STG5R_CHP5=1 end
 if R.resetSound then R.resetSound()end
 R.beginSection(from)
end
local function limited(v,a,m)
 if not a or a==0 then return v end
 local r=v+a;if m then r=a>0 and math.min(r,m)or math.max(r,m)end;return r
end
function R.step(px,py)
 if R.finished then return end
 R.tick=R.tick+1;R.px,R.py=px or R.px,py or R.py
 local count=#R.threads
 for i=1,count do local t=R.threads[i];if not t.dead and R.tick>=t.wake then R.resume(t)end end
 local threads={};for _,t in ipairs(R.threads)do if not t.dead then threads[#threads+1]=t end end;R.threads=threads
 local objects={}
 for _,o in ipairs(R.objects)do if not o.dead then
  if o.hp and o.hp<=0 then o.killed=true;o.dead=true end
  if not o.dead then
   o.age=o.age+1
   if o.motion then
    local m=o.motion;m.t=m.t+1;local t=math.min(m.n,m.t);local u
    if m.slow then u=t*(2*m.n-t+1)/(m.n*(m.n+1))
    else
     local a=math.floor(m.n/3);local b=m.n-2*a;local total=b+a+1
     if t<=a then u=t*(t+1)/(2*a*total)
     elseif t<=a+b then u=((a+1)/2+t-a)/total
     else local k=t-a-b;u=((a+1)/2+b+k*(2*a-k+1)/(2*a))/total end
    end
    o.x,o.y=m.x+(m.tx-m.x)*u,m.y+(m.ty-m.y)*u
    if t>=m.n then o.motion=nil end
   elseif o.vx then
    o.vx,o.vy=limited(o.vx,o.ax,o.mx),limited(o.vy,o.ay,o.my);o.x,o.y=o.x+o.vx,o.y+o.vy
   else
    o.speed=limited(o.speed,o.accel,o.limit);o.angle=o.angle+(o.turn or 0)
    o.x,o.y=o.x+o.speed*E.cos(o.angle),o.y+o.speed*E.sin(o.angle)
   end
   if o.kind~='enemy' and ((o.life and o.age>=o.life)or(o.autoDelete~=false and not E.CheckDispIN(o,1024)))then o.dead=true end
   objects[#objects+1]=o
  end
 end end
 R.objects=objects
 if R.nextAt then
  if R.tick>=R.nextAt then R.nextAt=nil;R.scheduleDone=false;R.beginSection(R.section+1)end
 elseif R.scheduleDone then
  local active=false
  for _,o in ipairs(R.objects)do if o.kind=='enemy'and not o.dead then active=true;break end end
  if not active and #R.threads==0 then
   R.award(R.section);R.clear()
   if R.section<3 then R.nextAt=R.tick+120 else R.finished=true end
  end
 end
end
