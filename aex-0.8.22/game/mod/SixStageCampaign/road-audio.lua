-- Original TH10 PCM, extracted without processing from the user's th10.dat.
local C=SixStageCampaign
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
  return lstg.PlaySound('six.th10.'..name,volume or 1,pan or 0)
 end
 local reset=R.resetSound
 R.resetSound=function(...)ticks={};return reset(...)end
 local play=PlaySound
 local aliases={plst00='plst00',graze='graze',pldead00='pldead00',item00='item00',
  powerup1='powerup',extend='extend',cardget='cardget',power1='power1',cat00='cat00',
  nep00='enep01',slash='slash',explode='enep01',enep00='enep00',
  select00='select00',cancel00='cancel00',ok00='ok00',pause='pause'}
 PlaySound=function(name,volume,pan,...)
  if road()and aliases[name]then return lstg.PlaySound('six.th10.'..aliases[name],volume or 1,pan or 0)end
  return play(name,volume,pan,...)
 end
end
