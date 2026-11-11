-- Campaign opening nonspell: HP can advance a segment, never rewind its clock.
function SixStageCampaign.installMarisaSegments(classes)
 local X,R,S=SSGSelected05,SSG,MarisaMixed
 local function live()return X.active and X.mode=='full'and S.phase=='ssg'end
 local function advance(index,early)
  if index<=X.index then return end
  if early then
   for _,list in ipairs({R.bullets,R.beams,R.homing})do
    for _,b in ipairs(list)do b.dead=true end
   end
   -- Remove host collision objects immediately; preserve the body and five bits.
   local pending={}
   for o in pairs(MarisaVisual.owned)do
    if o.data and o.data.dead and IsValid(o)then pending[#pending+1]=o end
   end
   for _,o in ipairs(pending)do
    o.colli=false
    if o.group==GROUP_ENEMY_BULLET then Kill(o)else Del(o)end
   end
  end
  X.index=index
  S.boss.hp=(4-index)*8000
  X.transition(X.sequence[index])
 end
 local start=X.start
 X.start=function(...)
  start(...)
  if X.mode=='full'then X.segmentHP=8000 end
 end
 local step=X.step
 X.step=function(px,py,hp)
  if not live()then return step(px,py,hp)end
  -- The original absolute deadlines stay 1261 and 2581, independent of stageStart.
  local index=1;local deadline=X.lengths[X.sequence[1]]
  while index<#X.sequence and X.clock+1>deadline do
   index=index+1;deadline=deadline+X.lengths[X.sequence[index]]
  end
  if index>X.index then
   X.clock=X.clock+1;advance(index,false);X.clock=X.clock-1
   hp=S.boss.hp
  end
  -- Original step's scheduler sees the already active index, including early entry.
  -- Suppress only its obsolete attempt to return to an earlier segment.
  local transition=X.transition
  local active=X.index
  X.transition=function(id)
   if id~=X.sequence[active]then X.index=active;return end
   return transition(id)
  end
  local result=step(px,py,hp)
  X.transition=transition
  X.index=active
  return result
 end
 for _,class in ipairs(classes)do
  local info=class.init and debug.getinfo(class.init,'S')
  local damage=class.base and class.base.take_damage
  local di=damage and debug.getinfo(damage,'S')
  if info and di and info.source:find('MarisaMixed/root.lua',1,true)
   and di.source:find('MarisaMixed/root.lua',1,true)then
   local init=class.init
   class.init=function(o,...)
    local factory=boss.card.New
    boss.card.New=function(name,t1,t2,t3,hp,...)
     if (setting.marisa_ssg_mode or'full')=='full'and name==''and hp==30000 and t3==X.frames('full')/60 then hp=24000 end
     return factory(name,t1,t2,t3,hp,...)
    end
    init(o,...)
    boss.card.New=factory
   end
   class.base.take_damage=function(o,dmg)
    if not live()or X.index==3 then return damage(o,dmg)end
    local floor=(3-X.index)*8000
    -- Host damage only subtracts HP; reset at the boundary before boss.frame can
    -- end the card. Overkill is discarded, with protection/reduction unchanged.
    damage(o,dmg)
    if o.hp<=floor then advance(X.index+1,true)end
   end
  end
 end
end
