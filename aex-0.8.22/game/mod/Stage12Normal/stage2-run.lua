Include('assets.lua')
Include('magic-assets.lua')
Include('magic.lua')
Include('mamizou/attack.lua')
Include('flare/attack.lua')
Include('mystia/attack.lua')
Include('schedule.lua')
Include('route.lua')
Include('tail-waves.lua')
local R=Stage2Route
local function clean()
    Stage12Music.stop()
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
    Stage12Music.play('s2.route')
    Stage12Background.start(2);New(Hud);phase('Opening')
    local entry=setting.stage12_entry
    local starts={['s2-magic']=974,['s2-flare']=974,['s2-mystia']=4964}
    local mamizouStart=entry and tonumber(entry:match('^s2%-mz(%d)$'))
    local firstTick=mamizouStart and 5864 or starts[entry] or 0
    R.tick=firstTick
    local afterMid=false;local mystiaBoss;local tailIndex=0
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
        if e.t>=firstTick and not (e.t>=5164 and e.name:find('Girl00B')) then
        -- Start the post-midboss source schedule relative to actual defeat.
        if e.postmid and afterMid then R.tick=e.t;afterMid=false end
        while R.tick<e.t and not (e.name=='Boss' and mystiaBoss) do R.tick=R.tick+1;task.Wait(1) end
        if e.name=='MapleEnemy' then -- Background leaf effect has no gameplay attack.
        elseif e.name=='MBossDummy' then
            phase('Patchouli passage')
            if entry~='s2-flare' then local h=R.hina();while IsValid(h) do task.Wait(1) end end
            R.clean();phase('Royal Flare');Stage2Flare.reset()
            New(Stage2Magic.Entry,0,134);task.Wait(60)
            local b=New(Stage2Flare.Boss)
            while IsValid(b) do task.Wait(1) end
            Stage2Flare.clean();task.Wait(60);afterMid=true
        elseif e.name=='Girl02' then
            -- Keep the fourteen prior sunflowers intact until they leave.
            while next(R.enemies) do task.Wait(1) end
            R.clean();phase('Mystia');Stage2Mystia.reset()
            mystiaBoss=New(Stage2Mystia.Boss)
            Stage12Tail.run(mystiaBoss,R.spawn,IsValid,function(n) for _=1,n do R.tick=R.tick+1;task.Wait(1) end end,R)
            Stage2Mystia.clean();phase('Last fairy waves')
            assert(R.finalTail==6 and R.finalTailCleared,'final-six gate')
            print('STAGE12 FINAL SIX CLEARED count='..R.finalTail..' total='..R.tailFairies)
        elseif e.name=='Boss' then
            while IsValid(mystiaBoss) do task.Wait(1) end
            while next(R.enemies) do task.Wait(1) end
            R.clean();phase('Mamizou');Stage2Mamizou.reset();Stage12Music.play('s2.boss')
            local b=New(Stage2Mamizou.Boss,mamizouStart)
            while IsValid(b) do task.Wait(1) end
            Stage2Mamizou.clean();phase('Complete');R.finished=true;task.Wait(120)
        elseif e.t>=5164 and e.name:find('Girl00B') then -- Tail helper owns all post-Mystia reinforcements.
        else
            if e.postmid then
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
end
Stage2FullAPI={clean=clean,Hud=Hud}
