-- User-selected BGM; original MP3s preserved. Whole-file loops.
Stage12Music={names={}}
local M=Stage12Music
M.names['s1.route']='stage12.s1.route'
LoadMusic(M.names['s1.route'],'music/user-s1-route.wav',324.859841269841,324.859841269841)
M.names['s1.boss']='stage12.s1.boss'
LoadMusic(M.names['s1.boss'],'music/user-s1-boss.wav',177.320249433107,177.320249433107)
M.names['s2.route']='stage12.s2.route'
LoadMusic(M.names['s2.route'],'music/user-s2-route.wav',213.56,213.56)
M.names['s2.boss']='stage12.s2.boss'
LoadMusic(M.names['s2.boss'],'music/user-s2-boss.wav',252.644716553288,252.644716553288)
function M.stop()
 local global,staged=EnumRes('bgm')
 for _,pool in ipairs({global,staged})do for _,name in pairs(pool)do StopMusic(name)end end
end
function M.play(key)
 local name=assert(M.names[key],'unknown Stage12 music')
 M.stop();PlayMusic(name,1);print('STAGE12 MUSIC '..key)
end
local pause,resume=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pause(self);self.stage12Paused={}
 for _,name in pairs(M.names)do
  if GetMusicState(name)=='playing' then self.stage12Paused[#self.stage12Paused+1]=name;PauseMusic(name)end
 end
end
function ext.pausemenu:ResumeSound()
 resume(self)
 for _,name in ipairs(self.stage12Paused or {})do if GetMusicState(name)=='paused' then ResumeMusic(name)end end
 self.stage12Paused={}
end
