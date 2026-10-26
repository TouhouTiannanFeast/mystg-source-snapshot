Include('THlib.lua')
Include('player.lua')
Include('music.lua')
Include('unified-assets.lua')
Include('character-animation.lua')
Include('background.lua')
Include('stage1/host.lua')
Include('stage1/enemies.lua')
Include('stage1/momiji-pattern.lua')
Include('stage1/momiji.lua')
Include('stage1/context.lua')
Include('stage1/anchor.lua')
Include('stage1/boss.lua')
Include('stage1/stage.lua')
Include('stage2-run.lua')
Include('unified-bind.lua')
Include('balance-probe.lua')
Include('player-probe.lua')
if not setting.stage12_context_only then
stage.group.AddStage('Normal','Stage Two@Normal',nil,true)
stage.group.DefStageFunc('Stage Two@Normal','init',function(s)
 if setting.stage12_test and not setting.stage12_entry then
  assert(Stage12Carry,'missing stage-one handoff')
  for k,v in pairs(Stage12Carry) do assert(lstg.var[k]==v,'resource reset at transition: '..k) end
  assert(next(th14.owned)==nil and next(Stage1Momiji.state.owned)==nil and next(Stage1Context.state.owned)==nil,'stage-one hazards survived')
  print('STAGE12 RESOURCE/CLEANUP HANDOFF PASS')
 end
 Stage2Route.finished=false
 stage.group.initTask(s,function() Stage2FullRun(s) end)
end)
stage.group.DefStageFunc('Stage Two@Normal','del',Stage2FullAPI.clean)
else Stage2Route.finished=true end
local oldDel=stage.stages['Misty Lake@Normal'].del
stage.stages['Misty Lake@Normal'].del=function(s)
 if setting.stage12_test then
  Stage12Carry={}
  for _,k in ipairs({'lifeleft','bomb','power','score','graze'}) do Stage12Carry[k]=lstg.var[k] end
 end
 oldDel(s)
end
local Field=Class(object)
function Field:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY_BULLET-1,false,false end
function Field:render() Stage1Context.render() end
local oldInit=stage.stages['Misty Lake@Normal'].init
stage.stages['Misty Lake@Normal'].init=function(s) oldInit(s);New(Field) end
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
local previousAfter=AfterFrame
AfterFrame=function()
 previousAfter()
 local st=stage.current_stage
 if st and st.name=='Misty Lake@Normal' then th14.stage_frames=th14.stage_frames+1 end
 if setting.stage12_test and IsValid(player) then
  player.protect=1000
  if setting.stage12_fire and _boss and IsValid(_boss) and _boss.th14_phase and _boss.__card_timer==300 then
   local hp=({momiji=800,non1=700,context=1000,non2=700,scale=800})[_boss.th14_phase]
   assert(_boss.hp<hp,'real primary shot did not damage '.._boss.th14_phase)
   print('STAGE12 REAL SHOT PASS '.._boss.th14_phase..' hp='.._boss.hp)
  end
  if setting.stage12_kill and _boss and IsValid(_boss) and _boss.is_combat and _boss.__card_timer>300 then _boss.hp=0 end
 end
end
if setting.stage12_fire then player_lib.debug_data.keep_shooting=true end
if setting.stage12_test then
 local previousFrame=DoFrame
 DoFrame=function(...) for i=1,8 do previousFrame(...) end end
 local previousMenu=stage_menu.frame
 stage_menu.frame=function(s)
  previousMenu(s)
  if th14.finished and Stage2Route.finished and s.timer>=30 then print('STAGE12 COMPLETE');stage.Set('stage.quit') end
 end
 local seen={}
 local previousRender=RenderFunc
 RenderFunc=function()
  previousRender()
  local st=stage.current_stage;local phase=st and st.name or 'menu'
  if _boss and IsValid(_boss) and _boss.__card_timer>240 then phase=phase..'/'..(_boss.th14_phase or Stage2Route.phase) end
  if not seen[phase] then
   seen[phase]=true
   local path='userdata/snapshot/stage12-'..tostring(#Stage12Captures+1)..'.jpg'
   Stage12Captures[#Stage12Captures+1]=path;lstg.Snapshot(path);print('STAGE12 SNAPSHOT '..path..' '..phase)
  end
 end
end
Stage12Captures={}


Include('practice.lua')
