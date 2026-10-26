-- User-designed Normal baseline. Screen (x,y) -> AEX (x-192,224-y).
Include('THlib.lua')
local D={owned={},fans=0,cores=0,scales=0,splits=0,turns=0,finished=false,tick=-1}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle,kind,sign,color)
    bullet.init(self,kind=='core' and ball_mid or (kind=='scale' and grain_a or ball_small),color or COLOR_RED,false,true)
    bullet.skip_fade_in(self)
    self.x,self.y,self.speed,self.angle=x,y,speed,angle
    self.kind,self.sign,self.age=kind,sign,0
    self.bound=false; self.rot=angle
    D.owned[self]=true
    if kind=='core' then D.cores=D.cores+1 elseif kind=='scale' then D.scales=D.scales+1 else D.fans=D.fans+1 end
end
function Shot:frame()
    if self.kind=='core' and self.age==48 then
        for m=-1,1 do
            New(Shot,self.x,self.y,1.30+0.15*math.abs(m),self.angle-self.sign*(58+18*m),'scale',self.sign,COLOR_ORANGE)
        end
        D.splits=D.splits+1; Del(self); return
    end
    if self.kind=='scale' then
        if self.age<75 then
            self.angle=self.angle-self.sign*0.45
            self.speed=math.min(2,self.speed+0.006)
        elseif self.age==75 then
            local expected=1.30+0.15*math.abs(self.initial_m or 0)
            assert(self.speed<=2.000001,'scale speed cap')
            D.turns=D.turns+1
        end
    end
    self.vx,self.vy=self.speed*cos(self.angle),self.speed*sin(self.angle)
    self.rot=self.angle; self.age=self.age+1
    if self.age>1000 or (self.age>48 and (math.abs(self.x)>240 or self.y>280 or self.y< -280)) then Del(self) end
end
function Shot:del() D.owned[self]=nil; bullet.del(self) end
function Shot:kill() D.owned[self]=nil; bullet.kill(self) end
local function fan(o,k)
    local n=6+2*k; local width=34+8*k; local speed=1+0.2*k
    local aim=Angle(o,player)
    for i=0,n-1 do New(Shot,o.x,o.y,speed+0.18*(i%2),aim-width/2+i*width/(n-1),'fan',0,({COLOR_YELLOW,COLOR_ORANGE,COLOR_RED})[k]) end
    print('DRAGON FAN tick='..D.tick..' count='..n)
end
local card=boss.card.New('幼龙「星火喷嚏」',0,0,45,1000000,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for cycle=0,12 do
            local sx,sy=o.x,o.y
            local tx,ty=ran:Float(130,254)-192,224-ran:Float(75,105)
            local rx,ry
            for t=0,209 do
                D.tick=cycle*210+t
                if t<20 then local u=(t+1)/20; u=u*u*(3-2*u); o.x,o.y=sx+(tx-sx)*u,sy+(ty-sy)*u end
                if t==20 then fan(o,1) elseif t==44 then fan(o,2) elseif t==68 then fan(o,3) end
                if t==102 then
                    local aim=Angle(o,player)
                    rx,ry=-12*cos(aim)/10,-12*sin(aim)/10
                    for i=0,17 do New(Shot,o.x,o.y,1.05,-(cycle*11+i*20),'core',i%2==0 and 1 or -1,COLOR_RED) end
                    print('DRAGON SNEEZE tick='..D.tick..' count=18')
                end
                if t>=102 and t<112 then o.x,o.y=o.x+rx,o.y+ry end
                if setting.dragon_test and cycle==0 and t==200 then
                    assert(D.fans==30 and D.cores==18 and D.scales==54 and D.splits==18,'first cycle schedule/count mismatch')
                    print('DRAGON FIRST CYCLE PASS fans=30 cores=18 scales=54 splits=18')
                end
                task.Wait(1)
            end
        end
    end)
end
card.del=function()
    clean(); D.finished=true
    assert(next(D.owned)==nil,'owned bullet leak')
    print('DRAGON CLEANUP PASS tick='..D.tick..' fans='..D.fans..' cores='..D.cores..' scales='..D.scales..' turns='..D.turns)
end
local Dragon=Class(boss)
function Dragon:init() boss.init(self,0,134,'Young Dragon',{card},nil,'Normal'); self.a,self.b=18,18 end
function Dragon:render()
    self._bosssys:render()
    Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.3,1.3)
end
local Hud=Class(object)
function Hud:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function Hud:render()
    RenderText('menu','STARFIRE SNEEZE / NORMAL',0,-185,0.28,'centerpoint')
    RenderText('menu','Arrows move / Shift slow / Z shoot / X bomb / Esc menu',0,-205,0.21,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=100,bomb=3},true,2)
stage.group.AddStage('Normal','Starfire Sneeze@Normal',nil,true)
stage.group.DefStageFunc('Starfire Sneeze@Normal','init',function(s)
    D.finished=false; D.tick=-1; D.fans=0; D.cores=0; D.scales=0; D.splits=0; D.turns=0
    stage.group.initTask(s,function()
        New(default_stage_background); New(Hud); task.Wait(60)
        local b=New(Dragon)
        while IsValid(b) do
            if setting.dragon_test then player.protect=1000 end
            task.Wait(1)
        end
        clean(); task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Starfire Sneeze@Normal','del',clean)
stage_init.frame=function(s)
    if s.timer==30 then
        lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
        stage.group.Start('Normal')
    end
end
if setting.dragon_test then
    local old_menu=stage_menu.frame
    stage_menu.frame=function(s) old_menu(s); if D.finished and s.timer>=30 then stage.Set('stage.quit') end end
    local captured={}; local old_render=RenderFunc
    RenderFunc=function()
        old_render()
        for _,tick in ipairs({150,200,225,300}) do
            if D.tick>=tick and not captured[tick] then
                captured[tick]=true
                local path='userdata/snapshot/dragon-'..tick..'.jpg'
                lstg.Snapshot(path); print('DRAGON SNAPSHOT '..path)
            end
        end
    end
end
