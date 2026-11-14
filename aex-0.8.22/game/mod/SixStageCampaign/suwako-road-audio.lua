-- Campaign-only Suwako road volleys: source modules create shots directly.
-- Original TH10 tan00 is loaded by the existing campaign road-audio module.
local C=SixStageCampaign
local install=C.install
function C.install(i,classes)
 install(i,classes);if i~=6 then return end
 local tick
 local function emit()
  local now=stage.current_stage.timer
  if tick==now then return end;tick=now
  local x=IsValid(_boss)and _boss.x or 0
  lstg.PlaySound('six.th10.tan00',.22,math.max(-1,math.min(1,x/192)))
 end
 local non=MilkHoneyNonspell.events
 MilkHoneyNonspell.events=function(...)
  local firing=non(...);if firing then emit()end;return firing
 end
 local spell=MilkHoneyPattern.events
 MilkHoneyPattern.events=function(...)
  local events=spell(...);if #events>0 then emit()end;return events
 end
end
