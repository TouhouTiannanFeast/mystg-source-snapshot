-- HSoB1.12 ControlSound event names; encounter-local PCM copies.
local R=Zuu4R
local files={bossBegin='BossEnd_Begin.wav',bossEnd='BossEnd_End.wav',spell='spellcard.wav',
 capture='getspellcard.wav',fail='Failed.wav',timer1='timer1.wav',timer2='timer2.wav',
 vanish='enemy_vanish_B.wav',boon='boon.wav',power1='power3.wav',power2='power2.wav',
 power3='power_logo.wav',power5='power_logo3.wav',shot1='shot1.wav',shot2='shot2.wav',
 shot3='shot3.wav',shot4='shot4.wav',shot5='shot5.wav',laser1='Laser01.wav',
 flare='flare.wav',bulletBreak='bulletbreak.wav'}
local prefix='stages/zuu4/audio/'
Include('stages/zuu4/th20-sounds.lua')
for id,file in pairs(R.th20Sounds)do files['th20.'..id]='th20-'..file end
for name,file in pairs(files)do LoadSound('horou.se.'..name,prefix..(name:sub(1,5)=='th20.'and''or'se/')..file)end
local music='horou.music'
-- MusicData gives sample endpoints, not seconds. Original Vorbis is 48000Hz.
LoadMusic(music,prefix..'hsob_6boss.wav',12570074/48000,(12570074-1082253)/48000)
local ticks={}
R.sound=function(name)
 if R.onSound then R.onSound(name)end
end
R.onSound=function(name)
 assert(files[name],'Unknown Horou source cue '..tostring(name))
 if ticks[name]==R.tick then return end;ticks[name]=R.tick
 PlaySound('horou.se.'..name,1)
 if setting.zuu4_test and not R.audioSeen[name]then
  R.audioSeen[name]=true;print('HOROU AUDIO '..name..' state='..GetSoundState('horou.se.'..name))
 end
end
R.resetAudio=function()ticks={};R.audioSeen={}end
R.musicStart=function()
 R.audioActive=true
 if GetMusicState(music)=='playing' then return end
 local global,staged=EnumRes('bgm')
 for _,pool in ipairs({global,staged})do for _,name in pairs(pool)do StopMusic(name)end end
 PlayMusic(music,1);print('HOROU MUSIC state='..GetMusicState(music))
end
R.musicStop=function()StopMusic(music);R.audioActive=false end
-- Global resources also need the engine's pause/resume lifecycle.
local pause,resume=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pause(self);self.horouPaused=GetMusicState(music)=='playing'
 if self.horouPaused then PauseMusic(music)end
end
function ext.pausemenu:ResumeSound()
 resume(self);if self.horouPaused and GetMusicState(music)=='paused'then ResumeMusic(music)end;self.horouPaused=false
end
local play=PlaySound
function PlaySound(name,...)
 -- Native boss emits cat00 at card construction; source spells announce later.
 if R.audioActive and name=='cat00'then return end
 if R.audioActive then
  local alias=({cardget='capture',fault='fail',timeout='timer1',timeout2='timer2'})[name]
  if alias then return R.sound(alias)end
 end
 return play(name,...)
end
local after=AfterFrame
AfterFrame=function()
 after()
 if R.audioActive and (not stage.current_stage or stage.current_stage.name~='Stage 4B@Normal')then R.musicStop()end
end
