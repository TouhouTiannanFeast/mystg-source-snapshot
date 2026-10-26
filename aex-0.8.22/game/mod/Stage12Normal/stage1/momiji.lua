Include('stage1/momiji-config.lua')
local P=MomijiPattern
LoadSound('momiji.th143.kira00','art/momiji-sound/se_kira00.wav')
LoadTexture('momiji.local','momiji.png')
for i=0,15 do LoadImage('momiji.'..i,'momiji.local',(i%4)*64,math.floor(i/4)*64,64,64) end
local D={owned={},tick=-1,gun=0,rice=0,scale=0,lasers=0,rounds=0,bounces=0,finished=false}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
-- Set this function to play the supplied sound. Called exactly at wave 1.
MomijiEchoRoundStart=function(boss,round,tick) end
LoadTexture('momiji.th10.medium','art/momiji-medium-th10.png')
LoadImage('momiji.th10.medium','momiji.th10.medium',0,0,32,32,8,8)
local Shot=Class(bullet)
function Shot:init(x,y,angle,kind,speed,color,ox,oy,center,medium)
    bullet.init(self,kind=='rice' and grain_a or ball_mid,color or COLOR_BLUE,false,true)
    bullet.skip_fade_in(self)
    if kind=='scale' and medium then
        self.img='momiji.th10.medium';self.a,self.b=8,8;self.hscale,self.vscale=1,1
        self.medium=true
    end
    if kind=='rice' then Stage12Art.bullet(self,'rice',color or COLOR_RED) end
    self.x,self.y,self.rot=x,y,angle
    speed=speed or P.echoSpeed
    self.fanX,self.fanY,self.fanCenter=ox or x,oy or y,center or angle
    self.fanHalf=kind=='rice' and (P.gunCount-1)*P.gunSpacing/2 or P.rearHalf
    self.vx,self.vy=speed*cos(angle),speed*sin(angle)
    self.kind,self.reflected,self.bound,self.age=kind,false,false,0
    D.owned[self]=true;D[kind]=D[kind]+1
end
function Shot:frame()
    self.age=self.age+1
    if not P.inside(self.x,self.y,self.fanX,self.fanY,self.fanCenter,self.fanHalf) or not P.inside(self.x+self.vx,self.y+self.vy,self.fanX,self.fanY,self.fanCenter,self.fanHalf) then Del(self);return end
    if setting.momiji_test and self.lastX then
        assert(math.abs(self.x-self.lastX-self.vx)<0.02 and math.abs(self.y-self.lastY-self.vy)<0.02,'straight flight changed')
    end
    self.lastX,self.lastY=self.x,self.y
    if self.age>800 or self.y< -256 or math.abs(self.x)>224 or self.y>256 then Del(self) end
end
function Shot:del() D.owned[self]=nil;bullet.del(self) end
function Shot:kill() D.owned[self]=nil;bullet.kill(self) end
-- Native curved-laser object supplies actual collision/graze/Bomb handling.
LoadTexture('momiji.th143.laser','art/momiji-laser-th143.png')
-- Original laser2 script294: four256x32 lightning frames, two ticks per frame.
local laserSample=14305
laser_bent_renderFunc[laserSample]=function(o)
 o.data:Render('momiji.th143.laser',o._blend,Color(o._a*o.alpha,o._r,o._g,o._b),0,32*(math.floor(o.timer/2)%4),256,32)
end
laser_bent_renderFuncDeath[laserSample]=function(o)
 o.data:Render('momiji.th143.laser',o._blend,Color(o._a*(1-o.timer/30),o._r,o._g,o._b),0,32*(math.floor(o.timer/2)%4),256,32)
end
local Laser=Class(laser_bent)
function Laser:init(x,y,angle)
 laser_bent.init(self,COLOR_GRAY,x,y,60,28,laserSample,0)
 self.window=D.laserWindow;self.angle,self.age=angle,0;self.originX,self.originY=x,y
 self.vx,self.vy=0,0;self._bound=false
 D.owned[self]=true;D.lasers=D.lasers+1
end
function Laser:frame()
 local speed=4+0.2*math.min(self.age,60)
 self.x=self.x+speed*cos(self.angle);self.y=self.y+speed*sin(self.angle)
 laser_bent.frame(self);self.age=self.age+1
 if self.age>240 or (self.window and D.tick>=self.window.finish) then Del(self) end
end
function Laser:del() D.owned[self]=nil;laser_bent.del(self) end
function Laser:kill() D.owned[self]=nil;laser_bent.kill(self) end
local function start_move(o)
 -- Original movement box x[-140,140], source y[96,196] -> LuaSTG y[28,128].
 local a=ran:Float(-180,180)
 if o.x< -70 then a=ran:Float(-60,60) elseif o.x>70 then a=180+ran:Float(-60,60) end
 if o.y<53 then a=math.abs(P.wrap(a)) elseif o.y>103 then a=-math.abs(P.wrap(a)) end
 o.moveAngle=a
end
local card=boss.card.New('',0,2,35,900,{0,0,0},false)
card.init=function(o)
    o.stage12MomijiReward=false;D.riceBurst=nil
    th14.clean_bullets();th14.clean_actors()
    th14.label='Inubashiri Momiji';th14.stats.phases=th14.stats.phases+1
    o.th14_phase='momiji';print('TH14 PHASE START momiji frame='..th14.stage_frames)
    task.New(o,function()
        for t=0,P.duration-1 do
            D.tick=t
            if setting.stage12_momiji_probe and (t==100 or t==160 or t==220) then lstg.Snapshot('userdata/snapshot/momiji-wave-'..t..'.jpg') end
            if t<60 then o.y=72+24*(1-(1-(t+1)/60)^2) end
            local moveAge=P.move_age(t)
            if moveAge==0 then start_move(o) end
            if moveAge then
                local speed=3*(1-(moveAge+1)/40)
                o.x=math.max(-140,math.min(140,o.x+speed*cos(o.moveAngle)))
                o.y=math.max(28,math.min(128,o.y+speed*sin(o.moveAngle)))
            end
            if setting.momiji_test then player.x=100*sin(t*1.5);player.y=-160 end
            for _,e in ipairs(P.events(t)) do
                local front=P.front(o,player)
                if e.kind=='rice' then
                    if D.riceBurst~=e.burst then D.riceBurst=e.burst;D.ricePhase=ran:Float(-180,180) end
                    local half=(P.gunCount-1)*P.gunSpacing/2
                    local radius=e.step+2
                    -- Source: opposing9degree spirals and independent1..1.7 speeds.
                    for j=1,2 do
                        local phase=-D.ricePhase+(j==1 and 1 or -1)*(e.step+1)*0.15708*180/math.pi
                        local birth=front+P.fold(phase,half)
                        local angle=front+ran:Float(-half,half)
                        New(Shot,o.x+radius*cos(birth),o.y+radius*sin(birth),angle,'rice',ran:Float(1,1.7),j==1 and COLOR_RED or COLOR_DEEP_RED,o.x,o.y,front)
                    end
                else
                    if e.wave==1 then D.rounds=D.rounds+1;MomijiEchoRoundStart(o,e.round,t) end
                    local angles,center=P.angles('scale',front,0)
                    local x,y=o.x+32*cos(center),o.y+32*sin(center)
                    for _,a in ipairs(angles) do New(Shot,x,y,a,'scale',P.echoSpeed,COLOR_BLUE,o.x,o.y,center,true) end
                    if e.wave==1 then D.laserWindow={start=t,finish=t+P.echoInterval-1} end
                    if e.wave==3 then
                        local longest=0
                        for _,a in ipairs(angles) do
                            local vx,vy=P.echoSpeed*cos(a),P.echoSpeed*sin(a)
                            local tx=math.abs(vx)<1e-8 and math.huge or ((vx>0 and 224 or -224)-x)/vx
                            local ty=math.abs(vy)<1e-8 and math.huge or ((vy>0 and 256 or -256)-y)/vy
                            longest=math.max(longest,math.max(0,math.min(tx,ty)))
                        end
                        D.laserWindow.finish=t+math.max(0,math.floor(longest)-20)
                    end

                end
            end
            local w=D.laserWindow
            local pulse=w and (t-w.start)
            if w and t<=w.finish and (pulse>=15 and pulse<=115 and (pulse-15)%20==0) then
                PlaySound('momiji.th143.kira00',0.33,o.x/224)
                local front=P.front(o,player);local center=front+180
                local x,y=o.x+32*cos(center),o.y+32*sin(center)
                for _,a in ipairs(P.laserAngles(center,MomijiAimConfig.directLaser and Angle(o,player) or front,function(a,b)return ran:Float(a,b)end,(pulse==15 or pulse==75) and 8 or 5)) do New(Laser,x,y,a)end
            end
            if setting.momiji_test then player.protect=1000;o.hp=900 end
            if setting.momiji_test=='kill' and t==900 then o.hp=0 end
            task.Wait(1)
        end
    end)
end
card.del=function(o)
    if o and o.hp<=0 and o.timeout~=true and o.timeout~=1 and not o.stage12MomijiReward then
        o.stage12MomijiReward=true;New(item_bomb,o.x,o.y)
    end
    th14.stats.ended=th14.stats.ended+1
    print('TH14 PHASE END momiji frame='..th14.stage_frames)
    clean();D.finished=true
    assert(next(D.owned)==nil,'bullet cleanup failed')
    print('MOMIJI RICE/LASER rice='..D.rice..' lasers='..D.lasers..' aim='..tostring(MomijiAimConfig.aimFans))
    print(string.format('MOMIJI CLEANUP PASS tick=%d gun=%d scale=%d rounds=%d bounces=%d',D.tick,D.gun,D.scale,D.rounds,D.bounces))
end
local Momiji=Class(boss)
function Momiji:init() boss.init(self,0,72,'Inubashiri Momiji',{card},nil,'Normal');self.a,self.b=16,16 end
function Momiji:render() self._bosssys:render();Render('momiji.'..math.floor(self.ani/8)%4,self.x,self.y) end

Stage1Momiji={Shot=Shot,Laser=Laser,Boss=Momiji,clean=clean,state=D}
