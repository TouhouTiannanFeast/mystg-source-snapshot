-- Original BackgroundWorld05 official Lite path, source 384x448 images.
local R=HSoB5
for i,c in ipairs({'a','b','c','d','e'})do
 LoadTexture('hs5.bg'..i,'art/bg17/stgimg05'..c..'_lite.png')
 LoadImage('hs5.bg'..i,'hs5.bg'..i,0,0,384,448)
end
LoadTexture('hs5.warp','art/bg17/explode2.png')
LoadImage('hs5.warp','hs5.warp',0,0,128,128)
local BG=Class(object)
function BG:init()
 self.group=GROUP_GHOST;self.layer=LAYER_BG+1;self.bound=false;self.colli=false
 self.rows={};self.last=R.tick
 local function show(i,delay,scene)
  local row={i=i,alpha=0};self.rows[#self.rows+1]=row
  for n=1,51 do row.alpha=n*5;task.Wait(1)end
  while R.scene<scene do task.Wait(1)end
  task.Wait(delay)
  task.New(self,function()task.Wait(180);for n=50,0,-1 do row.alpha=n*5;task.Wait(1)end end)
 end
 task.New(self,function()
  if R.section==3 then show(5,360,3);return end
  if R.section==1 then show(1,600,0);show(2,0,1)end
  show(3,0,2)
  local warp=math.floor(39.435*64)
  show(3,warp-1200,2);show(4,1050,2);show(5,360,3)
 end)
end
function BG:frame()task.Do(self)end
function BG:render()
 for _,row in ipairs(self.rows)do if row.alpha>0 then
  SetImageState('hs5.bg'..row.i,'',Color(row.alpha,255,255,255));Render('hs5.bg'..row.i,0,0)
 end end
end
local Warp=Class(object)
function Warp:init()self.group=GROUP_GHOST;self.layer=LAYER_TOP-1;self.bound=false;self.colli=false end
function Warp:render()
 if not R.warpAt then return end
 local t=R.tick-R.warpAt;local long=math.floor(39.435*64)
 for i=0,4 do
  local delay=long-180+i*15;local u=math.max(0,(t-delay)/(long-delay))
  local scale,alpha
  if t<long then scale=math.min(1,u*12)*12;alpha=math.min(1,u*2)*255
  else local v=math.max(0,(29-(t-long))/30);scale=v*12;alpha=v*255 end
  if scale>0 then
   SetImageState('hs5.warp','mul+rev',Color(alpha,255,255,255))
   Render('hs5.warp',0,0,-i*360/5/5*2,scale)
  end
 end
end
R.newBackground=function()New(BG);New(Warp)end
