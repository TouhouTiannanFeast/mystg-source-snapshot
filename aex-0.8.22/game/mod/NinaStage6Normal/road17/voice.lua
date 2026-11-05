TH11S6Voice={clips={},active={},gains={}}
local V=TH11S6Voice
function V.checkFirstBatch(R)
 if V.firstBatchDone or R.tick<=300 then return end
 for _,a in ipairs(R.actors or {})do if a.name=='Crow00'and not a.dead then return end end
 V.firstBatchDone=true;V.play(1)
end
function V.play(id,gain)
 print('NINA ROAD VOICE '..id..' stageframe='..tostring(stage.current_stage and stage.current_stage.timer))
 local c=assert(V.clips[id]);StopMusic(c.name);PlayMusic(c.name,0)
 V.active[id]=0
 V.gains[id]=gain or c.volume or 1
end
function V.step()
 for id,age in pairs(V.active)do
  local c=V.clips[id];age=age+1
  if age>=c.frames then StopMusic(c.name);V.active[id]=nil;V.gains[id]=nil
  else SetBGMVolume(c.name,V.gains[id]*math.min(1,age/30,(c.frames-age)/30));V.active[id]=age end
 end
end
function V.clean()
 for _,c in ipairs(V.clips)do StopMusic(c.name)end
 V.active={}
 V.gains={}
 V.firstBatchDone=false
end
local Driver=Class(object)
function Driver:init()self.group=GROUP_GHOST;self.bound=false;self.colli=false end
function Driver:frame()V.step()end
V.Driver=Driver
local playerMiss=item.PlayerMiss
function item:PlayerMiss(...)
 local before=lstg.var.lifeleft
 local result=playerMiss(self,...)
 if NinaRoad17.active and stage.current_stage and stage.current_stage.stage_name=='Nina Six@Normal'
 and lstg.var.lifeleft<before then V.play(1,1)end
 return result
end
V.clips[1]={name='th11s6.voice1',frames=250,volume=.5};LoadMusic(V.clips[1].name,'road17/voice/laugh1.ogg',4.15986394557823,4.15986394557823)
V.clips[2]={name='th11s6.voice2',frames=221,volume=2};LoadMusic(V.clips[2].name,'road17/voice/laugh2.ogg',3.66943310657596,3.66943310657596)
V.clips[3]={name='th11s6.voice3',frames=261,volume=2};LoadMusic(V.clips[3].name,'road17/voice/laugh3.ogg',4.34993197278912,4.34993197278912)
V.clips[4]={name='th11s6.voice4',frames=232};LoadMusic(V.clips[4].name,'road17/voice/laugh4.ogg',3.86659863945578,3.86659863945578)
