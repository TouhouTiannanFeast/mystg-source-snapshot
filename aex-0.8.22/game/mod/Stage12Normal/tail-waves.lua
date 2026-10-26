Stage12Tail={}
function Stage12Tail.run(boss,spawn,alive,wait,stats)
 local templates={}
 for _,e in ipairs(Stage2Schedule) do if e.t>=5164 and e.name:find('Girl00B') then templates[#templates+1]=e end end
 assert(#templates>0,'missing tail templates')
 local index=1
 local function emit(final)
  local source=templates[index];index=index%#templates+1
  local e={};for k,v in pairs(source) do e[k]=v end
  -- Alternate humans and fairies; both retain the source enemy movement.
  e.human=(stats.tailFairies or 0)%2==1
  local o=spawn(e)
  stats.tailFairies=stats.tailFairies+1
  if e.human then stats.tailHumans=stats.tailHumans+1 end
  if final then stats.finalTail=stats.finalTail+1 else stats.mystiaOverlap=stats.mystiaOverlap+1 end
  return o
 end
 for _=1,200 do if not alive(boss) then break end;wait(1) end
 while alive(boss) do emit(false);for _=1,30 do if not alive(boss) then break end;wait(1) end end
 stats.phase='Last fairy waves';stats.finalTail=0
 local last={}
 for i=1,6 do last[i]=emit(true);if i<6 then wait(30) end end
 while true do
  local any=false;for _,o in ipairs(last) do if alive(o) then any=true;break end end
  if not any then break end;wait(1)
 end
 stats.finalTailCleared=true
end
