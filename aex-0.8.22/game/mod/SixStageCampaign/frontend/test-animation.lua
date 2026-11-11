-- Opt-in, menu-only screenshots of actual rendered selection and confirmation.
local C,M=SixStageCampaign,SixStageCampaign.frontend
local step=0
M.testStep=function()
 if step==0 and M.clock==80 then C.snapshot='six-title-idle';step=1
 elseif step==1 and M.clock==90 then M.input('down');assert(M.cursor==3);step=2
 elseif step==2 and M.clock==92 then C.snapshot='six-title-jog';step=3
 elseif step==3 and M.clock==100 then C.snapshot='six-title-selected';step=4
 elseif step==4 and M.clock==110 then M.input('confirm');step=5
 elseif step==5 and M.pending and M.pending.age==2 then C.snapshot='six-title-confirm-white';step=6
 elseif step==6 and M.pending and M.pending.age==4 then C.snapshot='six-title-confirm-grey';step=7
 elseif step==7 and M.page=='rank'and M.age==80 then
  C.snapshot='six-rank-black-locks';step=8
 elseif step==8 then
  print('SIX MENU ANIMATION PASS selected jog/color, Z flash, black rank silhouettes and MS Gothic question glyph')
  stage.QuitGame()
 end
end
local frame=FrameFunc
FrameFunc=function(...)
 local args={...};local result
 local ok,err=xpcall(function()result=frame(unpack(args))end,debug.traceback)
 if not ok then print('SIX MENU ANIMATION ERROR '..tostring(err));stage.QuitGame()end
 return result
end
local render=RenderFunc
RenderFunc=function(...)
 local args={...};local ok,err=xpcall(function()render(unpack(args))end,debug.traceback)
 if not ok then print('SIX MENU ANIMATION ERROR '..tostring(err));stage.QuitGame()end
end
