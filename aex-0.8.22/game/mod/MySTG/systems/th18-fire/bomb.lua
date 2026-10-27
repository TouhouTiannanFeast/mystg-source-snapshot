-- Retail Reimu Bomb: 421590 (tick), 421936 (source), 4220c5
-- (400 cumulative threshold), 422176 (11-frame expanding explosion).
local F=Th18Fire
local Blast=Class(object)
local Orb=Class(object)
local function eachOverlap(x,y,radius,callback)
 for _,group in ipairs({GROUP_ENEMY,GROUP_NONTJT}) do
  for _,e in ObjList(group) do
   if e.colli and not e.protect and e.hp and e.hp>0 then
    local dx,dy=math.abs(e.x-x),math.abs(e.y-y)
    if e.rect then
     dx=math.max(0,dx-(e.a or 0));dy=math.max(0,dy-(e.b or 0))
     if dx*dx+dy*dy<radius*radius then callback(e) end
    elseif dx*dx+dy*dy<(radius+(e.a or 0))^2 then callback(e) end
   end
  end
 end
end
function Blast:init(x,y)
 self.x,self.y=x,y;self.group=GROUP_GHOST;self.layer=LAYER_PLAYER_BULLET
 self.bound=false;self.colli=false
end
function Blast:frame()
 if self.timer>=11 then Del(self);return end
 local radius=64+8*self.timer
 eachOverlap(self.x,self.y,radius,function(e)F.damage(e,100)end)
 New(bomb_bullet_killer,self.x,self.y,radius,radius,false)
end
function Blast:render()
 local scale=(64+8*self.timer)/32
 SetImageState('reimu_bomb_ef','mul+add',Color(255*(11-self.timer)/11,255,255,255))
 Render('reimu_bomb_ef',self.x,self.y,self.timer*12,scale,scale)
end
function Orb:init(p,index)
 self.player=p;self.index=index;self.x,self.y=p.x,p.y
 self.heading=index*45;self.radius=0;self.total=0;self.speed=0
 self.group=GROUP_GHOST;self.layer=LAYER_PLAYER_BULLET
 self.colli=false;self.bound=false
end
function Orb:explode()
 if self.exploded then return end
 self.exploded=true;New(Blast,self.x,self.y);Del(self)
end
function Orb:frame()
 if not IsValid(self.player) then Del(self);return end
 if self.timer>=200 or self.total>=400 then Orb.explode(self);return end
 local oldx,oldy=self.x,self.y
 local release=90+self.index*10
 if self.timer<release then
  if self.timer<90 then self.radius=self.radius+1.5 end
  self.heading=self.heading-6
  self.x=self.player.x+self.radius*cos(self.heading)
  self.y=self.player.y+self.radius*sin(self.heading)
  self.orbitDx,self.orbitDy=self.x-oldx,self.y-oldy
 elseif self.timer==release then
  self.heading=atan2(self.orbitDy or 0,self.orbitDx or 0)
  self.speed=math.sqrt((self.orbitDx or 0)^2+(self.orbitDy or 0)^2)
 else
  local target=F.nearest(self.x,self.y,512)
  if target then
   local diff=(Angle(self,target)-self.heading+540)%360-180
   if math.abs(diff)>=45 then self.speed=math.max(1,self.speed-.7)
   elseif math.abs(diff)<15 then self.speed=math.min(8,self.speed+.2) end
   self.heading=self.heading+diff*.1
  elseif self.x<-192 or self.x>192 or self.y<-224 or self.y>224 then self.speed=self.speed*.9 end
  self.x=self.x+self.speed*cos(self.heading);self.y=self.y+self.speed*sin(self.heading)
 end
 if self.timer%3==0 then
  eachOverlap(self.x,self.y,56,function(e)
   F.damage(e,15);self.total=self.total+15
  end)
 end
 if self.timer%8==self.index then New(bomb_bullet_killer,self.x,self.y,64,64,false) end
end
function Orb:render()
 SetImageState('reimu_bomb_ef','mul+add',Color(255,255,255,255))
 Render('reimu_bomb_ef',self.x,self.y,self.heading,2,2)
end
F.BombOrb,F.BombBlast=Orb,Blast
local sys=player_lib.system
local frame=sys.frame
local installed=false
function sys:frame(...)
 if not installed and reimu_player then
  installed=true
  reimu_player.spell=function(p)
   PlaySound('nep00',.8);PlaySound('slash',.8)
   New(player_spell_mask,200,0,0,30,180,30)
   for i=0,7 do New(Orb,p,i) end
   -- Retain the project's existing inventory, invulnerability and collection.
   p.collect_line=p.collect_line-300
   New(tasker,function()task.Wait(90);if IsValid(p)then p.collect_line=p.collect_line+300 end end)
   p.nextspell=p.slow==1 and 240 or 300;p.protect=360
  end
 end
 return frame(self,...)
end
