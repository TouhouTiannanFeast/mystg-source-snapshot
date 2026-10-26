-- Opt-in native probe; normal launch does not enter this branch.
if setting.stage12_player_probe then
 local Target=Class(enemy)
 function Target:init(y)
  enemybase.init(self,100);self.x,self.y=0,y;self.a,self.b=8,8;self.bound=false
 end
 function Target:frame() enemybase.frame(self) end
 function Target:render() Render('s2.enemy-0',self.x,self.y) end
 function Target:del() enemybase.del(self) end
 stage.group.DefStageFunc('Misty Lake@Normal','init',function(s)
  th14.finished=false;Stage2Route.finished=false
  stage.group.initTask(s,function()
   New(default_stage_background);task.Wait(120)
   assert(lstg.var.power==400 and player.support==4,'initial full Power')
   local a,b=New(Target,-64),New(Target,32)
   local shot=New(Stage12Player.Shot,0,-128,28,10,true)
   task.Wait(10)
   assert(a.hp==90 and b.hp==90,'native piercing duplicate/second target: '..a.hp..'/'..b.hp)
   print('PLAYER NATIVE PIERCE PASS front='..a.hp..' rear='..b.hp)
   Del(a);Del(b)
   local life=lstg.var.lifeleft
   player.death=100
   for i=1,140 do
    task.Wait(1);assert(lstg.var.power==400 and player.support==4,'death lowered Power')
    for _,o in ObjList(GROUP_ITEM) do
     assert(o.class~=item_power and o.class~=item_power_large and o.class~=item_power_full,'red item survived')
    end
   end
   assert(lstg.var.lifeleft==life-1 and player.death==0,'actual death lifecycle')
   print('PLAYER NATIVE DEATH/FULL POWER PASS life='..lstg.var.lifeleft)
   item.DropItem(0,64,{300,2,3});task.Wait(10)
   local count=0
   for _,o in ObjList(GROUP_ITEM) do
    assert(o.class~=item_power and o.class~=item_power_large and o.class~=item_power_full,'red drop');count=count+1
   end
   assert(count==5,'other item drops changed: '..count)
   print('PLAYER NATIVE DROP PASS other='..count..' red=0')
   player_lib.debug_data.keep_shooting=true
   task.Wait(180)
   lstg.Snapshot('userdata/snapshot/stage12-player-fast.jpg')
   player.slowlock=true
   task.Wait(90)
   lstg.Snapshot('userdata/snapshot/stage12-player-slow.jpg')
   print('PLAYER PROBE COMPLETE')
   th14.finished=true;Stage2Route.finished=true
  end)
 end)
end

-- A straight shot must be aligned with a moving Boss in the damage test.
-- Only moves the test player; never changes a Boss or production controls.
if setting.stage12_reimu_b_test then
 local previous=AfterFrame
 AfterFrame=function(...)
  previous(...)
  if IsValid(player) and _boss and IsValid(_boss) then
   player.x=math.max(-180,math.min(180,_boss.x))
  end
 end
end
