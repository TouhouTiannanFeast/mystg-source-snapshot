-- Native objects, exclusively owned by this independent mod.
th14 = {stats={spawned=0,waves=0,phases=0,ended=0},owned={}}
local T=th14
-- Include does not return chunk values in AEX; load geometry as a module.
local old=package.path
package.path='mod/TH14Stage1Normal/?.lua;'..old
T.g=require('geometry')
package.path=old
local g=T.g
T.rad=g.angle
function T.rand(a,b) return ran:Float(a,b) end
function T.randint(a,b) return ran:Int(a,b) end
function T.aim(o) return IsValid(player) and Angle(o,player) or -90 end
function T.track(o) T.owned[o]=true; return o end
function T.clean()
    for o in pairs(T.owned) do if IsValid(o) then Del(o) end end
    T.owned={}
end
function T.clean_bullets()
    for o in pairs(T.owned) do
        if IsValid(o) and o.th14_bullet then Del(o); T.owned[o]=nil end
    end
end
function T.clean_actors()
    for o in pairs(T.owned) do
        if IsValid(o) and not o.th14_bullet then Del(o); T.owned[o]=nil end
    end
end

-- Source type -> approximate THlib image family. Collision is AEX native.
local styles={[5]=ball_small,[6]=ball_small,[8]=grain_b,[10]=grain_c,
    [12]=arrow_small,[18]=grain_b,[20]=knife_b}
local colors={[2]=COLOR_RED,[3]=COLOR_PURPLE,[4]=COLOR_BLUE,[6]=COLOR_CYAN,
    [8]=COLOR_GREEN,[9]=COLOR_GREEN,[10]=COLOR_YELLOW}
T.Bullet=Class(bullet)
function T.Bullet:init(x,y,speed,angle,typ,color,opt)
    opt=opt or {}
    bullet.init(self,styles[typ] or arrow_small,colors[color] or COLOR_CYAN,false,true)
    bullet.skip_fade_in(self)
    self.x,self.y=x,y
    self.speed,self.angle=speed,angle
    self.rot=angle
    self.th14_bullet=true
    self.bound=false
    self.wait,self.duration=opt.wait or 0,opt.duration or 0
    self.accel,self.turn=opt.accel or 0,opt.turn or 0
    self.boost=opt.boost
    self.step=opt.step
    self.age=0
    T.track(self); T.stats.spawned=T.stats.spawned+1
end
function T.Bullet:frame()
    self.speed,self.angle=g.motion(self.speed,self.angle,self.age,self.wait,self.duration,self.accel,self.turn)
    local speed=self.speed
    if self.boost and self.age<16 then speed=speed+5*(1-self.age/16) end
    if self.step then
        if self.age<60 then speed=self.speed*(1-self.age/60)
        elseif self.age==60 then
            self.angle=self.angle+self.step; self.speed=1.5; speed=1.5
        end
    end
    -- Motion is integrated ONCE by engine UpdateXY.
    self.vx,self.vy=speed*cos(self.angle),speed*sin(self.angle)
    self.rot=self.angle
    self.age=self.age+1
    if self.age>1800 or (self.age>20 and (math.abs(self.x)>256 or self.y>320 or self.y< -288)) then Del(self) end
end
function T.Bullet:del() T.owned[self]=nil; bullet.del(self) end
function T.Bullet:kill() T.owned[self]=nil; bullet.kill(self) end
function T.emit(o,speed,angle,typ,color,opt,dist)
    dist=dist or 0
    return New(T.Bullet,o.x+dist*cos(angle),o.y+dist*sin(angle),speed,angle,typ,color,opt)
end
function T.fan(o,speed,base,count,spread,typ,color,opt,dist)
    for _,a in ipairs(g.fan(base,count,spread)) do T.emit(o,speed,a,typ,color,opt,dist) end
end
function T.ring(o,first,last,base,count,layers,typ,color,opt)
    for i=1,layers do
        local speed=g.speed(first,last,i,layers)
        for _,a in ipairs(g.ring(base,count)) do T.emit(o,speed,a,typ,color,opt) end
    end
end
function T.pos(o,x,y,frames,mode)
    local tx,ty=g.position(x,y)
    local sx,sy=o.x,o.y
    for i=1,frames do
        local k=g.ease(i/frames,mode)
        o.x,o.y=sx+(tx-sx)*k,sy+(ty-sy)*k
        task.Wait(1)
    end
end
function T.vel(o,angle,speed) o.th14_angle,o.th14_speed=angle,speed end
function T.veltime(o,frames,mode,angle,speed)
    local sa,ss=o.th14_angle or angle,o.th14_speed or speed
    task.New(o,function()
        for i=1,frames do
            local k=g.ease(i/frames,mode)
            T.vel(o,sa+(angle-sa)*k,ss+(speed-ss)*k)
            task.Wait(1)
        end
    end)
end
function T.drift(o,frames,speed,wide,ycenter)
    local x=math.max(-wide,math.min(wide,o.x+T.rand(-1,1)*speed*frames))
    local y=(ycenter or 128)+T.rand(-32,32)
    T.pos(o,x,y,frames,4)
end

T.Hud=Class(object)
function T.Hud:init()
    self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false
end
function T.Hud:render()
    RenderText('menu','TH14 / STAGE 1 / NORMAL',-181,-198,0.28,'left')
    RenderText('menu',T.label or 'Misty Lake',-181,-216,0.25,'left')
end
