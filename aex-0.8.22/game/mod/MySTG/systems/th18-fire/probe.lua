-- Explicit short probe: actual initialized Reimu, real engine collision, Bomb.
local old=AfterFrame;local t=0;local victim;local hp;local realBoss;local bossHP
local Target=Class(enemy)
function Target:init(x,y)
 enemy.init(self,1,100000,false,false);self.x,self.y=x,y
 self.bound=false;self.a,self.b=30,30
end
function Target:frame()enemybase.frame(self)end
AfterFrame=function(...)
 old(...)
 if not IsValid(player)then return end
 t=t+1;player.protect=1000
 if t==2 then
  print('FIRE15 PLAYER '..tostring(lstg.var.player_name));assert(player.class==reimu_player)
  victim=New(Target,0,0);hp=victim.hp
  New(Th18Fire.Shot,player,{x=-player.x,y=0-player.y,w=48,h=16,angle=90,speed=0,damage=14,slot=0,homing=false},4,false)
 end
 if t==4 then assert(victim.hp==hp-14,'real shot damage');print('FIRE15 REAL SHOT14 PASS');Del(victim)
  victim=New(Target,0,0);hp=victim.hp;New(Th18Fire.BombBlast,0,0)
 end
 if t==16 then assert(victim.hp==hp-990,'bomb11 frames capped90 each');print('FIRE15 BOMB BLAST990 PASS');Del(victim)
  victim=New(Target,0,0);hp=victim.hp
  local orb=New(Th18Fire.BombOrb,player,0);orb.player={x=0,y=0};orb.timer=0
  -- Use actual valid player at origin so source overlap stays inside56.
  player.x,player.y=0,0;orb.player=player
 end
 if t==25 then assert(victim.hp==hp-45,'orb15 each3 frames');print('FIRE15 BOMB ORB15x3 PASS');Del(victim) end
 if t==26 then
  player.key=player.key or {};player.key.shoot=true;player.key.slow=false
 end
 if t==40 then print('FIRE15 HELD SHOT PASS');player.key.shoot=false;player.class.spell(player) end
 if t==100 then
  lstg.Snapshot('userdata/snapshot/fire15-bomb.jpg')
  for _,group in ipairs({GROUP_ENEMY,GROUP_NONTJT})do for _,e in ObjList(group)do
   if e._bosssys then realBoss=e;bossHP=e.hp end
  end end
  assert(realBoss,'real Suwako host missing');print('FIRE15 BOSS BEFORE '..bossHP)
 end
 if t==250 then
  assert(IsValid(realBoss) and realBoss.hp<bossHP,'bomb must damage actual Suwako host')
  print('FIRE15 BOSS DAMAGE '..bossHP..' -> '..realBoss.hp)
  print('FIRE15 COMPLETE');stage.Set('stage.quit')
 end
end
