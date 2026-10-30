Include('THlib.lua')
Include('player.lua')
Include('power-lock.lua')
Include('runtime.lua');Include('constants.lua');Include('art.lua');Include('sound.lua');Include('road.lua');Include('host.lua')
local R=HSoB5
local Hud=Class(object)
function Hud:init()self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()
 local label=R.finished and 'ROAD COMPLETE' or R.nextAt and 'LIFE +1 / B +1' or 'SECTION '..R.section..' / 3'
 RenderText('menu','HSOB STAGE 5 / NORMAL / '..label,0,-190,0.22,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','HSoB Stage5 Road@Normal',nil,true)
stage.group.DefStageFunc('HSoB Stage5 Road@Normal','init',function(s)
 stage.group.initTask(s,function()
  R.cleanup();New(default_stage_background);New(Hud);R.start(tonumber(setting.hsob5_seed)or 20261030,tonumber(setting.hsob5_from)or 1)
  LoadMusic('hs5.road','art/hsob_5road.ogg',8804862/44100,(8804862-520833)/44100);PlayMusic('hs5.road')
  local limit=setting.hsob5_test and (tonumber(setting.hsob5_test_frames)or 600)or math.huge
  if setting.hsob5_test and setting.hsob5_test_shoot then player_lib.debug_data.keep_shooting=true end
  while not R.finished and R.tick<limit do
   if setting.hsob5_invincible and IsValid(player)then player.protect=1000 end
   local x,y=192,400;if IsValid(player)then x,y=player.x+192,224-player.y end
   R.step(x,y);task.Wait(1)
   if setting.hsob5_test and R.tick==750 then lstg.Snapshot('userdata/snapshot/hsob5-startup.jpg')end
  end
  R.cleanup();print('HSOB5 '..(R.finished and 'COMPLETE'or'TEST END')..' tick='..R.tick..' enemies='..R.counts.enemies..' shots='..R.counts.shots..' beams='..R.counts.beams..' damage='..(R.damage or 0)..' sounds='..(R.soundCount or 0)..' section='..R.section)
  if setting.hsob5_test then task.Wait(30);stage.QuitGame()else task.Wait(120);stage.group.FinishStage()end
 end)
end)
stage.group.DefStageFunc('HSoB Stage5 Road@Normal','del',R.cleanup)
stage_init.frame=function(s)if s.timer==30 then lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal')end end
