Include('THlib.lua')
Include('pattern.lua')
local P=MomijiPattern
LoadTexture('momiji.local','momiji.png')
for i=0,15 do LoadImage('momiji.'..i,'momiji.local',(i%4)*64,math.floor(i/4)*64,64,64) end
local D={owned={},tick=-1,gun=0,scale=0,rounds=0,bounces=0,finished=false}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
-- Set this function to play the supplied sound. Called exactly at wave 1.
MomijiEchoRoundStart=function(boss,round,tick) end
local Shot=Class(bullet)
function Shot:init(x,y,angle,kind)
    bullet.init(self,kind=='gun' and gun_bullet or arrow_big,kind=='gun' and COLOR_YELLOW or COLOR_BLUE,false,true)
    bullet.skip_fade_in(self)
    self.x,self.y,self.rot=x,y,angle
    local speed=kind=='gun' and P.gunSpeed or P.echoSpeed
    self.vx,self.vy=speed*cos(angle),speed*sin(angle)
    self.kind,self.reflected,self.bound,self.age=kind,false,false,0
    D.owned[self]=true;D[kind]=D[kind]+1
end
function Shot:frame()
    self.age=self.age+1
    if setting.momiji_test and self.lastX then
        assert(math.abs(self.x-self.lastX-self.vx)<0.02 and math.abs(self.y-self.lastY-self.vy)<0.02,'straight flight changed')
    end
    self.lastX,self.lastY=self.x,self.y
    if self.age>800 or self.y< -256 or math.abs(self.x)>224 or self.y>256 then Del(self) end
end
function Shot:del() D.owned[self]=nil;bullet.del(self) end
function Shot:kill() D.owned[self]=nil;bullet.kill(self) end
local card=boss.card.New('',0,2,60,1200,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for t=0,P.duration-1 do
            D.tick=t
            if setting.momiji_test then player.x=100*sin(t*1.5);player.y=-160 end
            for _,e in ipairs(P.events(t)) do
                local aim=Angle(o,player)
                if e.kind=='scale' and e.wave==1 then
                    D.rounds=D.rounds+1;MomijiEchoRoundStart(o,e.round,t)
                end
                local jitter=e.kind=='gun' and ran:Float(-30,30) or 0
                local angles,center=P.angles(e.kind,aim,jitter)
                local x,y=o.x,o.y
                if e.kind=='scale' then x=x+32*cos(center);y=y+32*sin(center) end
                for _,a in ipairs(angles) do
                    local sx,sy=x,y
                    if e.kind=='gun' then sx=sx+16*cos(a);sy=sy+16*sin(a) end
                    New(Shot,sx,sy,a,e.kind)
                end
                if setting.momiji_test and e.kind=='scale' then
                    assert(math.abs((center-aim)%360-180)<0.0001,'reverse aim mismatch')
                    print(string.format('MOMIJI WAVE tick=%d wave=%d aim=%.3f center=%.3f count=%d',t,e.wave,aim,center,#angles))
                end
            end
            if setting.momiji_test then player.protect=1000;o.hp=1200 end
            if setting.momiji_test=='kill' and t==900 then o.hp=0 end
            task.Wait(1)
        end
    end)
end
card.del=function()
    clean();D.finished=true
    assert(next(D.owned)==nil,'bullet cleanup failed')
    print(string.format('MOMIJI CLEANUP PASS tick=%d gun=%d scale=%d rounds=%d bounces=%d',D.tick,D.gun,D.scale,D.rounds,D.bounces))
end
local Momiji=Class(boss)
function Momiji:init() boss.init(self,0,72,'Inubashiri Momiji',{card},nil,'Normal');self.a,self.b=16,16 end
function Momiji:render() self._bosssys:render();Render('momiji.'..math.floor(self.ani/8)%4,self.x,self.y) end
local Hud=Class(object)
function Hud:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function Hud:render()
    RenderText('menu','MOMIJI / NONSPELL 1 / PREVIEW',0,-185,0.25,'centerpoint')
    RenderText('menu','Arrows / Shift slow / Z shoot / X bomb / Esc',0,-205,0.22,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Momiji Non1@Normal',nil,true)
stage.group.DefStageFunc('Momiji Non1@Normal','init',function(s)
    clean();D.tick=-1;D.gun=0;D.scale=0;D.rounds=0;D.bounces=0;D.finished=false
    stage.group.initTask(s,function()
        New(default_stage_background);New(Hud);task.Wait(60)
        local b=New(Momiji)
        while IsValid(b) do task.Wait(1) end
        clean();task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Momiji Non1@Normal','del',clean)
stage_init.frame=function(s)
    if s.timer==30 then
        lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
        stage.group.Start('Normal')
    end
end
if setting.momiji_test then
    local oldFrame=FrameFunc;local finish=0
    FrameFunc=function()
        local signal=oldFrame()
        if D.finished then finish=finish+1;if finish==90 then stage.QuitGame() end end
        return signal
    end
    local oldRender=RenderFunc;local captured={}
    RenderFunc=function()
        oldRender()
        for _,t in ipairs({120,240,600}) do
            if D.tick>=t and not captured[t] then captured[t]=true;lstg.Snapshot('userdata/snapshot/momiji-non1-'..t..'.jpg') end
        end
    end
end
