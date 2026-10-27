-- Stage-four route extensions. Source scheduler is private to this stage.
local R=Th18Stage5Runtime
local oldCommand,oldValue,oldMotion,oldNew,oldStep=R.command,R.value,R.motion,R.newActor,R.step
local function zeros()return setmetatable({},{__index=function()return 0 end})end
function R.newActor(group,x,y)
 local a=oldNew(group,x,y);a.id=#R.actors;a.drops={main=0,extra={},timed={},area={32,32},start=R.tick};a.floatTweens={}
 a.flags=0;return a
end
function R.value(a,k)
 if k=='LAST_ENM_ID' then return R.lastId or 0 elseif k=='ABS_ANGLE' then return a.angle or 0
 elseif k=='TIMEOUT' then return a.timeout and 1 or 0 elseif k=='DIFF' then return 1
 elseif k:match('^GI%d') then return R.globals[k] or 0 end
 return oldValue(a,k)
end
function R.alive(id)local a=R.byId[id];return a and not a.dead and 1 or 0 end
function R.drop(a)
 local d=a.drops
 if d.main and d.main>0 and d.main<20 then if R.onDrop then R.onDrop(d.main,a.x,a.y,-math.pi/2,2.2,a)end end
 local angle=R.random()*math.pi
 for typ=1,19 do
  local n=d.extra[typ] or 0;local elapsed=R.tick-d.start
  if d.window and elapsed<d.window then local bonus=d.timed[typ] or 0;n=n+bonus-math.floor(bonus*elapsed/d.window)end
  for i=1,n do
   local radius=.5+.5*R.random()
   if R.onDrop then R.onDrop(typ,a.x+math.cos(angle)*d.area[1]*radius,a.y+math.sin(angle)*d.area[2]*radius,-math.pi/2,2.2,a)end
   angle=R.rad(angle+math.pi/2+R.random()*math.pi*.25)
  end
 end
 -- Native 42d0fd clears main only; extra slots can be flushed again explicitly.
 d.main=0
end
function R.die(a)
 if a.dead then return end
 if a.midboss and not a.ending then R.interrupt(a,false);return end
 if not a.controller then R.drop(a)end
 a.dead=true;if R.onDeath and not a.controller then R.onDeath(a)end
end
function R.interrupt(a,timeout)
 a.timeout=timeout;a.ending=true;a.flags=R.bitAnd(a.flags,0xfffffffc)+3
 a.threads={};a.floatTweens={};a.interrupt=nil
 R.spawn(a,timeout and 'MBossEscape' or 'MBossDead',{},-2)
 print('TH18S5 MIDBOSS '..(timeout and 'TIMEOUT' or 'DEFEAT')..' tick='..R.tick)
end
function R.cancel(a,radius,items)
 for _,b in ipairs(R.hazards)do
  if not b.dead and (b.x-a.x)^2+(b.y-a.y)^2<radius^2 then
   b.dead=true
   if items and b.x> -224 and b.x<224 and b.y> -32 and b.y<480 and R.onDrop then R.onDrop(9,b.x,b.y,-math.pi/2+R.random()*.1745329,2.2,a)end
   if R.onCancel then R.onCancel(b)end
  end
 end
end
function R.command(a,e,k,v)
 if k=='debug22' or k=='setChapter' or k=='lifeMarker' or k=='playSound' or k=='spellEnd' or k=='unknown570' or k=='setScreenShake' then return
 elseif k=='anmSelect' then a.anm=v[1]
 elseif k=='anmSetMain' or k=='anmSetSprite' then if R.onAnimation then R.onAnimation(a,v[1],v[2],k=='anmSetMain')end
 elseif k=='anmPlay' then if R.onEffect then R.onEffect(a,v[1],v[2])end
 elseif k=='dropMain' then a.drops.main=v[1]
 elseif k=='dropExtra' then a.drops.extra[v[1]]=v[2]
 elseif k=='unknown573' then a.drops.timed[v[1]]=v[2]
 elseif k=='ins_574' then a.drops.window=v[1];a.drops.start=R.tick
 elseif k=='dropArea' then a.drops.area={v[1],v[2]}
 elseif k=='dropClear' then a.drops={main=0,extra={},timed={},area=a.drops.area,start=R.tick}
 elseif k=='dropItems' then R.drop(a)
 elseif k=='lifeSet' then a.hp=v[1]
 elseif k=='setInterrupt' then if v[2]>=0 then a.interrupt={hp=v[2],time=v[3],start=R.tick}end
 elseif k=='setTimeout' then a.timeoutRoutine=v[2]
 elseif k=='setBoss' then a.midboss=v[1]>=0;R.midboss=a.midboss and a or nil
 elseif k=='timerReset' then a.timerStart=R.tick
 elseif k=='bossWait' then while R.midboss and not R.midboss.dead do coroutine.yield(1)end
 elseif k=='enmCreate' or k=='enmCreateA' then
  if v[1]=='Ecl_EtBreak' or v[1]=='Ecl_EtBreak_ni' then
   R.cancelWaves[#R.cancelWaves+1]={x=a.x,y=a.y,radius=16,items=v[1]=='Ecl_EtBreak'};return
  end
  local child=R.newActor('th18',v[2]+(k=='enmCreate' and a.x or 0),v[3]+(k=='enmCreate' and a.y or 0))
  child.i,child.f=R.copy(a.i),R.copy(a.f);setmetatable(child.i,{__index=function()return 0 end});setmetatable(child.f,{__index=function()return 0 end})
  child.hp=v[4];child.name=v[1];child.drops.main=v[6] or 0;R.lastId=child.id;R.byId[child.id]=child
  R.spawn(child,v[1],{},-2);if R.onActor then R.onActor(child)end
  R.stats.actors=R.stats.actors+1
 elseif k=='enmKillAll' then
  for _,child in ipairs(R.actors)do if child~=a and not child.dead and not child.controller and not child.midboss and R.bitAnd(child.flags,32)==0 then R.die(child)end end
 elseif k=='etCancel' or k=='etClear' then R.cancel(a,v[1],k=='etCancel')
 elseif k=='movePos' then a.x,a.y=v[1],v[2]
 elseif k=='moveEllipseRel' then a.relOrbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],tilt=v[5],ratio=v[6]}
 elseif k=='setFloatTween' then
  local key=v[2];local store=key:sub(1,1)=='%' and e.f or e.i;local reg=key:sub(2)
  if reg:match('^F%d') then store=a.f;reg=tonumber(reg:sub(2)) end
  store[reg]=v[5];a.floatTweens[v[1]]={store=store,key=reg,start=R.tick,n=v[3],mode=v[4],from=v[5],to=v[6]}
 else return oldCommand(a,e,k,v)end
end
local function ease(t,m)
 if m==1 then return t*t elseif m==2 then return t^3 elseif m==4 then return 1-(1-t)^2 elseif m==9 then return t<.5 and 2*t*t or 1-2*(1-t)^2 end
 return t
end
function R.motion(a)
 local ox,oy=a.relX or 0,a.relY or 0;a.x,a.y=a.x-ox,a.y-oy
 oldMotion(a)
 if a.relOrbit then local o=a.relOrbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
  local x,y=math.cos(o.angle)*o.radius,math.sin(o.angle)*o.radius*o.ratio
  a.relX=x*math.cos(o.tilt)-y*math.sin(o.tilt);a.relY=x*math.sin(o.tilt)+y*math.cos(o.tilt)
  a.x,a.y=a.x+a.relX,a.y+a.relY
 end
 for _,t in pairs(a.floatTweens)do local u=ease(math.min(1,(R.tick-t.start)/t.n),t.mode);t.store[t.key]=t.from+(t.to-t.from)*u end
end
function R.startRoute(seed)
 R.actors={};R.hazards={};R.byId={};R.cancelWaves={};R.globals={};R.midboss=nil
 R.tick=0;R.instructions=0;R.coverage={};R.random=Suwako5Pool.rng(seed);R.hp=1;R.spec={group='th18',id='route'};R.invuln=0;R.photos=0
 R.playerX,R.playerY=0,400;R.stats={bullets=0,lasers=0,actors=0}
 R.controller=R.newActor('th18',0,0);R.controller.controller=true;R.boss=R.controller
end
function R.stepRoute(px,py)
 oldStep(px,py,1)
 for _,a in ipairs(R.actors)do
  if not a.dead and not a.controller then
   if a.interrupt and not a.ending then
    if a.hp<=a.interrupt.hp then R.interrupt(a,false)
    elseif R.tick-a.interrupt.start>=a.interrupt.time then R.interrupt(a,true)end
   elseif not a.midboss and a.hp<=0 then R.die(a)end
  end
 end
 for i=#R.cancelWaves,1,-1 do local w=R.cancelWaves[i];R.cancel(w,w.radius,w.items);w.radius=w.radius+10;if w.radius>=640 then table.remove(R.cancelWaves,i)end end
 R.stepHazards()
end
function R.run(name)
 R.spawn(R.controller,name,{},-2)
end
function R.idle()for _,t in ipairs(R.controller.threads)do if coroutine.status(t.co)~='dead' then return false end end;return true end

function R.cullActor(a,w,h)
 local insideX=a.x+w/2>=-192 and a.x-w/2<=192
 local insideY=a.y+h/2>=0 and a.y-h/2<=448
 if insideX and insideY then a.entered=true end
 if a.entered and ((not insideX and R.bitAnd(a.flags,4)==0)or(not insideY and R.bitAnd(a.flags,8)==0))then a.dead=true end
end
