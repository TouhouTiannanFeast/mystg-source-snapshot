-- TH16 st04.std/st04wl.anm and TH07 eff06.anm; dumps in source/background/.
Include('background-program.lua')
Include('background-player.lua')
Y3Background={}
local P=Y3BackgroundPlayer
local Stage=Class(background)
Y3Background.stage=Stage
function Stage:init()
 background.init(self,false);self.bound=false;self.colli=false
 self.playback=P.new(1);self.playback.clear=0
 LoadFX('y3.bg.native','background-native.hlsl');CreateRenderTarget('y3.bg.blank')
 for name,t in pairs(self.playback.program.textures)do
  LoadTexture(name,t[1]);SetTextureSamplerState(name,'linear+wrap')
 end
 local entry=setting.y3_entry or 'full'
 local age=setting.y3_full and (entry=='full' and 0 or tonumber(entry:match('^road%-(%d+)$')) or 8130) or 8130
 P.advance(self.playback,age)
 print('Y3 BACKGROUND TH16 stage4 age='..age)
end
function Stage:frame()P.advance(self.playback,self.playback.age+1)end
local function norm(v)local n=math.sqrt(v[1]^2+v[2]^2+v[3]^2);return {v[1]/n,v[2]/n,v[3]/n}end
local function cross(a,b)return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}end
function Stage:render()
 local s=self.playback;local c=s.std.values;local eye=c.pos;local f=c.fog
 local forward=norm(c.facing);local right=norm(cross(c.up,forward));local vertical=cross(forward,right)
 SetViewMode('world');SetZBufferEnable(0);SetFog()
 lstg.PostEffect('y3.bg.native','y3.bg.blank',6,'',{
  {eye[1],eye[2],eye[3],math.tan(c.fov[1]/2)},
  {forward[1],forward[2],forward[3],408/472},
  {right[1],right[2],right[3],0},
  {vertical[1],vertical[2],vertical[3],0},
  {f[1]/255,f[2]/255,f[3]/255,f[4]},
  {f[5],0,0,0},
  {s.anms[2].uv[2],s.anms[3].uv[2],0,0}
 },{{'y3.bg.ground',6},{'y3.bg.cloud',6}})
end
local Spell=Class(background)
Y3Background.spell=Spell
function Spell:init()
 background.init(self,true);self.bound=false;self.colli=false;self.age=0
 LoadTexture('y3.bg.spell.base','art/background/eff06b.png')
 LoadTexture('y3.bg.spell.tree','art/background/eff06.png')
 SetTextureSamplerState('y3.bg.spell.base','linear+wrap')
 SetTextureSamplerState('y3.bg.spell.tree','linear+wrap')
end
function Spell:frame()
 if self.alpha>0 then self.age=self.age+1 else self.age=0 end
end
function Spell:render()
 if self.alpha<=0 then return end
 SetViewMode('world')
 local t=math.min(1,self.age/60)
 local color=Color(255*self.alpha*t,255,255,255)
 local v=self.age*0.008333334*256
 -- Original top-left (32,16) is the game viewport origin; UV wraps at256.
 RenderTexture('y3.bg.spell.base','',{-192,224,0,0,v,color},{192,224,0,384,v,color},{192,-224,0,384,v+448,color},{-192,-224,0,0,v+448,color})
 color=Color(224*self.alpha*t,255,255,255)
 RenderTexture('y3.bg.spell.tree','',{-192,224,0,0,0,color},{192,224,0,256,0,color},{192,-224,0,256,256,color},{-192,-224,0,0,256,color})
end
