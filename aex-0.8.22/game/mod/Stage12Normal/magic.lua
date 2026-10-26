-- Independently implemented TH06 Sub45 moving laser segment.
Stage2Magic={}
local Laser=Class(object)
function Laser:init(x,y,angle)
    self.originX,self.originY=x,y;self.x,self.y=x,y;self.angle=angle
    self.age=0;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY_BULLET
    self.bound=false;self.vx,self.vy=0,0;self.img='s2.magic.laser'
    self.rot=angle;self.rect=true;self.a,self.b=0,1.5;self.colli=false
    self.kind='water-laser';self.length=0;self.width=6;self.speed=8/3
    Stage2Route.owned[self]=true;Stage2Route.lasers=(Stage2Route.lasers or 0)+1
end
function Laser:frame()
    self.age=self.age+1
    local head=self.age*self.speed;local tail=math.max(0,head-96)
    self.length=head-tail
    self.x=self.originX+(head+tail)/2*cos(self.angle)
    self.y=self.originY+(head+tail)/2*sin(self.angle)
    self.rot=self.angle;self.a,self.b=self.length/2,1.5
    self.colli=self.length>0
    if self.age>300 or (head>96 and (math.abs(self.x)>320 or self.y< -340 or self.y>400))then Del(self)end
end
function Laser:render()
    -- Original laser sprite is16x14, visual width6; source hit width is3.
    Render('s2.magic.laser',self.x,self.y,self.angle+90,6/16,self.length/14)
end
function Laser:del() Stage2Route.owned[self]=nil end
function Laser:kill() Stage2Route.owned[self]=nil end
Stage2Magic.Laser=Laser
local Entry=Class(object)
function Entry:init(x,y)
    self.x,self.y=x,y;self.age=0;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY+1
    self.bound=false;self.colli=false;Stage2Route.owned[self]=true
end
function Entry:frame()self.age=self.age+1;if self.age>=120 then Del(self)end end
function Entry:render()
    local alpha=math.min(1,self.age/30,math.max(0,(120-self.age)/45))
    SetImageState('s2.magic.circle','mul+add',Color(math.floor(alpha*220),210,220,255))
    local size=1.5+0.5*math.min(1,self.age/60)
    Render('s2.magic.circle',self.x,self.y,self.age*1.5,size,size)
    local glow=math.max(0,1-math.abs(self.age-60)/35)
    SetImageState('s2.magic.glow','mul+add',Color(math.floor(glow*140),220,230,255))
    Render('s2.magic.glow',self.x,self.y,0,2.3,2.3)
    SetImageState('s2.magic.circle','',Color(255,255,255,255))
end
function Entry:del()Stage2Route.owned[self]=nil end
Stage2Magic.Entry=Entry
