-- Test-only bounded original-trigger observations; never enabled in ordinary play.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local laugh=S.randomLaugh
S.randomLaugh=function()
 assert(not D.active and not S.active,'voice-only battle laugh displayed dialogue')
 return laugh()
end
local transform=C.sourceText
C.sourceText=function(path)
 local code=transform(path)
 if path=='mod/MarisaMixed/stage14.lua'then
  code=assert(code):gsub('if not probe then','if false then',1)
  local old="s.phase='latter';R.run(probe=='tail'and'MainSub07'or'MainLatter')\n while not R.idle()do step()end"
  local a=assert(code:find(old,1,true));code=code:sub(1,a-1).."s.phase='latter'"..code:sub(a+#old)
 end
 return code
end
local snaps,seen={},{}
local priorUpdate=D.probeUpdate
D.probeUpdate=function()
 if not D.scene then if priorUpdate then priorUpdate()end;return end
 assert(S.active and player.dialog,'story released attack gate')
 local key=D.which
 if seen[key]then assert(stage.current_stage.timer==seen[key]+1,'story paused or accelerated engine')end
 seen[key]=stage.current_stage.timer
 if D.pageAge==8 and not snaps[key..D.page]then
  snaps[key..D.page]=true
  if D.page==1 or D.page==#D.pages or((D.which=='s6kanako'or D.which=='s4rabbitpre')and D.page==2)or(D.which=='s4pre'and D.page==3)or(D.which=='s6pre'and D.page==4)then C.snapshot='story46-'..key..'-'..D.page end
 end
 if D.pageAge>=16 then D.advance()end
 if setting.six_story46_portrait_probe and D.which=='s6pre'and D.page==4 and D.pageAge==12 then
  assert(D.art.fakesanae=='fakesanaeno'and S.data.art.fakesanaeno.layers[1].file=='art/watari-nina-bs.png')
  print('STORY46 NATIVE PASS portraitOnly=WatariNina_EX source=st07enm');stage.QuitGame()
 end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 local forced={}
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  if IsValid(player)then player.protect=100000 end
  if i==4 then
   local rs=MarisaRabbit14 and MarisaRabbit14.state
   if rs and rs.world and _boss and IsValid(_boss)and _boss.is_combat and not S.active and rs.world.t>=120 and not forced[_boss.current_card]then
    forced[_boss.current_card]=true;_boss.hp=0
   end
   if MarisaMixed and MarisaMixed.boss and IsValid(MarisaMixed.boss)and MarisaMixed.boss.is_combat and not S.active and MarisaMixed.age>=180 and not forced[MarisaMixed.boss.current_card]then
    forced[MarisaMixed.boss.current_card]=true;MarisaMixed.boss.hp=0
   end
  else
   local h=TH11S6Host
   if h.midboss and IsValid(h.midboss)and h.midboss.is_combat and not S.active and h.midboss.timer>=180 and not forced[h.midboss.current_card]then
    forced[h.midboss.current_card]=true;h.midboss.hp=0
   end
   if S.played.s6midpost and not S.active and NinaRoad17.active then TH11S6Runtime.roadEnd=true end
   if NinaState and NinaState.runtime and _boss and IsValid(_boss)and _boss.is_combat and not S.active and _boss.timer>=180 and not forced[_boss.current_card]then
    forced[_boss.current_card]=true;_boss.hp=0
   end
  end
  if C.clearWait then
   local required=i==4 and{'s4rabbitpre','s4rabbitpost','s4pre','s4post'}or{'s6open','s6midpre','s6midpost','s6pre','s6battle','s6post','s6kanako'}
   for _,key in ipairs(required)do assert(S.played[key],'missing scene '..key)end
   assert(not S.active,'clear window started before dialogue ended')
   if i==6 then assert(#S.voices==2 and S.voices[1]==1 and S.voices[2]>=1 and S.voices[2]<=4,'missing/duplicate opening or battle laugh')end
   print('STORY46 NATIVE PASS stage='..i..' scenes='..#required..' pickup='..C.clearWait)
   stage.QuitGame()
  end
  assert(stage.current_stage.timer<20000,'story probe deadline')
 end
end
