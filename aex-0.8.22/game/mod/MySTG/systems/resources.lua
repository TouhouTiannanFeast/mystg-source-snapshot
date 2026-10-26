Include('systems/resource-config.lua')
MyResources={}
local R,C=MyResources,MyResourceConfig
function R.enabled() return C.enabled end
function R.state()
 local v=lstg.var
 v.my_resources=v.my_resources or {coins=0,cards={}}
 return v.my_resources
end
-- Cards store IDs only, so run state is replay/save serializable.
R.cards={tap_shot={name='Tap shot',rules={shoot_mode='press'}}}
function R.has(id) return R.state().cards[id]==true end
function R.equip(id)
 assert(R.cards[id],'unknown card: '..tostring(id))
 R.state().cards[id]=true
end
function R.remove(id) R.state().cards[id]=nil end
function R.rule(key,default)
 -- Sorted IDs make future conflicting rule overrides deterministic.
 local ids={};for id,held in pairs(R.state().cards) do if held then ids[#ids+1]=id end end
 table.sort(ids)
 for _,id in ipairs(ids) do
  local card=R.cards[id]
  if card and card.rules and card.rules[key]~=nil then default=card.rules[key] end
 end
 return default
end
local init=item.PlayerInit
function item.PlayerInit(...)
 init(...)
 if C.enabled then
  lstg.var.my_resources={coins=0,cards={}}
  for _,id in ipairs(C.starting_cards) do R.equip(id) end
 end
end
-- Coin art uses the existing item sprite tinted gold; no source art replaced.
LoadImage('my.coin','item',32,32,32,32,8,8)
LoadImage('my.coin.up','item',96,32,32,32)
LoadImage('my.yellow','item',32,32,32,32,8,8)
LoadImage('my.yellow.up','item',96,32,32,32)
for _,name in ipairs({'my.coin','my.coin.up','my.yellow','my.yellow.up'}) do
 SetImageState(name,'',Color(255,255,215,48))
end
-- Keep the original classes/physics/drop tables; replace presentation/rewards.
for _,class in ipairs({item_point,item_faith,item_faith_minor}) do
 local oldInit,oldCollect=class.init,class.collect
 local minor=class==item_faith_minor
 class.init=function(self,...)
  oldInit(self,...)
  if C.enabled then
   self.img=minor and 'my.yellow' or 'my.coin'
   self.imgup=minor and 'my.yellow.up' or 'my.coin.up'
   if minor then self.hscale,self.vscale=0.4,0.4 end
  end
 end
 class.collect=function(self,...)
  if not C.enabled then return oldCollect(self,...) end
  if minor then lstg.var.score=lstg.var.score+C.yellow_score
  else local s=R.state();s.coins=s.coins+C.coin_value end
 end
end
local oldPower=GetPower
function GetPower(value)
 if not C.enabled then return oldPower(value) end
 -- Preserve the existing gain and threshold-crossing semantics.
 local before=math.floor(lstg.var.power/100)
 lstg.var.power=math.min(400,lstg.var.power+value)
 if math.floor(lstg.var.power/100)>before then PlaySound('powerup1',0.5) end
 if lstg.var.power>=400 then lstg.var.score=lstg.var.score+value*C.full_power_score end
end
local collect=item.playercollect
function item.playercollect(...)
 if not C.enabled then return collect(...) end
 -- Hide the old faith/collection-combo subsystem, leaving its code available.
end
-- Read physical held state every frame, even during cooldown/dialog/death.
-- A press during a blocked frame is discarded rather than firing later.
local sys=player_lib.system
local oldFrame=sys.updateKeyState
function sys:updateKeyState(...)
 local result=oldFrame(self,...)
 local p=self.player
 local held=p.__shoot_flag or player_lib.debug_data.keep_shooting or false
 local press=held and not self.my_shoot_held
 self.my_shoot_held=held
 self.my_shoot_press=press
 return result
end
local shoot=sys.shoot
function sys:shoot(...)
 if C.enabled and R.rule('shoot_mode','hold')=='press' then
  if not self.my_shoot_press then return end
  self.my_shoot_press=false
 end
 return shoot(self,...)
end
Include('systems/resource-ui.lua')

if setting.resources_test then Include('systems/resource-probe.lua') end
