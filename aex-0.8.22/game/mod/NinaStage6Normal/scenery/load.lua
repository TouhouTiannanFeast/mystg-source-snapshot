-- Private Nina scenery API. Root owns call sites; this package owns only views.
Include('scenery/th10boss-assets.lua')
LoadTexture('nina.scenery.th10leaf.texture','scenery/art/bullet-etama2.png')
LoadImage('nina.scenery.th10leaf','nina.scenery.th10leaf.texture',192,192,32,32)
Include('scenery/th10boss.lua')
Include('scenery/th11sanae-spell.lua')
Include('scenery/world06.lua')
NinaScenery={phase='normal',host=nil}
local N=NinaScenery
local function classFor(id)
 if id=='spell'then return NinaTH11SanaeSpell.Object end
 if id=='kanako'then return TH10S6Background.BossObject end
 return NinaWorld06.Object
end
local function newView(id)
 local saved=lstg.tmpvar.bg;lstg.tmpvar.bg=nil
 local o=New(classFor(id));lstg.tmpvar.bg=saved
 o.ninaHidden=true;o.ninaPhase=id;return o
end
function N.setPhase(id,isSpell)
 id=id or(isSpell and'spell'or'normal');N.phase=id
 if N.host and IsValid(N.host)and not(N.host.active and N.host.active.ninaPhase==id)then N.Object.switch(N.host,id)end
end
function N.arrival(duration)
 if not(N.host and IsValid(N.host))then N.phase='kanako';return end
 local h=N.host;if h.active and h.active.ninaPhase=='kanako'then return end
 N.Object.switch(h,'kanako',duration or 120);N.phase='kanako'
end
N.Object=Class(background)
function N.Object:init(previous)
 if previous and IsValid(previous)then lstg.tmpvar.bg=nil;previous.ninaHidden=true end
 background.init(self,false);self.bound=false;N.host=self;CreateRenderTarget('nina.scenery.old');CreateRenderTarget('nina.scenery.new')
 LoadImage('nina.scenery.old.image','nina.scenery.old',32,16,384,448);LoadImage('nina.scenery.new.image','nina.scenery.new',32,16,384,448)
 self.active=newView(N.phase);self.fade=0;self.fadeMax=0
 if previous and IsValid(previous)then self.old=previous;self.fade=120;self.fadeMax=120 end
end
function N.Object:switch(id,duration)
 if self.active and self.active.ninaPhase==id then return end
 if self.old and IsValid(self.old)then Del(self.old)end
 self.old=self.active;if self.old then self.old.ninaHidden=true end
 self.active=newView(id);self.fade=duration or 120;self.fadeMax=self.fade
end
function N.Object:frame()
 if self.fade>0 then self.fade=self.fade-1;if self.fade==0 and self.old and IsValid(self.old)then Del(self.old);self.old=nil end end
end
local function capture(o,rt)
 PushRenderTarget(rt);RenderClear(Color(0,0,0,0));o.ninaHidden=false;o.class.render(o);o.ninaHidden=true;PopRenderTarget()
end
function N.Object:render()
 capture(self.active,'nina.scenery.new')
 if self.old and IsValid(self.old)then
  capture(self.old,'nina.scenery.old');local u=self.fade/self.fadeMax
  SetViewMode('world');SetImageState('nina.scenery.old.image','',Color(255,255,255,255));Render('nina.scenery.old.image',0,0)
  SetImageState('nina.scenery.new.image','',Color(255*(1-u),255,255,255));Render('nina.scenery.new.image',0,0)
 else SetViewMode('world');SetImageState('nina.scenery.new.image','',Color(255,255,255,255));Render('nina.scenery.new.image',0,0)end
end
function N.Object:del()if self.active and IsValid(self.active)then Del(self.active)end;if self.old and IsValid(self.old)then Del(self.old)end;if N.host==self then N.host=nil end end
