-- Campaign recording context and deterministic presentation/playback boundaries.
local C,R,D=SixStageCampaign,SixStageRecording,SixStageDialogue3
local P={playing=false,record={}};SixStageReplaySync=P
local function records()
 for i=1,20 do local n,v=debug.getupvalue(P.saveNative,i);if not n then break end;if n=='replayStages'then return v end end
end
local function stageIndex(name)for i,n in ipairs(C.names)do if n==name then return i end end end
local function currentRecord()return P.record[lstg.var.stage_name]end
local begin=R.begin
function R.begin(...)P.playing=false;P.record={};return begin(...)end
P.saveNative=ext.replay.SaveReplay
local replayStages=records()
function ext.replay.SaveReplay(names,...)
 local all=replayStages;local originals={};local encoded={}
 for _,name in ipairs(names)do
  local row=all and all[name];local meta=P.record[name]
  if row and meta then
   originals[name]=row.stageExtendInfo
   local vars=DeSerialize(row.stageExtendInfo);vars.six_replay_meta=meta
   encoded[name]=Serialize(vars)
  end
 end
 for name,text in pairs(encoded)do all[name].stageExtendInfo=text end
 local ok,err=pcall(P.saveNative,names,...)
 for name,text in pairs(originals)do all[name].stageExtendInfo=text end
 if not ok then error(err)end
end
local set=stage.Set
function stage.Set(name,mode,path)
 local incoming=stageIndex(name)
 if incoming and mode=='load'then
  local info=plus.ReplayManager.ReadReplayInfo(path);local row
  for _,v in ipairs(info.stages)do if v.stageName==name then row=v;break end end
  assert(row,'recorded stage absent')
  local vars=DeSerialize(row.stageExtendInfo);local meta=vars.six_replay_meta
  P.playing=true;P.path=path;P.info=info;P.meta=meta;P.stage=name;R.active=false
  C.entry=meta and meta.entry or'full';if meta then C.first=meta.first==true else C.first=incoming==1 end
  C.complete=false;C.target=incoming;C.god=false;C.speed=1
  if not meta then print('SIX REPLAY LEGACY missing dialogue/entry metadata '..name)end
 elseif P.playing and incoming then
  mode='load';path=P.path
  return stage.Set(name,mode,path)
 elseif incoming and(mode=='save'or mode=='none'or mode==nil)and R.active then
  P.record[name]={version=1,entry=C.entry,first=C.first,dialogue={},continues={}}
 end
 local wasPlaying=P.playing
 local value=set(name,mode,path)
 if wasPlaying and name=='menu'then P.playing=false;P.meta=nil;P.path=nil end
 return value
end
-- During playback dialogue updates once per logic frame, after recorded keys.
local update=C.updateDialogue
function C.updateDialogue(...)
 if P.playing and not P.inDialogue then return end
 P.beforeInput=not P.playing
 local value=update(...);P.beforeInput=false;return value
end
local advance=D.advance
function D.advance(...)
 if P.playing and P.meta and not P.eventAdvance then return end
 if not P.playing and R.active and replayWriter and D.active and not D.exit then
  local meta=currentRecord()
  if meta then meta.dialogue[tostring(replayWriter:GetCount()+(P.beforeInput and 1 or 0))]=true end
 end
 return advance(...)
end
local order=ext.GetPauseMenuOrder
function ext.GetPauseMenuOrder(...)
 local value=order(...)
 if P.playing and P.meta and replayReader and P.meta.continues[tostring(replayReader._read)]then return'Continue'end
 if not P.playing and R.active and replayWriter and value=='Continue'then
  local meta=currentRecord();if meta then meta.continues[tostring(replayWriter:GetCount())]=true end
 end
 return value
end
local key=GetKeyState
GetKeyState=function(k,...)
 if P.playing and P.inDialogue then
  if k==KEY.Z then return KeyState.shoot end
  if k==(KEY.CTRL or 17)then return false end
 end
 return key(k,...)
end
local input=GetInput
function GetInput(...)
 if P.playing and replayReader and replayReader._read>=replayReader._count then
  print('SIX REPLAY END stage='..tostring(P.stage)..' frames='..replayReader._read)
  stage.Set('menu','none')
 end
 local value=input(...)
 if P.playing and D.active and not stage.next_stage then
  P.inDialogue=true;C.updateDialogue();P.inDialogue=false
  if P.meta and replayReader and P.meta.dialogue[tostring(replayReader._read)]then
   P.eventAdvance=true;D.advance();P.eventAdvance=false
  end
 end
 return value
end
-- Ctrl may execute several logic ticks, but never crosses a pending stage change.
local doFrameEx=DoFrameEx
function DoFrameEx(...)
 if not P.playing then return doFrameEx(...)end
 ext.replayTicker=ext.replayTicker+1;ext.slowTicker=ext.slowTicker+1
 local n=GetKeyState(setting.keysys.repfast)and 4 or 1
 if n==1 then
  if GetKeyState(setting.keysys.repslow)then
   if ext.replayTicker%4~=0 then return end
  elseif lstg.var.timeslow and lstg.var.timeslow>0 and lstg.var.timeslow~=1 then
   local level=math.min(4,math.max(1,lstg.var.timeslow))
   if ext.slowTicker%ext.time_slow_level[level]~=0 then return end
  end
 end
 for i=1,n do
  DoFrame(true,false);ext.pause_menu_order=nil
  if stage.next_stage or not P.playing or C.reward then break end
 end
end
-- Card acquisition has no logic frames in the recording; auto-confirm in playback.
local frame=FrameFunc
FrameFunc=function(...)
 if P.playing and C.reward then
  local r=C.reward
  if not r.exit and r.age>=60 then r.exit=0;PlaySound('six.notice.confirm',1,0,true)end
 end
 return frame(...)
end

