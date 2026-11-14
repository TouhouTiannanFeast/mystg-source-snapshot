-- Original TH18 equipment-card HUD, presenting this campaign's existing shots.
local C=SixStageCampaign
local A={};SixStageCards18=A
local root='mod/SixStageCampaign/cards18/'
for key,file in pairs({needle='REIMU_OP2_min.png',orb='REIMU_OP_min.png',frame='abframe.png'})do
 local name='six.cards18.'..key;LoadTexture(name,root..file);LoadImage(name,name,0,0,64,80)
end
LoadTexture('six.cards18.labels',root..'category-labels.png')
LoadImage('six.cards18.equipment','six.cards18.labels',656,144,144,36)
function A.owned()
 if C.index<1 then return{}end
 -- The post-stage2 award appends the orb. Direct later-stage entries include it.
 if C.index>=3 or C.reward then A.hasOrb=true end
 if A.hasOrb then return{'needle','orb'}end
 return{'needle'}
end
-- abcard script5: first120f 0 ->-2 degrees, then120f half-cycles
-- -2 ->+2 ->-2, using source interpolation21 (sinusoidal easing).
function A.motion(age)
 local function ease(t)return(1-math.cos(math.pi*t))/2 end
 if age<120 then return -2*ease(age/120)end
 local n=math.floor((age-120)/120);local t=(age-120)%120/120
 return n%2==0 and(-2+4*ease(t))or(2-4*ease(t))
end
function A.render()
 local cards=A.owned();local n=#cards;if n==0 then return end
 local age=stage.current_stage.timer or 0
 local tilt=A.motion(age)
 -- User-requested1.5x size, all card geometry/shadows scaled together.
 local scale=.75;local y=480-(537+130)/2
 SetViewMode('ui')
 SetImageState('six.cards18.equipment','',Color(255*math.min(1,age/20),255,255,255))
 Render('six.cards18.equipment',lstg.world.scrr+112,187.5,0,.5,.5)
 for i,key in ipairs(cards)do
  local cardAge=key=='orb'and C.reward and C.reward.age or age
  local alpha=255*math.min(1,cardAge/20)
  local x=lstg.world.scrr+112+30*(n-1)-60*(i-1)
  local name='six.cards18.'..key
  local function draw(image,dx,dy,blend,r,g,b,a)
   SetImageState(image,blend,Color(a,r,g,b));Render(image,x+(dx or 0),y+(dy or 0),tilt,scale,scale*math.cos(tilt*math.pi/180))
  end
  -- Original script10 shadow; script11 is transparent in ordinary equipment idle.
  draw('six.cards18.frame',2.25,-2.25,'',0,0,0,alpha*90/255)
  -- Scripts6/7 card layers and8/9 dark-green native card frame.
  draw(name,0,0,'',128,128,128,alpha)
  draw(name,0,0,'',255,255,255,alpha)
  draw('six.cards18.frame',0,0,'',0,32,0,alpha)
  draw('six.cards18.frame',0,0,'',0,32,0,alpha)
 end
end
local function installUI()
 local class=lstg.lstg_ui;local info=class.drawInfo1
 class.drawInfo1=function(self)info(self);A.render()end
end
installUI()
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if C.first then A.hasOrb=i>=3 elseif i>=3 then A.hasOrb=true end
 installUI()
end
local prepare=C.prepareMenu
if prepare then C.prepareMenu=function(...)A.hasOrb=false;return prepare(...)end end
