local T=th08s4
local stage_name='Stage 4B@Normal'
T.stage_name=stage_name
stage.group.AddStage('Normal',stage_name,{lifeleft=4,power=400,bomb=5},true)
stage.group.DefStageFunc(stage_name,'init',function(s)
    T.finished=false; T.frame=0; T.label='Road to Marisa'
    T.stats={waves=0,phases=0,ended=0,bullets=0,beams=0}
    stage.group.initTask(s,function()
        New(default_stage_background); New(T.Hud)
        if setting.th08_practice then
            local practice=setting.th08_practice
            local zuu=practice=='boss' or practice:sub(1,4)=='zuu-'
            local b=New(zuu and Zuu4Boss or T.Marisa,practice:sub(1,4)=='zuu-' and practice:sub(5) or practice)
            while IsValid(b) do task.Wait(1) end
        else
            local previous=0
            for _,e in ipairs(th08_schedule) do
                if e.at>previous then task.Wait(e.at-previous) end
                previous=e.at
                if e.kind=='Sub14' then T.clear(false)
                elseif e.kind=='Sub16' or e.kind=='Sub27' then
                    T.clear(false)
                    local mid=e.kind=='Sub16'
                    local b=New(mid and T.Marisa or Zuu4Boss,mid and 'mid' or 'boss')
                    while IsValid(b) do task.Wait(1) end
                    T.label=mid and 'Stage 4B / latter road' or 'Stage Clear'
                elseif e.kind=='Sub15' or e.kind=='Sub35' then
                    -- Background-only actor; conditional Last Spell is explicit practice.
                else New(T.Enemy,e) end
            end
        end
        local remaining={}
        for o in pairs(T.owned) do remaining[#remaining+1]=o end
        T.clear(false); task.Wait(1)
        for _,o in ipairs(remaining) do assert(not IsValid(o),'TH08 stage teardown leaked an object') end
        T.finished=true; T.label='Stage Clear'
        print(string.format('TH08 COMPLETE frames=%d waves=%d phases=%d ended=%d bullets=%d beams=%d',T.frame,T.stats.waves,T.stats.phases,T.stats.ended,T.stats.bullets,T.stats.beams))
        task.Wait(120)
    end)
end)
stage.group.DefStageFunc(stage_name,'del',function() T.clear(false) end)

local old_after=AfterFrame
AfterFrame=function()
    old_after()
    if stage.current_stage and stage.current_stage.name==stage_name then
        T.frame=T.frame+1
        if setting.th08_autotest and IsValid(player) then
            player.protect=1000
            if setting.th08_killtest and _boss and IsValid(_boss) and _boss.is_combat and _boss.__card_timer>450 then _boss.hp=0 end
        end
    end
end
if setting.th08_autostart then
    stage_init.frame=function(s)
        if s.timer==30 then
            lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
            stage.group.PracticeStart(stage_name)
        end
    end
end
if setting.th08_autotest then
    if setting.th08_fast then
        local original_frame=DoFrame
        DoFrame=function(...) for i=1,8 do original_frame(...) end end
    end
    local original_menu=stage_menu.frame
    stage_menu.frame=function(s)
        original_menu(s)
        if T.finished and s.timer>=30 then stage.Set('stage.quit') end
    end
    local captured={}
    local original_render=RenderFunc
    RenderFunc=function()
        original_render()
        local id=_boss and IsValid(_boss) and _boss.th08_phase
        local capture_at=id=='earthlight' and 500 or 390
        if id and not captured[id] and _boss.__card_timer>capture_at then
            captured[id]=true
            local path='userdata/snapshot/th08-stage4-'..id..'-'..os.date('%Y%m%d-%H%M%S')..'.jpg'
            lstg.Snapshot(path); print('TH08 SNAPSHOT '..path)
        end
        if not setting.th08_practice and T.frame>1200 and T.frame<4000 and not captured.road then
            captured.road=true
            local path='userdata/snapshot/th08-stage4-road-'..os.date('%Y%m%d-%H%M%S')..'.jpg'
            lstg.Snapshot(path); print('TH08 SNAPSHOT '..path)
        end
    end
end
