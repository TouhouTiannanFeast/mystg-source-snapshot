-- Source shot rows, support positions, cadence and piercing rule from
-- Stage12Normal/player.lua. No changes to items, death, Bomb, or Power rules.
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
    New(Shot,x+s.x,y+s.y,s.speed,s.damage*Y3PlayerConfig.damage_scale,s.option>0)
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
