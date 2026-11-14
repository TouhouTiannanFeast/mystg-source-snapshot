-- Freeze shared dialogue presentation whenever the engine pause menu is open.
local C=SixStageCampaign
local update=C.updateDialogue
C.updateDialogue=function(...)
 if ext.pause_menu and not ext.pause_menu:IsKilled()then return end
 return update(...)
end
-- Remove only completion-time stops. Stage del and music transitions still stop.
local edits={
 ['mod/YuyukoStage3/root.lua']={{'clean();Y3Music.stop();S.current=nil','clean();S.current=nil'}},
 ['mod/MarisaMixed/root.lua']={{'clean();MarisaMusic14.stop();if setting.marisa_road','clean();if setting.marisa_road'}},
 ['mod/NinaStage6Normal/root.lua']={{'clean();musicStop();task.Wait(90);S.finished=true','clean();task.Wait(90);S.finished=true'}},
 ['mod/HSoBStage5Normal/stages/zuu4/host.lua']={
  {'if self.timer>=255 then R.musicStop();Del(self);return end','if self.timer>=255 then Del(self);return end'},
  {'if index==#S.ids then R.musicStop()end','-- BGM continues through the final pickup window.'}},
}
local previous=C.sourceText
function C.sourceText(path)
 local code=previous and previous(path)
 local changes=edits[path];if not changes then return code end
 if not code then local f=assert(io.open(path,'rb'));code=f:read('*a');f:close()end
 for _,pair in ipairs(changes)do
  local a,b=code:find(pair[1],1,true);assert(a,'completion BGM hook missing: '..path)
  assert(not code:find(pair[1],b+1,true),'ambiguous completion BGM hook: '..path)
  code=code:sub(1,a-1)..pair[2]..code:sub(b+1)
 end
 return code
end
