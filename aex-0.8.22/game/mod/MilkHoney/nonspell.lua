-- TH10 stage07 Boss7/Boss7_at; optional drawing-only rainbow crossfade.
MilkHoneyNonspell={duration=3600,hp=8000,start=120,interval=30,count=32,
    colorFrames=20, -- Frames per color transition: larger=slower; 60frames=1second.
    speeds={3.75,3.10,2.44,1.78},palette={118,120,122,124,126,114,116},
    --原始speeds={5,4.125,3.25,2.375}。这里是约3/4
    owned={},tick=-1,shots=0,volleys=0,moves=0,checks=0,colorChecks=0}
local N=MilkHoneyNonspell
function N.events(t) return t>=120 and (t-120)%30==0 end
function N.moveAge(t)
    if t<150 then return nil end
    local a=(t-150)%60
    if a<30 then return a end
end
function N.colors(age,phase)
    local h=(age+phase)/N.colorFrames
    local i=math.floor(h)
    return N.palette[i%7+1],N.palette[(i+1)%7+1],h-i
end
function N.clean()
    for o in pairs(N.owned) do if IsValid(o) then Del(o) end end
    N.owned={}
end
for _,id in ipairs({118,120,122,124,126,114,116,214}) do
    local name='milk.ofuda'..id
    LoadTexture(name,'art/ofuda-'..id..'.png')
    local w,h=GetTextureSize(name)
    LoadImage(name,name,0,0,w,h)
end
local Image=Class(img_class);Image.size=0.3
function Image:init() self.img='milk.ofuda118' end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle)
    bullet.init(self,Image,COLOR_BLUE,false,true);bullet.skip_fade_in(self)
    self.initialVX,self.initialVY=speed*cos(angle),speed*sin(angle)
    self.x,self.y=x-4*self.initialVX,y-4*self.initialVY
    self.age=0;self.vx,self.vy=0,0;self.bound=false;self.colli=false
    self.rot=0;self.a,self.b,self.rect=2,2,true
    self.heading=angle-90
    self.phase=0 -- Every volley starts blue; all bullets in a volley change together.
    N.owned[self]=true;N.shots=N.shots+1
end
function Shot:frame()
    if setting.milk_test and self.lastX then
        assert(math.abs(self.x-self.lastX-self.lastVX)<0.003 and math.abs(self.y-self.lastY-self.lastVY)<0.003,'nonspell integration mismatch')
        N.checks=N.checks+1
    end
    local factor=self.age<15 and 0.5 or (self.age==15 and 1.5 or 1)
    self.vx,self.vy=self.initialVX*factor,self.initialVY*factor
    self.colli=self.age>=15
    self.lastX,self.lastY,self.lastVX,self.lastVY=self.x,self.y,self.vx,self.vy
    self.age=self.age+1
    if self.age>15 and MilkHoneyPattern.outside(self.x+self.vx,self.y+self.vy,14,16) then Del(self) end
end
function Shot:render()
    if self.age<15 then
        local u=self.age/15;local scale=0.5+2.5*(1-u)^2
        SetImageState('milk.ofuda214','',Color(math.floor(u*255),255,255,255))
        Render('milk.ofuda214',self.x,self.y,0,scale,scale)
        SetImageState('milk.ofuda214','',Color(255,255,255,255))
    else
        local a,b,u=N.colors(self.age-15,self.phase)
        -- Opaque base + transparent next color: smooth blend, no dark midpoint.
        SetImageState('milk.ofuda'..a,'',Color(255,255,255,255))
        SetImageState('milk.ofuda'..b,'',Color(math.floor(255*u),255,255,255))
        Render('milk.ofuda'..a,self.x,self.y,self.heading)
        Render('milk.ofuda'..b,self.x,self.y,self.heading)
        SetImageState('milk.ofuda'..b,'',Color(255,255,255,255))
        if setting.milk_test then
            assert(u>=0 and u<1 and self.rot==0 and self.a==2 and self.b==2,'gradient changed collision')
            N.colorChecks=N.colorChecks+1
        end
    end
end
function Shot:del() N.owned[self]=nil;bullet.del(self) end
function Shot:kill() N.owned[self]=nil;bullet.kill(self) end
function N.create(P)
    local card=boss.card.New('',1,1,60,8000,{0,0,0},false)
    card.init=function(o)
        N.tick=-1;N.shots=0;N.volleys=0;N.moves=0;N.checks=0;N.colorChecks=0
        task.New(o,function()
            local sx,sy=o.x,o.y
            for t=0,N.duration-1 do
                N.tick=t
                if t<60 then local u=(t+1)/60;local f=1-(1-u)^2;o.x,o.y=sx*(1-f),sy+(96-sy)*f end
                if setting.milk_test and t==240 then
                    assert(N.shots==512 and N.volleys==4 and N.moves==2,'nonspell schedule mismatch')
                    assert(N.checks>1000 and N.colorChecks>1000,'nonspell runtime checks missing')
                    print('MILK NONSPELL PASS volleys=4 shots=512 moves=2 checks='..N.checks..' gradientChecks='..N.colorChecks)
                    o.hp=0;return
                end
                if N.events(t) then
                    local aim=Angle(o,player)
                    for _,speed in ipairs(N.speeds) do
                        for i=0,31 do New(Shot,o.x,o.y,speed,aim-i*360/32) end
                    end
                    N.volleys=N.volleys+1
                end
                local age=N.moveAge(t)
                if age==0 then o.nonMoveAngle=P.moveAngle(o.x,o.y,player.x,function(a,b)return ran:Float(a,b)end);N.moves=N.moves+1 end
                if age then
                    local v=2*(1-(age+1)/30)
                    o.x=math.max(-140,math.min(140,o.x+v*cos(o.nonMoveAngle)))
                    o.y=math.max(96,math.min(160,o.y+v*sin(o.nonMoveAngle)))
                end
                task.Wait(1)
            end
        end)
    end
    card.del=function()
        N.clean();N.tick=-1
        assert(next(N.owned)==nil,'nonspell bullet leak into spell')
        print('MILK NONSPELL CLEANUP PASS')
    end
    return card
end
