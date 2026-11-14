-- TH08 result bitmap presentation; no gameplay/score changes.
local C,R=SixStageCampaign,SixStageRecording
local P={};SixStageResultSkin=P
local dir='mod/SixStageCampaign/result-skin/'
LoadTexture('six.result.labels',dir..'labels.png')
LoadTexture('six.result.ascii',dir..'ascii.png')
-- Fixed original label strips; omit original slowdown row entirely.
local widths={80,64,116,168,84,116,220}
for i=1,7 do
 LoadImage('six.result.label'..i,'six.result.labels',0,32+(i-1)*22,widths[i],22)
 SetImageCenter('six.result.label'..i,0,11)
end
LoadImage('six.result.title','six.result.labels',110,0,146,28)
SetImageCenter('six.result.title',0,14)
for code=33,126 do
 local n=code-32;local name='six.result.char'..code
 LoadImage(name,'six.result.ascii',(n%16)*16,32+math.floor(n/16)*16,16,16)
 SetImageCenter(name,0,8)
end
function P.ascii(text,right,y)
 text=tostring(text);local scale=math.min(1,208/(#text*16));local x=right-#text*16*scale
 for i=1,#text do
  local code=text:byte(i)
  if code~=32 then Render('six.result.char'..code,x,y,0,scale,scale)end
  x=x+16*scale
 end
end
local begin=R.begin
function R.begin(...)
 P.stats={misses=0,bombs=0,continues=0,captures=0};return begin(...)
end
local function count(field)if R.active and P.stats then P.stats[field]=P.stats[field]+1 end end
local miss=item.PlayerMiss
function item.PlayerMiss(...)count('misses');return miss(...)end
local bomb=item.PlayerSpell
function item.PlayerSpell(...)count('bombs');return bomb(...)end
local reinit=item.PlayerReinit
function item.PlayerReinit(...)
 if ext.GetPauseMenuOrder()=='Continue'then count('continues')end
 return reinit(...)
end
local sound=PlaySound
function PlaySound(name,...)
 if name=='cardget'then count('captures')end
 return sound(name,...)
end
local set=stage.Set
function stage.Set(...)
 local old=R.result;local index=C.index
 local difficulty=lstg.var.difficulty or 'Normal'
 local result=set(...)
 if R.result and R.result~=old then
  local s=P.stats or{}
  R.result.stats={misses=s.misses or 0,bombs=s.bombs or 0,continues=s.continues or 0,captures=s.captures or 0}
  R.result.difficulty=difficulty
  R.result.completion=R.result.clear and 100 or math.max(0,math.min(5,(index or 1)-1))/6*100
 end
 return result
end
local result=stage.stages.SixStageResult
function result:render()
 SetViewMode('ui');RenderClear(Color(255,0,0,0))
 local w,h=GetTextureSize('six.result.bg');Render('six.result.bg',320,240,0,640/w,480/h)
 SetImageState('white','',Color(205,8,10,30));RenderRect('white',32,608,38,448)
 Render('six.result.title',64,420)
 SixStageTypography.draw('本局成绩',228,434,255)
 local d=R.result or{};local s=d.stats or{}
 local values={string.format('%.0f',d.score or 0),tostring(d.difficulty or'Normal'),
  d.clear and'100%'or string.format('%.2f%%',d.completion or 0),
  tostring(s.continues or 0),tostring(s.misses or 0),tostring(s.bombs or 0),tostring(s.captures or 0)}
 local translations={'最终得分','难度','关卡完成率','续关次数','失误次数','使用炸弹次数','符卡取得次数'}
 for i=1,7 do
  local y=366-(i-1)*32
  Render('six.result.label'..i,48,y)
  SixStageTypography.draw(translations[i],48+widths[i]+8,y+14,255)
  P.ascii(values[i],592,y)
 end
 SixStageTypography.draw(R.path and'录像已自动保存'or(R.error or'本局无录像'),64,98,255)
 P.ascii('Z / Enter',212,62);SixStageTypography.draw('返回标题',232,76,255)
end
