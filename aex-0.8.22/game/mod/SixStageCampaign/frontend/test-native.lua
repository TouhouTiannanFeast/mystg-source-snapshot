-- Opt-in bounded frontend acceptance probe. Never loaded by ordinary launchers.
local C,M=SixStageCampaign,SixStageCampaign.frontend
local phase=0
M.testStep=function(s)
 if phase==0 and M.page=='title'and M.age==90 then
  for _,i in ipairs({3,4,5,8,1})do M.input('down');assert(M.cursor==i,'disabled item was selected')end
  for _,i in ipairs({8,5,4,3,1})do M.input('up');assert(M.cursor==i,'disabled reverse item was selected')end
  C.snapshot='six-th10-title';phase=1
 elseif phase==1 and M.age==100 then M.input('confirm');phase=2
 elseif phase==2 and M.page=='rank'and M.age==70 then
  assert(M.rank==2);M.input('up');M.input('down');assert(M.rank==2)
  C.snapshot='six-th10-rank';phase=3
 elseif phase==3 and M.age==80 then M.input('confirm');phase=4
 elseif phase==4 and M.page=='player'and M.age==70 then
  M.input('left');M.input('right');assert(M.player==1)
  C.snapshot='six-th10-player';phase=5
 elseif phase==5 and M.age==80 then M.input('cancel');phase=6
 elseif phase==6 and M.page=='rank'and M.age==30 then M.input('confirm');phase=7
 elseif phase==7 and M.page=='player'and M.age==30 then
  M.input('confirm');assert(M.pending.page=='launch','weapon page inserted');phase=8
 elseif phase==9 and M.page=='title'and M.age==70 then
  assert(C.index==0);M.input('down');M.input('confirm');phase=10
 elseif phase==10 and M.page=='rank'and M.age==30 then M.input('confirm');phase=11
 elseif phase==11 and M.page=='player'and M.age==30 then M.input('confirm');phase=12
 elseif phase==12 and M.page=='practice'and M.age==40 then
  local front,back
  for i,e in ipairs(M.entries)do
   if e.stage==3 and e.key=='road-front'then front=i end
   if e.stage==3 and e.key=='road-back'then back=i end
   assert(not e.key:match('^road%-%d'),'old wave selector reappeared')
  end
  assert(front and back);M.entryCursor=back;C.snapshot='six-th10-practice';phase=13
 elseif phase==13 and M.age==50 then M.input('cancel');phase=14
 elseif phase==14 and M.page=='player'and M.age==30 then M.input('cancel');phase=15
 elseif phase==15 and M.page=='rank'and M.age==30 then M.input('cancel');phase=16
 elseif phase==16 and M.page=='title'and M.age==30 then
  M.cursor=4;M.input('confirm');phase=17
 elseif phase==17 and M.page=='replay'and M.age==50 then
  assert(M.replays and not M.replays.locked);M.replays.exitCallback();phase=18
 elseif phase==18 and M.page=='title'and M.age==30 then M.cursor=5;M.input('confirm');phase=19
 elseif phase==19 and M.page=='data'and M.age==30 then M.input('cancel');phase=20
 elseif phase==20 and M.page=='title'and M.age==30 then
  print('SIX FRONTEND PASS title/rank/player locks, skip/confirm/cancel, no weapon, stage launch/return, practice/replay/data')
  stage.QuitGame()
 end
end
local frame=FrameFunc
FrameFunc=function(...)
 local args={...}
 local result
 local ok,err=xpcall(function()
  result=frame(unpack(args))
  if phase==8 and C.index==1 and stage.current_stage.timer>=120 then
   assert(IsValid(player),'frontend did not reach actual gameplay')
   assert(lstg.var.power==400,'frontend changed shot power')
   print('SIX FRONTEND GAMEPLAY PASS '..tostring(lstg.var.player_name))
   phase=9;stage.Set('menu','none')
  end
 end,debug.traceback)
 if not ok then print('SIX FRONTEND ERROR '..tostring(err));stage.QuitGame()end
 return result
end
local render=RenderFunc
RenderFunc=function(...)
 local args={...};local ok,err=xpcall(function()render(unpack(args))end,debug.traceback)
 if not ok then print('SIX FRONTEND ERROR '..tostring(err));stage.QuitGame()end
end
