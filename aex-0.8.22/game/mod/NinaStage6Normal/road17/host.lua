TH11S6Host={owned={},enemies={},spawns=0,kills=0,culls=0,damage=0,drops=0,finished=false}
local H=TH11S6Host;local R=TH11S6Runtime;local P=TH11S6Presentation
function H.finalFrogLife(x,y)
 if H.frogLife then return end
 H.frogLife=true;New(item_extend,x,y)
end
local pi=math.pi
local function own(o)H.owned[o]=true end
local NativeMinor=item_faith_minor
local Minor=Class(NativeMinor)
function Minor:init(x,y)NativeMinor.init(self,x,y);self.img='item2';self.imgup='item_up2';own(self)end
function Minor:frame()
 if not self.target or not IsValid(self.target)then
  if player and IsValid(player)then self.target=player else Del(self);return end
 end
 NativeMinor.frame(self)
end
function Minor:kill()H.owned[self]=nil end
function Minor:del()H.owned[self]=nil end
Minor.collect=item_point.collect
-- Base bullet.kill (also used by the imported Boss) resolves this class at
-- runtime. Keep its existing flight/auto-collection, replace green faith by blue.
item_faith_minor=Minor
local Cancel=Class(object)
function Cancel:init(b)
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET_EF;self.colli=false;self.bound=false
 self.x,self.y=b.x,224-b.y;self.shot=b;self.heading=-b.angle*180/pi+90;self.rot=0;own(self)
end
function Cancel:frame()local _,_,_,n=P.cancel(self.shot,self.timer);if self.timer>=n then Del(self)end end
function Cancel:render()
 local img,scale,alpha=P.cancel(self.shot,self.timer)
 SetImageState(img,'mul+add',Color(alpha,255,255,255));Render(img,self.x,self.y,self.heading,scale,scale)
end
function Cancel:del()H.owned[self]=nil end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,ball_small,COLOR_RED,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;self.rect=true;self.colli=false
 self.x,self.y=b.x,224-b.y;own(self)
end
function Shot:frame()
 local b=self.data
 if b.dead then Del(self);return end
 self.x,self.y=b.x,224-b.y;self.colli=b.collidable==true
 local a=assert(TH11S6BulletArt[b.typ..':'..b.color]);self.img=TH11S6Sprites.bullet[a.body]
 self.a,self.b=a.width/2,a.width/2;self.heading=-b.angle*180/pi+90;self.rot=0
 if b.typ==4 then self.heading=self.heading+180 end -- chain art's head was reversed; drawing only
end
function Shot:render()
 local img,scale,alpha,blend=P.bullet(self.data)
 SetImageState(img,blend,Color(alpha,255,255,255));Render(img,self.x,self.y,self.heading,scale,scale)
end
function Shot:del()
 local b=self.data;b.dead=true;H.owned[self]=nil
 if not H.cleaning and not b.offscreenRemoval then New(Cancel,b)end
end
function Shot:kill()
 if self.data.dead then return end
 self.data.dead=true;H.owned[self]=nil
 if not H.cleaning then New(Cancel,self.data);New(Minor,self.x,self.y)end
end
-- All source enemy drops go through one local item subclass. A target is set
-- before the inherited attraction update, including the timer>=24 branch.
local Drop=Class(item)
function Drop:init(x,y,kind)
 self.sourceKind=kind;item.init(self,x,y,2,2.6,90)
 self.target=player and IsValid(player) and player or nil;own(self);H.drops=H.drops+1
end
function Drop:frame()
 if not self.target or not IsValid(self.target) then
  if player and IsValid(player)then self.target=player else self.attract=0;self.target=nil end
 end
 item.frame(self)
end
function Drop:collect()item_point.collect(self)end
function Drop:del()H.owned[self]=nil end
function Drop:kill()H.owned[self]=nil end
local Contact=Class(object)
function Contact:init(owner)
 self.owner=owner;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false;self.rect=true;self.rot=0
 self.x,self.y=owner.x,owner.y;own(self)
end
function Contact:frame()
 local o=self.owner
 if not IsValid(o)or o.data.dead then Del(self);return end
 local a=o.data;self.x,self.y=o.x,o.y;self.a,self.b=(a.hitW or 16)/2,(a.hitH or 16)/2
 self.colli=R.bitAnd(a.flags or 0,2)==0
end
function Contact:del()H.owned[self]=nil end
Contact.kill=Contact.del
local Trail=Class(object)
local visualSeed=1106
local function visualRandom(a,b)visualSeed=visualSeed*16807%2147483647;return a+(b-a)*visualSeed/2147483647 end
function Trail:init(a)
 local sid=a.anm and a.anm[0]or 98;local base=({[94]=155,[96]=163,[98]=171,[100]=179})[sid]or 171
 if a.name=='RPhantom01' then base=179 end
 self.img=TH11S6Sprites.enemy[base+math.floor(visualRandom(0,8))]
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY-.01;self.colli=false;self.bound=false
 self.ox,self.oy=a.x,224-a.y;self.sx,self.sy=visualRandom(-8,8),visualRandom(-4,4)
 self.tx,self.ty=visualRandom(-8,8),visualRandom(16,32);own(self)
end
function Trail:frame()if self.timer>=10 then Del(self)end end
function Trail:render()
 local u=math.min(1,self.timer/10);local scale=.5*(1-u*u)
 SetImageState(self.img,'',Color(255,255,255,255));Render(self.img,self.ox+self.sx+(self.tx-self.sx)*u,self.oy+self.sy+(self.ty-self.sy)*u,0,scale,scale)
end
function Trail:del()H.owned[self]=nil end
local DamageBase=Class(enemy)
local Enemy=Class(DamageBase)
function Enemy:init(a)
 enemybase.init(self,a.hp,false);self.data=a;self.bound=false;self.vx,self.vy=0,0;self.protect=true
 self.x,self.y=a.x,224-a.y;self.a,self.b=12,12;self.rect=true;self.group=GROUP_NONTJT;self.contact=New(Contact,self);self.death_ef=({B=1,R=2,G=3,Y=4})[a.name:sub(1,1)]or 1
 if a.name=='RPhantom01'then self.death_ef=4 end
 H.enemies[self]=true;own(self);H.spawns=H.spawns+1
end
function Enemy:frame()
 local a=self.data
 if a.dead then Del(self);return end
 self.x,self.y=a.x,224-a.y;self.protect=a.age<20 or (a.invuln or 0)>0 or R.bitAnd(a.flags or 0,9)~=0
 self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2;self.colli=R.bitAnd(a.flags or 0,1)==0
 if self.hp<=0 then Kill(self);return end
 self.image,self.rotation,self.flip=P.enemy(a)
 self.visualScale=1
 if not a.name:find('Crow')then
  local t=a.age-(a.poseStart or 0)
  if t<6 then self.visualScale=2*(1-(1-t/6)^2)elseif t<12 then self.visualScale=2-((t-6)/6)^2 end
  if t>=12 then New(Trail,a)end
 end
 a.previousX=a.x
 enemybase.frame(self)
end
function Enemy:render()
 local a=self.data;local img,rot,scale,alpha=P.ring(a)
 if img then SetImageState(img,'mul+add',Color(alpha,255,255,255));Render(img,self.x,self.y,rot,scale,scale)end
 if self.image then SetImageState(self.image,'',Color(255,255,255,255));Render(self.image,self.x,self.y,self.rotation,self.flip*(self.visualScale or 1),self.visualScale or 1)end
end
function Enemy:take_damage(dmg)
 if self.data.age>=20 and not self.protect and not self.data.dead then self.hp=self.hp-dmg;H.damage=H.damage+dmg end
end
-- THlib Damage dispatches through class.base, not the instance method.
DamageBase.take_damage=Enemy.take_damage
function Enemy:kill()
 local a=self.data
 if a.dead then return end
 a.dead=true;a.defeated=true;H.kills=H.kills+1;H.enemies[self]=nil;H.owned[self]=nil
 if a.name=='RPhantom01'and a.f[0]<0 then H.finalFrogLife(self.x,self.y)end
 -- Animated native enemy_death_ef owns the one-shot enep00 sound.
 enemy.kill(self)
 local function drop(kind,index)
  local area=a.dropArea or {0,0};local n=index or 0
  -- Stable scatter is cosmetic and does not consume the source attack RNG.
  local angle=n*2.3999632297
  New(Drop,self.x+math.cos(angle)*area[1]*.5,self.y+math.sin(angle)*area[2]*.5,kind)
 end
 if (a.dropMain or 0)>0 then drop(a.dropMain)end
 for kind,n in pairs(a.dropExtra or {})do for i=1,n do drop(kind,i)end end
end
function Enemy:del()
 H.owned[self]=nil;H.enemies[self]=nil
 if self.data.offscreenRemoval then H.culls=H.culls+1 end
 self.data.dead=true;enemybase.del(self)
end
R.onActor=function(a)New(Enemy,a)end
R.onShot=function(b)
 TH11S6Sound.play('tan00',.22,b.x);New(Shot,b)
end
function H.clean()
 H.cleaning=true
 for o in pairs(H.owned)do if IsValid(o)then Del(o)end end
 H.owned={};H.enemies={};H.cleaning=false
 for _,a in ipairs(R.actors or {})do a.dead=true end
 for _,b in ipairs(R.hazards or {})do b.dead=true end
 R.actors={};R.hazards={}
end
H.Shot,H.Enemy,H.Drop,H.Cancel,H.Minor=Shot,Enemy,Drop,Cancel,Minor
