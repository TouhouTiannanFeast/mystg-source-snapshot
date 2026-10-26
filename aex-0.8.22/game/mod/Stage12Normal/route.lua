-- TH10 stage02 Normal route; specified substitutions are explicit at spawn time.
local R={owned={},enemies={},tick=0,phase='Opening',spawns=0,shots=0,human=0,sunflowers=0,tangentChecks=0}
Stage2Route=R
function R.clean()
    for o in pairs(R.owned) do if IsValid(o) then Del(o) end end
    R.owned={};R.enemies={}
end
local function ease(u,mode)
    u=math.max(0,math.min(1,u))
    if mode==4 then return 1-(1-u)^2 end
    if mode==9 then return u<0.5 and 2*u*u or 1-2*(1-u)*(1-u) end
    return u
end
local Shot=Class(bullet)
local Native=Class(img_class);Native.size=ball_small.size
function Native:init() self.img='s2.bullet-54' end
function Shot:init(x,y,speed,angle,img,opt)
    bullet.init(self,Native,COLOR_RED,false,true);bullet.skip_fade_in(self)
    self.x=x;self.y=y;self.speed=speed;self.angle=angle;self.age=0;self.img=img
    local radius=img=='mz.t8c13' and 2.400000095 or (tonumber(img:match('bullet%-(%d+)')) or 0)>=64 and 2 or 3
    self.a,self.b=radius,radius
    self.rect=false;self.bound=false;self.vx,self.vy=0,0;self.opt=opt or {};self.rot=angle+90
    R.owned[self]=true;R.shots=R.shots+1
end
function Shot:frame()
    local a=self.age;local speed=self.speed
    if self.opt.turn then
        -- TH10 update0x407780: speed - speed * age /90 before the turn.
        if a<90 then speed=self.speed*(1-a/90)
        elseif a==90 then
            self.angle=self.angle+self.opt.turn;speed=1.8;self.speed=speed
            self.img='s2.bullet-77';self.a,self.b=2,2
        end
    end
    if self.opt.acc then speed=math.min(1,math.max(0,a-120)*0.01);self.angle=self.opt.angle end
    local x,y=self.x,self.y
    self.x=x+speed*cos(self.angle);self.y=y+speed*sin(self.angle)
    local dx,dy=self.x-x,self.y-y
    if dx*dx+dy*dy>1e-12 then self.rot=math.atan2(dy,dx)*180/math.pi+90 end
    if self.img=='mz.t8c13' and dx*dx+dy*dy>1e-12 then
        assert(cos(self.rot-90)*dx+sin(self.rot-90)*dy>0,'rice heading');R.tangentChecks=R.tangentChecks+1
    end
    self.age=a+1
    if a>1800 or math.abs(self.x)>270 or self.y< -290 or self.y>350 then Del(self) end
end
function Shot:del() R.owned[self]=nil;bullet.del(self) end
function Shot:kill() R.owned[self]=nil;bullet.kill(self) end
local function shot(x,y,speed,angle,img,opt) return New(Shot,x,y,speed,angle,img,opt) end
-- Damage() dispatches through class.base.take_damage; use enemy's damage hook.
local Enemy=Class(enemy)
function Enemy:init(e)
    local healthScale=e.name=='Girl01' and Stage12PlayerConfig.damage_scale or 0.25
    local hp=math.max(1,math.ceil(e.hp*healthScale))
    if e.name=='Girl01' then hp=hp/2*0.8 end
    enemybase.init(self,hp,false)
    self.x,self.y=e.x,224-e.y;self.bound=false;self.a,self.b=8,8;self.age=0;self.e=e
    self.mirror=e.mirror and -1 or 1;self.noShot=e.name:find('Girl00B')~=nil
    self.kind=e.name=='Girl01' and 'sunflower' or e.name:find('Girl00C') and 'fairy' or self.noShot and 'fairy' or 'kedama'
    self.human=self.kind=='fairy' and ((e.t>=560 and e.t<974) or e.human==true)
    self.base=e.name:sub(1,1)=='R' and 12 or e.name:sub(1,1)=='G' and 24 or 0
    self.depart=22.5+ran:Float(-0.4,0.4)*180/math.pi;self.startSpeed=ran:Float(5.5,7.5);self.orbit=ran:Float(-180,180)
    if self.human then R.human=R.human+1 end
    if self.kind=='sunflower' then R.sunflowers=R.sunflowers+1;self.invuln=30 end
    R.enemies[self]=true;R.owned[self]=true;R.spawns=R.spawns+1
end
function Enemy:emit()
    local a=self.age;local e=self.e;local aim=Angle(self,player)
    if self.noShot then return end -- Girl00B shoots on Hard/Lunatic only.
    if self.kind=='fairy' then
        if a==60 then
            local speed=self.human and 3 or 1.2
            for k=0,6 do
                local offset=math.floor((k+1)/2)*0.31415927*180/math.pi*(k%2==1 and -1 or 1)
                shot(self.x,self.y,speed,aim+offset,self.human and 'mz.t8c13' or 's2.bullet-54')
            end
        end
    elseif self.kind=='kedama' then
        if a>=4 and a<=48 and a%4==0 then
            local k=a/4-1;local d=self.orbit+k*0.314159*180/math.pi
            local after=e.name:find('Girl00D')~=nil
            local radius=k*(after and 4 or 6);local speed=after and 1.5+k*0.1 or 1.6+k*0.2
            local x,y=self.x+radius*cos(d),self.y-radius*sin(d)
            shot(x,y,speed,math.atan2(player.y-y,player.x-x)*180/math.pi,'s2.bullet-54')
        end
    elseif self.kind=='sunflower' then
        -- Girl01_at: 5 rows, 1+2+3+4+5 shots; ten frames per row.
        local r=a-90
        if r>=0 and r<250 and r%80<50 and r%10==0 then
            local row=math.floor((r%80)/10)+1
            if row==1 then self.lockAim=aim end
            for k=0,row-1 do
                local angle=self.lockAim+(row-1)*5.625-k*11.25
                shot(self.x,self.y,3,angle,'s2.bullet-67',{turn=-(row-1)*11.25+k*22.5})
            end
        end
    end
end
function Enemy:frame()
    local a=self.age;local angle,speed
    if self.kind=='sunflower' then angle=157.5;speed=5-4*ease(a/60,4)
    elseif self.e.name:find('Girl00C') then
        if a<60 then angle=90+(45-90)*ease(a/60,0);speed=4.7*(1-a/60)
        elseif a<160 then angle=45;speed=2*math.min(1,(a-60)/60)
        else angle=22.5;speed=2.7 end
    elseif self.noShot then
        if a<60 then angle=90+(self.depart-90)*a/60;speed=4.7*(1-a/60)
        else angle=self.depart;speed=4*math.min(1,(a-60)/60) end
    else
        if a<40 then angle=90;speed=self.startSpeed*(1-ease(a/40,4))
        elseif a<100 then angle=90;speed=0
        else angle=90+(self.depart-90)*ease((a-100)/40,4);speed=2.7*ease((a-100)/40,4) end
    end
    self.x=self.x+self.mirror*speed*cos(angle);self.y=self.y-speed*sin(angle)
    Enemy.emit(self);self.age=a+1
    self.protect=self.kind=='sunflower' and a<30
    self.img=self.human and 'mz.th185-'..({15,16,15,17})[math.floor(a/8)%4+1] or 's2.enemy-'..(self.kind=='kedama' and (49+math.floor(self.base/12)) or self.kind=='sunflower' and (96+math.floor(a/5)%4) or self.base+math.floor(a/5)%4)
    self.a,self.b=8,8 -- Assigning img resets collision extents to sprite defaults.
    if a>15 and (math.abs(self.x)>265 or self.y< -275) then Del(self);return end
    enemybase.frame(self)
end
-- Bounded native evidence distinguishes failed hits from excessive HP.
local hitLogs,killLogs=0,0
local function hit(o,other)
    local hp=o.hp
    enemybase.colli(o,other)
    if other.dmg and o.hp<hp and not o.hitLogged and hitLogs<12 then
        o.hitLogged=true;hitLogs=hitLogs+1
        print(string.format('STAGE2 HIT %s hp=%.2f->%.2f dmg=%.2f',o.e and o.e.name or o.name,hp,o.hp,other.dmg))
    end
end
function Enemy:colli(other) hit(self,other) end
function Enemy:render() Render(self.img or 's2.enemy-0',self.x,self.y,0,self.mirror,1) end
function Enemy:del() R.owned[self]=nil;R.enemies[self]=nil;enemybase.del(self) end
function Enemy:kill()
    if killLogs<12 then killLogs=killLogs+1;print('STAGE2 KILL '..self.e.name) end
    R.owned[self]=nil;R.enemies[self]=nil
    item.DropItem(self.x,self.y,{self.e.name:sub(1,1)=='R' and 1 or 0,1,0})
    PlaySound('enep00',0.3,self.x/200,true)
    enemybase.del(self)
end
function R.spawn(e) return New(Enemy,e) end

-- Hina's untargetable pre-spell passage and all 32 source emitters.
local Seed=Class(enemy)
function Seed:init(x,y,name)
    enemybase.init(self,13,false)
    self.x,self.y=x,y;self.age=0;self.name=name;self.layer=LAYER_ENEMY;self.group=GROUP_GHOST;self.bound=false;self.colli=false
    self.a,self.b=8,8;self.protect=true
    self.color=name:sub(1,1)=='R' and 2 or name:sub(1,1)=='G' and 10 or name:sub(1,1)=='Y' and 13 or 6
    self.book=name:find('01')~=nil
    self.img=self.book and 's2.magic.book0' or 's2.magic.circle'
    self.a,self.b=8,8 -- Set extents after img assignment.
    R.owned[self]=true
end
function Seed:frame()
    local a=self.age;local aimed=self.name:find('01')~=nil
    if a==76 then self.group=GROUP_ENEMY;self.colli=true;self.protect=false end
    if a==76 then
        local aim=Angle(self,player)
        if not aimed then
            for k=0,23 do shot(self.x,self.y,2,aim+k*15,'s2.bullet-'..(48+self.color)) end
        else
            self.aimed=aim
        end
    end
    if aimed and a==87 then
        for k=0,4 do
            local offset=math.floor((k+1)/2)*0.2617994*180/math.pi*(k%2==1 and -1 or 1)
            shot(self.x,self.y,4/3,Angle(self,player)+offset,'s2.magic.paper'..self.color)
        end
    end
    if a>=196 then
        if a==196 then self.depart=Angle(self,player) end
        local s=2.7*ease((a-196)/60,4);self.x=self.x+s*cos(self.depart);self.y=self.y+s*sin(self.depart)
    end
    self.img=self.book and 's2.magic.book'..(math.floor(a/6)%3) or 's2.magic.circle'
    self.a,self.b=8,8
    self.age=a+1
    if a>196 and (math.abs(self.x)>260 or self.y< -275) then Del(self) end
    if IsValid(self) then enemybase.frame(self) end
end
function Seed:colli(other) hit(self,other) end
function Seed:render() Render(self.img,self.x,self.y,self.book and 0 or self.age*1.5,self.book and 1 or 0.65,self.book and 1 or 0.65) end
function Seed:del() R.owned[self]=nil;enemybase.del(self) end
function Seed:kill() R.owned[self]=nil;PlaySound('enep00',0.3,self.x/200,true);enemybase.del(self) end
local Hina=Class(object)
function Hina:init()
    R.circleSeeds=0;R.laserRounds=0
    self.x,self.y=0,352;self.age=0;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false
    R.owned[self]=true
end
function Hina:frame()
    local t=self.age
    local phase=math.max(0,t-120)%240;local u=phase<120 and phase/120 or (phase-120)/120
    local base=t<120 and -80*ease(t/120,9) or phase<120 and (-80+160*ease(u,9)) or (80-160*ease(u,9))
    local radius=32*math.min(1,t/120);local angle=180+t*1.5
    local by=t<120 and -128+240*ease(t/120,9) or 112
    if t>=1702 then base=base*(1-ease((t-1702)/60,4));by=by+(128-by)*ease((t-1702)/60,4) end
    self.x=base+radius*cos(angle);self.y=224-(by+radius*sin(angle))
    if t>=92 and t<=1702 and (t-92)%46==0 then
        local n=(t-92)/46
        local colors={'G','G','B','B','R','B','G','G','R','R','B','B','R','R','B','B','G','G','B','B','B','R','B','G','R','R','B','B','R','B','Y','Y'}
        local color=n<20 and colors[n%16+1] or colors[n-4+1]
        New(Seed,-self.x,self.y,color..'SpCir'..(n<20 and '00' or '01'))
        if n<20 then R.circleSeeds=(R.circleSeeds or 0)+1 end
    end
    -- Preserve15 rounds and5-frame bursts, emitted by the latest surviving book.
    local laserAge=t-1089
    if laserAge>=0 and laserAge<15*30 then
        local shotAge=laserAge%30
        if shotAge==0 or shotAge==5 or shotAge==10 then
            local book
            for o in pairs(R.owned)do
                if IsValid(o) and o.class==Seed and o.book and o.age>=76 and (not book or o.age<book.age)then book=o end
            end
            if book then New(Stage2Magic.Laser,book.x,book.y,Angle(book,player)) end
            if shotAge==0 then R.laserRounds=(R.laserRounds or 0)+1 end
        end
    end
    self.age=t+1
    if t==1799 then Del(self) end
end
function Hina:del() R.owned[self]=nil end
function Hina:render() end -- Invisible choreography anchor; Patchouli enters at the spell.
function R.hina() return New(Hina) end
R.Shot=Shot;R.Enemy=Enemy;R.Seed=Seed;R.Hina=Hina
