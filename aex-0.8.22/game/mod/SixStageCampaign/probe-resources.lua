-- Opt-in bounded developer observer; absent from ordinary play.
local C,B=SixStageCampaign,SixStageCampaignRoadBonus
local install=C.install
function C.install(i,classes)
 install(i,classes)
 local mode=setting.six_resource_probe
 local ended,forced,homed,observed
 local sound=PlaySound
 PlaySound=function(n,...)
  if n=='six.anchor.impact'then C.anchorSoundProbe=true end
  return sound(n,...)
 end
 local drop=B.drop
 B.drop=function(life,bomb,...)
  local result=drop(life,bomb,...)
  print('RESOURCE PROBE DROP '..mode..' life='..life..' bomb='..bomb)
  local expected=({stage2={0,1},marisa={1,0},horou={0,3},nina={1,0}})[mode]
  if expected then
   assert(life==expected[1]and bomb==expected[2],'unexpected actual phase payout')
   observed=true;ended=stage.current_stage.timer+30
  end
  return result
 end
 if mode=='opening'then
  for _,class in ipairs({item_extend,item_bomb})do
   local frame=class.frame
   class.frame=function(o,...)
    local result=frame(o,...)
    if o.resourceProbe then
     if o.timer==59 then assert(o.attract==0,'resource attracted early')end
     if o.timer==60 then
      assert(o.attract==8 and o.target==player,'resource did not auto-attract')
      homed=(homed or 0)+1;print('RESOURCE AUTO60 PASS '..o.resourceProbe)
     end
    end
    return result
   end
  end
 end
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  local t=stage.current_stage.timer
  if IsValid(player)then player.protect=100000 end
  for _,o in ObjList(GROUP_ITEM)do assert(o.class~=item_chip and o.class~=item_bombchip,'fragment spawned')end
  assert((lstg.var.chip or 0)==0 and(lstg.var.bombchip or 0)==0)
  if mode=='opening'then
   if t==30 then
    for j,class in ipairs({item_extend,item_bomb})do local o=New(class,-130+(j-1)*260,100);o.resourceProbe=j end
   end
   if t==110 then
    assert(homed==2,'missing60f pickup checks')
    C.snapshot='resources-opening';ended=t+30
   end
  elseif mode=='anchor'and Stage1Anchor.state.stats.impacts and Stage1Anchor.state.stats.impacts>0 and not ended then
   local s=lstg.tmpvar._G_shaker
   assert(s and s.size==2 and C.anchorSoundProbe,'anchor source shake/audio missing')
   print('RESOURCE ANCHOR PASS time='..s.time..' size='..s.size)
   C.snapshot='resources-anchor';ended=t+30
  elseif not forced and t>=350 and IsValid(_boss)then
   if mode=='stage2'and Stage2Mamizou.state.phase==2 then _boss.hp=0;forced=true
   elseif mode=='marisa'and MarisaMixed.phase=='final'then
    assert(_boss.maxhp==12000);_boss.hp=0;forced=true
   elseif mode=='horou'and Zuu4Stage.current=='final'then _boss.hp=0;forced=true
   elseif mode=='nina'and NinaState.current=='non3'then _boss.hp=0;forced=true end
  end
  if ended and t==ended-8 then C.snapshot='resources-'..mode end
  if ended and t>=ended then
   if mode~='opening'and mode~='anchor'then assert(observed,'no payout observed')end
   print('RESOURCE NATIVE PASS '..mode);stage.QuitGame()
  end
  if t>4000 then error('resource probe deadline '..mode)end
 end
end
