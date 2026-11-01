TH10S6Host={owned={},enemies={},spawns=0,kills=0,culls=0,damage=0,drops=0,finished=false}
local H=TH10S6Host;local R=TH10S6Runtime;local P=TH10S6Presentation
local pi=math.pi
local function own(o)H.owned[o]=true end
local Minor=Class(item_faith_minor)
function Minor:init(x,y)item_faith_minor.init(self,x,y);own(self)end
function Minor:frame()
 if not self.target or not IsValid(self.target)then
  if player and IsValid(player)then self.target=player else Del(self);return end
 end
 item_faith_minor.frame(self)
end
function Minor:kill()H.owned[self]=nil end
function Minor:del()H.owned[self]=nil end
local Cancel=Class(object)
function Cancel:init(b)
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET_EF;self.colli=false;self.bound=false
 self.x,self.y=b.x,224-b.y;self.shot=b;self.rot=-b.angle*180/pi+90;own(self)
end
function Cancel:frame()local _,_,_,n=P.cancel(self.shot,self.timer);if self.timer>=n then Del(self)end end
function Cancel:render()
 local img,scale,alpha=P.cancel(self.shot,self.timer)
 SetImageState(img,'mul+add',Color(alpha,255,255,255));Render(img,self.x,self.y,self.rot,scale,scale)
end
function Cancel:del()H.owned[self]=nil end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,ball_small,COLOR_RED,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;self.rect=false;self.colli=false
 self.x,self.y=b.x,224-b.y;own(self)
end
function Shot:frame()
 local b=self.data
 if b.dead then Del(self);return end
 self.x,self.y=b.x,224-b.y;self.colli=b.collidable==true
 local a=assert(TH10S6BulletArt[b.typ..':'..b.color]);self.img=TH10S6Sprites.bullet[a.body]
 self.a,self.b=a.width/2,a.width/2;self.rot=-b.angle*180/pi+90
end
function Shot:render()
 local img,scale,alpha,blend=P.bullet(self.data)
 SetImageState(img,blend,Color(alpha,255,255,255));Render(img,self.x,self.y,self.rot,scale,scale)
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
 self.sourceKind=kind;item.init(self,x,y,({[1]=1,[2]=2,[3]=5,[4]=6})[kind] or 5,2.6,90)
 self.target=player and IsValid(player) and player or nil;own(self);H.drops=H.drops+1
end
function Drop:frame()
 if not self.target or not IsValid(self.target) then
  if player and IsValid(player)then self.target=player else self.attract=0;self.target=nil end
 end
 item.frame(self)
end
function Drop:collect()
 if self.sourceKind==1 then item_power.collect(self)
 elseif self.sourceKind==2 then item_point.collect(self)
 elseif self.sourceKind==4 then item_power_large.collect(self)
 else item_faith.collect(self)end
end
function Drop:del()H.owned[self]=nil end
function Drop:kill()H.owned[self]=nil end
local DamageBase=Class(enemy)
local Enemy=Class(DamageBase)
function Enemy:init(a)
 enemybase.init(self,a.hp,false);self.data=a;self.bound=false;self.vx,self.vy=0,0
 self.x,self.y=a.x,224-a.y;self.a,self.b=12,12;self.death_ef=({B=1,R=2,G=3,Y=4})[a.name:sub(1,1)]or 1
 H.enemies[self]=true;own(self);H.spawns=H.spawns+1
end
function Enemy:frame()
 local a=self.data
 if a.dead then Del(self);return end
 self.x,self.y=a.x,224-a.y;self.protect=(a.invuln or 0)>0
 self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2
 if self.hp<=0 then Kill(self);return end
 self.image,self.rotation,self.flip=P.enemy(a)
 a.previousX=a.x
 enemybase.frame(self)
end
function Enemy:render()
 local a=self.data;local img,rot,scale,alpha=P.ring(a)
 if img then SetImageState(img,'mul+add',Color(alpha,255,255,255));Render(img,self.x,self.y,rot,scale,scale)end
 if self.image then SetImageState(self.image,'',Color(255,255,255,255));Render(self.image,self.x,self.y,self.rotation,self.flip,1)end
end
function Enemy:take_damage(dmg)
 if not self.protect and not self.data.dead then self.hp=self.hp-dmg;H.damage=H.damage+dmg end
end
-- THlib Damage dispatches through class.base, not the instance method.
DamageBase.take_damage=Enemy.take_damage
function Enemy:kill()
 local a=self.data
 if a.dead then return end
 a.dead=true;a.defeated=true;H.kills=H.kills+1;H.enemies[self]=nil;H.owned[self]=nil
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
 TH10S6Sound.play('tan00',.22,b.x);New(Shot,b)
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
