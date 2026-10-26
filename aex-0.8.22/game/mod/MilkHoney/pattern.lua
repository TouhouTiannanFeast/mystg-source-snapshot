-- TH10 BossCard7. ECL screen-down radians -> AEX screen-up degrees.
MilkHoneyPattern={duration=3000,start=80,secondaryStart=180,interval=4,count=8,
    spacing=22.5,acceleration=0.032,accelerationFrames=120,birthFrames=8,cullDelay=240}
local P=MilkHoneyPattern
function P.events(t,random)
    local out={}
    if t>=P.start and (t-P.start)%4==0 then
        local n=(t-P.start)/4
        -- Keep the actual source radian constants rather than rounded degrees.
        out[#out+1]={kind='main',angle=-(0.5235988*math.sin(n*0.10472)-1.5707964)*180/math.pi,speed=2.5}
    end
    if t>=P.secondaryStart and (t-P.secondaryStart)%4==0 then
        out[#out+1]={kind='secondary',angle=-(-1.5707964+random(-math.pi,math.pi)/8)*180/math.pi,speed=random(0,1)*0.8+1}
    end
    return out
end
function P.angles(center)
    local a={}
    for i=0,7 do
        local d=math.floor(i/2)*0.3926991+0.3926991*0.5
        if i%2==1 then d=-d end
        a[#a+1]=center-d*180/math.pi
    end
    return a
end
function P.moveAge(t)
    if t<140 then return nil end
    local age=(t-140)%120
    if age<60 then return age end
end
function P.moveAngle(x,y,px,random)
    local a
    if x< -70 then a=random(-60,60)
    elseif x>70 then a=180+random(-60,60)
    elseif x<px then a=random(-90,90)
    else a=180+random(-360,360) end
    a=(a+180)%360-180
    local sy=224-y
    if sy<80 then a=math.abs(a) elseif sy>112 then a=-math.abs(a) end
    return -a
end
function P.moveSpeed(age) return (1-(age+1)/60)^2 end
-- Native birth retreats four initial velocities and travels at half speed.
function P.velocity(vx,vy,age)
    if age<8 then return vx*0.5,vy*0.5 end
    local n=math.min(age-8+1,120)
    -- State2 adds half a velocity before falling through into state1 on
    -- the activation frame (retail BulletUpdateRuntime, 0x406240).
    if age==8 then return vx*1.5,vy*1.5-0.032 end
    return vx,vy-0.032*n
end
function P.outside(x,y,w,h)
    -- Retail culling bounds: X=-192..192,Y=-64..448 (screen-down).
    return x+w/2<=-192 or x-w/2>=192 or y-h/2>=288 or y+h/2<=-224
end
