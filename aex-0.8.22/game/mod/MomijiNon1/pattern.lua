-- Degrees, AEX coordinates. ECL source snapshots are in source/.
MomijiPattern={gunInterval=20,gunCount=8,gunSpacing=30,gunSpeed=2,
    echoInterval=422,echoWaveInterval=60,echoCount=72,echoSpacing=3.5,
    echoSpeed=2.8,start=60,duration=3600}
local P=MomijiPattern
function P.events(t)
    local e={}
    if t>=P.start then
        local age=t-P.start
        if age%P.gunInterval==0 then e[#e+1]={kind='gun'} end
        local n=age%P.echoInterval
        if n==0 or n==60 or n==120 then e[#e+1]={kind='scale',wave=n/60+1,round=math.floor(age/P.echoInterval)+1} end
    end
    return e
end
function P.angles(kind,aim,jitter)
    local count=kind=='gun' and P.gunCount or P.echoCount
    local spacing=kind=='gun' and P.gunSpacing or P.echoSpacing
    local center=aim+(kind=='scale' and 180 or (jitter or 0))
    local a={}
    for i=0,count-1 do a[#a+1]=center+(i-(count-1)/2)*spacing end
    return a,center
end
