-- Explicit bounded presentation/ordering check, not an ordinary gameplay path.
local C,D=SixStageCampaign,SixStageDialogue3
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=3 then return end
 local road,forced={},{}
 local snap={}
 local live
 D.probeUpdate=function()
  if not D.active then live=nil;return end
  if live and live.which==D.which then
   assert(stage.current_stage.timer==live.timer+1 and player.timer>live.playerTimer,'dialogue paused engine or sped up simulation')
  end
  live={which=D.which,timer=stage.current_stage.timer,playerTimer=player.timer}
  assert(player.dialog,'dialogue allowed player attacks')
  if D.which=='pre'then
   assert(IsValid(D.entrance)and not D.spawned,'missing visible entrance or premature Boss combat')
   if D.roadEndTick then assert(D.flightStartTick-D.roadEndTick==60,'road-to-flight gap is not60f')end
   assert(D.preStartTick-D.flightStartTick==60,'original flight duration changed')
   for _,o in ObjList(GROUP_PLAYER_BULLET)do error('player shot during noncombat dialogue')end
  end
  local key=D.which..'-'..D.page
  if D.pageAge==20 and not snap[key]then
   snap[key]=true
   if D.page==1 or(D.which=='pre'and(D.page==2 or D.page==8))or D.page==#D.pages then C.snapshot='dialogue3-'..key end
  end
  if D.pageAge>=32 then D.advance()end
 end
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  player_lib.debug_data.keep_shooting=true
  if IsValid(player)then player.protect=100000 end
  if Y3Road and Y3Road.active and Le03.tick>=16 and not road.stopped then
   road.stopped=true;Le03.finished=true
  end
  if not D.active and D.spawned and IsValid(_boss)and _boss.name=='死宛'and _boss.is_combat and _boss.timer>=180 and not forced[_boss.current_card]then
   if D.preDone then assert(D.combatTick-D.preEndTick==90,'dialogue-to-non1 gap is not90f')end
   forced[_boss.current_card]=true;_boss.hp=0
  end
  if D.postDone and C.clearWait then
   assert((not D.preEnabled or D.preDone)and D.spawned and C.clearWait<=240,'missing dialogue/clear-window ordering')
   local expected=setting.y3_practice=='spell3'and 1 or 6
   local n=0;for _ in pairs(forced)do n=n+1 end;assert(n==expected,'source Boss card sequence changed')
   print('DIALOGUE3 NATIVE PASS entry='..setting.y3_practice..' live=true pre='..tostring(D.preDone)..' post='..#D.data.post..' cards='..n..' pickup='..C.clearWait)
   stage.QuitGame()
  end
  if stage.current_stage.timer>3000 then error('dialogue3 probe deadline')end
 end
end
