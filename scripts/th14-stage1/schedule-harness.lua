-- Execute the actual stage composition with virtual frame time. No engine mock
-- claims about collision or visual rendering; native tests cover those boundaries.
th14={stats={},owned={},events={},finished=false,stage_frames=0}
local T=th14
local jobs,clock={},0
task={}
function task.Wait(frames) coroutine.yield(frames or 1) end
function task.New(owner,fn)
    local co=coroutine.create(fn)
    jobs[#jobs+1]={co=co,wake=clock,owner=owner}
    return co
end
function T.spawn(kind,x,y,hp,mirror)
    T.events[#T.events+1]={frame=clock,kind=kind,x=x,y=y,mirror=mirror}
end
function T.rand(a,b) return (a+b)/2 end
function T.clean() end
function T.clean_bullets() end
function T.clean_actors() end
function IsValid(o) return o and o.until_frame and clock<o.until_frame end
T.Wakasagi='boss'; T.Hud='hud'; default_stage_background='background'
T.boss_events={}
function New(class,mid,practice)
    if class=='boss' then
        local o={until_frame=clock+(mid and 1500 or 9600)}
        T.boss_events[#T.boss_events+1]={frame=clock,mid=mid}
        return o
    end
end
setting={}
stage={group={}}
function stage.group.New() end
function stage.group.AddStage() end
function stage.group.DefStageFunc(name,kind,fn) if kind=='init' then T.stage_init=fn end end
function stage.group.initTask(owner,fn) task.New(owner,fn) end
function T.run()
    T.stage_init({})
    for frame=0,20000 do
        clock=frame; T.stage_frames=clock
        local index=1
        while index<=#jobs do
            local j=jobs[index]
            if coroutine.status(j.co)~='dead' and j.wake<=clock then
                local ok,wait=coroutine.resume(j.co); assert(ok,wait)
                j.wake=clock+(wait or 1)
            end
            index=index+1
        end
        if T.finished then return T.events,T.boss_events end
    end
    error('actual stage schedule failed to finish')
end
