-- Explicit bounded test only; never loaded during ordinary play.
local old=AfterFrame
local ticks=0
AfterFrame=function(...)
 old(...)
 if not IsValid(player) then return end
 ticks=ticks+1;player.protect=1000
 if ticks==1 then
  local coins=MyResources.state().coins;local score=lstg.var.score
  local o=New(item_point,player.x,player.y);item.colli(o,player)
  assert(MyResources.state().coins==coins+MyResourceConfig.coin_value)
  o=New(item_faith,player.x,player.y);item.colli(o,player)
  assert(MyResources.state().coins==coins+2*MyResourceConfig.coin_value)
  o=New(item_faith_minor,player.x,player.y);item.colli(o,player)
  assert(lstg.var.score==score+MyResourceConfig.yellow_score)
  lstg.var.power=400;o=New(item_power,player.x,player.y);item.colli(o,player)
  assert(lstg.var.score==score+MyResourceConfig.yellow_score+MyResourceConfig.full_power_score)
  New(item_point,-80,40);New(item_faith,0,40);New(item_faith_minor,80,40)
  print('RESOURCE NATIVE PICKUP PASS')
 end
 if ticks==60 then lstg.Snapshot('userdata/snapshot/resources.jpg');print('RESOURCE SNAPSHOT') end
 if ticks==70 then print('RESOURCE NATIVE COMPLETE');stage.Set('stage.quit') end
end
