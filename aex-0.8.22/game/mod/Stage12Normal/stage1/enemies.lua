local T=th14
local r=T.rad
T.Enemy=Class(enemy)
local function shotA(o)
    task.Wait(T.randint(0,299)); T.emit(o,1.2,T.aim(o),5,6,{boost=true})
end
local function shotB(o)
    task.Wait(60)
    T.ring(o,1.2,1,T.rand(-180,180),16,1,8,4)
    for i=1,3 do
        for j=1,3 do T.emit(o,T.g.speed(1.2,1,j,3),T.aim(o),6,6,{boost=true}) end
        task.Wait(40)
    end
end
local function shotC(o)
    task.Wait(60)
    for wave=1,3 do
        for i=0,11 do T.emit(o,1+i*0.1,T.aim(o),8,6); task.Wait(4) end
        task.Wait(60)
    end
end
local function shotD(o)
    task.Wait(60)
    for wave=1,4 do
        local speed,n=1.1,9
        for cluster=1,4 do
            local base=-90
            for i=0,n-1 do
                local a=base+r(-0.034906585*n/2+0.034907*i)
                T.emit(o,speed,a,5,9,{duration=30,turn=T.rand(-0.05,0.05)})
            end
            speed=speed+0.07; n=n-2; task.Wait(3)
            for i=1,2 do
                T.emit(o,speed,base,5,9,{duration=30,turn=T.rand(-0.1,0.1)})
                speed=speed+0.07; task.Wait(3)
            end
        end
        task.Wait(180)
    end
end
local function shotD2(o)
    task.Wait(60)
    for wave=1,4 do
        local speed=1.1
        for i=1,4 do T.emit(o,speed,-90,18,3); speed=speed+0.21; task.Wait(9) end
        task.Wait(180)
    end
end
function T.Enemy:init(kind,x,y,hp,mirror)
    local red=kind:find('Red')
    local style=kind=='Phantom02' and 15 or (red and 1 or 2)
    if kind=='GirlB01' or kind=='GirlC01' or kind=='GirlD01' then style=7 end
    enemy.init(self,style,math.max(1,math.ceil(hp*3/28)),false,false,false)
    self.x,self.y=T.g.position(x,y)
    local powerDrops={GirlB01=8,GirlC01=9,GirlD01=15}
    self.drop={powerDrops[kind] or 1,1,0}
    self.th14_kind=kind
    self.a,self.b=kind=='Phantom02' and 8 or 12,kind=='Phantom02' and 8 or 12
    self.A,self.B=self.a,self.b -- Keep intended hitbox when the old walk system changes img.
    T.track(self); T.stats.waves=T.stats.waves+1
    local side=mirror and -1 or 1
    if (kind=='GirlB01' or kind=='GirlC01' or kind=='GirlD01') and x>0 then side=-1 end
    local function angle(a) return side==1 and r(a) or 180-r(a) end
    task.New(self,function()
        if kind:find('A01') then
            local variant=kind:sub(-1)
            if variant=='c' then
                if x>0 then side=-1 end -- moveSetMirror(1) replaces, rather than toggles, creation mirror.
                T.vel(self,angle(0),4)
                T.veltime(self,60,0,angle(0),2.4)
                task.Wait(60); task.New(self,function() shotA(self) end)
                task.New(self,function()
                    for i=1,160 do self.th14_angle=angle(0.017453*i); task.Wait(1) end
                end)
                -- Speed interpolation must not overwrite the independent turn.
                local initial_speed=self.th14_speed
                task.New(self,function()
                    for i=1,100 do self.th14_speed=initial_speed+(1.4-initial_speed)*T.g.ease(i/100,1); task.Wait(1) end
                end)
            else
                T.vel(self,angle(1.1780972),4)
                T.veltime(self,60,0,angle(0.7853982),variant=='b' and 2.4 or 1.4)
                task.Wait(60); task.New(self,function() shotA(self) end)
                T.veltime(self,120,0,angle(-0.7853982),1.2)
                task.Wait(120)
                local a=math.pi+T.rand(-1,1)*0.08726646
                T.veltime(self,120,0,angle(a),variant=='b' and 2.5 or 0.5)
                if variant~='b' then task.Wait(180); T.veltime(self,60,0,angle(a),2) end
            end
        elseif kind=='GirlB01' then
            T.vel(self,-90,2.3); T.veltime(self,80,1,-90,0)
            task.New(self,function() shotB(self) end)
            task.Wait(180); T.veltime(self,80,1,angle(0.3926991),1)
        elseif kind=='GirlC01' then
            T.vel(self,angle(0.7853982),3); T.veltime(self,80,1,angle(0),1)
            task.New(self,function() shotC(self) end)
        elseif kind=='GirlD01' then
            T.vel(self,-90,3); T.veltime(self,80,1,-90,0)
            task.New(self,function() shotD(self) end)
            task.New(self,function() shotD2(self) end)
            task.Wait(80); T.vel(self,angle(0.3926991),0)
            T.veltime(self,120,1,angle(0.3926991),0.6)
        elseif kind=='Phantom02' then
            T.vel(self,angle(0.3926991),1)
            T.veltime(self,120,0,angle(0.3926991),2)
            -- Ellipse-relative motion is an explicit approximation.
            self.th14_wobble=T.rand(-180,180)
            task.New(self,function()
                task.Wait(120+T.randint(0,399)); T.emit(self,1,T.aim(self),5,6)
            end)
        else error('unsupported active stage-one enemy '..kind) end
    end)
end
function T.Enemy:frame()
    enemy.frame(self)
    if not IsValid(self) then return end
    if self.stage12Probe then
        if self.timer==10 then print('BALANCE HITBOX '..self.th14_kind..' a='..self.a..' b='..self.b) end
        self.x,self.y=0,112;self.vx,self.vy=0,0;return
    end
    local speed,a=self.th14_speed or 0,self.th14_angle or 0
    self.vx,self.vy=speed*cos(a),speed*sin(a)
    if self.th14_wobble then self.vy=self.vy+0.7*sin(self.th14_wobble+self.timer*2) end
    if self.timer>1200 or (self.timer>80 and (math.abs(self.x)>270 or self.y>330 or self.y< -280)) then Del(self) end
end
function T.Enemy:kill() T.owned[self]=nil; enemy.kill(self) end
function T.Enemy:del() T.owned[self]=nil; enemybase.del(self) end
function T.spawn(kind,x,y,hp,mirror)
    if setting.stage12_test then assert(not IsValid(T.midboss),'fairy spawned while Momiji active') end
    return New(T.Enemy,kind,x,y,hp,mirror)
end

function T.Enemy:render()
 local k=self.th14_kind;local age=self.timer or 0;local dx=self.vx or 0;local sprite
 if k=='Phantom02' then
  local seq=Stage1GhostAnimation;local n=Stage12Art.sample(seq,age)
  Render('u.ghost-'..n,self.x,self.y)
 else
  local big=k=='GirlB01' or k=='GirlC01' or k=='GirlD01'
  local base=big and 96 or (k:find('Red') and 12 or 24)
  sprite=base+(math.abs(dx)>0.3 and 4 or 0)+math.floor(age/5)%4
  Render('u.fairy-'..sprite,self.x,self.y,0,dx<0 and -1 or 1,1)
 end
end

function T.Enemy:colli(other)
 local before=self.hp;enemybase.colli(self,other)
 if setting.stage12_combat_probe and other.dmg and self.hp<before then
  print('BALANCE HIT '..self.th14_kind..' hp='..before..'->'..self.hp..' dmg='..other.dmg)
 end
end
