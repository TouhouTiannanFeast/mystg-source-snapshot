-- Record actual campaign stages through the engine's ReplayFrameWriter.
local C=SixStageCampaign
local R={active=false,names={},rows={}};SixStageRecording=R
local index={};for i,n in ipairs(C.names)do index[n]=i end
function R.begin()
 R.active=true;R.names={};R.rows={};R.lastScore=0;R.path=nil;R.error=nil;R.slot=nil;R.result=nil
 ext.replay.RefreshReplay()
 for i=1,ext.replay.GetSlotCount()do if not ext.replay.GetSlot(i)then R.slot=i;break end end
 if not R.slot then R.error='录像槽已满，未覆盖已有录像'end
end
function R.save(finish)
 if not R.slot or #R.names==0 then return end
 local ok,err=pcall(ext.replay.SaveReplay,R.names,R.slot,setting.username or'Player',finish or 0)
 if ok then
  ext.replay.RefreshReplay();local info=ext.replay.GetSlot(R.slot)
  R.path=info and info.path;R.error=nil
  print('SIX REPLAY SAVED stages='..#R.names..' slot='..R.slot..' path='..tostring(R.path))
 else R.error='录像保存失败';print('SIX REPLAY SAVE ERROR '..tostring(err))end
end
local begin=C.begin
function C.begin(...)
 R.begin();return begin(...)
end
local set=stage.Set
function stage.Set(name,mode,path)
 local incoming=index[name]
 if R.active and not ext.replay.IsReplay()then
  local outgoing=index[stage.current_stage and(stage.current_stage.name or stage.current_stage.stage_name)]
  local leaving=outgoing and not incoming
  if leaving then
   local score=tonumber(lstg.var.score)or 0
   R.rows[outgoing]={score=score,gain=math.max(0,score-R.lastScore)};R.lastScore=score
  end
  if incoming and(mode=='none'or mode==nil)then mode='save'end
  if incoming and mode=='save'then
   local found=false;for _,n in ipairs(R.names)do if n==name then found=true end end
   if not found then R.names[#R.names+1]=name end
  end
  local complete=name=='SixStageGap'and C.complete
  local ended=complete or(name=='menu'and outgoing)
  if ended then
   R.result={clear=complete,score=tonumber(lstg.var.score)or 0,lives=lstg.var.lifeleft or 0,bombs=lstg.var.bomb or 0,graze=lstg.var.graze or 0,rows=R.rows}
   name='SixStageResult'
  end
  local value=set(name,mode,path)
  if leaving then R.save(complete and 1 or 0)end
  if ended or name=='menu'then R.active=false end
  return value
 end
 return set(name,mode,path)
end
LoadTexture('six.result.bg','mod/SixStageCampaign/presentation/result.jpg')
local w,h=GetTextureSize('six.result.bg');LoadImage('six.result.bg','six.result.bg',0,0,w,h)
local result=stage.New('SixStageResult',false,true)
function result:init()self.ready=false;self.held=true;print('SIX RESULT SHOW score='..tostring(R.result and R.result.score))end
function result:frame()
 local down=GetKeyState(KEY.Z)or GetKeyState(KEY.ENTER)or GetKeyState(KEY.X)or GetKeyState(KEY.ESCAPE)
 if not down then self.held=false end
 if self.timer>=90 and down and not self.held then stage.Set('menu','none')end
end
function result:render()
 SetViewMode('ui');RenderClear(Color(255,0,0,0));Render('six.result.bg',320,240,0,640/w,480/h)
 SetImageState('white','',Color(205,8,10,30));RenderRect('white',70,570,40,446)
 local d=R.result or{rows={}};local draw=SixStageTypography.draw
 draw(d.clear and'All Clear!'or'Result',258,420,255,'body',true)
 draw('最终得分',100,376,255);draw(string.format('%012.0f',d.score or 0),355,376,255)
 for i=1,6 do
  local row=d.rows[i];local y=344-i*30
  draw('Stage '..i,114,y,255);draw(row and string.format('%012.0f',row.gain)or'----------',355,y,255)
 end
 draw('残机',114,120,255);draw(tostring(d.lives or 0),188,120,255)
 draw('Bomb',250,120,255);draw(tostring(d.bombs or 0),315,120,255)
 draw('Graze',380,120,255);draw(tostring(d.graze or 0),455,120,255)
 draw(R.path and'录像已自动保存'or(R.error or'本局无录像'),110,82,255)
 draw('Z / Enter 返回标题',210,54,255)
end
-- Legacy replay loader also has X, but its input can be masked by source menus.
-- Explicit title-page handling guarantees both X and Esc leave the page.
local M=C.frontend;local input=M.input
M.input=function(key)
 if M.page=='replay'and key=='cancel'and M.replays and not M.pending then
  M.replays.exitCallback();return
 end
 return input(key)
end
local menuFrame=stage_menu.frame
function stage_menu:frame()
 if M.page=='replay'and M.replays and not M.pending then
  local key=GetLastKey()
  if key==KEY.ESCAPE or key==setting.keys.spell then M.input('cancel')end
 end
 return menuFrame(self)
end
