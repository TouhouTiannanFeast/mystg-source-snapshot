-- Mod-local original HSoB bank. Shared engine/resources are never overwritten.
local R,E=HSoB5,HSoB5.env
Include('sound-data.lua')
local originalPlaySound=PlaySound
local files={}
for _,name in pairs(R.soundFiles)do files[name]=true end
for _,name in ipairs({'se_plst00.ogg','seGraze.ogg','sePlayerCollision.ogg','se_slash.ogg','plpower.ogg','se_nep00.wav','pan.ogg','menuselect.wav','menucancel.wav','menudecide.wav','pause.wav'})do files[name]=true end
for file in pairs(files)do LoadSound('hs5.se.'..file,'art/se/'..file)end
local ticks={}
function R.playSource(file,volume,pan)
 assert(files[file],'Unmapped HSoB sound '..tostring(file))
 -- Original ObjSound_Play reuses one handle per event, not layered copies.
 if ticks[file]==R.tick then return end;ticks[file]=R.tick
 originalPlaySound('hs5.se.'..file,volume or 1,pan or 0,true)
 R.soundCount=(R.soundCount or 0)+1
end
R.onSound=function(id)local file=assert(R.soundFiles[id],'Unknown HSoB sound event '..tostring(id));R.playSource(file)end
R.resetSound=function()ticks={};R.soundCount=0 end
local aliases={plst00='se_plst00.ogg',graze='seGraze.ogg',pldead00='sePlayerCollision.ogg',
 item00='seScore.wav',powerup1='plpower.ogg',extend='se1UP.wav',cardget='status03.wav',
 power1='plpower.ogg',cat00='spellcard.wav',nep00='se_nep00.wav',slash='se_slash.ogg',explode='pan.ogg',
 select00='menuselect.wav',cancel00='menucancel.wav',ok00='menudecide.wav',pause='pause.wav'}
function PlaySound(name,volume,pan,...)
 local current=stage.current_stage
 if current and current.stage_name=='HSoB Stage5 Road@Normal' then
  -- Enemy death and source shooting are emitted by their original event sites.
  if name=='enep00' or name=='damage00' or name=='damage01' then return end
  local file=aliases[name];if file then return R.playSource(file,volume,pan)end
 end
 return originalPlaySound(name,volume,pan,...)
end
R.soundAliases=aliases
