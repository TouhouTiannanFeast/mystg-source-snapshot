-- MySTG entry point for LuaSTG AEX+ v0.8.22.
-- The launcher mounts this mod and includes root.lua before switching to init.
Include("THlib.lua")
Include("systems/resources.lua")

-- Register the first difficulty and its temporary stage after THlib is ready.
Include("stages/normal.lua")

-- Stage-four Marisa route, with its own source schedule and owned objects.
Include("stages/th08_stage4/host.lua")
Include("stages/th08_stage4/enemies.lua")
Include("stages/th08_stage4/boss.lua")
Include("stages/th08_stage4/schedule.lua")
Include("stages/th08_stage4/stage.lua")

-- Stage-five Suwako pool and its isolated source scheduler.
Include("stages/suwako5/pool.lua")
Include("stages/suwako5/runtime.lua")
Include("stages/suwako5/projectiles.lua")
Include("stages/suwako5/programs.lua")
Include("stages/suwako5/art.lua")
-- TH18 stage4 route and full stage2 scenery feed the stage-five encounter.
Include("stages/th18_stage5/data.lua")
Include("stages/th18_stage5/anm.lua")
Include("stages/th18_stage5/runtime.lua")
Include("stages/th18_stage5/projectiles.lua")
Include("stages/th18_stage5/programs.lua")
Include("stages/th18_stage5/route.lua")
Include("stages/th18_stage5/background.lua")
Include("stages/th18_stage5/host.lua")
Include("stages/suwako5/stage.lua")
