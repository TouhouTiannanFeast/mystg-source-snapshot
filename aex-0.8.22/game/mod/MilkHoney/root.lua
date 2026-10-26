Include('THlib.lua')
Include('pattern.lua')
Include('nonspell.lua')
local P=MilkHoneyPattern
local D={owned={},tick=-1,main=0,secondary=0,moves=0,checks=0,finished=false,redRing=0,yellowRice=0,headingChecks=0}
MilkHoneyState=D
for _,id in ipairs({336,337,338,339,72,215,60,49,79,76}) do
    local n='milk.sprite'..id
    LoadTexture(n,'art/sprite'..id..'.png')
    local w,h=GetTextureSize(n)
    LoadImage(n,n,0,0,w,h)
end
local Main=Class(img_class);Main.size=0.6
function Main:init() self.img='milk.sprite60' end
local Secondary=Class(img_class);Secondary.size=0.3
function Secondary:init() self.img='milk.sprite79' end
local function clean()
    MilkHoneyNonspell.clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle,kind)
    local mixed=(D[kind]+1)%10==0
    local color=kind=='main' and (mixed and COLOR_RED or COLOR_YELLOW) or (mixed and COLOR_YELLOW or COLOR_GRAY)
    bullet.init(self,kind=='main' and Main or Secondary,color,false,true)
    bullet.skip_fade_in(self)
    self.kind,self.age=kind,0
    self.sprite=kind=='main' and (mixed and 49 or 60) or (mixed and 76 or 79)
    if mixed then if kind=='main' then D.redRing=D.redRing+1 else D.yellowRice=D.yellowRice+1 end end
    self.initialVX,self.initialVY=speed*cos(angle),speed*sin(angle)
    self.x,self.y=x-4*self.initialVX,y-4*self.initialVY
    self.renderX,self.renderY=self.x,self.y
    self.heading=angle-90
    self.vx,self.vy=0,0
    self.bound,self.colli=false,false
    self.rot=0
    D.owned[self]=true;D[kind]=D[kind]+1
end
function Shot:frame()
    if setting.milk_test and self.lastX then
        assert(math.abs(self.x-self.lastX-self.lastVX)<0.003 and math.abs(self.y-self.lastY-self.lastVY)<0.003,'native bullet integration differs')
        D.checks=D.checks+1
    end
    self.vx,self.vy=P.velocity(self.initialVX,self.initialVY,self.age)
    self.colli=self.age>=8
    if self.kind=='main' then
        self.img='milk.sprite'..self.sprite
        self.a,self.b=3,3
    else
        self.img='milk.sprite'..self.sprite
        self.a,self.b=2,2
    end
    self.rect=true;self.rot=0 -- Retail collision is an axis-aligned square.
    if self.age<8 then
        local u=self.age/8
        local ease=1-(1-u)^2
        local start=self.kind=='main' and 5 or 3
        local finish=self.kind=='main' and 1 or 0.5
        self.hscale,self.vscale=start+(finish-start)*ease,start+(finish-start)*ease
        self._blend='';self._a=math.floor(255*u);self._r,self._g,self._b=255,255,255
    else
        self.hscale,self.vscale=1,1
        self._a=255
    end
    self.lastX,self.lastY,self.lastVX,self.lastVY=self.x,self.y,self.vx,self.vy
    self.age=self.age+1
    local w=self.kind=='main' and 32 or 16
    -- Cull after integration, with the source's 240-frame grace period.
    if self.age>240 and P.outside(self.x+self.vx,self.y+self.vy,w,w) then Del(self) end
end
function Shot:render()
    if self.kind=='secondary' then
        local dx,dy=self.x-self.renderX,self.y-self.renderY
        self.renderX,self.renderY=self.x,self.y
        local length=math.sqrt(dx*dx+dy*dy)
        if length>0.000001 then
            self.heading=math.atan2(dy,dx)*180/math.pi-90
            if setting.milk_test then
                local hx,hy=cos(self.heading+90),sin(self.heading+90)
                assert((hx*dx+hy*dy)/length>0.999999,'rice head not aligned with trajectory tangent')
                D.headingChecks=D.headingChecks+1
            end
        end
        -- Rotate the drawing only; retain the existing axis-aligned collision.
        self.rot=self.heading;bullet.render(self);self.rot=0
    else bullet.render(self) end
end
function Shot:del() D.owned[self]=nil;bullet.del(self) end
function Shot:kill() D.owned[self]=nil;bullet.kill(self) end
local card=boss.card.New('神迹「流淌着奶与蜜之地」',1,1,50,2250,{0,0,0},true)
card.t3=P.duration -- Use the same frame limit as the firing loop.
card.init=function(o)
    task.New(o,function()
        local sx,sy=o.x,o.y
        for t=0,P.duration-1 do
            D.tick=t
            if t<60 then
                local u=(t+1)/60;local f=1-(1-u)^2
                o.x,o.y=sx*(1-f),sy+(96-sy)*f
            end
            local age=P.moveAge(t)
            if age==0 then o.moveAngle=P.moveAngle(o.x,o.y,player.x,function(a,b)return ran:Float(a,b)end);D.moves=D.moves+1 end
            if age then
                local v=P.moveSpeed(age)
                o.x=math.max(-140,math.min(140,o.x+v*cos(o.moveAngle)))
                o.y=math.max(96,math.min(160,o.y+v*sin(o.moveAngle)))
            end
            if setting.milk_test and t==720 then
                assert(D.main==1280 and D.secondary==1080 and D.moves==5,'native source schedule mismatch')
                assert(D.checks>10000,'native trajectory checks missing')
                assert(D.redRing==128 and D.yellowRice==108,'one-in-ten visual mix mismatch')
                assert(D.headingChecks>10000,'rice render tangent checks missing')
                print('MILK VISUAL PASS redRing='..D.redRing..' yellowRice='..D.yellowRice..' riceHeadingChecks='..D.headingChecks)
                print('MILK NATIVE PASS main='..D.main..' secondary='..D.secondary..' moves='..D.moves..' trajectoryChecks='..D.checks)
                o.hp=0;return
            end
            for _,e in ipairs(P.events(t,function(a,b)return ran:Float(a,b)end)) do
                for _,angle in ipairs(P.angles(e.angle)) do New(Shot,o.x,o.y,e.speed,angle,e.kind) end
            end
            task.Wait(1)
        end
    end)
end
card.del=function()
    clean();D.finished=true
    assert(next(D.owned)==nil,'owned bullet leak')
    print('MILK CLEANUP PASS tick='..D.tick)
end
local Suwako=Class(boss)
function Suwako:init() boss.init(self,0,128,'Suwako',{MilkHoneyNonspell.create(P),card},nil,'Extra');self.a,self.b=18,18 end
function Suwako:render()
    self._bosssys:render()
    Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.3,1.3)
end
stage.group.New('Extra','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Extra','Milk and Honey@Extra',nil,true)
stage.group.DefStageFunc('Milk and Honey@Extra','init',function(s)
    D.tick=-1;D.main=0;D.secondary=0;D.moves=0;D.checks=0;D.finished=false;D.redRing=0;D.yellowRice=0;D.headingChecks=0
    stage.group.initTask(s,function()
        New(default_stage_background);task.Wait(60)
        local b=New(Suwako)
        while IsValid(b) do
            if setting.milk_test then player.protect=1000 end
            task.Wait(1)
        end
        clean();task.Wait(60)
    end)
end)
stage.group.DefStageFunc('Milk and Honey@Extra','del',clean)
stage_init.frame=function(s)
    if s.timer==30 then
        lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
        stage.group.Start('Extra')
    end
end
if setting.milk_test then
    local oldMenu=stage_menu.frame
    stage_menu.frame=function(s) oldMenu(s);if D.finished and s.timer>=30 then stage.Set('stage.quit') end end
    local oldRender=RenderFunc;local captured={}
    RenderFunc=function()
        oldRender()
        for _,t in ipairs({160,225}) do
            local key='nonspell'..t
            if MilkHoneyNonspell.tick>=t and not captured[key] then
                captured[key]=true
                local path='userdata/snapshot/milk-honey-nonspell-'..t..'.jpg'
                lstg.Snapshot(path);print('MILK SNAPSHOT '..path)
            end
        end
        for _,t in ipairs({300,480,700}) do
            if D.tick>=t and not captured[t] then
                captured[t]=true
                local path='userdata/snapshot/milk-honey-'..t..'.jpg'
                lstg.Snapshot(path);print('MILK SNAPSHOT '..path)
            end
        end
    end
end
