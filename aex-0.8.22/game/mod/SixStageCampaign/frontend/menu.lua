-- TH10 title.anm layout and art, with the campaign's requested locked choices.
Include('mod/SixStageCampaign/frontend/assets.lua')
Include('mod/SixStageCampaign/frontend/loading.lua')
local C=SixStageCampaign
local M={page='title',cursor=1,rank=2,player=1,age=0,enabled={true,false,true,true,true,false,false,true}}
C.frontend=M
local function sound(name)PlaySound('six.title.'..name,0.4)end
local function ease(t)t=math.max(0,math.min(1,t));return 1-(1-t)^2 end
local function sprite(id,x,y,alpha,shade,sx,sy)
 local img='six.title.'..id
 SetImageState(img,'',Color(math.floor(alpha or 255),shade or 255,shade or 255,shade or 255))
 Render(img,x,480-y,0,sx or 1,sy or sx or 1)
end
local function words(value,x,y,size,alpha)
 RenderTTF('six.title.font',value,x,x+560,480-y-26,480-y,
  Color(alpha or 255,255,255,255),'left','vcenter')
end
M.entries={}
local function add(stage,key,label)M.entries[#M.entries+1]={stage=stage,key=key,label=stage..'面  '..label}end
add(1,'full','完整一面 → 六面')
for _,p in ipairs({{'s1-momiji','椛'},{'s1-non1','若鹭姬一非'},{'s1-context','若鹭姬一符'},{'s1-non2','若鹭姬二非'},{'s1-scale','若鹭姬终符'}})do add(1,p[1],p[2])end
add(2,'full','完整二面 → 六面')
for _,p in ipairs({{'s2-magic','帕秋莉'},{'s2-flare','Royal Flare'},{'s2-mystia','米斯蒂娅'},{'s2-mz1','猯藏一阶段'},{'s2-mz2','猯藏二阶段'},{'s2-mz3','猯藏三阶段'},{'s2-mz4','猯藏四阶段'},{'s2-mz5','猯藏终符'}})do add(2,p[1],p[2])end
add(3,'full','完整三面 → 六面');add(3,'road-front','前半道中');add(3,'road-back','后半道中')
for _,id in ipairs({'non1','spell1','non2','spell2','non3','spell3'})do add(3,id,'幽幽子 '..id)end
add(4,'full','完整四面 → 六面')
for _,id in ipairs({'ssg','stardust','non1','milky','non3','comet','final'})do add(4,id,'魔理沙 '..id)end
add(5,'full','完整五面 → 六面')
for _,id in ipairs({'1','2','3'})do add(5,id,'道中第 '..id..' 部分')end
for _,id in ipairs({'boss','non1','spell1','non2','spell2','non3','stone','final'})do add(5,id,'珠乌 '..id)end
add(6,'full','完整六面')
for _,id in ipairs({'boss','non1','spell1','non2','spell2','non3','spell3','non4','spell4','final','kanako'})do add(6,id,'关底 '..id)end

function M.switch(page,action)
 M.pending={page=page,action=action,age=0,duration=20}
end
local function confirmTitle(page,action)
 M.switch(page,action)
 -- title.anm selected-label interrupt2: 22f grey/white flashes, then 20f exit.
 M.pending.flash=true;M.pending.duration=42
end
local function confirmSelection(page,action,kind,frames)
 M.switch(page,action)
 M.pending.selection=kind;M.pending.flashFrames=frames;M.pending.duration=frames+20
end
local function jog(age)
 if age>=8 then return-4 end
 age=math.max(0,age)
 local targets={0,-4,-2,-7,-4};local n=math.floor(age/2)+1
 return targets[n]+(targets[n+1]-targets[n])*ease((age-(n-1)*2)/2)
end
local function flash(age)return math.floor(age/2)%2==0 and 64 or 255 end
local function selectedPulse(age)
 -- First ins_57 targets the initial color for60f, then white for60f.
 -- Subsequent loops alternate white and the selection color every60f.
 local t=age-8
 if t<=60 then return 0 end
 local phase=(t-60)%120
 if phase>60 then phase=120-phase end
 return(1-math.cos(phase*math.pi/60))/2
end
function M.choose(index)
 if M.cursor==index and M.lastCursor==index then return end
 M.deselectedAt[M.lastCursor or M.cursor]=M.clock
 M.cursor=index;M.lastCursor=index;M.selectedAt[index]=M.clock
end
function M.open(page)
 M.page=page;M.age=0;M.rank=2;M.player=1
 if page=='replay'then
  M.replays=New(replay_loader,function(filename,stageName)
   if not filename then
    local loader=M.replays
    if not loader then return end
    -- FlyOut ignores locked objects. Own this short exit task so input is
    -- blocked immediately and the replay loader is deleted after sliding out.
    loader.locked=true;task.Clear(loader)
    task.New(loader,function()
     task.MoveTo(screen.width*1.5,loader.y,30,1)
     Del(loader)
    end)
    M.replays=nil;M.switch('title')
   else
    M.replays.locked=true
    M.switch('launch',function()
     C.first=true;C.entry='full';C.complete=false;C.index=0;stage.IsReplay=true
     stage.Set(stageName,'load',filename)
    end)
   end
  end)
  menu.FlyIn(M.replays,'right')
 end
end
function M.move(delta)
 local index=M.cursor
 repeat index=(index-1+delta)%8+1 until M.enabled[index]
 M.choose(index)
 sound('select00')
end
function M.input(key)
 if M.pending then return end
 if M.page=='title'then
  if key=='up'then M.move(-1)
  elseif key=='down'then M.move(1)
  elseif key=='cancel'then
   if M.cursor==8 then sound('ok00');confirmTitle('launch',function()stage.Set('stage.quit','none')end)
   else M.choose(8);sound('cancel00')end
  elseif key=='confirm'then
   if not M.enabled[M.cursor]then return end
   sound('ok00')
   if M.cursor==1 or M.cursor==3 then M.practice=M.cursor==3;confirmTitle('rank')
   elseif M.cursor==4 then confirmTitle('replay')
   elseif M.cursor==5 then confirmTitle('data')
   elseif M.cursor==8 then confirmTitle('launch',function()stage.Set('stage.quit','none')end)end
  end
 elseif M.page=='rank'then
  if key=='cancel'then sound('cancel00');M.switch('title')
  elseif key=='confirm'then sound('ok00');confirmSelection('player',nil,'rank',22)
  elseif key=='up'or key=='down'or key=='left'or key=='right'then sound('invalid')end
 elseif M.page=='player'then
  if key=='left'or key=='right'then sound('invalid')
  elseif key=='cancel'then sound('cancel00');M.switch('rank')
  elseif key=='confirm'then
   sound('ok00')
   if M.practice then M.entryCursor=M.entryCursor or 1;confirmSelection('practice',nil,'player',32)
   else confirmSelection('launch',function()C.load(1,'full')end,'player',32)end
  end
 elseif M.page=='practice'then
  if key=='up'or key=='down'then
   M.entryCursor=(M.entryCursor-1+(key=='up'and-1 or 1))%#M.entries+1;sound('select00')
  elseif key=='left'or key=='right'then
   M.entryCursor=math.max(1,math.min(#M.entries,M.entryCursor+(key=='left'and-12 or 12)));sound('select00')
  elseif key=='cancel'then sound('cancel00');M.switch('player')
  elseif key=='confirm'then
   sound('ok00');local e=M.entries[M.entryCursor]
   M.switch('launch',function()C.load(e.stage,e.key)end)
  end
 elseif M.page=='data'then
  if key=='cancel'or key=='confirm'then sound('cancel00');M.switch('title')end
 end
end

local keys={}
local function input()
 local binds={{'up',setting.keys.up},{'down',setting.keys.down},{'left',setting.keys.left},
  {'right',setting.keys.right},{'confirm',setting.keys.shoot},{'cancel',setting.keys.spell},{'cancel',KEY.ESCAPE}}
 local event
 for _,k in ipairs(binds)do
  local down=GetKeyState(k[2]);local held=keys[k[2]]or 0
  keys[k[2]]=down and held+1 or 0
  local repeatable=k[1]=='up'or k[1]=='down'or k[1]=='left'or k[1]=='right'
  if down and(held==0 or repeatable and held>=24 and held%6==0)then event=event or k[1]end
 end
 if event then M.input(event)end
end

function M.drawPage(page,a,offset)
 local enter=ease(M.age/20);offset=offset or 0
 if page=='title'then
  local logoX,logoY,logoScale=32-32*(1-enter)+offset,200,1
  if M.pending and M.pending.flash then
   local t=ease(math.max(0,(M.pending.age-22)/20))
   logoX=logoX+(12-logoX)*t;logoY=logoY+(400-logoY)*t;logoScale=1-.5*t
  end
  sprite(76,logoX,logoY,255*math.min(1,M.age/20),255,logoScale)
  local spriteIds={0,2,4,6,8,10,14,16}
  for i,id in ipairs(spriteIds)do
   local selected=M.cursor==i
   local age=M.clock-(M.selectedAt[i]or M.clock)
   local lost=M.clock-(M.deselectedAt[i]or-100)
   local active=M.enabled[i]and(selected and ease(age/5)or(1-ease(lost/5)))or 0
   local x=416+(i-1)*8+64*(1-ease((M.age-(i-1)*2)/15))+offset
   local y=144+(i-1)*36
   -- Interrupt7: four 2f moves 0 -> -4 -> -2 -> -7 -> -4.
   local jog=-4
   if age<8 then
    local targets={0,-4,-2,-7,-4};local n=math.min(4,math.floor(age/2)+1)
    jog=targets[n]+(targets[n+1]-targets[n])*ease((age-(n-1)*2)/2)
   end
   x=x+(selected and jog or-4*(1-ease(lost/5)))
   local scale=1
   local pulse=selectedPulse(age)
   local r,g,b=255,math.floor(160+95*pulse),math.floor(160+95*pulse)
   if M.pending and M.pending.flash and selected then
    local f=M.pending.age
    if f<22 then r=math.floor(f/2)%2==0 and 64 or 255;g=r;b=r;active=1
    else
     r,g,b=255,255,255
     local t=ease((f-22)/20);x=x+320*t
    end
   end
   if M.pending and M.pending.flash and not selected then
    x=x+320*ease(math.max(0,(M.pending.age-22)/20))
   end
   sprite(id+1,x,y,a*(1-active))
   if active>0 then
    local img='six.title.'..id
    local blend=''
    SetImageState(img,blend,Color(math.floor(a*active),r,g,b))
    Render(img,x,480-y,0,scale,scale)
   end
  end
 elseif page=='rank'then
  sprite(76,12,400,255,128,.5)
  sprite(79,32-288*(1-enter)+offset,24,a)
  for i=1,4 do
   local x=192+64*(1-enter)+offset;local y=64+(i-1)*100
   if i==2 then
    local age=math.max(0,M.age-17)
    x=x+jog(age)
    local pulse=selectedPulse(age)
    local r,g,b=math.floor(192+63*pulse),255,math.floor(192+63*pulse)
    local scale=1
    if M.pending and M.pending.selection=='rank'then
     local f=M.pending.age
     if f<22 then r=flash(f);g=r;b=r
     else local t=ease((f-22)/20);x=x+(448-x)*t;y=y+(396-y)*t;scale=1-.5*t;r,g,b=255,255,255 end
    end
    sprite(95,x,y,a*(1-ease(age/5)))
    SetImageState('six.title.90','',Color(math.floor(a*ease(age/5)),r,g,b))
    Render('six.title.90',x,480-y,0,scale,scale)
   else
    -- Reuse the native card alpha silhouette, with all old text/colors blacked out.
    local shadow=({89,90,91,92})[i]
    sprite(shadow,x,y,a*.5,0)
    RenderTTF('six.title.question.font','?',x,x+256,480-y-96,480-y,
     Color(math.floor(a),0,0,0),'center','vcenter')
   end
  end
 elseif page=='player'then
  sprite(76,12,400,255,128,.5)
  sprite(90,448,396,255,255,.5)
  sprite(80,32-288*(1-enter)+offset,24,a)
  -- Original script125 parent y=96; script123 info centre x=256, script121 portrait x=384.
  local age=M.age
  local infoX=128-256*(1-ease(age/15))-4*ease((age-15)/4)+offset
  local portraitX=256+jog(age)+offset
  local infoGrey,portraitGrey=255,255
  local infoAlpha,portraitAlpha=a,a*ease(age/5)
  if M.pending and M.pending.selection=='player'then
   local f=M.pending.age
   if f<32 then infoGrey=flash(f)
   else local t=ease((f-32)/20);infoX=infoX+(224+offset-infoX)*t;infoAlpha=infoAlpha*(1-.5*t)end
   if f<30 then portraitGrey=flash(f)
   else local t=ease((f-30)/20);portraitX=portraitX+(352+offset-portraitX)*t end
  end
  sprite(101,infoX,128,infoAlpha,infoGrey)
  sprite(99,portraitX,128,portraitAlpha,portraitGrey)
 elseif page=='practice'then
  sprite(87,32+offset,24,a)
  local first=math.floor((M.entryCursor-1)/12)*12+1
  for i=first,math.min(#M.entries,first+11)do
   local label=(i==M.entryCursor and'▶ 'or'   ')..M.entries[i].label
   words(label,90+offset,90+(i-first)*28,18,math.floor(a*(i==M.entryCursor and 1 or .65)))
  end
 elseif page=='replay'then sprite(82,32+offset,24,a)
 elseif page=='data'then
  sprite(83,32+offset,24,a)
  local scores={};for name,value in pairs(scoredata.hiscore or{})do scores[#scores+1]={tostring(name),value}end
  table.sort(scores,function(a,b)return a[1]<b[1]end)
  words('Normal  /  博丽灵梦',90+offset,100,18,a)
  if #scores==0 then words('—',90+offset,150,18,a)end
  for i=1,math.min(8,#scores)do words(scores[i][1]..'    '..tostring(scores[i][2]),90+offset,140+i*28,18,a)end
 end
end

function stage_menu:init()
 if C.prepareMenu then C.prepareMenu()end
 LoadTTF('six.title.font','assets/font/SourceHanSansCN-Bold.otf',36)
 C.select=false;C.reward=nil;M.pending=nil;M.replays=nil;M.background=0;M.cursor=1;M.practice=false
 keys={};M.clock=0;M.lastCursor=1;M.selectedAt={[1]=0};M.deselectedAt={}
 M.open('title');PlayMusic('six.title.bgm',0.7)
 print('SIX FRONTEND title')
end
function stage_menu:frame()
 M.clock=M.clock+1
 if M.cursor~=M.lastCursor then M.choose(M.cursor)end
 M.age=M.age+1
 local target=M.page~='title'and 1 or 0
 M.background=math.max(0,math.min(1,M.background+(target==1 and 1/60 or-1/60)))
 if M.page~='replay'then input()end
 if M.pending then
  M.pending.age=M.pending.age+1
  if M.pending.age>=M.pending.duration then
   local p=M.pending;M.pending=nil
   if p.action then StopMusic('six.title.bgm');p.action()else M.open(p.page);print('SIX FRONTEND '..p.page)end
  end
 end
 if M.testStep then M.testStep(self)end
end
function stage_menu:render()
 SetViewMode('ui');RenderClear(Color(255,0,0,0))
 sprite(73,0,0);sprite(74,512,0)
 if M.background>0 then
  local shade=math.floor(192+63*math.cos(M.age*math.pi/300))
  sprite(77,0,0,255*M.background,shade);sprite(78,512,0,255*M.background,shade)
 end
 local fade=M.pending and math.max(0,(M.pending.age-(M.pending.flash and 22 or M.pending.flashFrames or 0))/20)or 0
 local alpha=255*(M.pending and(1-fade)or math.min(1,M.age/20))
 M.drawPage(M.page,alpha)
 if M.pending and M.pending.page=='launch'then
  SetImageState('white','',Color(math.floor(255*math.min(1,fade)),0,0,0));RenderRect('white',0,640,0,480)
 end
end
if setting.six_select_loading_test then Include('mod/SixStageCampaign/frontend/test-select-loading.lua')
elseif setting.six_menu_animation_test then Include('mod/SixStageCampaign/frontend/test-animation.lua')
elseif setting.six_menu_test then Include('mod/SixStageCampaign/frontend/test-native.lua')end
