-- Private TH13 actor bridge. No changes to the shared engine or other mods.
local R=SeigaRuntime
local function zero()return setmetatable({},{__index=function()return 0 end})end
function R.actorX(id)return assert(R.actors[id],'missing source actor').x end
function R.actorY(id)return assert(R.actors[id],'missing source actor').y end
function R.switch(a,name)
 a.threads={};a.pending=name;a.interrupt=nil;a.scriptStart=R.tick
 a.down=false;a.poseStart=R.tick
end
local command=R.command
function R.command(a,e,k,v)
 R.coverage[k]=true
 if k=='lifeSet'then
  if a~=R.boss then a.hp=v[1];a.maxhp=v[1];a.hpRevision=(a.hpRevision or 0)+1 end
 elseif k=='setInterrupt'then
  if a~=R.boss then a.interrupt={hp=v[2],frames=v[3],entry=v[4],start=R.tick}end
 elseif k=='enmCall'then R.switch(assert(R.actors[v[1]],'missing enmCall target'),v[2])
 elseif k=='clearMinors'then for _,o in ipairs(R.actors)do if o~=R.boss and o~=R.yoshika then o.dead=true end end
 elseif k=='timerReset'then a.scriptStart=R.tick
 elseif k=='moveReset'then a.positionTween=nil;a.velocityTween=nil;a.angleTween=nil;a.speedTween=nil;a.orbit=nil;a.speed=0
 elseif k=='moveAddTime'then command(a,e,'movePosTime',{v[1],v[2],a.x+v[3],a.y+v[4]})
 elseif k=='movePosTime'and v[1]==0 and v[3]==0 and v[4]==0 then
  -- Native duration0/position0 sentinel cancels interpolation in transitions.
  a.positionTween=nil
 elseif k=='flagSet'or k=='flagClear'then
  local flags=a.flags or 0
  if k=='flagSet'then a.flags=flags+v[1]-R.bitAnd(flags,v[1])else a.flags=flags-R.bitAnd(flags,v[1])end
 elseif k=='setInvuln'then a.invuln=v[1];if a==R.boss then R.invuln=v[1]end
 elseif k=='anm316'then a.down=true;a.poseStart=R.tick
 elseif k=='anmSetMain'then a.down=false;a.poseStart=R.tick
 elseif k=='anmSetSprite'then a.anm=a.anm or{};a.anm[v[1]]=v[2]
 elseif k=='anmSelect'then a.anmBank=v[1]
 elseif k=='laserTiming'then a.patterns[v[1]].laser.history=v[2]
 elseif k=='laserCuOn'then
  local p=a.patterns[v[1]];p.laser.curved=true;p.laser.length=0;p.aim=1
  R.fire(a,p)
 elseif k=='laserNew'then a.patterns[v[1]].laser={length=0,width=v[5],history=40,curved=true}
 elseif k=='laserCancel'then return -- TH13 cancels actor laser templates; live curves persist
 elseif k=='funcSet'or k=='spec3'or k=='spell'or k=='dropMain'or k=='anm334'then return
 else return command(a,e,k,v)end
end
local start=R.start
function R.start(spec,seed)
 start(spec,seed);R.gi=zero();R.shared=zero();R.gi[1]=1
 R.boss.id=1;R.boss.name='Seiga';R.boss.hurtW=48;R.boss.hurtH=48;R.boss.hp=spec.hp
 R.yoshika=R.newActor('th13',spec.yx,spec.yy);local a=R.yoshika
 a.id=2;a.name='Yoshika';a.hp=12000;a.maxhp=12000;a.hurtW=48;a.hurtH=48;a.hitW=48;a.hitH=48
 a.flags=0;a.scriptStart=0;R.gi[0]=2;R.spawn(a,spec.yentry,{},-2)
 R.onActor(a)
end
local newActor=R.newActor
function R.newActor(...)
 local a=newActor(...);a.id=#R.actors;a.angle=0;return a
end
local step=R.step
function R.step(px,py,hp)
 for _,a in ipairs(R.actors)do
  if not a.dead then
   if a.invuln then a.invuln=math.max(0,a.invuln-1)end
   if a.pending then local name=a.pending;a.pending=nil;R.spawn(a,name,{},-2)end
   local it=a.interrupt
   if it and(a.hp<=it.hp or R.tick-it.start>=it.frames)then
    R.switch(a,it.entry);local name=a.pending;a.pending=nil;R.spawn(a,name,{},-2)
   end
  end
 end
 step(px,py,hp)
 -- Non-boss balls leave naturally, retaining their full acceleration period.
 for _,a in ipairs(R.actors)do
  if a~=R.boss and a~=R.yoshika and(a.x< -256 or a.x>256 or a.y< -64 or a.y>512)then a.dead=true end
 end
end
local projectile=R.projectileStep
function R.projectileStep(b)
 if b.dead then return end
 local curve=b.laser and b.laser.curved
 if curve then
  b.points=b.points or{};b.points[#b.points+1]={x=b.x,y=b.y}
  if #b.points>b.laser.history then table.remove(b.points,1)end
 end
 projectile(b)
 if curve then
  if b.offscreenRemoval then
   for _,p in ipairs(b.points)do if p.x>=-208 and p.x<=208 and p.y>=-32 and p.y<=480 then b.dead=false;b.offscreenRemoval=false;break end end
  end
  b.collidable=true
 end
end
