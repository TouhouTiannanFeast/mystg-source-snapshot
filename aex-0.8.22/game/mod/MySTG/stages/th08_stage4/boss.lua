local T=th08s4
local phase_specs={
    non1={sub=17,time=40,hp=15700,inv=180},milky={sub=36,time=40,hp=2300,inv=270,name='Magic Sign / Milky Way'},
    non2={sub=22,time=40,hp=15600,inv=240},stardust={sub=41,time=65,hp=2400,inv=690,name='Magic Sign / Stardust Reverie'},
    non3={sub=28,time=40,hp=15500,inv=240},nondirectional={sub=47,time=45,hp=2500,inv=390,name='Love Sign / Non-Directional Laser'},
    non4={sub=31,time=40,hp=16000,inv=240},master={sub=55,time=50,hp=2000,inv=390,name='Love Sign / Master Spark'},
    earthlight={sub=62,time=55,hp=2500,inv=390,name='Light Sign / Earthlight Ray'},
    final={sub=67,time=65,hp=2500,inv=390,name='Magicannon / Final Spark'}
}
T.phase_specs=phase_specs
local palettes={2,4,6,10,13,14,8}
local function group(o,n,base,angular,radial,behavior,opt)
    local result={}
    for i=1,n do
        result[i]=New(T.Familiar,o,base+(i-1)*360/n,angular,radial,palettes[(i-1)%#palettes+1],1000,behavior,opt)
    end
    return result
end
local function non1_f(f)
    local spread=120; local i=0
    while true do
        local typ=i%2==0 and 13 or 12
        T.emit(f,1.4,f.angle,typ,f.color)
        T.emit(f,2,f.angle-spread,typ==13 and 12 or 13,f.color)
        T.emit(f,1.6,f.angle+spread,typ,f.color)
        i=i+1; if i>=30 then spread=spread+1.8 end
        task.Wait(7)
    end
end
local function non2_f(f)
    local offset,i=0,0
    while true do
        T.volley(f,'ring',i%2==0 and 13 or 12,f.color,2,1,1.1,0.9,f.angle+offset,0)
        i=i+1; if i>=20 then offset=offset+1.8 end
        task.Wait(10)
    end
end
local function non3_f(f)
    local offset,i=0,0
    while true do
        T.emit(f,1.1,f.angle+offset,i%2==0 and 13 or 12,f.color,
            {duration=300,accel=T.rand(-0.001,0.001),turn=T.rad(T.rand(-math.pi,math.pi)/300)})
        offset=offset+6; i=i+1; task.Wait(10)
    end
end
local function non4_f(f)
    local offset,i=0,0
    while true do
        T.emit(f,1.4,f.angle+offset,i%2==0 and 13 or 12,f.color)
        offset=offset+6; i=i+1; task.Wait(5)
    end
end
local function familiar_count(o)
    local count=0
    for f in pairs(T.phase_objects) do if IsValid(f) and f.owner==o and f.behavior then count=count+1 end end
    return count
end
local function nonspell(o,id)
    task.Wait(id=='non1' and 60 or 120)
    if id=='non1' then
        group(o,5,-180,T.rad(-0.02617994),1.0666667,non1_f)
        task.New(o,function()
            while true do
                if IsValid(player) and Dist(o,player)<128 then
                    T.volley(o,'ring',14,6,16,1,3.4,0.9,T.rand(-180,180),0)
                    T.volley(o,'ring',15,6,16,1,2.4,0.9,T.rand(-180,180),0)
                end
                task.Wait(8)
            end
        end)
    elseif id=='non2' then
        group(o,5,-180,T.rad(-0.0062831854),1.0666667,non2_f)
        group(o,5,0,T.rad(0.006981317),0.53333336,non2_f)
    elseif id=='non3' then
        group(o,4,-180,T.rad(-0.06283186),0.8,non3_f)
        group(o,4,0,T.rad(0.02617994),1.0666667,non3_f)
        group(o,4,0,T.rad(-0.03926991),1.3333334,non3_f)
    else group(o,7,-180,T.rad(-0.10471976),0.6666667,non4_f) end
    if id=='non1' or id=='non4' then
        task.New(o,function()
            local limit=id=='non1' and 5 or 12
            while true do
                if familiar_count(o)<limit then
                    New(T.Familiar,o,-180,T.rad(-0.02617994),1.0666667,13,700,id=='non1' and non1_f or non4_f)
                end
                task.Wait(120)
            end
        end)
    end
    while true do task.Wait(420); T.drift(o,80,id=='non1' and 1.5 or 1) end
end
local function milky_f(f)
    while true do
        for i=1,4 do T.volley(f,'fan',12,f.color,3,1,2.3,0.9,f.angle,T.rad(0.049087387)); task.Wait(10) end
        task.Wait(200)
    end
end
local function milky(o)
    T.move(o,192,128,90,4)
    group(o,5,-180,T.rad(0.006544985),0.8,milky_f)
    task.New(o,function()
        local a=T.rand(-180,180); local typ=14
        while true do
            T.volley(o,'ring',typ,typ==14 and 1 or 3,9,1,1.8,0.9,a,0)
            a=a+7.5; typ=typ==14 and 15 or 14; task.Wait(15)
        end
    end)
    task.Wait(180)
    while true do
        for zone=1,4 do
            local x=zone<=2 and -7 or 391
            local y=T.rand(0,224)+(zone%2==0 and 224 or 0)
            local p={}; p.x,p.y=T.xy(x,y); p.th08_phase_owned=true
            T.emit(p,T.rand(0.8,1.3),T.rad((zone<=2 and 0.3926991 or 2.7488935)+T.rand(-0.09817477,0.09817477)),zone<=2 and 12 or 13,zone<=2 and 13 or 10)
            task.Wait(4)
        end
    end
end
local function stardust_update(f)
    local age=f.timer
    local base=T.rad(-0.009817477)
    if age<120 then f.angular=base*4
    elseif age<180 then f.angular=base*(4-3*(age-120)/60)
    elseif age<420 then f.radius=f.radius+0.53333336; f.angular=base
    elseif age<480 then f.angular=base*(1+0.4*(age-420)/60)
    elseif age<720 then f.angular=base*1.4
    else
        local cycle=math.floor((age-720)/480); local t=(age-720)%480
        local speed=base*1.4*((-1.04)^cycle)
        if t<240 then f.radius=math.max(0,f.radius-0.9); f.angular=speed
        elseif t<300 then f.angular=speed
        elseif t<420 then f.radius=f.radius+1.8; f.angular=speed
        else f.angular=speed+(speed*(-1.04)-speed)*(t-420)/60 end
    end
end
local function stardust_f(f)
    while true do
        local age=f.timer
        if age<420 or (age>=720 and (age-720)%480<300) then
            local a=f.angle+(age<420 and 90 or -90)
            local n=age<420 and 60 or 90
            T.emit(f,0,f.angle,12,f.color,{duration=n,ax=(1/60)*cos(a),ay=(1/60)*sin(a)})
            task.Wait(10)
        else T.volley(f,'fan',13,f.color,7,1,1,0.9,f.angle,30); task.Wait(4) end
    end
end
local function stardust(o)
    T.move(o,192,224,90,4)
    group(o,7,T.rand(-180,180),T.rad(-0.009817477)*4,0.8,stardust_f,{update=stardust_update})
    while true do task.Wait(100) end
end
local function laser_f(f)
    local delay=f.opt.delay or 0
    task.Wait(delay)
    task.New(f,function()
        while true do
            local b=New(T.Beam,f,f.x,f.y,f.angle,320,16,f.color,60,150,20,f.angular)
            -- Rotation and attachment follow the source familiar each frame.
            b.follow_angle=true
            task.Wait(330)
        end
    end)
    task.Wait(200-delay)
    local color,i=1,0
    while true do
        T.emit(f,2,f.angle+180,i%2==0 and 15 or 14,color)
        color=color%6+1; i=i+1; task.Wait(13)
    end
end
local function nondirectional(o)
    T.move(o,192,160,90,4)
    group(o,5,T.rad(2.7488935),T.rad(0.003807991),0.53333336,laser_f,{delay=0})
    group(o,5,T.rad(0.7853982),T.rad(-0.003807991),0.53333336,laser_f,{delay=120})
    task.Wait(300)
    while true do
        local a=T.rand(-180,180)
        local speed=IsValid(player) and player.y>96 and 3.5 or 1.4
        for i=0,5 do T.emit(o,3,a-i*60,i%2==0 and 13 or 12,palettes[i+1],{change={after=60,speed=speed}}) end
        task.Wait(60)
    end
end

local function spark_stars(o,final,reverse)
    if final then
        local a=T.rand(-180,180)
        for burst=1,36 do
            T.volley(o,'ring',burst%2==0 and 15 or 14,burst%2==0 and 3 or 1,8,1,1.8,0.9,a,0,
                {wait=60,duration=240,accel=0.015})
            a=a+(reverse and -7.5 or 7.5); task.Wait(10)
        end
    else
        local i=0
        while true do
            local color=i%6+1
            T.volley(o,'ring',i%2==0 and 15 or 14,color,11,1,color==6 and 2.5 or 2,0.1,T.rand(-180,180),0,{duration=60,accel=1/60})
            T.volley(o,'ring',i%2==0 and 14 or 15,color,11,1,1,0.1,T.rand(-180,180),0)
            i=i+1; task.Wait(24)
        end
    end
end
local function spark(o,final)
    T.move(o,192,160,90,4)
    local first=true; local reverse=false
    while true do
        task.New(o,function() T.drift(o,80,final and 0.5 or (first and 1 or 0.5)) end)
        local aim=final or not first
        -- Aim is locked when the beam is spawned, before its 120-frame warning.
        task.Wait(60)
        local a=aim and T.aim(o) or -90
        local b=New(T.Beam,nil,o.x,o.y,a,650,final and 220 or 180,6,120,190,60,0)
        if final then b.track_player=true; b.turn_limit=T.rad(0.0035699916) end
        if final then
            task.New(o,function() spark_stars(o,true,reverse) end)
        elseif first then
            task.New(o,function() task.Wait(100); spark_stars(o,false) end)
        end
        first=false; reverse=not reverse
        task.Wait(400)
    end
end
T.EarthEmitter=Class(object)
function T.EarthEmitter:init(owner,x,angle,color)
    self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY,false,false
    self.owner=owner; self.x,self.y=owner.x,owner.y
    self.th08_phase_owned=true; T.own(self,true)
    task.New(self,function()
        local ox,oy=self.x,self.y; local tx,ty=T.xy(x,448)
        for i=1,120 do local k=i/120; self.x,self.y=ox+(tx-ox)*k,oy+(ty-oy)*k; task.Wait(1) end
        local b=New(T.Beam,self,self.x,self.y,angle,600,16,color,60,40,20,0)
        task.Wait(140); Del(self)
    end)
end
function T.EarthEmitter:frame() task.Do(self) end
function T.EarthEmitter:render() Render('enemy_orb2',self.x,self.y,0,0.65,0.65) end
function T.EarthEmitter:del() T.owned[self]=nil; T.phase_objects[self]=nil end
local function earthlight(o)
    T.move(o,192,128,90,4)
    for _,x in ipairs({64,320,32,352}) do New(T.EarthEmitter,o,x,90,(x==64 or x==320) and 6 or 2) end
    task.Wait(120)
    task.New(o,function()
        while true do
            for i=0,1 do
                for _,speed in ipairs({3.5,2.5}) do
                    T.volley(o,'ring_aimed',i==0 and 12 or 13,13,1,32,speed,0.5,T.rad(i==0 and -2.0943952 or 2.0943952),T.rad(i==0 and 0.15707964 or -0.15707964))
                end
                task.Wait(i==0 and 20 or 60)
            end
            for i=1,4 do T.volley(o,'aimed',i%2==0 and 13 or 12,13,3,3,2.2,1,0,T.rad(0.07479983)); task.Wait(16) end
        end
    end)
    task.New(o,function() T.drift(o,80,0.5) end); task.Wait(80)
    local n=5; local side=1; local wave=0
    while true do
        local start=(side==1 and 32 or 352)+T.rand(-28,28)
        local step=n==5 and 80 or (n==6 and 64 or 53)
        for i=0,n-1 do
            local delta=wave>=2 and T.rand(-math.pi,math.pi)/(n==6 and 64 or 32) or 0
            New(T.EarthEmitter,o,start+side*i*step,90+T.rad(delta),side==1 and 6 or 2)
            task.Wait(8)
        end
        task.New(o,function() T.drift(o,80,0.5) end)
        task.Wait(200); side=-side; wave=wave+1
        if wave%2==0 then n=math.min(7,n+1) end
    end
end
function T.card(id)
    local spec=assert(phase_specs[id],'unknown Marisa phase')
    local c=boss.card.New(spec.name or '',math.floor(spec.inv/60),math.floor(spec.inv/60),spec.time,spec.hp,{5,5,0},false)
    c.t1=spec.inv; c.t2=spec.inv
    c.init=function(o)
        T.clear(true); T.stats.phases=T.stats.phases+1; o.th08_phase=id; o.th08_phase_owned=true
        T.label=spec.name or ('Marisa / '..id)
        print('TH08 PHASE START '..id..' frame='..T.frame)
        task.New(o,function()
            if id:sub(1,3)=='non' and id~='nondirectional' then nonspell(o,id)
            elseif id=='milky' then milky(o)
            elseif id=='stardust' then stardust(o)
            elseif id=='nondirectional' then nondirectional(o)
            elseif id=='master' or id=='final' then spark(o,id=='final')
            elseif id=='earthlight' then earthlight(o) end
        end)
    end
    c.del=function(o)
        T.clear(true); T.stats.ended=T.stats.ended+1
        print('TH08 PHASE END '..id..' frame='..T.frame)
    end
    c.after=function(o) if id=='stardust' then T.move(o,256,-32,60,1) end end
    return c
end
T.Marisa=Class(boss)
function T.Marisa:init(mode)
    local ids=mode=='mid' and {'non1','milky','non2','stardust'} or {'non3','nondirectional','non4','master','earthlight'}
    if phase_specs[mode] then ids={mode} end
    if mode=='boss' and setting.th08_include_final then ids[#ids+1]='final' end
    local cards={boss.move.New(0,96,60,MOVE_DECEL)}
    for _,id in ipairs(ids) do cards[#cards+1]=T.card(id) end
    boss.init(self,mode=='mid' and -160 or -224,256,'Marisa Kirisame',cards,nil,'Normal')
    self.a,self.b=24,16; self.fxr,self.fxg,self.fxb=255,210,80
end
function T.Marisa:render()
    self._bosssys:render()
    Render('enemy8_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.2,1.2)
end
