-- Explicit test-only observer; the normal game never loads this file.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local index=tonumber(setting.six_stage)
if index==1 then dofile('mod/SixStageCampaign/dialogue1/probe.lua')
elseif index==2 and setting.six_mystia_portrait_only then
 local source=C.sourceText
 C.sourceText=function(path)
  local code=source and source(path)
  if path~='mod/Stage12Normal/stage2-run.lua'then return code end
  assert(code)
  local old='for _,e in ipairs(Stage2Schedule) do';local a=assert(code:find(old,1,true))
  return code:sub(1,a-1).."for _,e in ipairs({{t=4964,name='Girl02'}}) do"..code:sub(a+#old)
 end
elseif index==2 then
 local f=assert(io.open('mod/SixStageCampaign/dialogue2/probe.lua','rb'));local code=f:read('*a');f:close()
 code=code:gsub('text=43','text=26'):gsub(';stage.QuitGame%(%)end',';C.reward=nil;stage.QuitGame()end')
 assert(loadstring(code,'@screenplay/test-stage2'))()
elseif index==3 then dofile('mod/SixStageCampaign/probe-dialogue3.lua')
elseif index==4 or index==6 then dofile('mod/SixStageCampaign/dialogue46/probe.lua')
elseif index==5 then
 local source=C.sourceText
 C.sourceText=function(path)
  if path~='mod/HSoBStage5Normal/root.lua'then return source and source(path)end
  local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
  local old='  while not R.finished and R.tick<limit do'
  local a=assert(code:find(old,1,true));return code:sub(1,a-1)..'  R.finished=true;while false do'..code:sub(a+#old)
 end
 local install=C.install
 function C.install(i,classes)
  install(i,classes)
  local after=AfterFrame;local forced={}
  AfterFrame=function(...)
   after(...)
   if IsValid(player)then player.protect=100000 end
   if IsValid(_boss)and _boss.is_combat and _boss.timer>=180 and not forced[_boss.current_card]then
    forced[_boss.current_card]=true;_boss.hp=0
   end
   if C.clearWait then
    for _,key in ipairs({'s5off','s5pre','s5mid','s5post'})do assert(S.played[key],'missing '..key)end
    assert(not S.active and not D.active)
    print('SCREENPLAY5 NATIVE PASS all4seams=true pickup='..C.clearWait);stage.QuitGame()
   end
   assert(stage.current_stage.timer<8000,'Stage5 screenplay probe deadline')
  end
 end
end
local seen,snap={},{}
local revealed=false
local update=D.probeUpdate
D.probeUpdate=function()
 local p=D.pages[D.page]
 if setting.six_mystia_portrait_only and D.which=='s2mystiapre'and p.speaker=='mystia'then
  assert(p.portrait==(p.line==3 and'mystiaspecial'or'mystiahappy'))
  if D.pageAge==8 then C.snapshot='mystia-portrait-'..D.page end
  if D.page==#D.pages and D.pageAge==12 then print('MYSTIA PORTRAITS NATIVE PASS happy/special/happy Aya-field');stage.QuitGame();return end
 end
 if p.text:find('吾乃永远与须臾的公主',1,true)then revealed=true end
 if index<=4 and not revealed then assert(D.art.kaguya=='maskedreimu','inactive protagonist revealed early')end
 assert(IsValid(player)and player.dialog,'script allowed player attack')
 if p.speaker=='kaguya'then
  if p.displayName==''then assert(p.portrait=='maskedreimu'and D.art.kaguya=='maskedreimu')
  else assert(p.displayName=='辉夜'and p.portrait:find('kaguya',1,true)==1)end
 end
 assert(D.which~='s6post'and D.which~='s6midpost'and not D.which:find('ending'),'deleted story displayed')
 local old=seen[D.which]
 if old then assert(stage.current_stage.timer==old+1,'dialogue froze or sped up engine')end
 seen[D.which]=stage.current_stage.timer
 if D.pageAge==8 then
  local wanted=p.paragraph==239 or D.page==1 or p.text:find('吾乃',1,true)or(D.which=='s4post'and p.line==2)or(D.which=='s6kanako'and p.line==3)
  if wanted and not snap[D.which..'-'..D.page]then
   snap[D.which..'-'..D.page]=true;C.snapshot='screenplay-'..index..'-'..D.which..'-'..D.page
  end
 end
 if index==5 and D.which=='s5off'then assert(not HSoB5.bossActive and p.hideOtherPortrait,'offscreen Horou appeared early')end
 if index==5 and D.which=='s5pre'then assert(IsValid(SixStageScreenplay.arrival),'visible Horou vanished during pre-story')end
 if update then update()elseif D.pageAge>=16 then D.advance()end
end
-- Stage3 installs its observer only when its classes import; wrap it afterwards.
if index==3 and setting.six_shion_portrait_only then
 local install=C.install
 function C.install(i,classes)
  install(i,classes)
  local update=D.probeUpdate
  D.probeUpdate=function()
   if D.which=='pre'and D.page==1 then
    if D.pageAge==8 then C.snapshot='shion-portrait-user08'end
    if D.pageAge==12 then
     assert(D.data.art.shion08.file=='art/shion08.png')
     print('SHION PORTRAIT NATIVE PASS user no-hyphen08');stage.QuitGame();return
    end
   end
   return update()
  end
 end
end
