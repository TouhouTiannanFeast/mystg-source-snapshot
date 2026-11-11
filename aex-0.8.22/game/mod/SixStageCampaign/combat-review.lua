-- Scoped campaign fixes; standalone source mods retain their own behavior.
local C=SixStageCampaign
local function marisa(classes)
 local T=th08s4
 T.phase_specs.milky.hp=12000
 for _,class in ipairs(classes)do
  local info=class.frame and debug.getinfo(class.frame,'S')
  if info and info.source:find('MarisaMixed/root.lua',1,true)then
   local init=class.init
   class.init=function(o,...)
    init(o,...)
    for _,card in ipairs(o.cards)do
     if card.name=='Love Sign / Master Spark'then card.hp=12000 end
     if card.name=='彗星「Blazing Star」'then card.t1=card.t3;card.t2=card.t3 end
    end
    -- Direct Milky practice uses the common entry card's landing position.
    -- Return there after Stardust, before the adjacent nonspell is initialized.
    local entry=o.cards[1]
    for j,card in ipairs(o.cards)do
     if j>=4 and card.name=='Magic Sign / Milky Way'then
      local previous=o.cards[j-2]
      previous.after=function()task.MoveTo(entry.x,entry.y,entry.t,entry.m)end
     end
    end
   end
   local damage=class.base.take_damage
   class.base.take_damage=function(o,...)
    -- The private source reapplies dmg_factor; protect the real damage dispatch.
    if o.time_sc then return end
    return damage(o,...)
   end
  end
 end
 local frame=T.Beam.frame
 T.Beam.frame=function(o,...)
  local result=frame(o,...)
  if o.spark then o.layer=LAYER_ENEMY_BULLET-1 end
  return result
 end
 local order={'ssg','stardust','non1','milky','non3','comet','final'}
 local from
 for i,id in ipairs(order)do if id==setting.marisa_phase then from=i end end
 if not from then return end
 for _,class in ipairs(classes)do
  local damage=class.base and class.base.take_damage
  -- The opening HP adapter wraps the private Boss init/damage first; its base
  -- still identifies the source through the inherited Marisa frame callback.
  local fi=class.frame and debug.getinfo(class.frame,'S')
  if fi and fi.source:find('MarisaMixed/root.lua',1,true)and damage then
   local init=class.init
   class.init=function(o,...)
    local selected=setting.marisa_phase
    setting.marisa_phase='all'
    local original=boss.init
    boss.init=function(b,x,y,name,cards,...)
     local suffix={cards[1]} -- original entry movement
     for j=from+1,#cards do suffix[#suffix+1]=cards[j]end
     return original(b,x,y,name,suffix,...)
    end
    init(o,...)
    boss.init=original;setting.marisa_phase=selected
   end
  end
 end
end

local function horou()
 local R=Zuu4R
 local fx=R.fx
 if fx then
  local birdTail=fx.birdTail
  fx.birdTail=function(...)
   local first=#fx.items+1
   birdTail(...)
   -- DrawBirdOption2 emits one fading sprite every8f, without an extra ring.
   for j=#fx.items,first,-1 do
    if fx.items[j].kind=='birdRing'then table.remove(fx.items,j)end
   end
  end
 end
 local projectileStep=R.projectileStep
 R.projectileStep=function(b,...)
  if R.id=='final'and b.id==636 then b.life=30;b.fadeStart=nil end
  return projectileStep(b,...)
 end
 -- THlib respawn deletes GROUP_ENEMY_BULLET without consulting SpellResist.
 -- Source final retains the sun/notes/birds/lasers; only rage feather548 is erased.
 local frame=bullet_deleter.frame
 bullet_deleter.frame=function(o,...)
  if R.id~='final'or not Zuu4Stage or Zuu4Stage.current~='final'or o.kill_indes then return frame(o,...)end
  if o.timer==60 then Del(o)end
  for _,native in ObjList(GROUP_ENEMY_BULLET)do
   local b=native.data
   if b and b.id==548 and Dist(o,native)<o.timer*20 then
    R.erase(b);native.colli=false;Del(native)
   end
  end
 end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i==4 then marisa(classes)end
 if i==5 then horou();C.installRoadAudio()end
end
Include('mod/SixStageCampaign/road-audio.lua')
