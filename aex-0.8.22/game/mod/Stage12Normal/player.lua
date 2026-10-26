-- Mod-local adapters; source drop tables and shared framework remain intact.
Include('player-config.lua')
Include('player-data.lua')
Stage12Player={}
local P=Stage12Player
function P.locked() return Stage12PlayerConfig.lock_power end
function P.lock(p)
 if P.locked() then
  lstg.var.power=400
  if p then p.support=4 end
 end
end
local initItem=item.PlayerInit
function item.PlayerInit(...) initItem(...);P.lock() end
local getPower=GetPower
function GetPower(v) if P.locked() then P.lock() else return getPower(v) end end
local dropItem=item.DropItem
function item.DropItem(x,y,drop)
 if P.locked() and drop then
  local filtered={};for k,v in pairs(drop) do filtered[k]=v end
  filtered[1]=0;return dropItem(x,y,filtered)
 end
 return dropItem(x,y,drop)
end
-- Also suppress direct P creation, including death/recovery/editor drops.
for _,class in ipairs({item_power,item_power_large,item_power_full}) do
 local init=class.init
 class.init=function(self,...)
  init(self,...)
  if P.locked() then self.hide=true;self.colli=false;Del(self) end
 end
end
local miss=item.PlayerMiss
function item.PlayerMiss(self)
 if not P.locked() then return miss(self) end
 lstg.var.chip_bonus=false
 if lstg.var.sc_bonus then lstg.var.sc_bonus=0 end
 self.protect=360
 lstg.var.lifeleft=lstg.var.lifeleft-1
 lstg.var.bomb=max(lstg.var.bomb,3)
 P.lock(self)
end
-- Called before subclasses are defined: both stages and Bosses share this hook.
local hit=enemybase.colli
local function piercingCollision(self,other)
 if other.stage12Piercing then
  if other.stage12Hits[self] then return end
  -- Protected contacts do not consume the one hit allowed per enemy.
  if self.protect or self.invuln and self.invuln>0 or self.dmg_factor==0 then return end
  other.stage12Hits[self]=true
 end
 return hit(self,other)
end
enemybase.colli=piercingCollision
boss.colli=piercingCollision
enemy.colli=piercingCollision
local Shot=Class(player_bullet_straight)
P.Shot=Shot
function Shot:init(x,y,speed,damage,piercing)
 player_bullet_straight.init(self,piercing and 'stage12.pierce' or 'stage12.main',x,y,speed,90,damage)
 self.a,self.b=24,piercing and 8 or 9;self.rect=true
 self.stage12Piercing=piercing;self.killflag=piercing
 self.stage12Hits=setmetatable({},{__mode='k'})
end
function Shot:frame()
 if self.y>lstg.world.boundt+64 then Del(self) end
end
local initReimu=reimu_player.init
function reimu_player:init(...)
 P.lock();initReimu(self,...)
 if Stage12PlayerConfig.reimu_b then
  self.slist=Stage12ReimuBData.positions
  self.slist[6]=self.slist[5]
  self.stage12FireClock=0
 end
 P.lock(self)
end
local frameReimu=reimu_player.frame
function reimu_player:frame()
 P.lock(self);frameReimu(self);P.lock(self)
 if Stage12PlayerConfig.reimu_b and not self.time_stop then
  if self.death==0 and (self.__shoot_flag or player_lib.debug_data.keep_shooting) and not self.dialog then
   self.stage12FireClock=(self.stage12FireClock+1)%16
  else self.stage12FireClock=0 end
 end
end
local shootReimu=reimu_player.shoot
function reimu_player:shoot()
 if not Stage12PlayerConfig.reimu_b then return shootReimu(self) end
 self.nextshoot=1
 local clock=self.stage12FireClock or 0
 local rows=Stage12ReimuBData.shooters[math.min(4,math.floor(lstg.var.power/100))+1]
 local played=false
 for _,s in ipairs(rows) do
  if clock>=s.delay and clock%s.rate==0 then
   local x,y=self.x,self.y
   if s.option>0 then
    local sp=self.sp[s.option]
    if sp and sp[3]>0.5 then x=self.supportx+sp[1];y=self.supporty+sp[2] else x=nil end
   end
   if x then
    New(Shot,x+s.x,y+s.y,s.speed,s.damage*Stage12PlayerConfig.damage_scale,s.option>0)
    if not played then PlaySound('plst00',0.3,self.x/1024);played=true end
   end
  end
 end
end
LoadTexture('stage12.player','art/player/pl00.png')
LoadImage('stage12.main','stage12.player',0,176,64,16,24,9,true)
LoadImage('stage12.pierce','stage12.player',64,176,64,8,24,8,true)
SetImageState('stage12.main','',Color(0x80FFFFFF))
SetImageState('stage12.pierce','',Color(0x80FFFFFF))
Include('player-ui.lua')

-- Practice-only: ignore the complete contact event before death/deletion hooks.
local practiceCollision=reimu_player.colli
function reimu_player:colli(other)
 if setting.stage12_entry and setting.stage12_invincible then
  if setting.stage12_invincible_probe then self.stage12IgnoredContacts=(self.stage12IgnoredContacts or 0)+1 end
  return
 end
 return practiceCollision(self,other)
end
