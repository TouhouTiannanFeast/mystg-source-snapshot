-- Source-driven scene and animation playback for the selected two backgrounds.
Include('background-program.lua')
Include('background-player.lua')
Stage12Background={}
local S=Stage12BackgroundPlayer
local BG=Class(background)
function BG:init(stageIndex)
 background.init(self,false);self.bound=false;self.colli=false;self.stageIndex=stageIndex;self.age=0
 self.playback=S.new(stageIndex)
 for name,tex in pairs(self.playback.program.textures)do LoadTexture(name,tex[1]);SetTextureSamplerState(name,'linear+wrap')end
 local starts={['s1-momiji']=2420,['s1-non1']=5094,['s1-context']=5094,['s1-non2']=5094,['s1-scale']=5094,['s2-magic']=974,['s2-flare']=974,['s2-mystia']=4964}
 if setting.stage12_entry and setting.stage12_entry:match('^s2%-mz%d$') then starts[setting.stage12_entry]=5496 end
 if starts[setting.stage12_entry] then self.age=starts[setting.stage12_entry];S.advance(self.playback,self.age)end
 Stage12Background.current=self
 print('STAGE12 BACKGROUND source-program stage='..stageIndex)
end
function BG:frame()
 self.age=self.age+1;S.advance(self.playback,self.age)
 if not self.bossEntered then
  local phase=_boss and IsValid(_boss) and _boss.th14_phase
  local first=self.stageIndex==1 and (phase=='non1' or phase=='context' or phase=='non2' or phase=='scale')
  local second=self.stageIndex==2 and Stage2Route and Stage2Route.phase=='Mamizou'
  if first or second then S.interrupt(self.playback,1);self.bossEntered=true;print('STAGE12 BACKGROUND BOSS INTERRUPT stage='..self.stageIndex)end
 end
end
function BG:render()S.render(self.playback)end
function Stage12Background.start(n)return New(BG,n)end
