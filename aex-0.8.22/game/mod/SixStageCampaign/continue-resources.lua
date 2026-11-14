-- Campaign gameover Continue only; keep the engine reset/score/menu flow.
local C=SixStageCampaign
local reinit=item.PlayerReinit
function item.PlayerReinit(...)
 local result=reinit(...)
 if C.index>0 and ext.GetPauseMenuOrder()=='Continue'then
  lstg.var.lifeleft=3;lstg.var.bomb=5
 end
 return result
end
