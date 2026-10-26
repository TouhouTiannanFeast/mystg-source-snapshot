local T=th14
local r=T.rad
local function mid(o)
    task.Wait(160)
    task.New(o,function()
        task.Wait(300)
        local side=1
        while true do
            local a=side==1 and 0.3926991 or 2.7488935
            local base=r(a+T.rand(-math.pi,math.pi)/32)
            for layer=1,6 do
                T.emit(o,T.g.speed(8,1,layer,6),base+r(side*0.05235988*(layer-1)),20,4,{step=r(side*math.pi/2)})
            end
            side=-side; task.Wait(160)
        end
    end)
    local side=1
    while true do
        task.New(o,function()
            local a=0
            for i=1,8 do
                T.ring(o,1.1,1,r(a),2,8,10,6,{boost=true})
                a=a-side*0.17453292; task.Wait(6)
            end
        end)
        task.Wait(120); T.drift(o,60,1,140); task.Wait(20)
        side=-side
    end
end
local function nonspell(o,index)
    task.Wait(index==1 and 60 or 120)
    task.New(o,function()
        task.Wait(120)
        while true do
            local off=T.rand(-180,180); local dist=T.rand(0,32)
            local point={x=o.x+dist*cos(off),y=o.y+dist*sin(off)}
            T.emit(point,0.8,T.aim(o)+T.rand(-45,45),5,6,{boost=true})
            task.Wait(index==1 and 16 or 20)
        end
    end)
    local side=1
    while true do
        task.Wait(20)
        local step=r((index==1 and 0.349066 or 0.20944)*side)
        local a=T.aim(o)-step*5
        task.New(o,function()
            for i=1,(index==1 and 12 or 32) do
                T.fan(o,1.4,a,2,r(0.7853982),12,6,nil,20)
                a=a+step; task.Wait(4)
            end
        end)
        side=-side
        task.Wait(120); T.drift(o,30,2,140); task.Wait(2)
    end
end
local function tail(o)
    T.pos(o,0,128,60,4)
    local count,side=2,1
    while true do
        if side==1 then task.Wait(30) end
        local step=r(0.17453292)*side
        local spacing=r(side==1 and 0.097081 or 0.388322)
        local a=T.aim(o)-step*20
        for volley=1,60 do
            local b=a+spacing*count*side
            for i=0,count-1 do
                T.emit(o,0.4,b-spacing*i*side,12,6,
                    {wait=60,duration=60,accel=(0.8+0.4*i)/60,turn=r(T.rand(-math.pi,math.pi)/600)},20)
            end
            a=a+step; task.Wait(2)
        end
        task.Wait(120); T.drift(o,60,2,120); -- moveRand starts asynchronously in ECL.
        count=math.min(6,count+1); side=-side
    end
end

T.ScaleEmitter=Class(object)
function T.ScaleEmitter:init(owner,side)
    self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY,false,false
    self.owner,self.side=owner,side
    self.rx,self.ry=-112*side,-64
    self.x,self.y=owner.x+self.rx,owner.y+self.ry
    self.th14_angle=side==1 and 0 or -180
    self.th14_speed=0
    T.track(self)
    task.New(self,function()
        task.Wait(10)
        task.New(self,function()
            local a=side==1 and -180 or 0
            for i=1,400 do
                T.emit(self,0.1,a,12,side==1 and 10 or 8,{wait=60,duration=60,accel=0.025})
                a=a+r(-0.2617994*side); task.Wait(1)
            end
        end)
        -- Polar speed and angular interpolation are separate channels in ECL.
        local initial=self.th14_angle
        task.New(self,function()
            for i=1,120 do self.th14_angle=initial+r(-0.05235988*side)*i; task.Wait(1) end
        end)
        self.th14_speed=18
        local function speed(to,frames,mode)
            local from=self.th14_speed
            for i=1,frames do self.th14_speed=from+(to-from)*T.g.ease(i/frames,mode); task.Wait(1) end
        end
        speed(0,40,4); speed(8,20,0); speed(0,20,0); speed(18,40,1)
        task.Wait(20); Del(self)
    end)
end
function T.ScaleEmitter:frame()
    if not IsValid(self.owner) then Del(self); return end
    task.Do(self)
    self.rx=self.rx+self.th14_speed*cos(self.th14_angle)
    self.ry=self.ry+self.th14_speed*sin(self.th14_angle)
    self.x,self.y=self.owner.x+self.rx,self.owner.y+self.ry
end
function T.ScaleEmitter:del() T.owned[self]=nil end
local function scale(o)
    T.pos(o,0,192,60,4); task.Wait(60)
    local delay=300
    while true do
        New(T.ScaleEmitter,o,1)
        task.Wait(60)
        task.New(o,function() T.drift(o,60,0.8,140,192) end)
        New(T.ScaleEmitter,o,-1)
        task.Wait(60)
        task.New(o,function() T.drift(o,60,2,140,192) end)
        task.Wait(delay); delay=math.max(60,delay-60)
    end
end

local names={mid='Midboss / nonspell',non1='Boss / nonspell 1',tail='Water Sign / Tail Fin Slap',
    non2='Boss / nonspell 2',scale='Scale Sign / Scale Wave'}
function T.card(id)
    if id=='scale' then return Stage1Anchor.card() end
    local spell=id=='tail' or id=='scale'
    local hp=({mid=500,non1=700,tail=240,non2=700,scale=800})[id]
    local seconds=id=='mid' and 24 or (spell and 40 or 30)
    local card=boss.card.New(spell and names[id] or '',id=='non2' and 2 or 1,2,seconds,hp,{5,5,0},false)
    card.init=function(o)
        T.clean_bullets(); T.clean_actors()
        T.label=names[id]; T.stats.phases=T.stats.phases+1
        print('TH14 PHASE START '..id..' frame='..T.stage_frames)
        o.th14_phase=id
        task.New(o,function()
            if id=='mid' then
                task.New(o,function() T.pos(o,0,128,100,4) end)
                task.Wait(40); mid(o)
            elseif id=='non1' then nonspell(o,1)
            elseif id=='non2' then nonspell(o,2)
            elseif id=='tail' then tail(o)
            elseif id=='scale' then scale(o) end
        end)
    end
    card.del=function(o)
        T.clean_bullets(); T.clean_actors()
        T.stats.ended=T.stats.ended+1
        print('TH14 PHASE END '..id..' frame='..T.stage_frames)
    end
    card.after=function(o)
        if id=='mid' then T.pos(o,-224,-16,60,4) end
    end
    return card
end
T.Wakasagi=Class(boss)
function T.Wakasagi:init(is_mid,practice,continue_route)
    local cards
    if is_mid then cards={T.card('mid')}
    elseif practice and continue_route then
        cards={};local include=false
        for _,id in ipairs({'non1','context','non2','scale'}) do
            if id==practice then include=true end
            if include then cards[#cards+1]=id=='context' and Stage1Context.card() or T.card(id) end
        end
    elseif practice then cards={practice=='context' and Stage1Context.card() or T.card(practice)}
    else cards={T.card('non1'),Stage1Context.card(),T.card('non2'),T.card('scale')} end
    local x,y=T.g.position(is_mid and -192 or 0,is_mid and -64 or 128)
    boss.init(self,x,y,'Wakasagihime',cards,nil,'Normal')
    self.a,self.b=20,20
    self.fxr,self.fxg,self.fxb=80,180,255
end
function T.Wakasagi:render()
    self._bosssys:render()
    -- Bundled placeholder, intentionally no unverified original ANM mapping.
    Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.2,1.2)
end
