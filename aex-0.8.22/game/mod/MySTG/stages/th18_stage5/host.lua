-- Owned TH18 route objects and inert original resource drops.
Th18Stage5Host={owned={},items={},counts={spawned={},collected={}}}
local H,R,A,D=Th18Stage5Host,Th18Stage5Runtime,Th18Stage5Animation,Th18Stage5Data
local function own(o)H.owned[o]=true;return o end
local function validPlayer()return player and IsValid(player)end
function H.cleanup()
 for o in pairs(H.owned)do if IsValid(o)then Del(o)end end
 H.owned={};H.items={};H.cancelCount=0;H.cancelSerial=0;R.clearHazards(false)
end
-- Deliberately empty gameplay hook. All source types remain distinct for the future TH18 system.
function H.onCollect(event)end
local Effect=Class(object)
function Effect:init(bank,id,x,y,n)
 self.animation=A.new(bank,id,R.random);self.x,self.y=x,224-y;self.left=n or 45;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET+1;self.bound=false;self.colli=false;own(self)
end
function Effect:frame()A.step(self.animation);self.left=self.left-1;if self.animation.dead or self.left<=0 then Del(self)end end
function Effect:render()A.render(self.animation,self.x,self.y)end
function Effect:del()H.owned[self]=nil end
local Item=Class(object)
function Item:init(typ,x,y,angle,speed,source)
 self.typ=typ;self.source=source and source.name;self.nativeX=math.max(-192,math.min(192,x));self.nativeY=y
 self.dropVX,self.dropVY=math.cos(angle)*speed,math.sin(angle)*speed;self.age=0;self.attractSpeed=5;self.point=typ>=9 and typ<=14
 if self.point then local n=H.cancelCount or 0;local i=H.cancelSerial or 0;self.intro=n>=1024 and(i%32+16)or n>=512 and(i%16+8)or n>=256 and(i%8+4)or i%4;H.cancelSerial=i+1;H.cancelCount=n+1 end
 self.x,self.y=self.nativeX,224-y;self.bound=false;self.colli=false;self.group=GROUP_GHOST;self.layer=LAYER_ITEM
 local t=assert(D.itemTypes[typ],'unsupported native item type '..typ)
 self.animation=A.new(typ>=16 and 'ability' or 'bullet',typ>=16 and 14 or t[1],R.random)
 if typ>=16 then self.card=t[1];self.animation.sprite=assert(D.cardSprites[self.card])end
 H.items[self]=true;H.counts.spawned[typ]=(H.counts.spawned[typ]or 0)+1;own(self)
 if typ==1 or typ==2 or typ>=16 then New(Effect,'bullet',101,self.nativeX,self.nativeY,20)end
end
function Item:frame()
 if self.intro and self.intro>=0 then self.intro=self.intro-1;return end
 self.age=self.age+1;A.step(self.animation)
 if validPlayer()then
  local px,py=player.x,224-player.y;local dx,dy=px-self.nativeX,py-self.nativeY;local dist=math.sqrt(dx*dx+dy*dy)
  if dist<30 then
   H.counts.collected[self.typ]=(H.counts.collected[self.typ]or 0)+1
   H.onCollect({type=self.typ,card=self.card,source=self.source,x=self.nativeX,y=self.nativeY,tick=R.tick})
   PlaySound('item00',.3,self.x/200);Del(self);return
  end
  -- Source player defaults: point-of-collection128, attraction70, speed5->12 by0.2.
  if self.point and self.dropVY>=0 then self.attracted=true end
  if py<=128 and not self.globalAttract then self.globalAttract=true;self.attracted=true;self.attractSpeed=5
  elseif not self.point and not self.attracted and dist<70 then self.attracted=true;self.attractSpeed=5/3 end
  if self.attracted then
   local speed=math.min(self.attractSpeed,dist);if dist>0 then self.dropVX,self.dropVY=dx/dist*speed,dy/dist*speed end
   self.attractSpeed=math.min(12,self.attractSpeed+.2)
  end
 end
 self.nativeX,self.nativeY=self.nativeX+self.dropVX,self.nativeY+self.dropVY
 if not self.attracted then self.dropVY=math.min(2,self.dropVY+.03);if self.dropVY>=0 then self.dropVX=0 end end
 self.x,self.y=self.nativeX,224-self.nativeY
 if self.nativeY>472 or math.abs(self.nativeX)>=200 then Del(self)end
end
function Item:render()if not self.intro or self.intro<0 then A.render(self.animation,self.x,self.y)end end
function Item:del()if self.point then H.cancelCount=math.max(0,(H.cancelCount or 0)-1)end;H.items[self]=nil;H.owned[self]=nil end
local EnemyBase=Class(enemybase)
function EnemyBase:take_damage(dmg)
 local a=self.data
 if not a.dead and R.bitAnd(a.flags,0x31)==0 and not a.ending then a.hp=a.hp-dmg;self.hp=a.hp end
end
local Enemy=Class(EnemyBase)
function Enemy:init(a)
 enemybase.init(self,a.hp,true);self.data=a;self.bound=false;self.vx,self.vy=0,0;self.animations={};a.host=self;own(self)
end
function Enemy:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.x,self.y=a.x,224-a.y;self.hp=a.hp;self.protect=a.ending or R.bitAnd(a.flags,0x31)~=0
 self.a,self.b=(a.hurtW or 0)/2,(a.hurtH or 0)/2;self.rect=true;self.colli=not a.ending
 -- enemybase intercepts colli writes into _colli; our source-driven frame must sync the engine flag.
 SetAttr(self,'colli',self._colli)
 if not a.ending and R.bitAnd(a.flags,2)==0 and validPlayer()and player.colli and math.abs(player.x-self.x)<(a.hitW or 0)/2+player.a and math.abs(player.y-self.y)<(a.hitH or 0)/2+player.b then player.class.colli(player,self)end
 for _,anm in pairs(self.animations)do A.step(anm)end
 local root=self.animations[0];local spr=root and D.enemy.sprites[root.sprite];local w,h=32,32
 if spr then w,h=spr[4]*math.abs(root.values.scale[1]),spr[5]*math.abs(root.values.scale[2])end
 R.cullActor(a,w,h)
end
function Enemy:render()
 local list={}for slot,anm in pairs(self.animations)do list[#list+1]={slot,anm}end
 table.sort(list,function(a,b)return(a[2].layer or 0)<(b[2].layer or 0)end)
 for _,v in ipairs(list)do A.render(v[2],self.x,self.y)end
end
function Enemy:kill()R.die(self.data);H.owned[self]=nil end
function Enemy:del()H.owned[self]=nil end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,1,false,true);bullet.skip_fade_in(self);self.data=b;self.bound=false;self.vx,self.vy=0,0;local row=assert(D.bulletTypes[b.typ]);self.animation=A.new('bullet',row.script,R.random);self.animation.spriteMap=function(id)return assert(row.spriteSets[b.color][id+1],'native bullet sprite callback')end;own(self)
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 local native=assert(D.bulletTypes[b.typ],'TH18 bullet type '..b.typ);local sprite=assert(D.bullet.sprites[native.colors[b.color]],'TH18 bullet color '..b.color)
 self.img=sprite.image;self.a,self.b=native.radius,native.radius;self.rect=false
 self.x,self.y,self.vx,self.vy=b.x,224-b.y,0,0;self.heading=-b.angle*180/math.pi-90;self.rot=0
 self.colli=b.collidable~=false;self.group=(b.bombProof or 0)>0 and GROUP_INDES or GROUP_ENEMY_BULLET
 local scale=1;if b.birth and b.age<b.birth then scale=1+2*(1-b.age/b.birth)^2 end
 self.hscale,self.vscale,self._a=scale,scale,255;A.step(self.animation);self.animation.heading=(self.animation.renderType==2 or self.animation.autoRotate)and self.heading or 0
end
function Shot:render()A.render(self.animation,self.x,self.y)end
function Shot:kill()self.data.dead=true;H.owned[self]=nil;bullet.kill(self)end
function Shot:del()H.owned[self]=nil;bullet.del(self)end
function H.begin(seed)
 H.cleanup();A.load();H.counts={spawned={},collected={}};R.startRoute(seed)
 R.onActor=function(a)New(Enemy,a)end
 R.onAnimation=function(a,slot,id,main)if a.host and IsValid(a.host)then a.host.animations[slot]=id>=0 and A.new('enemy',id,R.random)or nil end end
 R.onEffect=function(a,bank,n)New(Effect,bank==0 and 'bullet' or 'effect',n,a.x,a.y,120)end
 R.onShot=function(b)New(Shot,b)end
 R.onDrop=function(typ,x,y,angle,speed,a)New(Item,typ,x,y,angle,speed,a)end
 R.onDeath=function(a)PlaySound('enep00',.3,a.x/200)end
 R.onCancel=function(b)
  local row=D.bulletTypes[b.typ];local fx=New(Effect,'bullet',row.script,b.x,b.y,16)
  fx.animation.spriteMap=function(id)return row.spriteSets[b.color][id+1]end;A.case(fx.animation,1)
 end
end
function H.step()
 local px,py=0,400;if validPlayer()then px,py=player.x,224-player.y end;R.stepRoute(px,py)
end
function H.finishRoute()
 R.command(R.controller,{i={},f={}},'enmKillAll',{});R.command(R.controller,{i={},f={}},'etClear',{640})
 for _,typ in ipairs({1,2,9,16,17,18,19})do print('TH18S5 DROP type='..typ..' spawned='..(H.counts.spawned[typ]or 0)..' collected='..(H.counts.collected[typ]or 0))end
 print('TH18S5 ROUTE COMPLETE tick='..R.tick..' enemies='..R.stats.actors..' bullets='..R.stats.bullets)
end
-- Character uses original TH10 stgenm07 idle / left / right / return scripts.
function H.newSuwako()return {animation=A.new('suwako',0),direction=0,x=0}end
function H.stepSuwako(s,x)
 local d=x-s.x;local dir=math.abs(d)>.05 and(d<0 and -1 or 1)or 0
 if dir~=s.direction then s.animation=A.new('suwako',dir<0 and 1 or dir>0 and 2 or s.direction<0 and 3 or 4);s.direction=dir end
 s.x=x;A.step(s.animation)
end
function H.renderSuwako(s,x,y)A.render(s.animation,x,y)end

-- Keep shared source sheets in the mod resource pool across practice re-entry.
A.load()



if setting.th18_stage5_collision_test then Include('stages/th18_stage5/collision-probe.lua')end
