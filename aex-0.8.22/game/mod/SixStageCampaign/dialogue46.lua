-- Campaign story scenes only. Source gameplay files stay untouched.
local C,D=SixStageCampaign,SixStageDialogue3
local data=dofile('mod/SixStageCampaign/dialogue46/data.lua')
local S={data=data,played={},active=false,voiceSeed=20261111}
SixStageStory46=S
for key,a in pairs(data.art)do
 for j,layer in ipairs(a.layers)do
  local image='six.story.'..key..'.'..j;layer.image=image
  LoadTexture(image,'mod/SixStageCampaign/dialogue46/'..layer.file)
  LoadImage(image,image,layer.x or 0,layer.y or 0,layer.cw or layer.w,layer.ch or layer.h)
  SetImageCenter(image,layer.cx,layer.cy)
 end
 D.data.art[key]=a
end
for ch in pairs(data.fallback)do D.data.fallback[ch]=true end
function S.voice(id)
 if not IsValid(S.voiceDriver)then S.voiceDriver=New(TH11S6Voice.Driver)end
 TH11S6Voice.play(id);S.voices=S.voices or{};S.voices[#S.voices+1]=id
end
function S.randomLaugh()
 S.voiceSeed=S.voiceSeed*16807%2147483647
 S.voice(1+S.voiceSeed%4)
end
function S.play(key)
 if S.played[key]then return end
 if data.voiceOnly[key]then
  S.played[key]=true;S.randomLaugh()
  print('SIX STORY VOICE ONLY '..key);return
 end
 S.played[key]=true;S.active=true;S.current=key
 D.beginEntrance()
 local pages=assert(data.scenes[key],key);local other,initial='none',nil
 for _,p in ipairs(pages)do if p.speaker~='kaguya'then other,initial=p.speaker,p.portrait;break end end
 if other=='none'and key:find('midpost')then other,initial='suwako','suwakono'end
 local sounded={}
 D.show(key,{pages=pages,names=data.names,other=other,initial=initial,onPage=function(p)
  if key=='s6open'and p.line==3 and not sounded.open then sounded.open=true;S.voice(1)end
 end})
 while D.active do task.Wait(1)end
 D.endEntrance();S.active=false;S.current=nil
 print('SIX STORY DONE '..key)
end
function S.opening()S.play('s6open')end
local function storyCard(key,x,y,frames)
 local c=boss.move.New(x,y,frames or 1,MOVE_DECEL)
 c.init=function(o)
  task.New(o,function()
   task.MoveTo(x,y,frames or 1,MOVE_DECEL)
   S.play(key);task.Wait(90);Kill(o)
  end)
 end
 return c
end
local function prepend(class,key,index,x,y,frames)
 local init=class.init
 class.init=function(o,...)
  local original=boss.init
  boss.init=function(b,bx,by,name,cards,...)
   table.insert(cards,index,storyCard(key,x,y,frames))
   return original(b,bx,by,name,cards,...)
  end
  init(o,...);boss.init=original
 end
end
local previous=C.sourceText
C.sourceText=function(path)
 local replacements
 if path=='mod/MarisaMixed/stage14.lua'then replacements={
  {"  print('MARISA14 RABBIT COMPLETE cards=2')","  print('MARISA14 RABBIT COMPLETE cards=2');SixStageStory46.play('s4rabbitpost')"}}
 elseif path=='mod/MarisaMixed/root.lua'then replacements={
  {"  clean();MarisaMusic14.stop();if setting.marisa_road", "  if MarisaMixed.phase=='final'then SixStageStory46.play('s4post')end\n  clean();MarisaMusic14.stop();if setting.marisa_road"}}
 elseif path=='mod/NinaStage6Normal/road17/load.lua'then replacements={
  {' New(TH11S6Voice.Driver)',' New(TH11S6Voice.Driver);SixStageStory46.opening()'}}
 elseif path=='mod/NinaStage6Normal/intro12.lua'then replacements={
  {' Del(o);state.intro=nil;state.current=nil'," SixStageStory46.play('s6pre');task.Wait(90);SixStageStory46.play('s6battle')\n Del(o);state.intro=nil;state.current=nil"}}
 elseif path=='mod/NinaStage6Normal/root.lua'then replacements={
  {"  if selection=='all'or selection=='kanako'then","  if S.current=='final'then SixStageStory46.play('s6post')end\n  if selection=='all'or selection=='kanako'then"},
  {"task.Wait(90);Del(a);print('NINA KANAKO ARRIVAL", "task.Wait(90);SixStageStory46.play('s6kanako');task.Wait(90);Del(a);print('NINA KANAKO ARRIVAL"}}
 end
 if not replacements then return previous and previous(path)end
 local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
 for _,r in ipairs(replacements)do
  local a=assert(code:find(r[1],1,true),'Story source changed: '..path..' '..r[1])
  code=code:sub(1,a-1)..r[2]..code:sub(a+#r[1])
 end
 return code
end
local install=C.install
function C.install(i,classes)
 install(i,classes);S.played={};S.active=false;S.holdRoad=false;S.current=nil;S.voiceDriver=nil;S.voiceTick=nil;S.voices={}
 -- Cosmetic RNG only; never consume the attack generator's random stream.
 S.voiceSeed=(os.time()+(tonumber(setting.six_seed)or 20261111)+461)%2147483646+1
 if i==4 then
  if Th18Stage5Host then
   local step=Th18Stage5Host.step
   Th18Stage5Host.step=function(...)if S.active then return end;return step(...)end
  end
  if MarisaRabbit14 then prepend(MarisaRabbit14.Boss,'s4rabbitpre',1,0,96,1)end
  if setting.marisa_phase=='all'or setting.marisa_phase=='ssg'then
   for _,class in ipairs(classes)do
    local info=class.frame and debug.getinfo(class.frame,'S')
    if info and info.source:find('MarisaMixed/root.lua',1,true)then prepend(class,'s4pre',2,0,135,1)end
   end
  end
 elseif i==6 then
  prepend(TH11S6Milk.Boss,'s6midpre',1,0,96,60)
  local del=TH11S6Milk.card.del
  TH11S6Milk.card.del=function(o)S.holdRoad=true;return del(o)end
  local after=TH11S6Milk.card.after
  TH11S6Milk.card.after=function(o)
   if after then after(o)end
   task.MoveTo(224,280,60,MOVE_ACCEL);S.play('s6midpost');S.holdRoad=false
  end
  local step=TH11S6Runtime.step
  TH11S6Runtime.step=function(...)if S.active or S.holdRoad then return end;return step(...)end
  TH11S6Voice.checkFirstBatch=function()end -- opening story now owns laugh1
  NinaRoad17.arrived=function()NinaRoad17.pendingLaugh=false end -- battle story owns random laugh
  local voiceStep=TH11S6Voice.step
  TH11S6Voice.step=function()
   local t=stage.current_stage.timer
   if S.voiceTick==t then return end;S.voiceTick=t;voiceStep()
  end
 end
end
