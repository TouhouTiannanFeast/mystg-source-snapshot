-- Existing shot rows/cadence with a TH18-like high-speed homing option shot.
-- Slow mode keeps the focused piercing needles; resource rules are separate.
Include('player-config.lua')
Include('player-data.lua')
Y3Player={}
local P=Y3Player
local hit=enemybase.colli
local function piercingCollision(self,other)
 if other.y3Piercing then
  if other.y3Hits[self]then return end
  if self.protect or self.invuln and self.invuln>0 or self.dmg_factor==0 then return end
  other.y3Hits[self]=true
 end
 return hit(self,other)
end
enemybase.colli=piercingCollision;boss.colli=piercingCollision;enemy.colli=piercingCollision
local Shot=Class(player_bullet_straight)
P.Shot=Shot
function Shot:init(x,y,speed,damage,piercing)
 player_bullet_straight.init(self,piercing and 'y3.player.pierce' or 'y3.player.main',x,y,speed,90,damage)
 self.a,self.b=24,piercing and 8 or 9;self.rect=true
 self.y3Piercing=piercing;self.killflag=piercing
 self.y3Hits=setmetatable({},{__mode='k'})
end
function Shot:frame()if self.y>lstg.world.boundt+64 then Del(self)end end
-- Based on MySTG systems/th18-fire/core.lua nearest/home behavior. This
-- isolated adaptation preserves this mod's damage rows and firing clock.
function P.nearest(x,y)
 local target,dist=nil,256*256
 for _,group in ipairs({GROUP_ENEMY,GROUP_NONTJT})do
  for _,e in ObjList(group)do
   if IsValid(e)and e.colli and not e.protect and e.hp and e.hp>0
    and not(e.data and(e.data.dead or e.data.visible==false))then
    local d=(e.x-x)^2+(e.y-y)^2
    if d<dist then target,dist=e,d end
   end
  end
 end
 return target
end
function P.home(b,target)
 if target and b.timer<60 then
  local diff=(Angle(b,target)-b.heading+540)%360-180
  b.heading=b.heading+diff*.08
  if math.abs(diff)<15 then b.speed=math.min(16,b.speed+.2)
  elseif math.abs(diff)>=45 then b.speed=math.max(4,b.speed-.2)end
 else b.speed=math.min(16,b.speed+(target and .2 or .1))end
end
local Homing=Class(player_bullet_straight)
P.Homing=Homing
function Homing:init(x,y,damage,angle)
 player_bullet_straight.init(self,'hs5.player.charm',x,y,4,angle,damage)
 self.a,self.b,self.rect=8,8,true;self.bound=false
 self.heading,self.speed=angle,4;self.killflag=false
end
function Homing:frame()
 local target=P.nearest(self.x,self.y);P.home(self,target)
 self.rot=self.heading;self.vx,self.vy=self.speed*cos(self.heading),self.speed*sin(self.heading)
 if setting.hsob5_test and target and not P.nativeHomingChecked and self.timer>0 and self.timer<60 then
  P.nativeHomingChecked=true;print('HSOB5 HOMING native target acquired; angle='..self.heading..' speed='..self.speed)
 end
 if self.timer>=15 and(self.x<lstg.world.boundl-64 or self.x>lstg.world.boundr+64 or self.y<lstg.world.boundb-64 or self.y>lstg.world.boundt+64)then Del(self)end
end
function Homing:kill()
 if reimu_bullet_blue_ef then New(reimu_bullet_blue_ef,self.x,self.y,self.rot)end
end
function P.shoot(self)
 self.nextshoot=1
 if P.probing then return end
 local clock=self.y3FireClock or 0
 local rows=Y3ReimuBData.shooters[math.min(4,math.floor(lstg.var.power/100))+1]
 local played=false
 for _,s in ipairs(rows)do
  if clock>=s.delay and clock%s.rate==0 then
   local x,y=self.x,self.y
   if s.option>0 then
    local sp=self.sp[s.option]
    if sp and sp[3]>0.5 then x=self.supportx+sp[1];y=self.supporty+sp[2]else x=nil end
   end
   if x then
    if s.option>0 and self.slow~=1 then
     New(Homing,x+s.x,y+s.y,s.damage*Y3PlayerConfig.damage_scale,({110,70,100,80})[s.option])
    else
     New(Shot,x+s.x,y+s.y,s.speed,s.damage*Y3PlayerConfig.damage_scale,s.option>0)
    end
    if setting.y3_test_player then
     local key=self.slow==1 and 'slowDamage' or 'highDamage';P[key]=(P[key]or 0)+s.damage*Y3PlayerConfig.damage_scale
    end
    if not played then PlaySound('plst00',0.3,self.x/1024);played=true end
   end
  end
 end
end
-- PlayerExtensions may reload the character after mod/root.lua. Bind through
-- the running player system so the live class always uses this attack.
local sys=player_lib.system
local oldFrame=sys.frame
function sys:frame(...)
 local p=self.player
 if p.class~=reimu_player then return oldFrame(self,...)end
 if p.y3FireClock==nil then
  p.slist=Y3ReimuBData.positions;p.slist[6]=p.slist[5];p.y3FireClock=0
 end
 p.class.shoot=P.shoot
 local result=oldFrame(self,...)
 if not p.time_stop then
  if p.__death_state==0 and(p.__shoot_flag or player_lib.debug_data.keep_shooting)and not p.dialog then
   p.y3FireClock=(p.y3FireClock+1)%16
  else p.y3FireClock=0 end
 end
 return result
end
if setting.y3_test_player then
 local updateKeys=sys.updateKeyState
 function sys:updateKeyState(...)
  local result=updateKeys(self,...)
  self.player.__slow_flag=Y3 and Y3.tick>=450 or false
  return result
 end
end
LoadTexture('y3.player','art/player/pl00.png')
LoadImage('y3.player.main','y3.player',0,176,64,16,24,9,true)
LoadImage('y3.player.pierce','y3.player',64,176,64,8,24,8,true)
SetImageState('y3.player.main','',Color(0x80FFFFFF))
SetImageState('y3.player.pierce','',Color(0x80FFFFFF))
LoadTexture('hs5.player.charm','THlib/player/reimu/reimu.png')
LoadImage('hs5.player.charm','hs5.player.charm',0,160,16,16,8,8,true)
SetImageState('hs5.player.charm','',Color(0xC0FFFFFF))

-- Opt-in single-entry mechanical probe, called before the real Boss.
local ProbeTarget
if setting.y3_test_player then
 ProbeTarget=Class(enemy)
 function ProbeTarget:init(y)enemybase.init(self,100);self.x,self.y=0,y;self.a,self.b=8,8;self.bound=false end
 function ProbeTarget:frame()enemybase.frame(self)end
 function ProbeTarget:render()end
 function ProbeTarget:colli(other)
  print('Y3 PROBE CONTACT y='..self.y..' dmg='..tostring(other.dmg)..' pierce='..tostring(other.y3Piercing)..' repeat='..tostring(other.y3Hits and other.y3Hits[self]))
  piercingCollision(self,other)
 end
end
function P.probe()
 local held,dialog=player_lib.debug_data.keep_shooting,player.dialog
 P.probing=true
 print('Y3 PROBE CLASS name='..tostring(lstg.var.player_name)..' live='..tostring(player.class==reimu_player)..' current='..tostring(player.class.shoot==P.shoot))
 player_lib.debug_data.keep_shooting=false;player.dialog=true
 for _,o in ObjList(GROUP_PLAYER_BULLET)do Del(o)end
 -- Object removal/collision can finish after the stage coroutine yields.
 -- Drain pre-probe volleys before creating either isolated target.
 task.Wait(12)
 local a,b=New(ProbeTarget,-64),New(ProbeTarget,32)
 New(Shot,0,-128,28,10,true);task.Wait(10)
 assert(a.hp==90 and b.hp==90,'Y3 piercing failed: '..tostring(a.hp)..'/'..tostring(b.hp))
 print('Y3 PLAYER PIERCE PASS front='..a.hp..' rear='..b.hp)
 Del(a);Del(b)
 assert(lstg.var.power==400 and player.support==4,'Y3 initial Power/support')
 player_lib.debug_data.keep_shooting=held;player.dialog=dialog;P.probing=false
end
