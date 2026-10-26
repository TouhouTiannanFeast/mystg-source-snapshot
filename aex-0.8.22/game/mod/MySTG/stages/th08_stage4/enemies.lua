local T=th08s4
local function large_bullet(f)
    while true do
        T.emit(f,1.5,f.angle-180,2,2,{change={after=50,speed=2.5}})
        task.Wait(21)
    end
end
local function center_bullet(f)
    local delay=32
    while true do
        T.volley(f,'fan',1,6,1,2,2.2,1.2,f.angle,0)
        delay=math.max(8,delay-1); task.Wait(delay)
    end
end
T.Enemy=Class(enemy)
function T.Enemy:init(e)
    enemy.init(self,e.kind=='Sub7' and 7 or (e.drop==1 and 1 or 2),e.hp,false,false,false)
    self.x,self.y=T.xy(e.x,e.y); self.drop={1,1,0}; self.kind=e.kind
    self.mirror=e.mirror; self.a,self.b=12,12
    self.speed,self.angle=0,e.mirror and 180 or 0
    T.own(self,false); T.stats.waves=T.stats.waves+1
    task.New(self,function()
        if e.kind=='Sub0' or e.kind=='Sub12' then
            local target=e.kind=='Sub0' and 4 or 2
            for i=1,30 do self.speed=3*T.ease(i/30,4); task.Wait(1) end
            self.speed=target; self.curve=T.rad(0.0015707964)*(e.mirror and -1 or 1)
            if e.kind=='Sub0' then
                task.New(self,function()
                    while true do
                        T.volley(self,'aimed',6,6,1,1,3.2,2,0,0,{boost=true})
                        T.volley(self,'aimed',6,6,2,1,2,1,0,T.rad(0.3926991),{boost=true}); task.Wait(33)
                    end
                end)
                task.New(self,function()
                    while true do T.emit(self,3,T.aim(self),6,6); T.emit(self,1.6,T.aim(self)-180,6,6); task.Wait(10) end
                end)
            else
                while true do T.volley(self,'aimed',2,6,6,1,1.2,1,0,T.rad(0.34906584)); task.Wait(21) end
            end
        elseif e.kind=='Sub3' then
            self.angle=-90
            for i=1,30 do self.speed=2*T.ease(i/30,4); task.Wait(1) end
            self.speed=2.5; self.curve=T.rad(0.0015707964)*(e.mirror and -1 or 1)
            T.emit(self,3,T.aim(self),6,6); T.emit(self,1.5,T.aim(self)+180,6,6)
        elseif e.kind=='Sub5' then
            self.angle=-90
            for i=1,50 do
                self.speed=2*T.ease(i/50,4)
                if i==30 then T.volley(self,'ring_aimed',2,2,32,1,1.5,0.8,0,0) end
                task.Wait(1)
            end
            self.speed=0.5
            for i=1,4 do New(T.Familiar,self,-90+(i-1)*90,T.rad(-0.05235988),0.8333333,6,180,nil,{expand=60}); task.Wait(10) end
            task.Wait(600); self.accel=-0.02
        elseif e.kind=='Sub7' then
            self.angle=-90
            local side=e.x<192 and 1 or -1
            for i=0,2 do
                New(T.Familiar,self,T.rad(-math.pi+i*2*math.pi/3),T.rad(side*0.10471976),1.5,2,300,large_bullet,{expand=20})
                New(T.Familiar,self,T.rad(-math.pi+i*2*math.pi/3),T.rad(-side*0.07853982),2.5,6,300,center_bullet,{expand=20})
            end
            for i=1,30 do self.speed=4*T.ease(i/30,4); task.Wait(1) end
            self.speed=0.3
            task.Wait(650); self.speed=2
        else error('unsupported active TH08 4B enemy '..e.kind) end
    end)
end
function T.Enemy:frame()
    enemy.frame(self)
    self.angle=self.angle+(self.curve or 0)
    self.speed=self.speed+(self.accel or 0)
    self.vx,self.vy=self.speed*cos(self.angle),self.speed*sin(self.angle)
    if self.timer>1500 or (self.timer>30 and (math.abs(self.x)>300 or self.y>330 or self.y< -300)) then Del(self) end
end
function T.Enemy:kill() T.owned[self]=nil; enemy.kill(self) end
function T.Enemy:del()
    T.owned[self]=nil
    for o in pairs(T.owned) do if IsValid(o) and o.owner==self then Del(o) end end
    enemybase.del(self)
end
