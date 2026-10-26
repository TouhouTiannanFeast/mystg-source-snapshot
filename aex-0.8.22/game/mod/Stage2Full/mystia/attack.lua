-- Independently implemented from pinned local ECL behavior. No original ECL execution.

Include('mystia/pattern.lua')
local P=MystiaAyaPattern
if setting.mystia_test then
    local f=assert(io.open('G:/MySTG/work/logs/mystia-aya-easy-large/native-schedule.csv','w'))
    f:write('tick,color,speed,angle,radius\n')
    for t=0,P.duration-1 do
        for _,e in ipairs(P.events(t)) do
            f:write(string.format('%d,%s,%.9f,%.9f,%.9f\n',t,e.color,e.speed,e.angle,e.radius))
        end
    end
    f:close()
end
LoadTexture('mystia.local','mystia/mystia-local.png')
for i=0,11 do LoadImage('mystia.'..i,'mystia.local',(i%4)*48,math.floor(i/4)*64,48,64) end
-- TH08 type10: script25 -> sprite168 + color. Red=168, blue=169.
-- Native collisionSize is full width/height 24; AEX takes half extents.
for _,color in ipairs({'red','blue'}) do
    LoadTexture('mystia.large.'..color,'mystia/th08-large-'..color..'.png')
    LoadImage('mystia.large.'..color,'mystia.large.'..color,0,0,64,64,12,12,true)
    SetImageState('mystia.large.'..color,'mul+add')
end
local NativeLarge=Class(img_class)
NativeLarge.size=1.8
function NativeLarge:init(index)
    self.img='mystia.large.'..(index==COLOR_BLUE and 'blue' or 'red')
end
local D={owned={},tick=-1,shots=0,blue=0,red=0,checks=0,moves=0,moveChecks=0,movingShots=0,finished=false}
local function clean()
    for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
    D.owned={}
end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle,color,radius)
    bullet.init(self,NativeLarge,color=='blue' and COLOR_BLUE or COLOR_RED,false,true)
    bullet.skip_fade_in(self)
    self.a,self.b,self.rect=12,12,true
    if setting.mystia_test then
        assert(self.img=='mystia.large.'..color and self.a==12 and self.b==12 and self.rect,'TH08 type10 sprite/collision mismatch')
    end
    self.x,self.y=x,y
    self.vx,self.vy=speed*cos(angle),speed*sin(angle)
    self.age=0; self.bound=false
    self.originX,self.originY=x,y
    self.radius,self.direction=radius,angle
    D.owned[self]=true; D.shots=D.shots+1; D[color]=D[color]+1
end
function Shot:frame()
    if setting.mystia_test and self.age>0 then
        assert(math.abs(self.x-self.lastX-self.vx)<0.02 and math.abs(self.y-self.lastY-self.vy)<0.02,'center trajectory changed')
        -- Independently reconstruct the twelve old ring positions at this age.
        -- Their arithmetic center must be this single replacement bullet.
        local cx,cy=0,0
        for k=0,11 do
            local a=self.direction+k*30
            cx=cx+self.originX+self.age*self.vx+self.radius*cos(a)
            cy=cy+self.originY+self.age*self.vy+self.radius*sin(a)
        end
        assert(math.abs(cx/12-self.x)<0.00001 and math.abs(cy/12-self.y)<0.00001,'ring center mismatch')
        D.checks=D.checks+1
    end
    self.lastX,self.lastY=self.x,self.y
    self.age=self.age+1
    -- Original etEx 8192 keeps offscreen bullets alive for their first 60 frames.
    if self.age>1000 or (self.age>60 and (math.abs(self.x)>224 or math.abs(self.y)>256)) then Del(self) end
end
function Shot:del() D.owned[self]=nil; bullet.del(self) end
function Shot:kill() D.owned[self]=nil; bullet.kill(self) end
local function start_move(o)
    -- moveRand(40,0,4): angle selected by movement bounds/player side;
    -- polar speed interpolates linearly from 4 to 0 over forty frames.
    local a
    if o.x< -70 then a=ran:Float(-60,60)
    elseif o.x>70 then a=180+ran:Float(-60,60)
    elseif o.x<player.x then a=ran:Float(-90,90)
    else a=180+ran:Float(-360,360) end
    a=(a+180)%360-180
    local nativeY=224-o.y
    if nativeY<80 then a=math.abs(a) elseif nativeY>112 then a=-math.abs(a) end
    o.moveAngle=-a; D.moves=D.moves+1
end
local card=boss.card.New('',0,2,60,1200,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for t=0,P.duration-1 do
            D.tick=t
            local age=P.move_age(t)
            if age==0 then start_move(o) end
            o.motionSpeed=0
            if age then
                local speed=4*(1-(age+1)/40)
                o.motionSpeed=speed
                o.x=math.max(-140,math.min(140,o.x+speed*cos(o.moveAngle)))
                o.y=math.max(96,math.min(160,o.y+speed*sin(o.moveAngle)))
                D.moveChecks=D.moveChecks+1
                assert(o.x>=-140 and o.x<=140 and o.y>=96 and o.y<=160,'Boss movement bounds')
            end
            for _,e in ipairs(P.events(t)) do
                -- Every original ring shared one velocity. Its center starts at
                -- the current Boss position; radius is removed, not retained.
                New(Shot,o.x,o.y,e.speed,e.angle,e.color,e.radius)
                if age then D.movingShots=D.movingShots+1 end
            end
            if setting.mystia_test and t==340 then
                assert(D.shots==64 and D.blue==32 and D.red==32,'first volley mismatch')
                assert(D.moveChecks==40 and D.movingShots==16,'firing/motion overlap mismatch')
                print('MYSTIA FIRST VOLLEY PASS blue=32 red=32 move_frames=40 moving_shots=16')
            end
            if setting.mystia_test=='kill' and t==400 then o.hp=0 end
            task.Wait(1)
        end
    end)
end
card.del=function()
    clean(); D.finished=true
    assert(next(D.owned)==nil,'owned bullet leak')
    print(string.format('MYSTIA CLEANUP PASS tick=%d shots=%d blue=%d red=%d center_checks=%d moves=%d move_frames=%d moving_shots=%d',D.tick,D.shots,D.blue,D.red,D.checks,D.moves,D.moveChecks,D.movingShots))
end
local Mystia=Class(boss)
function Mystia:init()
    boss.init(self,0,112,'Mystia Lorelei',{card},nil,'Easy')
    self.A,self.B=16,16;self.a,self.b=16,16
end
function Mystia:render()
    self._bosssys:render()
    local frame=math.floor(self.ani/4)%4
    if self.motionSpeed and self.motionSpeed>0.2 then frame=4+math.min(3,math.floor(self.ani/4)%4) end
    local facing=(self.moveAngle and cos(self.moveAngle)<0) and -1 or 1
    Render('mystia.'..frame,self.x,self.y,0,facing,1)
end

Stage2Mystia={Boss=Mystia,clean=clean,state=D,card=card,reset=function() clean();for k,v in pairs(D) do if type(v)=="number" then D[k]=0 end end;D.tick=-1;D.finished=false end}
