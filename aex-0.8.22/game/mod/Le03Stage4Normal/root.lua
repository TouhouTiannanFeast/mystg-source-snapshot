-- LE03 1.21a Stage 4 Normal road, independent playable host.
-- Coordinates from source are 384x448, y-down; renderer maps x-192, 224-y.
Include('THlib.lua')
Include('player.lua')
Include('constants.lua')
Include('movement.lua')
Include('bullet-style.lua')
Include('firing.lua')
Include('runtime.lua')
Include('schedule.lua')

Include('host.lua')
local R=Le03
local clean=Le03Host.clean
local finished=false
local Hud=Class(object)
function Hud:init()self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()RenderText('menu','LE03 / STAGE 4 NORMAL',0,-190,0.24,'centerpoint');RenderText('menu','Arrows / Shift slow / Z shoot / X bomb / Esc',0,-210,0.20,'centerpoint')end

stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','LE03 Stage4@Normal',nil,true)
stage.group.DefStageFunc('LE03 Stage4@Normal','init',function(s)
  stage.group.initTask(s,function()
    clean();finished=false;New(default_stage_background);New(Hud)
    R.start(tonumber(setting.le03_seed)or 20261029)
    local limit=setting.le03_test and (tonumber(setting.le03_test_frames)or 6000) or math.huge
    while R.tick<limit and not R.finished do
      if setting.le03_invincible and IsValid(player)then player.protect=1000 end
      local px,py=192,400;if IsValid(player)then px,py=player.x+192,224-player.y end
      R.step(px,py);task.Wait(1)
    end
    clean();finished=true;print('LE03 NORMAL ROAD '..(R.finished and 'COMPLETE' or 'TEST END')..' ticks='..tostring(R.tick)..' spawned='..R.counts.enemies..' shots='..R.counts.shots..' damage='..R.counts.damage..' defeats='..R.counts.defeats);task.Wait(120)
  end)
end)
stage.group.DefStageFunc('LE03 Stage4@Normal','del',clean)
stage_init.frame=function(s)if s.timer==30 then lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal')end end
if setting.le03_test then
  if setting.le03_test_shoot then player_lib.debug_data.keep_shooting=true end
  local old=FrameFunc;local wait=0
  FrameFunc=function()local signal=old();if finished then wait=wait+1;if wait==60 then stage.QuitGame()end end;return signal end
end
