-- User-selected music, converted to PCM for the engine; whole-track loops.
Y3Music={names={road="y3.music.road",boss="y3.music.boss"}}
local M=Y3Music
LoadMusic(M.names.road,'music/road.wav',422.792902494331,422.792902494331)
LoadMusic(M.names.boss,'music/boss.wav',175.011882086168,175.011882086168)
function M.stop()
 for _,name in pairs(M.names)do StopMusic(name)end
 M.current=nil
end
function M.play(key)
 local name=assert(M.names[key],'Unknown Yuyuko music')
 if M.current==key and GetMusicState(name)=='playing' then return end
 local global,staged=EnumRes('bgm')
 for _,pool in ipairs({global,staged})do for _,n in pairs(pool)do StopMusic(n)end end
 PlayMusic(name,1);M.current=key
 print('Y3 MUSIC '..key)
end
-- The engine pause menu enumerates only stage resources; cover global BGM too.
local pause,resume=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pause(self);self.y3MusicPaused={}
 for _,name in pairs(M.names)do
  if GetMusicState(name)=='playing' then self.y3MusicPaused[#self.y3MusicPaused+1]=name;PauseMusic(name)end
 end
end
function ext.pausemenu:ResumeSound()
 resume(self)
 for _,name in ipairs(self.y3MusicPaused or {})do if GetMusicState(name)=='paused' then ResumeMusic(name)end end
 self.y3MusicPaused={}
end
