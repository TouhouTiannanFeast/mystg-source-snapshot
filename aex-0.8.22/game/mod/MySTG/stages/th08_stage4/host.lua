-- Bounded native host for the TH08 4B reconstruction, isolated from stage one.
th08s4={owned={},phase_objects={},stats={waves=0,phases=0,ended=0,bullets=0,beams=0},frame=0,finished=false,label='Stage 4B / Marisa'}
local T=th08s4
function T.rad(a) return -a*180/math.pi end
function T.xy(x,y) return x-192,224-y end
function T.rand(a,b) return ran:Float(a,b) end
function T.aim(o) return IsValid(player) and Angle(o,player) or -90 end
function T.own(o,phase)
    T.owned[o]=true
    if phase then T.phase_objects[o]=true end
    return o
end
function T.clear(phase)
    local owned=phase and T.phase_objects or T.owned
    for o in pairs(owned) do
        if IsValid(o) then Del(o) end
        T.owned[o]=nil; T.phase_objects[o]=nil
    end
end
function T.ease(t,mode)
    if mode==1 then return t*t end
    if mode==4 then return 1-(1-t)^2 end
    return t
end
function T.move(o,x,y,n,mode)
    local ox,oy=o.x,o.y; local tx,ty=T.xy(x,y)
    for i=1,n do local k=T.ease(i/n,mode); o.x,o.y=ox+(tx-ox)*k,oy+(ty-oy)*k; task.Wait(1) end
end
function T.drift(o,n,speed)
    T.move(o,math.max(32,math.min(352,o.x+192+T.rand(-1,1)*n*speed)),T.rand(48,128),n,4)
end
local styles={[1]=ball_small,[2]=ball_small,[6]=grain_b,[12]=star_small,[13]=star_small,[14]=star_big,[15]=star_big}
function T.color(i) return math.max(1,math.min(16,i+1)) end
T.Bullet=Class(bullet)
function T.Bullet:init(x,y,speed,angle,typ,color,opt,phase)
    opt=opt or {}
    bullet.init(self,styles[typ] or star_small,T.color(color),false,true)
    bullet.skip_fade_in(self)
    self.x,self.y,self.rot=x,y,angle
    self.speed,self.angle=speed,angle; self.age=0
    self.wait,self.duration=opt.wait or 0,opt.duration or 0
    self.accel,self.turn=opt.accel or 0,opt.turn or 0
    self.accel_x,self.accel_y=opt.ax,opt.ay
    self.vx,self.vy=speed*cos(angle),speed*sin(angle)
    self.boost=opt.boost; self.change=opt.change
    self.bound=false; T.own(self,phase); T.stats.bullets=T.stats.bullets+1
end
function T.Bullet:frame()
    if self.age>=self.wait and self.age<self.wait+self.duration then
        if self.accel_x then self.vx,self.vy=self.vx+self.accel_x,self.vy+self.accel_y
        else self.speed,self.angle=self.speed+self.accel,self.angle+self.turn end
    end
    if self.change and self.age==self.change.after then
        self.angle=T.aim(self)+(self.change.offset or 0); self.speed=self.change.speed
    end
    if not self.accel_x then
        local speed=self.speed
        if self.boost and self.age<16 then speed=speed+5*(1-self.age/16) end
        self.vx,self.vy=speed*cos(self.angle),speed*sin(self.angle)
    end
    self.rot=self.angle; self.age=self.age+1
    if self.age>2400 or (self.age>20 and (math.abs(self.x)>280 or math.abs(self.y)>320)) then Del(self) end
end
function T.Bullet:del() T.owned[self]=nil; T.phase_objects[self]=nil; bullet.del(self) end
function T.Bullet:kill() T.owned[self]=nil; T.phase_objects[self]=nil; bullet.kill(self) end
function T.emit(o,speed,angle,typ,color,opt)
    return New(T.Bullet,o.x,o.y,speed,angle,typ,color,opt,o.th08_phase_owned)
end
function T.volley(o,mode,typ,color,n,layers,first,last,base,spread,opt)
    if mode=='aimed' or mode=='ring_aimed' then base=base+T.aim(o) end
    for layer=1,layers do
        local speed=layers==1 and first or first+(last-first)*(layer-1)/(layers-1)
        for i=1,n do
            local angle=base
            if mode=='ring' or mode=='ring_aimed' then angle=angle+(i-1)*360/n+(layer-1)*spread
            else angle=angle+(i-1-(n-1)/2)*spread end
            T.emit(o,speed,angle,typ,color,opt)
        end
    end
end

-- THlib performs laser hit/graze checks; warnings explicitly disable collision.
T.Beam=Class(laser)
function T.Beam:init(owner,x,y,angle,length,width,color,warning,active,off,turn)
    laser.init(self,T.color(color),x,y,angle,16,math.max(1,length-32),16,width,0,0)
    self.bound=false; self.colli=false
    self.owner=owner; self.anchorx,self.anchory=x,y
    self.warning,self.active,self.off=warning,active,off
    self.turn=turn or 0; self.th08_phase_owned=true
    self.th08_beam=true
    laser.TurnHalfOn(self,1)
    T.own(self,true); T.stats.beams=T.stats.beams+1
end
function T.Beam:frame()
    if self.owner and not IsValid(self.owner) then Del(self); return end
    if self.owner then self.x,self.y=self.owner.x,self.owner.y end
    if self.follow_angle then self.rot=self.owner.angle else self.rot=self.rot+self.turn end
    if self.track_player and self.timer>=self.warning and self.timer<self.warning+self.active then
        local target=T.aim(self); local delta=(target-self.rot+180)%360-180
        local limit=math.abs(self.turn_limit or 0.2045)
        self.rot=self.rot+math.max(-limit,math.min(limit,delta))
    end
    if self.timer==self.warning then laser.TurnOn(self,10,true) end
    if self.timer==self.warning+self.active then laser.TurnOff(self,self.off) end
    self.colli=self.timer>=self.warning+10 and self.timer<self.warning+self.active
    laser.frame(self)
    if self.timer>=self.warning+self.active+self.off then Del(self) end
end
function T.Beam:del() T.owned[self]=nil; T.phase_objects[self]=nil; laser.del(self) end
function T.Beam:kill() T.owned[self]=nil; T.phase_objects[self]=nil; laser.kill(self) end

T.Familiar=Class(enemy)
function T.Familiar:init(owner,angle,angular,radial,color,hp,behavior,opt)
    enemy.init(self,15,hp or 700,false,false,true)
    self.owner=owner; self.angle=angle; self.angular=angular; self.radial=radial
    self.radius=0; self.color=color; self.behavior=behavior; self.opt=opt or {}
    self.th08_phase_owned=true; self.a,self.b=12,12
    self.x,self.y=owner.x,owner.y; self.protect=true
    T.own(self,true)
    task.New(self,function()
        task.Wait(self.opt.expand or 120)
        if self.behavior then self.behavior(self) end
    end)
end
function T.Familiar:frame()
    if not IsValid(self.owner) then Del(self); return end
    self.protect=self.timer<200
    self.radius=math.max(0,math.min(256,self.radius+((self.timer<(self.opt.expand or 120)) and self.radial or (self.opt.radial or 0))))
    if self.opt.update then self.opt.update(self) end
    self.angle=self.angle+self.angular
    self.x,self.y=self.owner.x+self.radius*cos(self.angle),self.owner.y+self.radius*sin(self.angle)
    enemy.frame(self)
end
function T.Familiar:kill() T.owned[self]=nil; T.phase_objects[self]=nil; enemy.kill(self) end
function T.Familiar:del() T.owned[self]=nil; T.phase_objects[self]=nil; enemybase.del(self) end
T.Hud=Class(object)
function T.Hud:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function T.Hud:render()
    RenderText('menu','MySTG / STAGE 4B / NORMAL',-180,-199,0.28,'left')
    RenderText('menu',T.label,-180,-216,0.25,'left')
end
