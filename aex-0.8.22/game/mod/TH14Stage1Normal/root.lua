Include('THlib.lua')
Include('host.lua')
Include('enemies.lua')
Include('boss.lua')
Include('stage.lua')
-- QA controls exist only in opt-in verification launches.
local old_after=AfterFrame
AfterFrame=function()
    old_after()
    if stage.current_stage and stage.current_stage.name=='Misty Lake@Normal' then
        th14.stage_frames=th14.stage_frames+1
        if setting.th14_autotest and IsValid(player) then
            player.protect=1000
            if setting.th14_killtest and _boss and IsValid(_boss) and _boss.is_combat and _boss.__card_timer>300 then _boss.hp=0 end
        end
    end
end
if setting.th14_autostart then
    stage_init.frame=function(s)
        if s.timer==30 then
            lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
            stage.group.Start('Normal')
        end
    end
end
if setting.th14_autotest then
    if setting.th14_fast then
        local old_frame=DoFrame
        DoFrame=function(...)
            for i=1,8 do old_frame(...) end
        end
    end
    local old_menu=stage_menu.frame
    stage_menu.frame=function(s)
        old_menu(s)
        if th14.finished and s.timer>=30 then stage.Set('stage.quit') end
    end
    local captured={}
    local function capture(id)
        captured[id]=true
        local path='userdata/snapshot/th14-'..id..'-'..os.date('%Y%m%d-%H%M%S')..'.jpg'
        lstg.Snapshot(path); print('TH14 SNAPSHOT '..path)
    end
    local old_render=RenderFunc
    RenderFunc=function()
        old_render()
        local id=_boss and IsValid(_boss) and _boss.th14_phase
        if id and not captured[id] and _boss.__card_timer>240 then
            capture(id)
        end
        if th14.stage_frames>=1000 and th14.stage_frames<2420 and not captured.front then capture('front') end
        if th14.stage_frames>=4600 and th14.stage_frames<5000 and not captured.latter then capture('latter') end
    end
end
