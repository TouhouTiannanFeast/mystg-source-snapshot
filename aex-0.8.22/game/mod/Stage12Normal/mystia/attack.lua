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
-- Each old large bullet becomes a hollow ring of five independent notes.
-- radius10 + note collision radius3.6 = 27.2px outer diameter (old large:24x24).
local ringRadius,noteRadius,noteCount=10,3.6,5
for _,c in ipairs({{'red',0},{'purple',60},{'blue',120},{'cyan',180}}) do
 -- Crop unused right-hand space so each visible note is centered.
 LoadAnimation('mystia.note.'..c[1],'bullet_music',c[2],0,48,32,1,3,8,noteRadius,noteRadius)
 SetAnimationCenter('mystia.note.'..c[1],20,12)
end
local NativeNote=Class(img_class)
NativeNote.size=0.3
function NativeNote:init(index)
 local names={[COLOR_RED]='red',[COLOR_PURPLE]='purple',[COLOR_BLUE]='blue',[COLOR_CYAN]='cyan'}
 self.img='mystia.note.'..assert(names[index],'unknown note color')
end
local D={owned={},tick=-1,shots=0,notes=0,blue=0,red=0,checks=0,moves=0,moveChecks=0,movingShots=0,finished=false}
local function clean()
 for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
 D.owned={}
end
local Shot=Class(bullet)
function Shot:init(x,y,speed,angle,color,k)
 local colors={red=COLOR_RED,purple=COLOR_PURPLE,blue=COLOR_BLUE,cyan=COLOR_CYAN}
 bullet.init(self,NativeNote,assert(colors[color]),false,true)
 bullet.skip_fade_in(self)
 -- Ring travel follows original angles; artwork stays vertically downward.
 local a=angle+k*360/noteCount
 self.offsetX,self.offsetY=ringRadius*cos(a),ringRadius*sin(a)
 self.x,self.y=x+self.offsetX,y+self.offsetY
 self.originX,self.originY=x,y
 self.vx,self.vy=speed*cos(angle),speed*sin(angle)
 self.a,self.b,self.rect=noteRadius,noteRadius,false
 self.hscale,self.vscale=0.9,0.9 -- Source-reference note display size.
 self.rot=-90;self.age=0;self.bound=false
 D.owned[self]=true;D.notes=D.notes+1
end
function Shot:frame()
 if setting.mystia_note_test then
  assert(math.abs(self.x-self.offsetX-self.originX-self.age*self.vx)<0.02,'note center X changed')
  assert(math.abs(self.y-self.offsetY-self.originY-self.age*self.vy)<0.02,'note center Y changed')
  assert(self.a==3.6 and self.b==3.6 and not self.rect,'note collision changed')
  D.checks=D.checks+1
 end
 self.age=self.age+1
 if self.age>1000 or (self.age>60 and (math.abs(self.x)>224 or math.abs(self.y)>256)) then Del(self) end
end
function Shot:del() D.owned[self]=nil;bullet.del(self) end
function Shot:kill() D.owned[self]=nil;bullet.kill(self) end
local function emitRing(x,y,speed,angle,color,noteColor)
 D.shots=D.shots+1;D[color]=D[color]+1
 for k=0,noteCount-1 do New(Shot,x,y,speed,angle,noteColor or color,k) end
end
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
local card=boss.card.New('',0,2,35,800,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for t=0,P.duration-1 do
            D.tick=t
            if setting.mystia_note_test and t==650 then
                lstg.Snapshot('userdata/snapshot/stage12-mystia-notes.jpg')
                print('MYSTIA NOTE GEOMETRY PASS radius=10 note_radius=3.6 count=5 hollow=true')
            end
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
                -- Preserve the existing large-bullet center trajectory and emission time.
                emitRing(o.x,o.y,e.speed,e.angle,e.color,e.noteColor)
                if age then D.movingShots=D.movingShots+1 end
            end
            if setting.mystia_test and t==340 then
                assert(D.shots==128 and D.blue==64 and D.red==64,'first volley mismatch')
                assert(D.moveChecks==40 and D.movingShots==32,'firing/motion overlap mismatch')
                print('MYSTIA FIRST VOLLEY PASS blue=64 red=64 move_frames=40 moving_shots=32')
            end
            if setting.mystia_test=='kill' and t==400 then o.hp=0 end
            task.Wait(1)
        end
    end)
end
card.del=function()
    local total=D.notes;clean(); D.finished=true
    if setting.mystia_note_test then assert(total==D.shots*5,'note count');print('MYSTIA NOTE CLEANUP PASS notes='..total..' rings='..D.shots..' checks='..D.checks) end
    assert(next(D.owned)==nil,'owned bullet leak')
    print(string.format('MYSTIA CLEANUP PASS tick=%d shots=%d blue=%d red=%d center_checks=%d moves=%d move_frames=%d moving_shots=%d',D.tick,D.shots,D.blue,D.red,D.checks,D.moves,D.moveChecks,D.movingShots))
end
local Mystia=Class(boss)
function Mystia:init()
    boss.init(self,0,112,'Mystia Lorelei',{card},nil,'Normal')
    self.A,self.B=16,16;self.a,self.b=16,16
end
function Mystia:render()
    self._bosssys:render()
    local frame=math.floor(self.ani/4)%4
    if self.motionSpeed and self.motionSpeed>0.2 then frame=4+math.min(3,math.floor(self.ani/4)%4) end
    local facing=(self.moveAngle and cos(self.moveAngle)<0) and -1 or 1
    Render('mystia.'..frame,self.x,self.y,0,facing,1)
end

Stage2Mystia={Shot=Shot,emitRing=emitRing,geometry={radius=ringRadius,noteRadius=noteRadius,count=noteCount},Boss=Mystia,clean=clean,state=D,card=card,reset=function() clean();for k,v in pairs(D) do if type(v)=="number" then D[k]=0 end end;D.tick=-1;D.finished=false end}
