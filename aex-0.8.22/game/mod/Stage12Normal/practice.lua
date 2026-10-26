-- Select a starting point in the existing two-stage group.
local entry=setting.stage12_entry
if not entry then return end
local plans={}
for _,id in ipairs({'s1-start','s1-momiji','s1-non1','s1-context','s1-non2','s1-scale','s2-start','s2-magic','s2-flare','s2-mystia','s2-mz1','s2-mz2','s2-mz3','s2-mz4','s2-mz5'}) do
 plans[id]={stage=id:sub(1,2)=='s1' and 'Misty Lake@Normal' or 'Stage Two@Normal'}
end
local p=assert(plans[entry],'unknown stage12 entry')
Stage12Practice={plans=plans,selected=p}
local pendingStart=false
local oldItemInit=_init_item
_init_item=function(s)
 if pendingStart and s.name==p.stage then
  pendingStart=false
  local normal=lstg.var.is_practice
  -- A direct stage-two start has no previous stage to initialize player data.
  lstg.var.is_practice=true;oldItemInit(s);lstg.var.is_practice=normal
 else oldItemInit(s) end
end
local oldStart=stage.group.Start
stage.group.Start=function(group)
 if group~='Normal' then return oldStart(group) end
 -- Framework initializes player/replay state here; keep normal stage progression.
 pendingStart=true;th14.finished=p.stage=='Stage Two@Normal'
 stage.group.PracticeStart(p.stage)
 lstg.var.is_practice=false
 print('STAGE12 STARTPOINT '..entry)
end
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
-- Opt-in native smoke check for opening entry routing.
if setting.stage12_entry_smoke then
 local oldAfter=AfterFrame
 AfterFrame=function()
  oldAfter()
  local s=stage.current_stage
  if s and s.name==p.stage and s.timer>=720 then
   print('STAGE12 PRACTICE SMOKE '..entry);stage.Set('stage.quit')
  end
 end
end

-- Native overlap test: real collision callbacks, not a forced death flag.
if setting.stage12_invincible_probe then
 local Contact=Class(object,{init=function(o,group,x,y)
  o.group=group;o.layer=LAYER_ENEMY_BULLET;o.x=x;o.y=y;o.a=8;o.b=8;o.bound=false;o.colli=true
 end,render=function()end})
 local oldAfter=AfterFrame
 local targets,life
 AfterFrame=function()
  oldAfter()
  local s=stage.current_stage
  if not s or s.name~=p.stage or not IsValid(player) then return end
  if s.timer==120 then
   player.protect=0;player.stage12IgnoredContacts=0;life=lstg.var.lifeleft
   targets={New(Contact,GROUP_ENEMY_BULLET,player.x,player.y),New(Contact,GROUP_ENEMY_BULLET,160,0),New(Contact,GROUP_ENEMY,player.x,player.y)}
  elseif s.timer==260 then
   if setting.stage12_invincible then
    assert(player.stage12IgnoredContacts>0,'no native contacts')
    assert(player.death==0 and lstg.var.lifeleft==life,'invincible life/death changed')
    for _,o in ipairs(targets) do assert(IsValid(o),'contact or screen clear deleted test object') end
    print('STAGE12 INVINCIBLE NATIVE PASS contacts='..player.stage12IgnoredContacts..' lives='..life..' bullets=2 enemy=1')
   else
    assert(player.stage12IgnoredContacts==0 and player.death==0 and lstg.var.lifeleft==life-1,'unchecked immunity did not restore actual collision death')
    print('STAGE12 VULNERABLE NATIVE PASS life='..life..'->'..lstg.var.lifeleft)
   end
   stage.Set('stage.quit')
  end
 end
end
