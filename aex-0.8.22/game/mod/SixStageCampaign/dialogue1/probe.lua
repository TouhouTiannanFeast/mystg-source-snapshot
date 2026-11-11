-- Test-only road cuts and forced defeats for the four requested story seams.
local C,D,S,A=SixStageCampaign,SixStageDialogue3,SixStageStory46,SixStageDialogue1
local source=C.sourceText
C.sourceText=function(path)
 local code=source(path)
 if path=='mod/Stage12Normal/stage1/stage.lua'then
  local old="if setting.stage12_entry~='s1-momiji' then front(s) end"
  local a=assert(code:find(old,1,true));code=code:sub(1,a-1)..'-- test skips front road'..code:sub(a+#old)
  a=assert(code:find("    print('TH14 POST-MOMIJI WAVES START",1,true))
  local b=assert(code:find('T.finished=false',a,true))
  code=code:sub(1,a-1)..'end\n'..code:sub(b)
 end
 return code
end
local seen,snaps={},{}
local update=D.probeUpdate
D.probeUpdate=function()
 if not D.which:match('^s1')then if update then update()end;return end
 assert(S.active and player.dialog)
 local last=seen[D.which];if last then assert(stage.current_stage.timer==last+1,'story froze/sped up engine')end
 seen[D.which]=stage.current_stage.timer
 if D.which=='s1open'then assert(not Stage12Background.current,'prologue started after Stage1 background')end
 if D.which=='s1open'or D.which:find('momiji')then assert(D.cast.other=='none'and not D.art.none,'Momiji dialogue acquired a portrait')end
 if D.which=='s1wakapre'and IsValid(_boss)then assert(not _boss.is_combat,'Boss started combat before pre-story ended')end
 if D.pageAge==8 and(D.page==1 or D.page==2 or D.page==#D.pages or(D.which=='s1wakapre'and D.page==9))and not snaps[D.which..D.page]then
  snaps[D.which..D.page]=true;C.snapshot='story1-'..D.which..'-'..D.page
 end
 if D.pageAge>=16 then D.advance()end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=1 then return end
 local forced={};local guideSeen=false;local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  for _,o in ObjList(GROUP_GHOST)do
   if o.class==SixStageCollectLine then
    if D.active and D.which=='s1open'then assert(o.timer<=1,'opening resource guide aged out during prologue')
    elseif o.timer>=60 then guideSeen=true end
   end
  end
  if IsValid(player)then player.protect=100000 end
  if IsValid(_boss)and _boss.is_combat and _boss.timer>=180 and not forced[_boss.current_card]then
   if _boss.th14_phase=='scale'then assert(_boss.maxhp==1080,'anchor HP changed')end
   forced[_boss.current_card]=true;_boss.hp=0
  end
  if C.clearWait then
   for _,key in ipairs({'s1open','s1momijipre','s1momijipost','s1wakapre','s1wakapost'})do assert(S.played[key],'missing '..key)end
   assert(A.finalSeen and guideSeen and not S.active and not D.active,'missing terminal/actual-stage resource guide')
   local n=0;for _ in pairs(forced)do n=n+1 end;assert(n==5,'source Boss card sequence changed')
   assert(player.class.shoot==C.stage12Shoot)
   print('STORY1 NATIVE PASS scenes=5 text=22 prologueBeforeStage=true guidePreserved=true threat=Kaguya momijiPortrait=false anchorHP=1080 pickup='..C.clearWait);stage.QuitGame()
  end
  assert(stage.current_stage.timer<6000,'stage1 story deadline')
 end
end
