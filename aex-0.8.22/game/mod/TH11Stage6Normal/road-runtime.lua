-- Only the road closure uses this scheduler. Newly scheduled zero-time work
-- is drained in the current source tick; waits always yield to a later tick.
local R=TH11S6Runtime
function R.step(px,py,hp)
 R.playerX,R.playerY,R.hp=px,py,hp;R.instructions=0
 local ai=1
 while ai<=#R.actors do
  local a=R.actors[ai]
  if not a.dead then
   local done={}
   while not a.dead do
    local th
    if a.threads[1] and not done[a.threads[1]] then th=a.threads[1]
    else for i=#a.threads,2,-1 do if not done[a.threads[i]] then th=a.threads[i];break end end end
    if not th then break end;done[th]=true
    if not th.dead and th.wake<=R.tick and coroutine.status(th.co)~='dead' then
     local ok,delay=coroutine.resume(th.co);assert(ok,delay)
     if coroutine.status(th.co)~='dead' then th.wake=R.tick+math.max(1,delay or 1)end
    end
   end
   if not a.dead then
    R.motion(a);a.age=a.age+1;a.invuln=math.max(0,(a.invuln or 0)-1)
    if not a.controller and R.bitAnd(a.flags or 0,4)==0 then
     local inside=a.x>=-224 and a.x<=224 and a.y>=-32 and a.y<=480
     a.entered=a.entered or (a.x>=-208 and a.x<=208 and a.y>=-16 and a.y<=464)
     if a.age>1 and a.entered and not inside then a.dead=true;a.offscreenRemoval=true end
    end
   end
  end
  ai=ai+1
 end
 R.tick=R.tick+1
end
