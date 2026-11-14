-- Campaign-only requested presentation/resource rules. Source mods stay untouched.
local C=SixStageCampaign
Include('mod/SixStageCampaign/marisa-segments.lua')
local view='world'
local setView=SetViewMode
SetViewMode=function(mode,...)view=mode;return setView(mode,...)end
local text=RenderText
RenderText=function(font,value,x,y,scale,...)
 if view=='world'and font=='menu'and y<=-175 and(scale or 1)<=0.35 then return end
 if view=='ui'then
  if font=='score3'and type(value)=='string'and value:match('^%d+/[35]$')then return end
  if font=='score1'and(y==262 or y==258.5)then return end
 end
 return text(font,value,x,y,scale,...)
end
local render=Render
Render=function(img,x,y,...)
 if view=='ui'and type(img)=='string'and(img=='hint.power'or img=='hint.point'or img=='hint.Cnumber'or img:match('^lifechip')or img:match('^bombchip'))then return end
 if view=='ui'then
  if img=='hint.life'or img=='hint.bomb'then
   render(img,x,y-11,...)
   y=y+5
  elseif img=='hint.lifeleft'or img=='hint.bombleft'then
   local i=math.floor((x-89-lstg.world.scrr)/13+.5)
   if i>16 then
    if i==17 then
     local count=img=='hint.lifeleft'and lstg.var.lifeleft or lstg.var.bomb
     text('score3','+'..(count-16),lstg.world.scrr+215,y-11,.25,'right')
    end
    return
   end
   if i>8 then x=x-104;y=y-11 else y=y+5 end
  end
 end
 return render(img,x,y,...)
end
local score=RenderScore
RenderScore=function(font,value,x,y,...)
 if view=='ui'and font=='score2'and y==239 then return end
 return score(font,value,x,y,...)
end

local function isA(c,base)
 while c do if c==base then return true end;c=c.base end
 return false
end
local function itemKind(c)
 if isA(c,item_chip)then return'life',true end
 if isA(c,item_extend)then return'life',false end
 if isA(c,item_bombchip)then return'bomb',true end
 if isA(c,item_bomb)then return'bomb',false end
 return'point',false
end
local function style(p,kind,fragment)
 p.img='six.item.'..kind;p.imgup=p.img
 p.hscale,p.vscale=fragment and .75 or 1,fragment and .75 or 1
end
local function itemRules(classes)
 item.PointRateFunc=function()return 10000 end
 GetPower=function()lstg.var.power=400 end
 item_point.collect=function(p)
  lstg.var.score=lstg.var.score+10000
  New(float_text,'item',10000,p.x,p.y+6,.75,90,60,.5,.5,Color(0x80FFFF00),Color(0x00FFFF00))
 end
 item.EndChipBonus=function()end
 lstg.var.chip=0;lstg.var.bombchip=0
 local seen={}
 local all={item,item_point,item_power,item_power_large,item_power_full,item_faith,item_faith_minor,item_extend,item_chip,item_bomb,item_bombchip}
 for _,c in ipairs(classes)do if isA(c,item)or isA(c,item_faith_minor)then all[#all+1]=c end end
 for _,c in ipairs(all)do
  if not seen[c]then
   seen[c]=true
   local kind,fragment=itemKind(c)
   local init=c.init
   c.init=function(p,...)
    init(p,...)
    -- Source subclasses may set their own image after item.init.
    local actualKind,actualFragment=itemKind(p.class or c)
    style(p,actualKind,actualFragment)
    if actualFragment then p.hide=true;p.colli=false;p.group=GROUP_GHOST;Del(p)end
   end
   if kind~='point'and not fragment then
    local frame=c.frame
    c.frame=function(p,...)
     if p.timer>=60 and IsValid(player)then p.target=player;p.attract=8 end
     return frame(p,...)
    end
   end
   if c~=item and kind=='point'then c.collect=item_point.collect end
  end
 end
 item_chip.collect=function()end
 item_bombchip.collect=function()end
end

local function protectLastThree(classes)
 local R=Le03
 local start=R.start
 R.start=function(...)
  local result=start(...)
  for _,e in ipairs(R.enemies)do if e.appear==9500 then e.invincible=1 end end
  return result
 end
 for _,c in ipairs(classes)do
  local info=c.init and debug.getinfo(c.init,'S')
  local baseInfo=c.base and c.base.take_damage and debug.getinfo(c.base.take_damage,'S')
  if info and baseInfo and info.source:find('Le03Stage4Normal/host.lua',1,true)and baseInfo.source:find('Le03Stage4Normal/host.lua',1,true)then
   local init,frame,kill,damage=c.init,c.frame,c.kill,c.take_damage or c.base.take_damage
   local baseDamage=c.base.take_damage
   c.base.take_damage=function(o,d)if not(o.data and o.data.appear==9500)then return baseDamage(o,d)end end
   c.init=function(o,...)init(o,...);if o.data.appear==9500 then o.protect=true end end
   c.frame=function(o,...)local v=frame(o,...);if o.data.appear==9500 then o.protect=true end;return v end
   c.take_damage=function(o,d)if o.data.appear~=9500 then return damage(o,d)end end
   c.kill=function(o)
    if o.data.appear==9500 and o.data.active then PreserveObject(o);o.hp=o.data.hp;return end
    return kill(o)
   end
  end
 end
end

local function marisaItems(classes)
 local H=Th18Stage5Host
 if not H then return end -- Boss-only entries do not load the road module.
 -- Source TH18 road used inert private drops, outside GROUP_ITEM. Convert both
 -- their display and their collection hook without changing drop/motion rules.
 H.onCollect=function(e)item_point.collect({x=e.x,y=224-e.y,attract=8})end
 for _,c in ipairs(classes)do
  local info=c.init and debug.getinfo(c.init,'S')
  if info and info.source:find('MarisaMixed/road/host.lua',1,true)and c.base==object then
   local init,render=c.init,c.render
   c.init=function(o,...)init(o,...);if H.items[o]then style(o,'point',false)end end
   c.render=function(o)
    if H.items[o]then if not o.intro or o.intro<0 then Render('six.item.point',o.x,o.y)end
    else return render(o)end
   end
  end
 end
end

local function charge()
 local sound=PlaySound
 PlaySound=function(name,volume,pan,...)
  if name=='mm.selected12.charge'then
   C.chargeStopTick=SSG.tick+60
   if setting.six_probe_b3 then print('SIX CHARGE START '..SSG.tick)end
   return sound('six.marisa.charge',1.0,pan or 0,...)
  end
  return sound(name,volume,pan,...)
 end
 local step=SSGSelected05.step
 SSGSelected05.step=function(...)
  local result=step(...)
  if C.chargeStopTick and SSG.tick>=C.chargeStopTick then
   StopSound('six.marisa.charge')
   if setting.six_probe_b3 then print('SIX CHARGE STOP '..SSG.tick)end
   C.chargeStopTick=nil
  end
  return result
 end
end
function C.install(i,classes)
 itemRules(classes)
 if i==3 then protectLastThree(classes)end
 if i==4 then marisaItems(classes);C.installMarisaSegments(classes);charge()end
 if i==6 then for _,spec in ipairs(NinaSpecs)do if spec.id=='kanako'then spec.frames=90*60 end end end
end
