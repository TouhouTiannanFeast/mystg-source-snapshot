local R,E=HSoB5,HSoB5.env
R.owned={}
local function own(o)R.owned[o]=true end
local function clean()
 R.clear();local list={};for o in pairs(R.owned)do list[#list+1]=o end
 for _,o in ipairs(list)do if IsValid(o)then Del(o)end end;R.owned={}
end
R.cleanup=clean
for _,n in ipairs({'bullet00','fairy','egypt','onmyou','soul'})do LoadTexture('hs5.'..n,'art/'..n..'.png')end
for id,a in pairs(R.art)do
 local r=a.rect;a.image='hs5.shot'..id
 LoadImage(a.image,'hs5.bullet00',r[1],r[2],r[3]-r[1],r[4]-r[2])
 for i,f in ipairs(a.frames)do r=f.rect;f.image=a.image..'.'..i;LoadImage(f.image,'hs5.bullet00',r[1],r[2],r[3]-r[1],r[4]-r[2])end
end
for _,n in ipairs({'fairy','egypt'})do
 for typ,row in pairs({[2]={32,48},[4]={128,48},[6]={224,64},[7]={288,64}})do
  for col=0,6 do LoadImage('hs5.'..n..typ..'.'..col,'hs5.'..n,col*row[2],row[1],row[2],row[2])end
 end
end
for col=0,7 do
 for layer=0,2 do LoadImage('hs5.onmyou'..col..'.'..layer,'hs5.onmyou',(col%4)*32,math.floor(col/4)*32+layer*64,32,32)end
end
LoadImage('hs5.soul','hs5.soul',0,0,32,32)
local Shot=Class(bullet)
function Shot:init(o)
 bullet.init(self,grain_b,1,false,true);bullet.skip_fade_in(self)
 self.data=o;o.native=self;self.bound=false;self.vx,self.vy=0,0;own(self)
end
function Shot:frame()
 local o=self.data;if o.dead then Del(self);return end
 local offset=R.art[o.id].offset;local a=o.angle+90
 local dx=offset[1]*E.cos(a)-offset[2]*E.sin(a);local dy=offset[1]*E.sin(a)+offset[2]*E.cos(a)
 self.x,self.y,self.vx,self.vy=o.x+dx-192,224-o.y-dy,0,0
 self.a,self.b,self.rect=o.radius,o.radius,false
 self.colli=o.collidable~=false and o.age>=o.delay;self.hide=o.renderVisible==false
 self.group=o.bombProof and GROUP_GHOST or GROUP_ENEMY_BULLET
 self.rot=-o.angle-90
end
local function shotImage(o)
 local a=R.art[o.id];local img=a.image
 if #a.frames>0 then
  local total=0;for _,f in ipairs(a.frames)do total=total+f.duration end
  local t=o.age%total
  for _,f in ipairs(a.frames)do if t<f.duration then img=f.image;break end;t=t-f.duration end
 end
 return img,a
end
function Shot:render()
 local o=self.data;local img,a=shotImage(o)
 SetImageState(img,a.add and 'mul+add'or'',Color(math.max(0,math.min(255,o.alpha)),o.color[1],o.color[2],o.color[3]))
 Render(img,o.x-192,224-o.y,self.rot,o.sx,o.sy)
end
function Shot:kill()self.data.dead=true;R.owned[self]=nil;bullet.kill(self)end
function Shot:del()R.owned[self]=nil end
local Beam=Class(laser)
function Beam:init(o)
 laser.init(self,1,o.x-192,224-o.y,-o.beamAngle,0,o.length,0,o.width,0,0)
 self.data=o;self.bound=false;self.alpha=1;own(self)
end
function Beam:frame()
 local o=self.data;if o.dead then Del(self);return end
 self.x,self.y,self.rot=o.x-192,224-o.y,-o.beamAngle
 local growth=o.straight and math.max(0,math.min(1,(o.age-o.delay+1)/15))^2 or 1
 self.l1,self.l2,self.l3=0,o.length,0;self.w=o.width*growth/2;self.alpha=1
 self.colli=o.collidable~=false and o.age>=o.delay
 laser.frame(self)
end
function Beam:render()
 local o=self.data;local a=R.art[o.id];local r=a.rect
 local growth=o.straight and math.max(0,math.min(1,(o.age-o.delay+1)/15))^2 or 1
 local w=o.age<o.delay and 2 or o.width*growth
 local alpha=o.age<o.delay and 192 or o.alpha
 SetImageState(a.image,'mul+add',Color(alpha,o.color[1],o.color[2],o.color[3]))
 Render(a.image,self.x+o.length*E.cos(o.beamAngle)/2,self.y-o.length*E.sin(o.beamAngle)/2,-o.beamAngle-90,w/(r[3]-r[1]),o.length/(r[4]-r[2]))
end
function Beam:kill()self.data.dead=true;R.owned[self]=nil end
function Beam:del()R.owned[self]=nil end
local EnemyBase=Class(enemybase)
local Enemy=Class(EnemyBase)
function Enemy:init(o)
 enemybase.init(self,o.hp,true);self.data=o;self.bound=false;self.a,self.b=o.radius,o.radius
 self.vx,self.vy=0,0;self.lastX=o.x;own(self);o.native=self
end
function Enemy:frame()
 local o=self.data
 if o.dead then if o.killed then Kill(self)else Del(self)end;return end
 if self.hp<=0 then o.hp=0;o.killed=true;o.dead=true;Kill(self);return end
 self.hp=o.hp;self.x,self.y,self.vx,self.vy=o.x-192,224-o.y,0,0
 self.colli=o.visible and o.radius>0;SetAttr(self,'colli',self._colli)
 self.hide=o.art==nil or o.renderVisible==false
 self.direction=o.x-self.lastX;self.lastX=o.x
 if o.visible and o.playerRadius>0 and IsValid(player)then
  local dx,dy=self.x-player.x,self.y-player.y
  if dx*dx+dy*dy<(o.playerRadius+(player.A or 0))^2 then player.class.colli(player,self)end
 end
end
function EnemyBase:take_damage(dmg)
 local o=self.data;dmg=dmg*o.damageRate;self.hp=self.hp-dmg;o.hp=self.hp
 R.damage=(R.damage or 0)+dmg
end
function Enemy:colli(other)
 local o=self.data
 if other==player then
  if o.playerRadius<=0 then return end
  local dx,dy=self.x-other.x,self.y-other.y
  if dx*dx+dy*dy>(o.playerRadius+(other.A or 0))^2 then return end
 end
 enemybase.colli(self,other)
end
function Enemy:render()
 local o=self.data;local img
 if o.art=='onmyou'then
  local name='hs5.onmyou'..(o.artColor or 2)..'.'
  for _,v in ipairs({{2,1.75,-4,'mul+add'},{1,1.4,6,''},{0,0.9,0,''}})do
   local image=name..v[1];SetImageState(image,v[4],Color(math.max(0,math.min(255,o.alpha)),o.color[1],o.color[2],o.color[3]))
   Render(image,self.x,self.y,-v[3]*o.age,v[2]*o.sx,v[2]*o.sy)
  end
  return
 elseif o.art=='soul'then img='hs5.soul'
 elseif o.art then
  local frames=math.abs(self.direction)>0.1 and {4,5,6,5}or{0,1,2,1}
  img='hs5.'..o.art..o.fairy..'.'..frames[math.floor(o.age/8)%4+1]
 end
 if img then
  SetImageState(img,'',Color(math.max(0,math.min(255,o.alpha)),math.max(0,math.min(255,o.color[1])),math.max(0,math.min(255,o.color[2])),math.max(0,math.min(255,o.color[3]))))
  Render(img,self.x,self.y,o.art=='onmyou'and o.age*6 or 0,o.sx*(self.direction<0 and -1 or 1),o.sy)
 end
end
function Enemy:kill()local o=self.data;o.dead=true;o.killed=true;R.owned[self]=nil;New(enemy_death_ef,1,self.x,self.y)end
function Enemy:del()self.data.dead=true;R.owned[self]=nil end
R.onEnemy=function(o)New(Enemy,o)end
R.onShot=function(o)New(Shot,o)end
R.onShotDisabled=function(o)if IsValid(o.native)then o.native.group=GROUP_GHOST end end
R.onBeam=function(o)New(Beam,o)end
R.getLife=function()return lstg.var.lifeleft end
R.onReward=function(n)
 lstg.var.lifeleft=lstg.var.lifeleft+1;lstg.var.bomb=lstg.var.bomb+1
 E.CallSound(E.snd1UP);E.CallSound(E.sndExtSpell)
 print('HSOB5 REWARD section='..n..' tick='..R.tick..' life='..lstg.var.lifeleft..' bomb='..lstg.var.bomb)
end
R.protect=function(n)if IsValid(player)then player.protect=math.max(player.protect or 0,n)end end
R.collect=function(n)if not IsValid(player)then return end;for _,o in ObjList(GROUP_ITEM)do o.target=player;o.attract=8 end end
-- Keep source time-crystal item identity at the interface. AEX has no time meter.
R.onItem=function(x,y,id)if id==E.MY_ITEM_SPELL then E.CallSound(E.sndItemSpecial);New(item_bomb,x-192,224-y)end end
