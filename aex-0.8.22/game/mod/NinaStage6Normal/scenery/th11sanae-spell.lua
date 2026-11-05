-- TH11 Extra midboss Sanae spell background, from stgenm07 ANM scripts 27/28.
-- stage07mboss calls ANM 131 at spell start; it creates cdbg07a then cdbg07b.
NinaTH11SanaeSpell={}
local S=NinaTH11SanaeSpell
LoadTexture('nina.th11.sanae.a','scenery/art/cdbg07a.png')
LoadImage('nina.th11.sanae.a','nina.th11.sanae.a',0,0,384,448)
LoadTexture('nina.th11.sanae.b','scenery/art/cdbg07b.png')
-- Although the packed payload is 256x256, source ANM entry15 declares
-- sprite65 as 384x448.  Keep that source sprite rectangle.
LoadImage('nina.th11.sanae.b','nina.th11.sanae.b',0,0,384,448)
S.Object=Class(background)
function S.Object:init()background.init(self,false);self.bound=false end
function S.Object:render()
 if self.ninaHidden then return end
 local t=self.timer;local born=math.min(1,t/60)
 -- script27: cdbg07a at (224,240), alpha 0->255 in 60f.
 SetImageState('nina.th11.sanae.a','',Color(255*born,255,255,255));Render('nina.th11.sanae.a',0,0,0,1,1)
 -- script28: additive cdbg07b, uniform scale velocity -.0033333334/f;
 -- its six 60f colour tweens make the 360f RGB loop.
 local k=math.floor((t%360)/60);local colors={{0,0,255},{0,255,255},{0,255,0},{255,255,0},{255,0,0},{255,0,255}}
 local c=colors[k+1];local u=(t%60)/60;local n=colors[(k+2-1)%6+1]
 local r,g,b=c[1]+(n[1]-c[1])*u,c[2]+(n[2]-c[2])*u,c[3]+(n[3]-c[3])*u
 SetImageState('nina.th11.sanae.b','mul+add',Color(255*born,r,g,b));local scale=1-t/300
 Render('nina.th11.sanae.b',0,0,0,scale,scale)
end
