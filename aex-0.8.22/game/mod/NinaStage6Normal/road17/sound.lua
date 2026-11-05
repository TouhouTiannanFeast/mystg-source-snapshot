TH11S6Sound={count=0,tick=-1,heard={}}
local S=TH11S6Sound
local original=PlaySound
local aliases={powerup1='powerup',nep00='power0',explode='power1'}
local available={}
for _,name in ipairs({'bonus','cancel00','cardget','cat00','ch00','ch01','damage00','damage01','enep00','enep01','extend','graze','gun00','hint00','invalid','item00','kira00','kira01','kira02','lazer00','lazer01','ok00','option','pause','pldead00','plst00','power0','power1','powerup','select00','slash','tan00','tan01','tan02','timeout','timeout2','water'})do available[name]=true end
function S.play(name,vol,x)
 local t=TH11S6Runtime.tick or -1
 if t~=S.tick then S.tick=t;S.heard={}end
 if S.heard[name]then return end;S.heard[name]=true;S.count=S.count+1
 original('th11s6.'..name,vol or .35,math.max(-1,math.min(1,(x or 0)/192)),true)
end
function PlaySound(name,vol,pan,flag)
 local mapped=aliases[name] or name
 if S.active and available[mapped] then S.play(mapped,vol,(pan or 0)*192)
 else original(name,vol,pan,flag)end
end
-- Native config0x4a34f0+53*8 selects wav43 at pointer-table0x4a36b0.
TH11S6Runtime.onSound=function(id,x)assert(id==53,'unresolved TH11 sound '..id)end -- source cat call muted
