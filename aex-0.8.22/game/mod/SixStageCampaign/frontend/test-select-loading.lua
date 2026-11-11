-- Opt-in bounded acceptance of rank/player animations and real loading handoff.
local C,M=SixStageCampaign,SixStageCampaign.frontend
local step=0
M.testStep=function()
 if step==0 and M.page=='title'and M.age==80 then C.snapshot='six-pink-title';step=1
 elseif step==1 and M.age==90 then M.input('confirm');step=2
 elseif step==2 and M.page=='rank'and M.age==5 then C.snapshot='six-rank-enter';step=3
 elseif step==3 and M.page=='rank'and M.age==70 then C.snapshot='six-rank-selected';step=4
 elseif step==4 and M.age==80 then M.input('confirm');step=5
 elseif step==5 and M.pending and M.pending.age==2 then C.snapshot='six-rank-confirm-white';step=6
 elseif step==6 and M.pending and M.pending.age==4 then C.snapshot='six-rank-confirm-grey';step=7
 elseif step==7 and M.page=='player'and M.age==4 then C.snapshot='six-player-enter';step=8
 elseif step==8 and M.page=='player'and M.age==70 then C.snapshot='six-player-selected';step=9
 elseif step==9 and M.age==80 then M.input('confirm');step=10
 elseif step==10 and M.pending and M.pending.age==2 then C.snapshot='six-player-confirm-white';step=11
 elseif step==11 and M.pending and M.pending.age==4 then C.snapshot='six-player-confirm-grey';step=12
 end
end
local frame=FrameFunc
FrameFunc=function(...)
 local args={...};local result
 local ok,err=xpcall(function()
  result=frame(unpack(args))
  local name=stage.current_stage.stage_name
  if step==12 and name=='SixStageLoading'and stage.current_stage.age>=30 then
   assert(C.index==0 and C.frontLoading,'game started before loading')
   C.snapshot='six-girl-praying';step=13
  elseif step==13 and C.index==1 and stage.current_stage.timer>=120 then
   assert(not C.frontLoading and IsValid(player)and lstg.var.power==400)
   print('SIX SELECT LOADING PASS original menu animations, presented loading, real source import ready before gameplay')
   C.snapshot='six-after-loading';step=14
  elseif step==14 then stage.QuitGame()end
 end,debug.traceback)
 if not ok then print('SIX SELECT LOADING ERROR '..tostring(err));stage.QuitGame()end
 return result
end
local render=RenderFunc
RenderFunc=function(...)
 local args={...};local ok,err=xpcall(function()render(unpack(args))end,debug.traceback)
 if not ok then print('SIX SELECT LOADING ERROR '..tostring(err));stage.QuitGame()end
end
