local old=AfterFrame;local saved={}
AfterFrame=function(...)
 old(...)
 local R=Suwako5Runtime
 if not IsValid(player)or not R.spec then return end
 player.protect=1000
 for _,t in ipairs({65,85,115})do
  if R.tick==t and not saved[t]then
   saved[t]=true;lstg.Snapshot('userdata/snapshot/dsd17-'..t..'.jpg')
   print('DSD17 SNAPSHOT '..t)
  end
 end
 if R.tick==260 then
  assert(R.photos==2 and R.dsLaserWaves==3)
  print('DSD17 PASS native third-wave stage2');stage.Set('stage.quit')
 end
end
