Include('THlib.lua')
Include('assets.lua')
Include('magic-assets.lua')
Include('magic.lua')
Include('mamizou/attack.lua')
Include('flare/attack.lua')
Include('mystia/attack.lua')
Include('schedule.lua')
Include('route.lua')
local musicName='s2.dark-road'
LoadMusic(musicName,'music/dark-road.wav',121.388117913832,117.693242630385)
-- Also handle globally loaded stage music outside the native stage-pool list.
local pauseSound,resumeSound=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
    pauseSound(self)
    self.stage2MusicPaused=GetMusicState(musicName)=='playing'
    if self.stage2MusicPaused then PauseMusic(musicName) end
end
function ext.pausemenu:ResumeSound()
    resumeSound(self)
    if self.stage2MusicPaused and GetMusicState(musicName)=='paused' then ResumeMusic(musicName) end
    self.stage2MusicPaused=false
end
local R=Stage2Route
local function clean()
    StopMusic(musicName)
    R.clean();Stage2Mamizou.clean();Stage2Flare.clean();Stage2Mystia.clean()
end
local Hud=Class(object)
function Hud:init() self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()
    RenderText('menu','STAGE 2 / '..R.phase,0,-199,0.22,'centerpoint')
    if R.tick>=420 and R.tick<560 then RenderText('menu','STAGE 2',0,15,0.7,'centerpoint') end
end
local function phase(name) R.phase=name;print('STAGE2 PHASE '..name..' source_tick='..R.tick) end
function Stage2FullRun(s)
    clean();R.tick=0;R.spawns=0;R.shots=0;R.lasers=0;R.human=0;R.tailHumans=0;R.tailFairies=0;R.mystiaOverlap=0;R.sunflowers=0;R.tangentChecks=0
    Stage2Mamizou.reset();Stage2Flare.reset();Stage2Mystia.reset()
    local _,bgm=EnumRes('bgm');for _,name in pairs(bgm)do StopMusic(name)end
    PlayMusic(musicName,1)
    New(default_stage_background);New(Hud);phase('Opening')
    local midActive=false;local mystiaBoss;local tailIndex=0
    local humanFlags={}
    local tailCount=0
    for _,e in ipairs(Stage2Schedule)do if e.t>=5164 and e.name:find('Girl00B')then tailCount=tailCount+1 end end
    for i=1,tailCount do humanFlags[i]=i<=math.floor(tailCount/2) end
    -- Seeded game RNG preserves the selection during replay.
    for i=tailCount,2,-1 do
        local j=math.min(i,math.floor(ran:Float(0,i))+1)
        humanFlags[i],humanFlags[j]=humanFlags[j],humanFlags[i]
    end
    for _,e in ipairs(Stage2Schedule) do
        while R.tick<e.t do R.tick=R.tick+1;task.Wait(1) end
        if e.name=='MapleEnemy' then -- Background leaf effect has no gameplay attack.
        elseif e.name=='MBossDummy' then
            phase('Patchouli passage');midActive=true
            task.New(s,function()
                local h=R.hina();while IsValid(h) do task.Wait(1) end
                R.clean();phase('Royal Flare');Stage2Flare.reset()
                New(Stage2Magic.Entry,0,134);task.Wait(60)
                local b=New(Stage2Flare.Boss)
                while IsValid(b) do task.Wait(1) end
                Stage2Flare.clean();task.Wait(60);midActive=false
            end)
        elseif e.name=='Girl02' then
            -- Keep the fourteen prior sunflowers intact until they leave.
            while next(R.enemies) do task.Wait(1) end
            R.clean();phase('Mystia');Stage2Mystia.reset()
            mystiaBoss=New(Stage2Mystia.Boss)
            task.New(s,function()
                while IsValid(mystiaBoss) do task.Wait(1) end
                Stage2Mystia.clean()
                if R.phase=='Mystia' then phase('Last fairy waves') end
            end)
        elseif e.name=='Boss' then
            while IsValid(mystiaBoss) do task.Wait(1) end
            while next(R.enemies) do task.Wait(1) end
            R.clean();phase('Mamizou');Stage2Mamizou.reset()
            local b=New(Stage2Mamizou.Boss)
            while IsValid(b) do task.Wait(1) end
            Stage2Mamizou.clean();phase('Complete');R.finished=true;task.Wait(120)
        else
            if e.postmid then
                while midActive do task.Wait(1) end
                if R.phase=='Royal Flare' then phase('Reinforcements') end
            end
            if e.name=='Girl01' and R.sunflowers==0 then phase('Fourteen sunflowers') end
            if e.name:find('Girl00C') then R.phase='Human fairy groups' end
            local event=e
            if e.t>=5164 and e.name:find('Girl00B') then
                tailIndex=tailIndex+1;event={}
                for k,v in pairs(e)do event[k]=v end
                event.human=humanFlags[tailIndex]
                R.tailFairies=R.tailFairies+1
                if event.human then R.tailHumans=R.tailHumans+1 end
                if IsValid(mystiaBoss) then R.mystiaOverlap=R.mystiaOverlap+1 end
            end
            R.spawn(event)
        end
    end
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Stage Two@Normal',nil,true)
stage.group.DefStageFunc('Stage Two@Normal','init',function(s)
    R.finished=false
    stage.group.initTask(s,function() Stage2FullRun(s) end)
end)
stage.group.DefStageFunc('Stage Two@Normal','del',clean)
stage_init.frame=function(s)
    if s.timer==30 then
        if setting.stage2_replay then
            stage.Set('Stage Two@Normal','load',setting.stage2_replay)
        else
            lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
            stage.group.Start('Normal')
        end
    end
end
Stage2FullAPI={clean=clean,Hud=Hud}
