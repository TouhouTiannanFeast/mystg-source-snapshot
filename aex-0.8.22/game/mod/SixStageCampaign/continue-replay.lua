-- Freeze the pre-Continue recording before the engine resets score/resources.
local R=SixStageRecording
local P={archives={},count=0,latched=false};SixStageContinueReplay=P
local function records()
 -- The engine exposes SaveReplay but keeps its per-stage metadata private.
 -- Read its named upvalue; never replace the writer or change the shared engine.
 for i=1,20 do
  local name,value=debug.getupvalue(ext.replay.SaveReplay,i)
  if not name then break end
  if name=='replayStages'and type(value)=='table'then return value end
 end
end
function P.snapshot()
 if not R.active or ext.replay.IsReplay()or not ext.replay.IsRecording()or #R.names==0 then return end
 if not R.slot then R.error='录像槽已满，无法另存续关前录像';print('SIX CONTINUE REPLAY ERROR '..R.error);return end
 local all=records();local record=all and all[lstg.var.stage_name]
 if not record then R.error='续关前录像保存失败';print('SIX CONTINUE REPLAY ERROR missing active metadata');return end
 local score,time=record.score,record.stageTime
 record.score=tonumber(lstg.var.score)or 0
 record.stageTime=math.max(0,os.time()-(time or os.time()))
 local slot=R.slot;local number=P.count+1
 local ok,err=pcall(ext.replay.SaveReplay,R.names,slot,(setting.username or'Player')..' pre-C'..number,0)
 record.score,record.stageTime=score,time
 if not ok then R.error='续关前录像保存失败';print('SIX CONTINUE REPLAY ERROR '..tostring(err));return end
 -- The old slot now belongs to the immutable pre-Continue archive.
 -- Release it even if refreshing the slot list unexpectedly fails.
 R.slot=nil;R.path=nil;P.count=number
 P.archives[#P.archives+1]={slot=slot,number=number,score=tonumber(lstg.var.score)or 0}
 local refreshed,refreshError=pcall(ext.replay.RefreshReplay)
 if refreshed then
  local info=ext.replay.GetSlot(slot);P.archives[#P.archives].path=info and info.path
  for i=1,ext.replay.GetSlotCount()do
   if i~=slot and not ext.replay.GetSlot(i)then R.slot=i;break end
  end
 end
 if R.slot then R.error=nil
 else R.error='续关前录像已保留，录像槽已满，后续录像无法保存'end
 print('SIX CONTINUE REPLAY SAVED archive='..slot..' next='..tostring(R.slot)..' score='..tostring(lstg.var.score))
 if not refreshed then print('SIX CONTINUE REPLAY REFRESH ERROR '..tostring(refreshError))end
end
local begin=R.begin
function R.begin(...)
 P.archives={};P.count=0;P.latched=false
 return begin(...)
end
local order=ext.GetPauseMenuOrder
function ext.GetPauseMenuOrder(...)
 local value=order(...)
 if value=='Continue'then
  if not P.latched then P.latched=true;P.snapshot()end
 else P.latched=false end
 return value
end
