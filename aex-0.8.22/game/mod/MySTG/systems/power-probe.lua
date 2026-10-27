-- Explicit short fixture for real player initialization, death path and HUD.
local old=AfterFrame;local t=0
AfterFrame=function(...)
 old(...)
 if not IsValid(player)then return end;t=t+1;player.protect=1000
 assert(lstg.var.power==400,'power must stay400')
 if t==1 then assert(player.support==4,'spawn must have four options');print('POWER14 SPAWN power='..lstg.var.power..' support='..player.support..' player='..tostring(lstg.var.player_name))end
 if t==20 then
  local lives=lstg.var.lifeleft;item.PlayerMiss(player)
  assert(lstg.var.power==400 and lstg.var.lifeleft==lives-1,'death hook changed unrelated miss state')
  local score=lstg.var.score;GetPower(1);assert(lstg.var.power==400 and lstg.var.score==score+100)
  GetPower(-50);assert(lstg.var.power==400 and lstg.var.score==score+100)
  print('POWER14 DEATH AND PICKUP PASS');lstg.var.power=100
 end
 if t==21 then assert(lstg.var.power==400 and player.support==4);print('POWER14 FRAME RESTORE PASS')end
 if t==140 then lstg.Snapshot('userdata/snapshot/power14-hud.jpg');print('POWER14 HUD SNAPSHOT')end
 if t==150 then print('POWER14 COMPLETE');stage.Set('stage.quit')end
end
