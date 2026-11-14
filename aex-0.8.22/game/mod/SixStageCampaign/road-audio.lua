-- Original TH10 PCM, extracted without processing from the user's th10.dat.
local C=SixStageCampaign
-- Common THlib correction; requested ordinary road firing gain is0.22.
local volumeDefaults={
 enep01=.6,cat00=.55,cardget=.8,invalid=.8,timeout=.6,timeout2=.7,
 item00=.32,tan00=.22,power0=.7,enep00=.35,gun00=.6,power1=.6,
 tan01=.22,tan02=.22,lazer00=.35,lazer01=.35,kira00=.33,extend=.6,
 powerup=.6,slash=.75,plst00=.27,graze=.4,pldead00=.7,
 select00=.4,cancel00=.4,ok00=.4,pause=.5,
}
local files={
 ['BossEnd_Begin.wav']='enep01',['BossEnd_End.wav']='enep01',
 ['spellcard.wav']='cat00',['getspellcard.wav']='cardget',['Failed.wav']='invalid',
 ['timer1.wav']='timeout',['timer2.wav']='timeout2',
 ['seScore.wav']='item00',['seScore2.wav']='item00',
 ['mo.wav']='tan00',['moUP.wav']='power0',['enemy_vanish_B.wav']='enep00',
 ['boon.wav']='gun00',['power3.wav']='power0',['power2.wav']='power1',
 ['power_logo.wav']='power0',['power_logo2.wav']='power1',['power_logo3.wav']='power1',
 ['shot1.wav']='tan00',['shot2.wav']='tan00',['shot3.wav']='tan01',
 ['shot4.wav']='tan02',['shot5.wav']='tan01',['shot6.wav']='tan02',['shot7.wav']='tan02',
 ['Laser01.wav']='lazer00',['Laser02.wav']='lazer01',['flare.wav']='enep01',
 ['bulletbreak.wav']='kira00',['fire00.wav']='gun00',['freeze05.wav']='kira00',
 ['crash16_b.wav']='enep01',['one07.wav']='item00',['se1UP.wav']='extend',
 ['status03.wav']='powerup',['se_extend2.wav']='extend',['se_extend4.wav']='extend',
 ['se_shutter.wav']='cat00',['pi64.wav']='tan00',['swing11.wav']='slash',
 ['chapter_c.wav']='bonus3',['chapter_d.wav']='bonus3',['se_nep00.wav']='enep01',
 ['metal33_a.wav']='tan02',['mecha07.wav']='tan01',['noise02.wav']='power0',
 ['se_plst00.ogg']='plst00',['seGraze.ogg']='graze',['sePlayerCollision.ogg']='pldead00',
 ['se_slash.ogg']='slash',['plpower.ogg']='powerup',['pan.ogg']='enep01',
 ['menuselect.wav']='select00',['menucancel.wav']='cancel00',['menudecide.wav']='ok00',['pause.wav']='pause',
}
local loaded={}
for _,name in pairs(files)do
 if not loaded[name]then
  LoadSound('six.th10.'..name,'mod/SixStageCampaign/se/th10/se_'..name..'.wav')
  loaded[name]=true
 end
end
C.roadAudioFiles=files
function C.installRoad4Audio()
 local H,R=Th18Stage5Host,Th18Stage5Runtime
 if not H then return end -- Boss-only practice does not import the road.
 local begin=H.begin
 H.begin=function(...)
  local result=begin(...)
  local shot=R.onShot
  local lastTick
  R.onShot=function(b,...)
   if lastTick~=R.tick then
    lastTick=R.tick
    lstg.PlaySound('six.th10.tan00',.22,math.max(-1,math.min(1,(b.x or 0)/192)))
   end
   return shot(b,...)
  end
  return result
 end
end
function C.installRoadAudio()
 local R=HSoB5
 local source=R.playSource
 local ticks={}
 local function road()return not setting.hsob5_boss_only and not R.finished end
 R.playSource=function(file,volume,pan)
  if not road()then return source(file,volume,pan)end
  local name=assert(files[file],'unmapped campaign road sound '..tostring(file))
  local tick=stage.current_stage and stage.current_stage.timer or R.tick
  if ticks[file]==tick then return end;ticks[file]=tick
  R.soundCount=(R.soundCount or 0)+1
  return lstg.PlaySound('six.th10.'..name,volumeDefaults[name]or volume or 1,pan or 0)
 end
 local reset=R.resetSound
 R.resetSound=function(...)ticks={};return reset(...)end
 local play=PlaySound
 local aliases={plst00='plst00',graze='graze',pldead00='pldead00',item00='item00',
  powerup1='powerup',extend='extend',cardget='cardget',power1='power1',cat00='cat00',
  nep00='enep01',slash='slash',explode='enep01',enep00='enep00',
  select00='select00',cancel00='cancel00',ok00='ok00',pause='pause'}
 PlaySound=function(name,volume,pan,sndflag,...)
  if road()and aliases[name]then
   local gain=not sndflag and volumeDefaults[aliases[name]]or nil
   return lstg.PlaySound('six.th10.'..aliases[name],gain or volume or 1,pan or 0)
  end
  return play(name,volume,pan,sndflag,...)
 end
end
