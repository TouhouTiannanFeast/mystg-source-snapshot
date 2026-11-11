-- Bounded acceptance observer. Loaded only by the explicit developer probe flag.
local C=SixStageCampaign
local install=C.install
function C.install(i,classes)
 install(i,classes)
 local mode=setting.six_combat_probe
 local sound=PlaySound
 PlaySound=function(name,...)
  if name=='cardget'or name=='fault'then print('COMBAT RESULT SOUND '..name)end
  return sound(name,...)
 end
 local ended
 if mode=='road'then
  local sound=lstg.PlaySound
  lstg.PlaySound=function(name,...)
   if name:match('^six%.th10%.')then C.roadAudioProbe=(C.roadAudioProbe or 0)+1 end
   assert(not name:match('^hs5%.se%.'),'road retained HSoB bank')
   return sound(name,...)
  end
 end
 if mode=='survival'or mode=='ordinary'or mode=='comet'then
  local result=boss.system.resultSpell
  boss.system.resultSpell=function(s,info)
   print('COMBAT RESULT survival='..tostring(info.time_sc)..' get='..tostring(info.getcard)..' timeout='..tostring(info.timeout))
   if mode=='survival'or mode=='comet'then assert(info.time_sc and info.getcard,'clean survival did not capture')
   else assert(not info.time_sc and not info.getcard and info.timeout,'ordinary timeout falsely captured')end
   result(s,info);ended=stage.current_stage.timer+30
  end
 end
 local after=AfterFrame
 AfterFrame=function(...)
  after(...)
  local t=stage.current_stage.timer
  if IsValid(player)then player.protect=100000 end
  if mode=='comet'and MarisaMixed.phase=='comet'and MarisaMixed.age==100 then
   local b=MarisaMixed.boss
   assert(b.t1==1800 and b.t2==1800 and b.t3==1800 and b.time_sc)
   local hp=b.hp;b.class.base.take_damage(b,1000000);assert(b.hp==hp,'survival took damage')
   print('COMBAT COMET IMMUNITY PASS t1=t2=t3=1800 hp='..b.hp)
  end
  if mode=='practice'then
   if MarisaMixed.phase=='stardust'and MarisaMixed.age==300 then
    assert(#MarisaMixed.boss.cards==7,'practice suffix lost cards')
    MarisaMixed.boss.hp=0
   elseif MarisaMixed.phase=='non1'and MarisaMixed.age==1 then
    assert(math.abs(MarisaMixed.boss.x)<.001 and math.abs(MarisaMixed.boss.y-135)<.001,'Stardust did not return to Milky practice landing')
    print('COMBAT RETURN PASS position=0,135')
   elseif MarisaMixed.phase=='non1'and MarisaMixed.age==100 then
    print('COMBAT PRACTICE PASS adjacent non1');C.snapshot='combat-practice';ended=t+30
   end
  elseif mode=='hit'then
   player_lib.debug_data.keep_shooting=true
   if not ended and t>180 then
    for o in pairs(SixStageCampaignHit.active)do
     if o.life==12 then
      assert(o.rot~=nil and o.vx==0 and o.vy==0,'ofuda impact leaked motion')
      print('COMBAT OFUDA PASS life=12 rot='..o.rot);C.snapshot='combat-hit';ended=t+10;break
     end
    end
   end
  elseif mode=='ordinary'and MarisaMixed.phase=='milky'and MarisaMixed.age==300 then
   assert(MarisaMixed.boss.maxhp==12000,'Milky Way HP incorrect')
  elseif mode=='road'and t==800 then
   assert((C.roadAudioProbe or 0)>0,'no original audio event played')
   print('COMBAT ROAD SOUND PASS events='..C.roadAudioProbe);ended=t+30
  elseif mode=='spark'and MarisaMixed.phase=='final'and MarisaMixed.age==800 then
   local beam,stars
   stars=0
   for o in pairs(th08s4.phase_objects)do
    if IsValid(o)then
     if o.spark then beam=o end
     if o.sourceType==14 or o.sourceType==15 then stars=stars+1;assert(o.layer>LAYER_ENEMY_BULLET-1)end
    end
   end
   assert(beam and beam.layer==LAYER_ENEMY_BULLET-1 and stars>0,'Spark/star layer order failed')
   assert(MarisaMixed.boss.maxhp==12000)
   print('COMBAT SPARK PASS stars='..stars);C.snapshot='combat-spark';ended=t+30
  elseif mode=='horou'and t==1000 then
   local R=Zuu4R
   local yellow=R.shot(player.x+192,224-player.y,0,90,548,0)
   local note=R.shot(player.x+200,224-player.y,0,90,356,0)
   C.probeYellow,C.probeNote=yellow,note
   New(bullet_deleter,0,-96)
  elseif mode=='horou'and t==1003 then
   assert(C.probeYellow.dead and not C.probeNote.dead,'native respawn filter failed')
   local tails=0
   for _,b in ipairs(Zuu4R.hazards)do if b.id==636 then assert(b.life==30);tails=tails+1 end end
   assert(tails>0,'no source bird tails')
   for _,p in ipairs(Zuu4R.fx.items)do assert(p.kind~='birdRing','extra non-source bird ring')end
   print('COMBAT HOROU PASS tails='..tails);C.snapshot='combat-horou';ended=t+30
  end
  if ended and t==ended-8 then C.snapshot='combat-'..mode end
  if ended and t>=ended then print('COMBAT NATIVE PASS '..mode);stage.QuitGame()end
  if t>5000 then error('combat probe deadline '..tostring(mode))end
 end
end
