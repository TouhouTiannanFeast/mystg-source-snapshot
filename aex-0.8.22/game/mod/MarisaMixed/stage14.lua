-- Private assembly: current TH18 road -> existing rabbit duo -> current Marisa.
Include('road/pool.lua');Include('road/data.lua');Include('road/anm.lua')
Include('road/runtime.lua');Include('road/projectiles.lua');Include('road/programs.lua')
Include('road/route.lua');Include('road/background.lua');Include('road/host.lua')
Include('rabbit/host.lua')
MarisaRoad14={state={phase='none',frame=0},delay=120}
local C,H,R,B=MarisaRoad14,Th18Stage5Host,Th18Stage5Runtime,Th18Stage5Background
function C.empty()
 for _,a in ipairs(R.actors)do if not a.dead and not a.controller then return false end end
 for _,b in ipairs(R.hazards)do if not b.dead then return false end end
 return #R.cancelWaves==0
end
function C.cleanup()MarisaMusic14.stopRoad();MarisaRabbit14.clean();H.cleanup();C.state.phase='none'end
function C.run()
 MarisaMusic14.startRoad()
 C.state={phase='front',frame=0,wait=0,testCuts={}};local s=C.state
 local probe=setting.marisa_test and setting.marisa_road_test or nil
 local bg=New(B.Object);C.background=bg;B.armMidboss(bg.state)
 H.begin(tonumber(setting.marisa_seed)or 20261106)
 local function step()
  H.step();s.frame=s.frame+1
  if(setting.marisa_test or setting.marisa_invincible)and IsValid(player)then player.protect=1000 end
  if probe=='mid'and s.rabbit and IsValid(s.rabbit)then
   local rs=MarisaRabbit14.state;local w=rs.world
   if w and s.frame%60==0 then print('MARISA14 PROBE '..rs.phase..' t='..w.t..' hp='..s.rabbit.hp..' tick='..s.frame)end
   if w and not s.testCuts[rs.phase]and((rs.phase=='nonspell'and w.t>=120)or(rs.phase=='spell'and w.t>=160))then s.testCuts[rs.phase]=true;s.rabbit.hp=0 end
  end
  task.Wait(1)
 end
 if not probe then
  R.run('MainFront');while not R.idle()do step()end
 end
 -- Same front-to-mid clear as the existing stage; no pyramid is ever spawned.
 R.command(R.controller,{i={},f={}},'enmKillAll',{})
 R.command(R.controller,{i={},f={}},'etClear',{640})
 B.beginValley(bg.state)
 if probe~='tail'then
  s.phase='rabbit';setting.rs_practice='all';MarisaRabbit14.state.ended=0
  ran:Seed(tonumber(setting.rs_seed)or 20261102)
  s.rabbit=New(MarisaRabbit14.Boss)
  print('MARISA14 RABBIT START')
  while IsValid(s.rabbit)do step()end
  assert(MarisaRabbit14.state.ended==2,'rabbit two-card sequence incomplete')
  print('MARISA14 RABBIT COMPLETE cards=2')
  if probe=='mid'then print('MARISA14 MID PASS');stage.QuitGame();task.Wait(99999);return end
 end
 s.phase='latter';R.run(probe=='tail'and'MainSub07'or'MainLatter')
 while not R.idle()do step()end
 s.phase='drain';s.routeEnd=s.frame
 -- Keep stepping the live source actors/projectiles until their natural exits.
 while not C.empty()do step()end
 s.clearFrame=s.frame;s.phase='wait'
 print('MARISA14 ROAD EMPTY frame='..s.frame..' tick='..R.tick)
 for i=1,C.delay do step();s.wait=i;assert(C.empty(),'route spawned after final drain')end
 s.entryFrame=s.frame;s.phase='entry'
 assert(s.entryFrame-s.clearFrame==120,'entry gap must be exactly120 frames')
 print('MARISA14 ENTRY GAP '..(s.entryFrame-s.clearFrame))
 -- The boss STD label resets camera Y; carry the existing scroll phase across it.
 local scenery=bg.state
 local oldY=scenery.std.values.pos[2]+(scenery.scrollOffset or 0)
 local oldRock,oldRockTime=scenery.rock,scenery.rockTime
 B.interrupt(scenery,1)
 scenery.scrollOffset=oldY-scenery.std.values.pos[2]
 if scenery.rock==oldRock then scenery.rockTime=oldRockTime end
end
if setting.marisa_test and setting.marisa_road_test then
 local render=RenderFunc;local captured={}
 RenderFunc=function()
  render();local s=C.state;local rs=MarisaRabbit14.state;local w=rs.world
  local key
  if s.phase=='rabbit'and w then
   if rs.phase=='nonspell'and w.t>=80 then key='rabbit-nonspell'
   elseif rs.phase=='spell'and w.dialogue then key='rabbit-dialogue-'..w.dialogue
   elseif rs.phase=='spell'and w.t>=140 then key='rabbit-hammer'end
  elseif s.phase=='latter'and R.tick>=240 then key='last-wave'
  elseif s.phase=='wait'and s.wait>=119 then key='boss-before'
  elseif s.phase=='entry'then key='boss-entry'
  elseif s.phase=='wait'then key='empty-wait'end
  if key and not captured[key]then captured[key]=true;local p='userdata/snapshot/marisa-stage14-'..key..'.jpg';lstg.Snapshot(p);print('MARISA SNAPSHOT '..p)end
 end
end
