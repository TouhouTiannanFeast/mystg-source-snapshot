Include('THlib.lua')
Include('assets.lua')
Include('pattern.lua')
local P=MamizouPattern
local test=setting.mamizou_test
local D={owned={},phase=0,tick=-1,finished=false,stats={},ringIndex=0,randomIndex=0}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
local function count(name,n) local s=D.stats[D.phase];s[name]=(s[name] or 0)+(n or 1) end
local Native=Class(img_class)
Native.size=ball_big.size
function Native:init() self.img='mz.t18c1' end
local Shot=Class(bullet)
local spawn
local function image(o,name,radius)
    o.img='mz.'..name;o.a=radius;o.b=radius;o.rect=false
end
function Shot:init(x,y,speed,angle,kind,color,extra)
    bullet.init(self,Native,COLOR_RED,false,true);bullet.skip_fade_in(self)
    self.bound=false;self.age=0;self.kind=kind;self.speed=speed;self.direction=angle;self.color=color;self.extra=extra or {}
    self.originX,self.originY=x,y;self.baseX,self.baseY=x,y
    self.fade=(kind=='non' or kind=='market') and 15 or (kind=='frogseed' or kind=='ring') and 23 or 15
    self.x=x-4*speed*cos(angle);self.y=y-4*speed*sin(angle)
    self.ux,self.uy=self.x-x,self.y-y
    self.vx,self.vy=0,0
    if kind=='ring' then image(self,'t32c'..color,14)
    elseif kind=='frogseed' then image(self,'t19c4',8.5)
    elseif kind=='rice' then image(self,'t8c13',2.4000000953674316)
    elseif kind=='bird' then self.fade=0;self.x=x;self.y=y;image(self,'th13-18',6.5)
    else image(self,'t18c'..(color or 1),8.5) end
    D.owned[self]=true;count('shots');count(kind)
end
local function frog_rice(o,aimed)
    if aimed then
        spawn(o.x,o.y,1.8,Angle(o,player),'rice',13)
    else
        for _,a0 in ipairs({135,45}) do
            for k=0,5 do
                local speed=k<3 and (1.5-0.3*k) or (0.6+0.3*(k-3))
                for j=0,1 do spawn(o.x,o.y,speed,-a0+k*30+j*180,'rice',13) end
            end
        end
    end
end
function Shot:frame()
    local a=self.age;local speed=self.speed;local dir=self.direction
    self.colli=a>=self.fade
    if self.kind=='ring' then
        local nativeSpeed=1.7
        if a<200 then self.direction=self.direction-self.extra.spin*180/math.pi end
        speed=nativeSpeed*(a<self.fade and 0.5 or 1)
        self.ux=self.ux+speed*cos(self.direction);self.uy=self.uy+speed*sin(self.direction)
        -- Scale the entire native displacement about the original emission center.
        -- The ring keeps its center, angular clock and complete circular coverage.
        self.x=self.originX+self.ux*P.radius_scale;self.y=self.originY+self.uy*P.radius_scale
        if test then
            assert(math.abs((self.x-self.originX)-self.ux*2/3)<1e-7,'ring x scale')
            assert(math.abs((self.y-self.originY)-self.uy*2/3)<1e-7,'ring y scale');count('radiusChecks')
        end
        if self.extra.frog and a==210 then self.kind='finalfrog';self.age=0;self.fade=0;image(self,'th13-21',5.5);count('finalfrog') end
    elseif self.kind=='finalfrog' or self.kind=='frog' then
        image(self,'th13-'..({21,22,23,22})[math.floor(a/10)%4+1],self.kind=='finalfrog' and 5.5 or 6.5)
        if a==210 then frog_rice(self,self.kind=='finalfrog');Del(self);return end
    elseif self.kind=='bird' then
        local jitter=self.extra.jitter
        self.direction=-90-jitter
        speed=4*math.min(1,(a+1)/230)
        self.x=self.x+speed*cos(self.direction);self.y=self.y+speed*sin(self.direction)
        image(self,'th13-'..({18,19,20,19})[(a%16<3 and 1) or (a%16<6 and 2) or (a%16<11 and 3) or 4],6.5)
    else
        if self.kind=='market' then
            if a==80 then
                count('randomCandidates')
                D.randomIndex=D.randomIndex+1
                -- Sample at the original transformation time, even if removed.
                local turn=ran:Float(-360,360)
                if not P.random_keep(D.randomIndex) then count('randomDeleted');Del(self);return end
                count('randomKept');self.direction=self.direction+turn;image(self,'th185-15',8.5)
            end
            if a>=80 then
                speed=a<161 and 0.5 or 0.5+0.5*math.min(1,(a-160)/120)
                image(self,'th185-'..({15,16,15,17})[math.floor((a-80)/8)%4+1],8.5)
            end
        end
        speed=speed*(a<self.fade and 0.5 or 1)
        self.x=self.x+speed*cos(self.direction);self.y=self.y+speed*sin(self.direction)
        if self.kind=='frogseed' and a==33 then self.kind='frog';self.age=0;self.fade=0;image(self,'th13-21',6.5);count('frog') end
    end
    -- Humanoids stay upright, feet down, regardless of their flight heading.
    self.rot=(self.kind=='market' and a>=80) and 0 or self.direction+90
    self.age=self.age+1
    local protected=self.kind=='ring' and a<500
    if self.age>1800 or (not protected and (math.abs(self.x)>240 or self.y< -270 or self.y>280)) then Del(self) end
end
function Shot:del() D.owned[self]=nil;bullet.del(self) end
function Shot:kill() D.owned[self]=nil;bullet.kill(self) end
spawn=function(...) return New(Shot,...) end
local function start_move(o,duration,speed,minY,maxY,minX,maxX,mode)
    local x,y=o.x,224-o.y;local a
    if x<minX+70 then a=ran:Float(-60,60)
    elseif x>maxX-70 then a=180+ran:Float(-60,60)
    elseif x<player.x then a=ran:Float(-90,90)
    else a=180+ran:Float(-90,90) end
    a=(a+180)%360-180
    if y<minY+8 then a=math.abs(a) elseif y>maxY-8 then a=-math.abs(a) end
    o.move={age=0,duration=duration,speed=speed,angle=-a,minY=minY,maxY=maxY,minX=minX,maxX=maxX,mode=mode};count('moves')
end
local function movement(o)
    local m=o.move;if not m then return end
    local f=(m.age+1)/m.duration
    local speed=m.speed*(1-f)
    o.x=math.max(m.minX,math.min(m.maxX,o.x+speed*cos(m.angle)))
    o.y=224-math.max(m.minY,math.min(m.maxY,224-o.y-speed*sin(m.angle)))
    m.age=m.age+1;if m.age>=m.duration then o.move=nil end
end
local function final_ring(o,spin,base)
    D.ringIndex=D.ringIndex+1;local n=P.ring_count(D.ringIndex)
    assert(n==18 or n==19);count('rings');count('ringParticles',n*2);count('originalRingParticles',56)
    for _,c in ipairs({1,3}) do
        for k=0,n-1 do
            local a=-P.ring_angle(base,k,n,c==3)*180/math.pi
            spawn(o.x,o.y,1.7,a,'ring',c,{spin=spin,frog=c==3})
        end
    end
end
local names={'','伍番胜负「鸟兽戏画」','','「空前绝后，大排长龙的黑市」','狢符「满月的腹鼓舞」'}
local cards={}
for phase=1,5 do
    local id=phase
    local card=boss.card.New(names[id],0,2,P.durations[id]/60,P.health[id],{0,0,0},false)
    card.init=function(o)
        clean();D.phase=id;D.tick=-1;D.stats[id]={};D.ringIndex=0;D.randomIndex=0;o.move=nil
        print('MAMIZOU PHASE START '..id)
        task.New(o,function()
            local base,marketStart,marketStream,marketAngle,marketTurn=0,60,1,0,3.883222
            local finalNext,finalSecond,finalBase,finalSpin=180,false,0,0.015708
            local entryX,entryY=o.x,o.y
            local targetY=id==2 and 32 or 96
            for t=0,P.durations[id]-1 do
                D.tick=t
                local entrance=id==1 and 0 or (id==2 or id==3) and 120 or 60
                if t<entrance then
                    local f=(t+1)/entrance;f=1-(1-f)^2
                    o.x=entryX*(1-f);o.y=entryY+(targetY-entryY)*f
                else movement(o) end
                if id==1 or id==3 then
                    local e=P.non(id,t)
                    if e then
                        if e.age==0 then base=ran:Float(-180,180) end
                        for k=0,2 do spawn(o.x,o.y,e.speed,base-k*120,'non',e.color) end
                        base=base-e.spin*180/math.pi
                    end
                    if P.non_move(id,t) then start_move(o,70,1.5,112,144,-140,140,4) end
                elseif id==2 then
                    local e=P.bird(t)
                    if e then spawn(e.x+ran:Float(-19,19),240,0,-90,'bird',1,{jitter=ran:Float(-10,10)}) end
                    if P.frog(t) then for k=0,3 do spawn(o.x,o.y,1.6,-135-k*90,'frogseed',4) end end
                elseif id==4 then
                    local r=t-marketStart
                    if r>=0 and r<120 then
                        if r==0 then marketAngle=ran:Float(-180,180);marketTurn=marketStream==1 and 3.883222 or -3.883222 end
                        if r==60 then marketAngle=ran:Float(-180,180);marketTurn=marketStream==1 and -4.6598663 or 4.6598663 end
                        for k=0,2 do spawn(o.x,o.y,2,marketAngle-k*120,'market',3) end
                        marketAngle=marketAngle-marketTurn*180/math.pi
                    elseif r==120 then
                        start_move(o,70,1.5,96,160,-140,140,4)
                        marketStart=t+P.market_wait(t);marketStream=3-marketStream
                    end
                elseif id==5 and t==finalNext then
                    if not finalSecond then finalBase=ran:Float(-math.pi,math.pi) end
                    final_ring(o,finalSpin,finalBase)
                    if not finalSecond then finalNext=t+15;finalSecond=true;finalSpin=-finalSpin
                    else
                        local pause=P.final_wait(t,o.hp)
                        finalNext=t+pause+60;finalSecond=false
                        o.finalMoveAt=t+pause
                    end
                end
                if id==5 and t==o.finalMoveAt then start_move(o,60,1,118,138,-32,32,21) end
                if test=='kill' and t==650 then o.hp=0 end
                task.Wait(1)
            end
        end)
    end
    card.del=function(o)
        clean();o.move=nil;o.finalMoveAt=nil
        local s=D.stats[id]
        assert(next(D.owned)==nil,'owned leak')
        if test and id==4 and test=='timeout' then
            assert(s.randomCandidates==s.randomKept+s.randomDeleted,'random accounting')
            assert(math.abs(s.randomDeleted-s.randomCandidates/4)<2,'random count ratio')
        end
        if test and id==5 then assert(s.radiusChecks and s.radiusChecks>1000,'radius coverage') end
        print(string.format('MAMIZOU PHASE CLEANUP %d tick=%d shots=%d rings=%d radius=%d random=%d kept=%d removed=%d',id,D.tick,s.shots or 0,s.rings or 0,s.radiusChecks or 0,s.randomCandidates or 0,s.randomKept or 0,s.randomDeleted or 0))
    end
    cards[id]=card
end
local Mamizou=Class(boss)
function Mamizou:init()
    local selected=cards
    if setting.mamizou_phase then selected={cards[setting.mamizou_phase]} end
    boss.init(self,0,112,'Futatsuiwa Mamizou',selected,nil,'Normal');self.a=24;self.b=24
end
function Mamizou:render()
    self._bosssys:render()
    local sprite=({0,1,2,1,0,1,3,1})[math.floor(self.ani/8)%8+1]
    if self.move then sprite=4+math.min(3,math.floor(self.ani/8)%4) end
    Render('mz.th13-'..sprite,self.x,self.y,0,self.move and cos(self.move.angle)<0 and -1 or 1,1)
end
local Hud=Class(object)
function Hud:init() self.group=GROUP_GHOST;self.layer=LAYER_TOP;self.bound=false;self.colli=false end
function Hud:render()
    RenderText('menu','STAGE 2 / MAMIZOU / '..D.phase..' OF 5',0,-187,0.27,'centerpoint')
    RenderText('menu','Arrows / Shift / Z shoot / X bomb / Esc',0,-205,0.23,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Mamizou Stage2@Normal',nil,true)
stage.group.DefStageFunc('Mamizou Stage2@Normal','init',function(s)
    clean();D.finished=false;D.stats={}
    stage.group.initTask(s,function()
        New(default_stage_background);New(Hud);task.Wait(60)
        local b=New(Mamizou)
        while IsValid(b) do if test then player.protect=1000 end;task.Wait(1) end
        clean();D.finished=true;print('MAMIZOU ALL CLEANUP PASS');task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Mamizou Stage2@Normal','del',clean)
stage_init.frame=function(s)
    if s.timer==30 then lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal') end
end
if test then
    MamizouTest={state=D,Shot=Shot,cards=cards,clean=clean,spawn=spawn}
    local oldFrame=FrameFunc;local wait=0
    FrameFunc=function()
        local signal=oldFrame();if D.finished then wait=wait+1;if wait==180 then stage.QuitGame() end end;return signal
    end
    local oldRender=RenderFunc;local captured={}
    RenderFunc=function()
        oldRender()
        for _,t in ipairs({350,650,1100}) do
            local key=D.phase..'-'..t
            if D.tick>=t and not captured[key] then
                captured[key]=true;local p='userdata/snapshot/mamizou-'..key..'.jpg';lstg.Snapshot(p);print('MAMIZOU SNAPSHOT '..p)
            end
        end
    end
end
