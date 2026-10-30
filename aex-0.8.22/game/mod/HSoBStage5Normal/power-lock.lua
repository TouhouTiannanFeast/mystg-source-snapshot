-- Applies only to the independent HSoB road. Keep native life/Bomb/death rules.
local function active()
 return stage.current_stage and stage.current_stage.stage_name=='HSoB Stage5 Road@Normal'
end
local gainPower=GetPower
function GetPower(n)
 if active()then lstg.var.power=400;return end
 return gainPower(n)
end
local miss=item.PlayerMiss
function item:PlayerMiss()
 if not active()then return miss(self)end
 lstg.var.chip_bonus=false
 if lstg.var.sc_bonus then lstg.var.sc_bonus=0 end
 self.protect=360
 lstg.var.lifeleft=lstg.var.lifeleft-1
 lstg.var.power=400
 lstg.var.bomb=max(lstg.var.bomb,3)
end
local frame=player_lib.system.frame
function player_lib.system:frame(...)
 if not active()then return frame(self,...)end
 lstg.var.power=400;self.player.support=4
 local result=frame(self,...)
 lstg.var.power=400;self.player.support=4
 return result
end
-- Native item.frame uses self.target whenever attract>0. Death/restart can
-- invalidate that reference even after it was initially assigned correctly.
local itemFrame=item.frame
function item:frame()
 if active()and self.attract>0 then
  if IsValid(player)then self.target=player else self.attract=0;self.target=nil end
 end
 return itemFrame(self)
end
-- Class copies inherited callbacks when it is declared, before this mod loads.
for _,name in ipairs({'item_power','item_power_large','item_power_full','item_extend','item_chip','item_bombchip','item_bomb','item_faith','item_point','item_faith_minor'})do
 local cls=_G[name];if cls and cls.frame==itemFrame then cls.frame=item.frame end
end
