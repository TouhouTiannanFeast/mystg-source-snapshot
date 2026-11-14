-- Campaign sidebar only; original exports and shared engine remain intact.
local C=SixStageCampaign
Include('mod/SixStageCampaign/sidebar16/assets.lua')
for id,a in pairs(Sidebar16Assets)do
 local name='six.sidebar16.'..id
 LoadTexture(name,'mod/SixStageCampaign/sidebar16/'..a[1])
 LoadImage(name,name,0,0,a[2],a[3]);SetImageCenter(name,0,a[3]/2)
end
LoadTexture('six.sidebar16.background','mod/SixStageCampaign/sidebar16/background.png')
local bw,bh=GetTextureSize('six.sidebar16.background')
LoadImage('six.sidebar16.background','six.sidebar16.background',0,0,bw,bh)
local function pic(id,x,y,sx,sy)
 local name='six.sidebar16.'..id;SetImageState(name,'',Color(255,255,255,255));Render(name,x,y,0,sx or .5,sy or sx or .5)
end
local function number(value,right,y)
 local str=tostring(math.floor(math.max(0,value or 0)));local step=math.min(10,126/#str)
 for i=1,#str do pic(35+tonumber(str:sub(i,i)),right-(#str-i+1)*step,y,step/16,.625)end
end
local function slots(empty,full,count,right,y)
 for i=1,16 do
  local x=right+96+13*((i-1)%8);local yy=y-16*math.floor((i-1)/8)
  pic(i<=count and full or empty,x,yy,.375)
 end
 if count>16 then
  SetFontState('score3','',Color(255,255,255,255))
  RenderText('score3','+'..(count-16),right+215,y-16,.25,'right')
 end
end
local class=lstg.lstg_ui
local function drawFrame(self)
 SetViewMode('ui')
 local world=lstg.world
 pic(0,0,240,world.scrl/64,480/960)
 pic(2,world.scrl,(world.scrt+480)/2,(world.scrr-world.scrl)/768,(480-world.scrt)/32)
 pic(3,world.scrl,world.scrb/2,(world.scrr-world.scrl)/768,world.scrb/32)
 SetImageState('six.sidebar16.background','',Color(255,255,255,255))
 -- Use the complete replacement image, scaled to the right panel only.
 Render('six.sidebar16.background',lstg.world.scrr+112,240,0,224/bw,480/bh)
end
local function drawInfo(self)
 local x=lstg.world.scrr
 pic(4,x+12,426);pic(5,x+12,404)
 number(math.max(lstg.tmpvar.hiscore or 0,self.score or 0),x+216,426)
 number(self.score or 0,x+216,404)
 pic(6,x+12,371);slots(12,17,lstg.var.lifeleft or 0,x,376)
 pic(8,x+12,334,.45);slots(18,23,lstg.var.bomb or 0,x,339)
 pic(9,x+28,290);number(lstg.var.graze or 0,x+216,290)
 -- Keep dividers associated with score/resources; no empty power/point/graze lines.
 for _,y in ipairs({419,397,349,311})do pic(55,x+53,y,.75,.5)end
end
local function drawDifficulty(self)
 local name=(stage.current_stage.name or stage.current_stage.stage_name or''):match('[%w_][%w_ ]*$')or'Normal'
 local id=({Easy=56,Normal=57,Hard=58,Lunatic=59,Extra=60})[name]or 57
 local a=Sidebar16Assets[id];pic(id,lstg.world.scrr+112-a[2]/4,448)
end
local function installUI()
 class.drawFrame1=drawFrame;class.drawInfo1=drawInfo;class.drawDifficulty=drawDifficulty
end
installUI()
local install=C.install
function C.install(i,classes)install(i,classes);installUI()end
