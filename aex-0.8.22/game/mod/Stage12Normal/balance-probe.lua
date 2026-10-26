if setting.stage12_combat_probe then
 player_lib.debug_data.keep_shooting=true
 stage.group.DefStageFunc('Misty Lake@Normal','init',function(s)
  th14.finished=false;th14.stage_frames=0
  th14.stats={spawned=0,waves=0,phases=0,ended=0}
  stage.group.initTask(s,function()
   New(default_stage_background)
   task.Wait(120)
   for _,c in ipairs({{'GirlRedA01',140},{'GirlB01',400},{'GirlC01',600},{'GirlD01',800},{'Phantom02',100}}) do
    player.x,player.y=0,-176;lstg.var.power=100
    local e=th14.spawn(c[1],0,112,c[2]);e.stage12Probe=true
    local elapsed=0
    while IsValid(e) and elapsed<600 do task.Wait(1);elapsed=elapsed+1 end
    print('BALANCE CASE '..c[1]..' hp='..math.ceil(c[2]*3/28)..' remaining='..e.hp..' frames='..elapsed..' killed='..tostring(not IsValid(e)))
    if IsValid(e) then Del(e) end
    task.Wait(90)
   end
   th14.clean()
   for i=0,7 do
    New(th14.Bullet,-140+i*40,80,1.5,-90+i*45,12,4,{duration=120,turn=0.7})
   end
   task.Wait(90)
   lstg.Snapshot('userdata/snapshot/stage12-tangent-probe.jpg')
   th14.clean();th14.finished=true;Stage2Route.finished=true
   print('BALANCE PROBE COMPLETE')
  end)
 end)
end
