-- Stage1 authored story; no Momiji portrait, no attack data changes.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local data=dofile('mod/SixStageCampaign/dialogue1/data.lua')
local A={data=data,finalSeen=false}
SixStageDialogue1=A
for key,a in pairs(data.art)do
 for j,v in ipairs(a.layers)do
  v.image='six.story1.'..key..'.'..j
  LoadTexture(v.image,'mod/SixStageCampaign/dialogue1/'..v.file)
  LoadImage(v.image,v.image,v.x or 0,v.y or 0,v.cw or v.w,v.ch or v.h);SetImageCenter(v.image,v.cx,v.cy)
 end
 D.data.art[key]=a
end
for key,pages in pairs(data.scenes)do S.data.scenes[key]=pages end
for key,name in pairs(data.names)do S.data.names[key]=name end
for ch in pairs(data.fallback)do D.data.fallback[ch]=true end
local draw=C.drawDialogue
C.drawDialogue=function(...)
 if D.active and D.which=='s1open'then
  SetViewMode('ui');RenderClear(Color(255,0,0,0))
 end
 if draw then return draw(...)end
end
function A.waitBeforeBattle()
 local p=player;local was=IsValid(p)and p.dialog
 if IsValid(p)then p.dialog=true end
 task.Wait(90)
 if IsValid(p)then p.dialog=was end
end
local function intro(x,y)
 local c=boss.move.New(x,y,1,MOVE_DECEL)
 c.init=function(o)
  task.New(o,function()S.play('s1wakapre');A.waitBeforeBattle();Kill(o)end)
 end
 return c
end
local source=C.sourceText
C.sourceText=function(path)
 if path~='mod/Stage12Normal/stage1/stage.lua'then return source and source(path)end
 local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
 local replacements={
  {'        Stage12Background.start(1); New(T.Hud)',"        if not setting.stage12_entry and not setting.th14_practice then SixStageStory46.play('s1open')end\n        Stage12Background.start(1); New(T.Hud)"},
  {'local mb=New(Stage1Momiji.Boss)',"SixStageStory46.play('s1momijipre');SixStageDialogue1.waitBeforeBattle()\n            local mb=New(Stage1Momiji.Boss)"},
  {"    print('TH14 POST-MOMIJI WAVES START", "    SixStageStory46.play('s1momijipost')\n    print('TH14 POST-MOMIJI WAVES START"},
  {'        T.clean();Stage1Momiji.clean();Stage1Context.clean(); T.finished=true;',"        if SixStageDialogue1.finalSeen then SixStageStory46.play('s1wakapost')end\n        T.clean();Stage1Momiji.clean();Stage1Context.clean(); T.finished=true;"}}
 for _,r in ipairs(replacements)do
  local a=assert(code:find(r[1],1,true),'Stage1 story source changed: '..r[1])
  code=code:sub(1,a-1)..r[2]..code:sub(a+#r[1])
 end
 return code
end
local install=C.install
function C.install(i,classes)
 install(i,classes);A.finalSeen=false
 if i~=1 then return end
 if not setting.stage12_entry and not setting.th14_practice and SixStageCollectLine then
  local frame=SixStageCollectLine.frame
  SixStageCollectLine.frame=function(o,...)
   if D.active and D.which=='s1open'then o.timer=o.timer-1;return end
   return frame(o,...)
  end
 end
 local class=th14.Wakasagi;local init,frame=class.init,class.frame
 class.init=function(o,is_mid,practice,...)
  if is_mid or(practice and practice~='non1')then return init(o,is_mid,practice,...)end
  local original=boss.init
  boss.init=function(b,bx,by,name,cards,...)
   local entry=cards[1];table.insert(cards,2,intro(entry.x,entry.y))
   return original(b,bx,by,name,cards,...)
  end
  init(o,is_mid,practice,...);boss.init=original
 end
 class.frame=function(o,...)
  local r=frame(o,...)
  if o.th14_phase=='scale'then A.finalSeen=true end
  return r
 end
end
