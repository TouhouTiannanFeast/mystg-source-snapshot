-- Background-only native fixture: no route, shots, boss, player graphics or balance changes.
local B=Th18Stage5Background
local oldFrame,oldRender=AfterFrame,RenderFunc
local valleyTest=setting.th18_stage5_background_valley_test;local tag=valleyTest and 'BG12' or 'BG11'
local sequence={{180,'0180'},{2176,'2176'},{2688,'2688'},{3100,'3100'},{3400,'3400'},{4300,'4300'},{6000,'6000'},{0,'boss-000',true},{600,'boss-600'}}
if valleyTest then sequence={{4176,'before-midboss','hold'},{0,'midboss-entry','midboss'},{2776,'entry-plus600'},{3100,'entry-plus924'},{3400,'entry-plus1224'},{4300,'late-valley'}}end
local slot,ticks,ready,finished=1,0,nil,false
AfterFrame=function(...)
 oldFrame(...)
 if finished or not B.current or not IsValid(player)then return end
 player.hide=true;player.protect=1000
 task.Clear(stage.current_stage)
 ticks=ticks+1
 local entry=sequence[slot]
 if entry and ticks>=91 and ticks%30==1 then
  local s=B.current.state
  if entry[3]=='hold' then B.armMidboss(s);for i=s.age+1,entry[1]do B.stageStep(s)end
  elseif entry[3]=='midboss' then
   local oldY=B.camera(s)[2];B.beginValley(s);assert(math.abs(B.camera(s)[2]-oldY)<1e-5,'camera scroll snap');print('BG12 MIDBOSS TRIGGER source='..s.age)
  elseif entry[3]then B.interrupt(s,1)end
  if entry[3]=='hold' then assert(s.age<=2047 and s.anms[1].values.color[1]==255,'early valley before midboss')
  elseif entry[3]=='midboss' then assert(s.age==2176 and s.valleyStarted,'missing midboss transition')
  elseif slot==9 then for i=1,entry[1]do B.step(s)end
  else while s.age<entry[1]do B.step(s)end end
  ready=entry[2]
  print(tag..' STATE '..ready..' age='..s.age..' clock='..s.std.clock..' loops='..s.loops..' tree1x='..s.anms[1].values.pos[1])
 end
 if ticks>=390 then print(tag..' COMPLETE fps='..tostring(GetFPS()));finished=true;stage.Set('stage.quit')end
end
RenderFunc=function(...)
 oldRender(...)
 if ready then
  local path='userdata/snapshot/'..(valleyTest and 'bg12-' or 'bg11-')..ready..'.jpg';lstg.Snapshot(path);print(tag..' SNAPSHOT '..path);ready=nil;slot=slot+1
 end
end
