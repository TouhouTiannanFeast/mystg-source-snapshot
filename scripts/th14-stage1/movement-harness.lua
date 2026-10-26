-- Run actual enemy tasks; compare independent angular/speed channels and the
-- replacement semantics of moveSetMirror(1) for right-hand A01c spawns.
object={}; enemy={}; enemybase={}; bullet={}
function Class(base) return setmetatable({base=base},{__index=base}) end
function enemy.init(o) o.hp=100; o.valid=true end
function IsValid(o) return o and o.valid~=false end
function Del(o) o.valid=false end
function Include() end
function cos(a) return math.cos(a*math.pi/180) end
function sin(a) return math.sin(a*math.pi/180) end
ran={}
function ran:Float(a,b) return (a+b)/2 end
function ran:Int(a,b) return math.floor((a+b)/2) end
task={}
local jobs,clock={},0
function task.Wait(n) coroutine.yield(n or 1) end
function task.New(owner,fn) jobs[#jobs+1]={co=coroutine.create(fn),owner=owner,wake=clock} end
function test_c(mirror,x)
    jobs={}; clock=0
    local o={}
    th14.Enemy.init(o,'GirlRedA01c',x,32,100,mirror)
    th14.emit=function() end
    for frame=0,220 do
        clock=frame
        local i=1
        while i<=#jobs do
            local j=jobs[i]
            if coroutine.status(j.co)~='dead' and j.wake<=clock then
                local ok,wait=coroutine.resume(j.co); assert(ok,wait); j.wake=clock+(wait or 1)
            end
            i=i+1
        end
    end
    return o.th14_angle,o.th14_speed
end
