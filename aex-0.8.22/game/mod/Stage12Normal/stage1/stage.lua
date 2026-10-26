local T=th14
local function sub00(s)
    task.New(s,function()
        task.Wait(120)
        for i=1,14 do T.spawn('GirlRedA01',192,-16,140,true); task.Wait(30) end
        for i=1,2 do T.spawn('GirlBlueA01',192,-16,140,true); task.Wait(30) end
    end)
    for i=1,14 do T.spawn('GirlRedA01',-192,-16,140); task.Wait(30) end
    for i=1,2 do T.spawn('GirlBlueA01',-192,-16,140); task.Wait(30) end
end
local function sub02b(s)
    task.New(s,function()
        for i=1,4 do T.spawn('GirlRedA01b',192,-16,80,true); task.Wait(30) end
        for i=1,5 do T.spawn('GirlBlueA01b',192,-16,80,true); task.Wait(30) end
    end)
    for i=1,5 do T.spawn('GirlBlueA01b',-192,-16,80); task.Wait(30) end
    for i=1,4 do T.spawn('GirlRedA01b',-192,-16,80); task.Wait(30) end
end
local function pairwave(s,x,y,n,hp,mirror)
    for i=1,n do
        T.spawn('GirlRedA01c',x,y,hp,mirror); task.Wait(30)
        T.spawn('GirlBlueA01c',x,y,hp,mirror); task.Wait(30)
    end
end
local function front(s)
    sub00(s); task.Wait(400)
    T.spawn('GirlB01',128,-24,400); task.Wait(60)
    T.spawn('GirlB01',-96,-24,400); task.Wait(230)
    T.spawn('GirlC01',-224,32,600); task.Wait(120)
    T.spawn('GirlC01',224,32,600); task.Wait(180)
    T.spawn('GirlB01',0,-24,400)
    task.New(s,function() sub02b(s) end); task.Wait(240)
    task.New(s,function() pairwave(s,224,64,6,80,false) end)
    task.Wait(120); pairwave(s,-224,64,6,80,false); task.Wait(170)
end
local function latter(s,midboss)
    -- Shift the entire latter-half timeline, preserving internal wave spacing.
    while IsValid(midboss) do task.Wait(1) end
    print('TH14 POST-MOMIJI WAVES START frame='..T.stage_frames)
    task.New(s,function()
        task.Wait(700); T.spawn('GirlB01',-128,-24,400)
        task.Wait(200); T.spawn('GirlB01',-160,-24,400)
        task.Wait(290); T.spawn('GirlB01',160,-24,400)
    end)
    for i=1,33 do T.spawn('Phantom02',224,T.rand(-32,32),100,true); task.Wait(30) end
    for i=1,13 do T.spawn('Phantom02',-224,32+T.rand(0,1),100); task.Wait(30) end
    while IsValid(midboss) do task.Wait(1) end
    task.Wait(50); T.spawn('GirlD01',-96,-48,800)
    task.Wait(110); task.New(s,function() pairwave(s,224,32,6,100,true) end)
    task.Wait(160); T.spawn('GirlD01',96,-48,800,true)
    task.Wait(160); task.New(s,function() pairwave(s,-224,32,15,100,false) end)
    task.Wait(320)
    T.spawn('GirlD01',-64,-48,1000); T.spawn('GirlD01',64,-48,600,true)
    task.Wait(160); task.New(s,function() pairwave(s,224,32,6,100,true) end)
end
T.finished=false
T.stage_frames=0
stage.group.New('Normal','menu',{lifeleft=2,power=100,bomb=3},true,2)
stage.group.AddStage('Normal','Misty Lake@Normal',nil,true)
stage.group.DefStageFunc('Misty Lake@Normal','init',function(s)
    T.finished=false; T.stage_frames=0
    T.stats={spawned=0,waves=0,phases=0,ended=0}
    stage.group.initTask(s,function()
        Stage12Background.start(1); New(T.Hud)
        local fromBoss=({['s1-non1']='non1',['s1-context']='context',['s1-non2']='non2',['s1-scale']='scale'})[setting.stage12_entry]
        if fromBoss then
            Stage12Music.play('s1.boss')
            local b=New(T.Wakasagi,false,fromBoss,true)
            while IsValid(b) do task.Wait(1) end
        elseif setting.th14_practice then
            Stage12Music.play('s1.boss')
            local b=New(T.Wakasagi,false,setting.th14_practice)
            while IsValid(b) do task.Wait(1) end
        else
            Stage12Music.play('s1.route');task.Wait(60); if setting.stage12_entry~='s1-momiji' then front(s) end
            local mb=New(Stage1Momiji.Boss);T.midboss=mb
            task.Wait(160); latter(s,mb); task.Wait(600)
            T.clean_actors(); T.clean_bullets(); T.label='Wakasagihime'
            task.Wait(120) -- Brief replacement for the omitted dialogue.
            Stage12Music.play('s1.boss')
            local b=New(T.Wakasagi,false)
            while IsValid(b) do task.Wait(1) end
        end
        T.clean();Stage1Momiji.clean();Stage1Context.clean(); T.finished=true; T.label='Stage Clear'
        print(string.format('TH14 COMPLETE frames=%d waves=%d phases=%d ended=%d bullets=%d',
            T.stage_frames,T.stats.waves,T.stats.phases,T.stats.ended,T.stats.spawned))
        task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Misty Lake@Normal','del',function() T.clean();Stage1Momiji.clean();Stage1Context.clean();Stage12Music.stop() end)
