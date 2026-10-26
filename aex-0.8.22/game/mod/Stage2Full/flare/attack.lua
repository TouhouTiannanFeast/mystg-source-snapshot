-- Independently authored local trial. Original scripts are behavioral evidence only.

local FLIGHT_SCALE=2/3
local FOLLOW_BOSS=true
local VARIANT=FOLLOW_BOSS and 'Follow' or 'Orbit'
LoadTexture('flare.fire','flare/th06-fire-local.png')
-- Native etama3.anm script7: sprites118..121, five frames per sprite.
for i=1,4 do
    LoadImage('flare.fire'..i,'flare.fire',1+(i-1)*32,193,30,30,2,2)
    SetImageState('flare.fire'..i,'mul+add')
end
local Fire=Class(img_class)
Fire.size=ball_small.size
function Fire:init(index) self.img='flare.fire1' end
LoadTexture('flare.patch','flare/patchouli-local.png')
-- TH06 stg4enm sprite39 / script66: Patchouli; neighboring frames are Koakuma.
LoadImage('flare.patch','flare.patch',64,208,32,48)
local D={owned={},tick=-1,shots=0,finished=false,phases={},checks=0,peak=0,live=0,followDistance=0,followLeft=0,followRight=0,headingChecks=0,bentHeadings=0}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle,acc,color,source)
    speed,acc=speed*FLIGHT_SCALE,acc*FLIGHT_SCALE
    bullet.init(self,Fire,color,false,true)
    bullet.skip_fade_in(self)
    self.x,self.y,self.speed,self.angle,self.acc=x,y,speed,angle,acc
    self.age=0; self.bound=false; self.rot=angle+90
    if FOLLOW_BOSS then self.source=source; self.bossX,self.bossY=source.x,source.y end
    self.vx,self.vy=speed*cos(angle),speed*sin(angle)
    self.renderX,self.renderY=x,y
    self.motionX,self.motionY=self.vx,self.vy
    D.owned[self]=true; D.shots=D.shots+1; D.live=D.live+1; D.peak=math.max(D.peak,D.live)
end
function Shot:frame()
    local dx,dy=0,0
    if FOLLOW_BOSS and IsValid(self.source) then
        dx,dy=self.source.x-self.bossX,self.source.y-self.bossY
        self.x,self.y=self.x+dx,self.y+dy
        self.bossX,self.bossY=self.source.x,self.source.y
        D.followDistance=D.followDistance+math.abs(dx)+math.abs(dy)
        if dx< -0.001 then D.followLeft=D.followLeft+1 elseif dx>0.001 then D.followRight=D.followRight+1 end
    end
    if setting.flare_test and self.age>0 then
        assert(math.abs(self.x-self.lastx-self.lastvx-dx)<0.02 and math.abs(self.y-self.lasty-self.lastvy-dy)<0.02,'shot trajectory/Boss translation mismatch')
        D.checks=D.checks+1
    end
    if self.age<100 then self.speed=self.speed+self.acc end
    self.vx,self.vy=self.speed*cos(self.angle),self.speed*sin(self.angle)
    self.motionX,self.motionY=self.vx+dx,self.vy+dy
    self.img='flare.fire'..(math.floor(self.age/5)%4+1)
    self.lastx,self.lasty,self.lastvx,self.lastvy=self.x,self.y,self.vx,self.vy
    self.age=self.age+1
    if self.age>800 or (self.age>100 and (math.abs(self.x)>260 or math.abs(self.y)>300)) then Del(self) end
end
function Shot:render()
    -- Measure displacement between actual rendered positions, after the
    -- engine integrates velocity. Boss translation is part of this tangent.
    local tx,ty=self.x-self.renderX,self.y-self.renderY
    self.renderX,self.renderY=self.x,self.y
    local length=math.sqrt(tx*tx+ty*ty)
    if length>0.000001 then
        -- Native sprite points down at rotation zero: head is local -Y.
        self.rot=math.atan2(ty,tx)*180/math.pi+90
        if setting.flare_test and self.age>0 then
            assert(math.abs(tx-self.motionX)<0.02 and math.abs(ty-self.motionY)<0.02,'rendered tangent differs from own flight plus Boss displacement')
            local hx,hy=cos(self.rot-90),sin(self.rot-90)
            assert((hx*tx+hy*ty)/length>0.999999,'fire head not forward on trajectory tangent')
            D.headingChecks=D.headingChecks+1
            if math.abs(hx*sin(self.angle)-hy*cos(self.angle))>0.001 then D.bentHeadings=D.bentHeadings+1 end
        end
    end
    -- A stationary fireball retains its last heading; it has no tangent.
    bullet.render(self)
end
function Shot:del() D.owned[self]=nil; D.live=D.live-1; bullet.del(self) end
function Shot:kill() D.owned[self]=nil; D.live=D.live-1; bullet.kill(self) end
-- Royal Flare Sub23: frames, group count, fan count, speed delta,
-- orbit-angle delta, firing-angle delta, acceleration, fan separation.
local phases={
    {280,3,2,0,1.40625,-1.40625,0.015,30},
    {280,5,2,0.1,-1.40625,1.40625,0.015,30},
    {180,6,1,0.1,-1.40625,0.5625,0.015,60},
    {200,5,1,0.1,1.40625,-3.75,0.02,30},
}
-- Original right-going route branch through (0,134), x=-52..52.
-- Fraction is horizontal progress from the left endpoint, not time phase.
local function route(fraction)
    local x=-52+104*fraction
    local phase=math.asin(math.max(-1,math.min(1,x/52)))*180/math.pi
    return x,134+10*sin(phase*0.19/0.32)
end
local function check_stationary(o)
    assert(math.abs(o.x-o.stopX)<0.000001 and math.abs(o.y-o.stopY)<0.000001,'Boss moved after arrival')
    D.stationaryChecks=D.stationaryChecks+1
end
local function emit(o,p,t,orbit,fire,speed)
    local sumX,sumY=0,0
    for k=0,p[2]-1 do
        -- Royal Flare callback13: center (192,224) + phase-age radius.
        -- Convert screen-down to AEX-up, then translate the entire layout.
        local theta=orbit+k*360/p[2]
        local referenceX=192+t*cos(theta)
        local referenceY=224+t*sin(theta)
        local x,y=o.x+(referenceX-192),o.y+(224-referenceY)
        sumX,sumY=sumX+x,sumY+y
        assert(math.abs((x-o.x)^2+(y-o.y)^2-t*t)<0.001,'Royal Flare phase radius mismatch')
        local direction=-(theta+fire)
        for j=1,p[3] do
            local a=direction+(p[3]==2 and (j==1 and 1 or -1)*p[8]/2 or 0)
            New(Shot,x,y,speed,a,p[7],({COLOR_RED,COLOR_ORANGE,COLOR_YELLOW,COLOR_RED})[o.phase],o)
        end
    end
    assert(math.abs(sumX/p[2]-o.x)<0.000001 and math.abs(sumY/p[2]-o.y)<0.000001,'Royal Flare group center not on Boss')
    D.centerChecks=D.centerChecks+1
end
local card=boss.card.New('火符「阿耆尼之火」',0,0,49,setting.flare_test and 1000000 or 1000,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        local destination=ran:Float(1/3,2/3)
        local startFraction=(o.x+52)/104
        for frame=1,60 do
            D.moveTick=frame
            local u=frame/60; u=u*u*(3-2*u)
            o.x,o.y=route(startFraction+(destination-startFraction)*u)
            assert(D.shots==0,'bullets fired during opening move')
            task.Wait(1)
        end
        o.x,o.y=route(destination); o.stopX,o.stopY=o.x,o.y
        D.destination=destination; D.arrived=true
        assert(destination>=1/3 and destination<=2/3,'destination outside middle third')
        print('FLARE ARRIVAL PASS fraction='..destination..' x='..o.x..' y='..o.y..' pre_arrival_shots='..D.shots)
        local tick,orbit,fire,speed=0,0,0,0.2
        while tick<2880 do
            for pi,p in ipairs(phases) do
                o.phase=pi; speed=speed+p[4]
                D.phases[pi]=(D.phases[pi] or 0)+1
                print('FLARE PHASE '..pi..' tick='..tick)
                for t=0,p[1]-1 do
                    D.tick=tick
                    check_stationary(o)
                    if t%6==0 then emit(o,p,t,orbit,fire,speed) end
                    orbit=orbit+p[5]; fire=fire+p[6]
                    tick=tick+1; task.Wait(1)
                    if tick>=2880 then break end
                end
                if tick>=2880 then break end
            end
            -- Royal Flare's 60-frame inter-loop pause; emitters keep following.
            for t=1,60 do check_stationary(o); D.tick=tick; tick=tick+1; task.Wait(1) end
        end
    end)
end
card.del=function()
    clean(); D.finished=true
    if setting.flare_test then
        for i=1,4 do assert(D.phases[i],'missing phase') end
        assert(D.shots>1000 and D.checks>1000 and D.peak<2500,'shot coverage/budget')
        assert(D.arrived and D.stationaryChecks>2800,'arrival/stationary coverage missing')
        assert(D.followDistance==0 and D.followLeft==0 and D.followRight==0,'stationary Boss dragged bullets')
        assert(D.headingChecks>1000,'missing rendered tangent coverage')
        assert(D.bentHeadings==0,'stationary fireballs changed trajectory')
        assert(D.centerChecks>400,'Royal Flare center coverage missing')
    end
    print('FLARE CLEANUP PASS variant='..VARIANT..' shots='..D.shots..' trajectory_checks='..D.checks..' peak='..D.peak..' follow_distance='..D.followDistance..' follow_left='..D.followLeft..' follow_right='..D.followRight)
    print('FLARE HEADING PASS tangent_checks='..D.headingChecks..' bent_headings='..D.bentHeadings)
    print('FLARE STATIONARY PASS checks='..D.stationaryChecks)
    print('FLARE CENTER PASS checks='..D.centerChecks..' layout=RoyalFlareTranslated')
end
local Patchouli=Class(boss)
function Patchouli:init()
    boss.init(self,0,134,'Patchouli Knowledge',{card},nil,'Extra')
    self.A,self.B=12,18;self.a,self.b=12,18
end
function Patchouli:render()
    self._bosssys:render()
    Render('flare.patch',self.x,self.y,0,1.2,1.2)
end

Stage2Flare={Shot=Shot,Boss=Patchouli,clean=clean,state=D,card=card,reset=function() clean();for k,v in pairs(D) do if type(v)=="number" then D[k]=0 end end;D.tick=-1;D.phases={};D.finished=false;D.arrived=false;D.moveTick=0;D.stationaryChecks=0;D.centerChecks=0 end}
