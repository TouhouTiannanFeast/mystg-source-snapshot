-- Explicit bounded dialogue/handoff test. Does not change normal game settings.
local C,D,S,A=SixStageCampaign,SixStageDialogue3,SixStageStory46,SixStageDialogue2
local source=C.sourceText
C.sourceText=function(path)
 local code=source(path)
 if path=='mod/Stage12Normal/stage2-run.lua'then
  local old='for _,e in ipairs(Stage2Schedule) do'
  local a=assert(code:find(old,1,true))
  local events=setting.six_story2_patchouli_only and "{{t=1,name='MBossDummy'}}"or "{{t=1,name='MBossDummy'},{t=2,name='Girl02'},{t=3,name='Boss'}}"
  code=code:sub(1,a-1)..'for _,e in ipairs('..events..') do'..code:sub(a+#old)
 end
 return code
end
local last,snaps={},{}
local update=D.probeUpdate
D.probeUpdate=function()
 if not D.which:match('^s2')then if update then update()end;return end
 assert(S.active and player.dialog,'dialogue released player attacks')
 if D.which=='s2hinapre'then assert(IsValid(_boss)and _boss.class==Stage2Flare.Boss and _boss.y<224,'Patchouli dialogue before visible Boss arrival')end
 local old=last[D.which]
 if old then assert(stage.current_stage.timer==old+1,'dialogue paused or accelerated engine')end
 last[D.which]=stage.current_stage.timer
 if D.which~='s2mamizoupost'and _boss and IsValid(_boss)then assert(not _boss.is_combat,'boss attacked during pre-dialogue')end
 if D.pageAge==8 and(D.page==1 or D.page==3 or D.page==#D.pages)and not snaps[D.which..D.page]then
  snaps[D.which..D.page]=true;C.snapshot='story2-'..D.which..'-'..D.page
 end
 if D.pageAge>=16 then D.advance()end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=2 then return end
 local forced,heldTick={},nil
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  if IsValid(player)then player.protect=100000 end
  if setting.six_story2_patchouli_only and IsValid(_boss)and _boss.is_combat then
   assert(S.played.s2hinapre and not S.active,'Patchouli battle before dialogue finished')
   assert(Stage2Flare.state.shots==0,'Patchouli attacked before dialogue exit')
   print('STORY2 NATIVE PASS PatchouliOnly visibleEntry->dialogue->90f->combat');stage.QuitGame();return
  end
  for o in pairs(Stage2Route.owned)do if o.class==Stage2Route.Hina and o.timer>=180 then Del(o)end end
  for o in pairs(Stage2Route.enemies)do if IsValid(o)and o.timer>=60 then Kill(o)end end
  if A.holdMystia then
   if heldTick then assert(Stage2Route.tick==heldTick,'Mystia reinforcements progressed during added story gate')end
   heldTick=Stage2Route.tick
  else heldTick=nil end
  if _boss and IsValid(_boss)and _boss.is_combat and _boss.timer>=180 and not forced[_boss.current_card]then
   forced[_boss.current_card]=true;_boss.hp=0
  end
  if C.clearWait then
   for _,key in ipairs({'s2hinapre','s2mystiapre','s2mamizoupre','s2mamizoupost'})do assert(S.played[key],'missing '..key)end
   assert(not S.active and not D.active)
   local n=0;for _ in pairs(forced)do n=n+1 end;assert(n==2+#Stage2Mamizou.cards,'source card sequence missing')
   assert(player.class.shoot==C.stage12Shoot,'stage2 changed to homing before stage3')
  end
  assert(stage.current_stage.timer<6000,'stage2 story deadline')
 end
end
local frame=FrameFunc
FrameFunc=function(...)
 local r=frame(...)
 if C.reward then
  assert(S.played.s2mamizoupost and not S.active and C.index==2 and C.target==3,'gift/notice handoff wrong')
  if C.reward.age==35 then C.snapshot='story2-yinyang-notice'end
  if C.reward.age>=45 then print('STORY2 NATIVE PASS scenes=4 text=43 clear240=true gift->notice=true purePierce=true');stage.QuitGame()end
 end
 return r
end
