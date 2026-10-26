-- Independent native THlib prototype. Bomb/deletion never creates descendants.
Include('THlib.lua')
local saved_path=package.path
package.path='mod/DeepSeekCoT/?.lua;'..saved_path
local R=require('rules'); package.path=saved_path
local S={owned={},tick=0,finished=false,mothers=0,first=0,second=0,scatter=0,peak=0}
local function clear()
    for o in pairs(S.owned) do if IsValid(o) then Del(o) end end
    S.owned={}
end
local function count()
    local n=0; for o in pairs(S.owned) do if IsValid(o) then n=n+1 end end; return n
end
local Shot=Class(bullet)
function Shot:init(x,y,angle,kind)
    local image=kind=='mother' and ball_big or (kind=='child' and ball_mid or grain_a)
    local color=kind=='mother' and COLOR_BLUE or (kind=='child' and COLOR_CYAN or COLOR_PURPLE)
    bullet.init(self,image,color,false,true); bullet.skip_fade_in(self)
    self.x,self.y,self.angle,self.kind,self.age=x,y,angle,kind,0
    self.speed=kind=='mother' and 1.65 or (kind=='child' and 1.55 or 2.15)
    self.bound=false; self.warning=nil; S.owned[self]=true
    if kind=='mother' then S.mothers=S.mothers+1 end
    if kind=='scatter' then S.scatter=S.scatter+1 end
end
function Shot:frame()
    if self.kind=='mother' then
        if not self.warning and R.trigger(self.age,self.x,self.y,player.x,player.y) then
            self.warning=0; self.vx,self.vy=0,0
            self.angle=Angle(self,player) -- Lock first split aim when warning starts.
        end
        if self.warning then
            self.vx,self.vy=0,0
            if self.warning>=R.warning then
                for i=-1,1 do New(Shot,self.x,self.y,self.angle+i*32,'child') end
                S.first=S.first+1; Del(self); return
            end
            self.warning=self.warning+1
        end
    elseif self.kind=='child' then
        -- Limited turn rate, then a 42-frame straight segment before the final split.
        if self.age<R.homing then self.angle=R.turn(self.angle,Angle(self,player),0.8) end
        if self.age>=R.child_life then
            New(Shot,self.x,self.y,self.angle-38,'scatter')
            New(Shot,self.x,self.y,self.angle+38,'scatter')
            S.second=S.second+1; Del(self); return
        end
    end
    if not self.warning then self.vx,self.vy=self.speed*cos(self.angle),self.speed*sin(self.angle) end
    self.rot=self.angle; self.age=self.age+1
    if self.age>360 or (self.age>30 and (math.abs(self.x)>235 or self.y>265 or self.y< -265)) then Del(self) end
end
function Shot:render()
    if self.warning then
        local size=1+0.15*sin(self.warning*24)
        Render(self.img,self.x,self.y,self.rot,size,size)
        RenderText('menu',string.format('%.1f',(R.warning-self.warning)/60),self.x,self.y+21,0.22,'centerpoint')
    else bullet.render(self) end
end
function Shot:del() S.owned[self]=nil; bullet.del(self) end
function Shot:kill() S.owned[self]=nil; bullet.kill(self) end
local card=boss.card.New('Inference Sign - Chain of Thought',0,0,60,1000000,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for t=0,3599 do
            S.tick=t
            if t%R.period==0 then
                local aim=Angle(o,player)
                for i=-1,1 do New(Shot,o.x+i*26,o.y,aim+i*18,'mother') end
            end
            S.peak=math.max(S.peak,count()); assert(count()<160,'CoT object budget exceeded')
            task.Wait(1)
        end
    end)
end
card.del=function()
    clear(); S.finished=true
    if setting.cot_test then assert(S.first>0 and S.second>0 and S.scatter==S.second*2,'missing branching generation') end
    print(string.format('COT COMPLETE mothers=%d first=%d second=%d scatter=%d peak=%d owned=%d',S.mothers,S.first,S.second,S.scatter,S.peak,count()))
end
local Boss=Class(boss)
function Boss:init() boss.init(self,0,132,'DeepSeek',{card},nil,'Normal'); self.a,self.b=18,18 end
function Boss:render()
    self._bosssys:render()
    Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.3,1.3)
end
local Hud=Class(object)
function Hud:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function Hud:render()
    RenderText('menu','CHAIN OF THOUGHT / 3 -> 9 -> 18',0,-188,0.27,'centerpoint')
    RenderText('menu','Blue: pause + split / Cyan: brief tracking / Purple: straight',0,-205,0.19,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=100,bomb=3},true,2)
stage.group.AddStage('Normal','Chain of Thought@Normal',nil,true)
stage.group.DefStageFunc('Chain of Thought@Normal','init',function(s)
    clear(); S.tick=0; S.finished=false; S.mothers=0; S.first=0; S.second=0; S.scatter=0; S.peak=0
    stage.group.initTask(s,function()
        New(default_stage_background); New(Hud); task.Wait(60)
        local b=New(Boss)
        while IsValid(b) do
            if setting.cot_test then
                player.protect=1000
                player.x=95*sin(S.tick*0.55); player.y=-165
            end
            task.Wait(1)
        end
        clear(); task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Chain of Thought@Normal','del',function() clear(); print('COT STAGE CLEANUP owned='..count()) end)
stage_init.frame=function(s)
    if s.timer==30 then
        lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
        stage.group.Start('Normal')
    end
end
if setting.cot_test then
    local old_menu=stage_menu.frame
    stage_menu.frame=function(s) old_menu(s); if S.finished and s.timer>=30 then stage.Set('stage.quit') end end
    local captured={}; local old_render=RenderFunc
    RenderFunc=function()
        old_render()
        for _,tick in ipairs({115,155,225,330}) do
            if S.tick>=tick and not captured[tick] then
                captured[tick]=true
                local path='userdata/snapshot/cot-'..tick..'.jpg'
                lstg.Snapshot(path); print('COT SNAPSHOT '..path)
            end
        end
    end
end
