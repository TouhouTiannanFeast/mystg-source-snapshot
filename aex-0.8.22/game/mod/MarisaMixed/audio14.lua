-- User supplied MP3 converted to engine-supported Vorbis, full track loop.
MarisaMusic14={name='mm.marisa.music',active=false}
local A=MarisaMusic14
LoadMusic(A.name,'bgm/marisa.ogg',186.254126984127,186.254126984127)
if setting.marisa_road then
 A.roadName='mm.road.music'
 LoadMusic(A.roadName,'bgm/road.ogg',226.58718820861677,226.58718820861677)
end
function A.stopRoad()
 if A.roadActive then StopMusic(A.roadName);A.roadActive=false end
 A.roadPaused=false
end
function A.startRoad()
 if not A.roadName or A.roadActive then return end
 PlayMusic(A.roadName,1);A.roadActive=true
 print('MARISA16 ROAD MUSIC state='..GetMusicState(A.roadName))
end
function A.start()
 A.stopRoad()
 if A.active then return end
 local global,staged=EnumRes('bgm')
 for _,pool in ipairs({global,staged})do for _,name in pairs(pool)do if GetMusicState(name)=='playing'then StopMusic(name)end end end
 PlayMusic(A.name,1);A.active=true
 print('MARISA14 MUSIC state='..GetMusicState(A.name))
end
function A.stop()if A.active then StopMusic(A.name);A.active=false end end
local pause,resume=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pause(self);A.paused=A.active and GetMusicState(A.name)=='playing'
 if A.paused then PauseMusic(A.name)end
 A.roadPaused=A.roadActive and GetMusicState(A.roadName)=='playing'
 if A.roadPaused then PauseMusic(A.roadName)end
end
function ext.pausemenu:ResumeSound()
 resume(self);if A.roadPaused and GetMusicState(A.roadName)=='paused'then ResumeMusic(A.roadName)end;A.roadPaused=false
 if A.paused and GetMusicState(A.name)=='paused'then ResumeMusic(A.name)end;A.paused=false
end
