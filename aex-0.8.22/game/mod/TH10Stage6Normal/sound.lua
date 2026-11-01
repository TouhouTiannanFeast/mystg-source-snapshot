TH10S6Sound={count=0,tick=-1,heard={}}
local S=TH10S6Sound
local original=PlaySound
local aliases={powerup1='powerup',nep00='power0',explode='power1'}
local available={}
for _,name in ipairs({'bonus3','cancel00','cardget','cat00','ch00','ch01','damage00','damage01','enep00','enep01','extend','graze','gun00','hint00','invalid','item00','kira00','kira01','kira02','lazer00','lazer01','ok00','option','pause','pldead00','plst00','power0','power1','powerup','select00','slash','tan00','tan01','tan02','timeout','timeout2','water'})do available[name]=true end
function S.play(name,vol,x)
 local t=TH10S6Runtime.tick or -1
 if t~=S.tick then S.tick=t;S.heard={}end
 if S.heard[name]then return end;S.heard[name]=true;S.count=S.count+1
 original('s6.'..name,vol or .35,math.max(-1,math.min(1,(x or 0)/192)),true)
end
function PlaySound(name,vol,pan,flag)
 local mapped=aliases[name] or name
 if S.active and available[mapped] then S.play(mapped,vol,(pan or 0)*192)
 else original(name,vol,pan,flag)end
end
-- Original v1.00a config row 41: [0x4749c8+41*8] -> wav index31,
-- name pointer [0x474b40+31*4] -> se_ch00.wav. Not guessed by label.
TH10S6Runtime.onSound=function(id,x)
 assert(id==41,'unexpected road sound id '..id);S.play('ch00',.55,x)
end
