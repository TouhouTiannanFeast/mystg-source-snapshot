-- TH10 front.anm scripts77..79, original sprites48/50; TH12 Anchor00 sounds.
local C=SixStageCampaign
LoadTexture('six.collect','mod/SixStageCampaign/art/th10-front.png')
LoadImage('six.collect.text','six.collect',256,256,192,32)
LoadImage('six.collect.line','six.collect',264,288,112,8)
LoadSound('six.anchor.launch','mod/SixStageCampaign/se/th12/se_boon00.wav')
LoadSound('six.anchor.impact','mod/SixStageCampaign/se/th12/se_don00.wav')
SixStageCollectLine=Class(object)
function SixStageCollectLine:init()
 self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP+1,false,false
end
function SixStageCollectLine:frame()if self.timer>=198 then Del(self)end end
function SixStageCollectLine:render()
 local t=self.timer
 if t<60 or not IsValid(player)then return end
 local fade=math.min(1,(t-60)/10,(198-t)/10)
 local orange=t>=68 and t<188 and math.floor((t-68)/8)%2==0
 local g,b=orange and 128 or 255,orange and 0 or 255
 local y=player.collect_line
 SetViewMode('world')
 SetImageState('six.collect.text','',Color(192*fade,255,g,b))
 Render('six.collect.text',0,y+16)
 SetImageState('six.collect.line','',Color(64*fade,255,g,b))
 local w=lstg.world;local width=(w.r-w.l-192)/2
 Render('six.collect.line',w.l+width/2,y,0,width/112,1)
 Render('six.collect.line',w.r-width/2,y,0,width/112,1)
end
local function anchor()
 local A=Stage1Anchor.Anchor
 local init,frame=A.init,A.frame
 A.init=function(o,...)
  local fire=Stage12FireSound
  Stage12FireSound=function(name,...)if name~='tan01'then return fire(name,...)end end
  init(o,...);Stage12FireSound=fire
  PlaySound('six.anchor.launch',10^(-500/2000),math.max(-1,math.min(1,o.x/192)))
 end
 A.frame=function(o,...)
  local previous=o.state
  local sound=PlaySound
  PlaySound=function(name,volume,...)if name=='tan00'and volume==.3 then return end;return sound(name,volume,...)end
  local result=frame(o,...)
  PlaySound=sound
  if previous=='outbound'and o.state=='hold'then
   misc.ShakeScreen(60,2);PlaySound('six.anchor.impact',1,math.max(-1,math.min(1,o.x/192)))
  elseif previous=='return'and o.state=='finish'then
   PlaySound('six.anchor.launch',10^(-500/2000),math.max(-1,math.min(1,o.x/192)))
  end
  return result
 end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i<=2 then anchor()end
 if i==1 then
  local card=Stage1Anchor.card
  Stage1Anchor.card=function(...)
   local c=card(...);c.hp=1080;return c
  end
 end
 if i==1 and not setting.stage12_entry and not setting.th14_practice then
  local after=AfterFrame;local shown=false
  AfterFrame=function(...)
   after(...)
   if not shown and IsValid(player)then shown=true;New(SixStageCollectLine)end
  end
 end
end
