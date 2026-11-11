-- Bounded real-player-shot regression, loaded only by the explicit verifier.
local H,R=Th18Stage5Host,Th18Stage5Runtime
local oldFrame,oldDamage=AfterFrame,Damage
local target,initialHP,hitCount,sourceDropBefore,finished
local function finish(ok,why)
 if finished then return end;finished=true
 print('COLLISION09 '..(ok and 'PASS ' or 'FAIL ')..why)
 stage.Set('stage.quit')
end
Damage=function(o,n)
 if target and o.data==target then hitCount=hitCount+1 end
 return oldDamage(o,n)
end
player_lib.debug_data.keep_shooting=true
AfterFrame=function(...)
 oldFrame(...)
 if finished or not IsValid(player) or not Suwako5Stage.route then return end
 player.protect=1000
 if not target then
  for _,a in ipairs(R.actors)do if a.name=='Cir00' and a.host and IsValid(a.host)and a.age>0 then
   target=a;initialHP=a.hp;hitCount=0;sourceDropBefore=H.counts.spawned[1]or 0
   print('COLLISION09 START native='..tostring(GetAttr(a.host,'colli'))..' requested='..tostring(a.host._colli)..' hp='..a.hp..' hurt='..a.hurtW..'x'..a.hurtH)
   break
  end end
 end
 if target then
  player.x=target.x;player.y=-176
  if target.hp<initialHP and not target.damageLogged then
   target.damageLogged=true;print('COLLISION09 DAMAGE '..initialHP..' -> '..target.hp..' hits='..hitCount)
  end
  if target.dead then
   local drops=(H.counts.spawned[1]or 0)-sourceDropBefore
   finish(target.hp<=0 and hitCount>0 and drops>0,'death hp='..target.hp..' hits='..hitCount..' powerDrops='..drops)
  end
 end
 if R.tick>=600 then finish(false,'no shot kill; hits='..tostring(hitCount)..' hp='..tostring(target and target.hp))end
end
