local R=Le03
local owned={}; local finished=false
local function own(o) owned[o]=true; return o end
local function clean()
  R.cancelBullets(); for o in pairs(owned) do if IsValid(o) then Del(o) end end
  owned={}
end

for _,typ in ipairs({3,8}) do
  local k='le03.srcb'..typ;LoadTexture(k,(Le03AssetRoot or 'art/')..'le03/b00'..typ..'.png')
  local w,h=GetTextureSize(k);for col=0,7 do LoadImage('le03.b'..typ..'.'..col,k,col*w/8,0,w/8,h)end
end
Include((Le03ModuleRoot or '')..'enemy-art.lua')
Include((Le03ModuleRoot or '')..'enemy-health.lua')
Le03BulletStyle.load()
LoadTexture('le03.pixel',(Le03AssetRoot or 'art/')..'pixel.png');LoadImage('le03.line','le03.pixel',0,0,1,1)

local Shot=Class(bullet)
local Beam
function Shot:init(b)
  bullet.init(self,grain_b,1,false,true); bullet.skip_fade_in(self)
  self.data=b; self.bound=false; self.x=b.x-192; self.y=224-b.y; own(self)
end
function Shot:frame()
  local b=self.data
  if not b.active then Del(self);return end
  self.x=b.x-192; self.y=224-b.y;self.img=Le03BulletStyle.image(b)
  self.hscale,self.vscale=b.scale or 1,b.scale or 1; self.a,self.b=({[0]=2,[1]=3,[3]=3,[5]=2,[6]=2,[8]=2.5,[10]=12})[b.typ] or 3,self.a
  self.b=self.a; self.colli=(b.birth or 0)<=0; self.rect=true; self.heading=-(b.angle or 0)*180/math.pi-90
end
function Shot:render()
  local b=self.data;local body,pulse,fade=Le03BulletStyle.birth(b.age)
  local r,g,bl=255,255,255;if b.style then r,g,bl=Le03BulletStyle.bodyRGB(b)end
  SetImageState(self.img,b.typ==10 and 'mul+add' or '',Color(math.floor((b.alpha or 255)*body),r,g,bl))
  if b.rainbow then
   local one,two,mix=Le03BulletStyle.rainbowImages(b)
   SetImageState(one,'',Color(math.floor((b.alpha or 255)*body),255,255,255))
   Render(one,self.x,self.y,self.heading,self.hscale,self.vscale)
   SetImageState(two,'',Color(math.floor((b.alpha or 255)*body*mix),255,255,255))
   Render(two,self.x,self.y,self.heading,self.hscale,self.vscale)
  else Render(self.img,self.x,self.y,self.heading,self.hscale,self.vscale)end
  if fade>0 then
   local pr,pg,pb=Le03BulletStyle.rgb(b)
   SetImageState('le03.th.b.birth','mul+add',Color(math.floor(255*fade),pr,pg,pb))
   Render('le03.th.b.birth',self.x,self.y,0,pulse,pulse)
  end
end
function Shot:del() self.data.active=false;owned[self]=nil;bullet.del(self) end
function Shot:kill() self.data.active=false;owned[self]=nil;bullet.kill(self) end
local soundTick=-1
local function shotSound(b)
 -- One sound per emission frame, so a fan never stacks dozens of identical sounds.
 if b.age<=1 and soundTick~=R.tick then
  soundTick=R.tick;PlaySound('tan00',0.3,math.max(-1,math.min(1,(b.x-192)/192)))
 end
end
R.onShot=function(b)
  if b._host then return end;b._host=true;shotSound(b)
  if b.laser then New(Beam,b) else New(Shot,b) end
end

Beam=Class(laser)
function Beam:init(b)
  laser.init(self,4,b.x-192,224-b.y,-(b.angle or 0)*180/math.pi,0,b.length or 128,0,b.width or 8,0,0)
  laser.ChangeImage(self,3) -- Pointed native texture; render its caps, not only its one-pixel middle.
  self.alpha=1;self.w=b.width or 8 -- THlib initializes beams invisible until enabled.
  self.data=b;self.bound=false;own(self)
end
function Beam:frame()
  local b=self.data;if not b.active then Del(self);return end
  self.x=(b.renderX or b.x)-192;self.y=224-(b.renderY or b.y);self.l2=b.length or 128;self.w=b.width or 8;self.rot=-(b.angle or 0)*180/math.pi;laser.frame(self)
end
function Beam:del()self.data.active=false;owned[self]=nil end
function Beam:render()
  -- Presentation geometry only; keep the existing width/collision profile.
  local l1,l2,l3=self.l1,self.l2,self.l3
  local total=l1+l2+l3;local center=math.min(1,total)
  self.l1=(total-center)/2;self.l2=center;self.l3=self.l1
  laser.render(self)
  self.l1,self.l2,self.l3=l1,l2,l3
end
function Beam:kill()self.data.active=false;owned[self]=nil end
R.onLaser=function(b) if not b._host then b._host=true;shotSound(b);New(Beam,b) end end

local EnemyDamage=Class(enemy)
local E=Class(EnemyDamage)
function E:init(e)
  enemy.init(self,1,e.hp or 1,false,false,false)
  self.death_ef=self.death_ef or 1
  self.protect=e.survival or false
  self.x,self.y=e.x-192,224-e.y
  self.data=e;self.hostHp=self.hp;self.bound=false;self.a,self.b=5,5;self.colli=true;own(self)
end
function E:frame()
  local e=self.data
  if not e.active then
   if e.defeated then Kill(self)else Del(self)end
   owned[self]=nil;return
  end
  self.x=e.x-192;self.y=224-e.y
  -- enemybase:init leaves engine collision off until its frame sync. This
  -- source-driven host replaces that frame, so perform the same sync here.
  SetAttr(self,'colli',BoxCheck(self,lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt) and self._colli)
  if self.hp < self.hostHp then R.damageEnemy(e,self.hostHp-self.hp) end
  self.hostHp=e.hp or self.hp;self.hp=self.hostHp;self.rot=0
end
function E:kill()
  if self.data.survival and self.data.active then
   PreserveObject(self);self.hp=self.data.hp;return
  end
  self.data.active=false;owned[self]=nil
  enemy.kill(self) -- Native bubble animation owns the enep00 sound; do not play it twice.
end
function E:render()
  local alpha,scale=Le03EnemyArt.entry(self.data)
  local img=Le03EnemyArt.image(self.data);SetImageState(img,'',Color(alpha,255,255,255));Render(img,self.x,self.y,Le03EnemyArt.rotation(self.data),scale,scale)
  for _,ring in ipairs(Le03EnemyArt.rings(self.data))do
   SetImageState(ring.img,'mul+add',Color(ring.alpha,255,255,255))
   Render(ring.img,self.x,self.y,ring.rotation,ring.scale,ring.scale)
  end
end
function EnemyDamage:take_damage(d)
  d=d*((Y3PlayerConfig and Y3PlayerConfig.road_damage_scale)or 1)
  local before=self.hp
  enemy.take_damage(self,d)
  local lost=before-self.hp
  if self.data and lost>0 then R.damageEnemy(self.data,lost);self.hostHp=self.hp end
end
R.onEnemy=function(e) if not e._host then e._host=true;New(E,e) end end
R.onReward=function(kind,e)
 New(kind=='life' and item_extend or item_bomb,e.x-192,224-e.y)
end


Le03Host={clean=clean}
function Le03Host.run(startFrame,options)
 options=options or {}
 clean()
 R.start(options.seed or 20261029)
 startFrame=math.max(0,math.floor(startFrame or 0))
 -- A practice checkpoint starts with an empty field; prior waves stay skipped.
 local checkpoint=R.spawnTick(startFrame)
 for i,e in ipairs(R.enemies)do if e.spawnTick<checkpoint then R.spawned[i]=true end end
 R.tick=checkpoint;R.nextFill=checkpoint+480
 print('STAGE3 ROAD START frame='..R.tick)
 while not R.finished do
  if options.invincible and IsValid(player)then player.protect=1000 end
  local px,py=192,400
  if IsValid(player)then px,py=player.x+192,224-player.y end
  R.step(px,py);task.Wait(1)
 end
 print('STAGE3 ROAD END ticks='..R.tick..' enemies='..R.counts.enemies)
 clean()
 -- Let pending deletions complete before creating the Boss.
 task.Wait(1)
 assert(next(owned)==nil,'Road owned objects survived transition')
 print('STAGE3 ROAD CLEAN')
end

