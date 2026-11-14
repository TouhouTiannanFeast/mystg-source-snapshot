-- Campaign-only TH20 stage06 STD/ANM scenery and road-completion handoff.
Include('mod/SixStageCampaign/background5/program.lua')
Include('mod/SixStageCampaign/background5/player.lua')
local C,S=SixStageCampaign,SixBoss5Player
for name,t in pairs(SixBoss5Program[1].textures)do LoadTexture(name,t[1]);SetTextureSamplerState(name,'linear+wrap')end
for _,n in ipairs({'a','b','c'})do LoadTexture('six.bg5.card.'..n,'mod/SixStageCampaign/background5/cdbg06'..n..'00.png');SetTextureSamplerState('six.bg5.card.'..n,'linear+wrap')end
Include('mod/SixStageCampaign/background5/spell.lua')
CreateRenderTarget('six.bg5.outgoing')
local U={duration=180};C.boss5Background=U
function U.start(road)
 if U.state then return end
 U.state=S.new(1);S.advance(U.state,5800);S.interrupt(U.state,1)
 U.last=stage.current_stage.timer;U.started=U.last;U.outgoing=road
 U.fade=road and 0 or 1;U.capturePending=road~=nil
 SixBoss5State=U.state
end
function U.draw()
 U.start()
 local now=stage.current_stage.timer
 local elapsed=math.max(0,now-U.last)
 S.advance(U.state,U.state.age+elapsed);U.last=now
 if U.capturePending then
  -- Capture only the outgoing playfield. Its camera/fog cannot affect the new scene.
  PushRenderTarget('six.bg5.outgoing');RenderClear(Color(0,0,0,0))
  SixRoad5Background.render(U.outgoing)
  PopRenderTarget();U.capturePending=false
 end
 local active=HSoB5.bossActive
 local id=active and Zuu4R.id or nil
 if id and id~=U.phase then
  U.phase=id
  -- Source Boss3 and Boss6/7 interrupt their STD camera sections.
  if id=='non3'then S.interrupt(U.state,2)
  elseif id=='stone'then S.interrupt(U.state,6)end
 end
 S.render(U.state)
 local F=Zuu4R.fx
 -- Follow the actual spell-start event, including pre-card staging delays.
 if active and F.spell then
  SixBoss5Spell(math.max(0,F.clock-F.spellTick),id=='stone'or id=='final')
 end
 if U.outgoing then
  U.fade=math.min(1,(now-U.started)/U.duration)
  if U.fade<1 then
   local w,h=GetTextureSize('six.bg5.outgoing');local world=lstg.world
   local u0,u1=world.scrl/640*w,world.scrr/640*w
   local v0,v1=(480-world.scrt)/480*h,(480-world.scrb)/480*h
   local c=Color(math.floor(255*(1-U.fade)),255,255,255)
   SetViewMode('world')
   RenderTexture('six.bg5.outgoing','',{-192,224,0,u0,v0,c},{192,224,0,u1,v0,c},{192,-224,0,u1,v1,c},{-192,-224,0,u0,v1,c})
  else U.outgoing=nil end
 end
end
local install=C.install
function C.install(i,classes)
 install(i,classes)
 if i~=5 then return end
 U.state=nil;U.phase=nil;U.outgoing=nil;U.capturePending=false;U.fade=1
 assert(Zuu4R.fx).background=U.draw
end
Include('mod/SixStageCampaign/road5-background.lua')
