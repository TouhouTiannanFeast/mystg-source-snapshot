Include('systems/th18-fire/data.lua')
Include('systems/th18-fire/core.lua')
local F,D=Th18Fire,Th18FireData
local Shot=Class(object)
function Shot:init(p,r,level,slow)
 self.row=r;self.x=p.x+r.x;self.y=p.y+r.y
 if r.slot>0 then
  local opt=D.options[level][r.slot];local i=slow and 3 or 1
  self.x=self.x+opt[i];self.y=self.y-opt[i+1]
 end
 self.group=GROUP_PLAYER_BULLET;self.layer=LAYER_PLAYER_BULLET
 self.rect=true;self.bound=false;self.a=r.w/2;self.b=r.h/2
 -- The source rectangle's long axis follows the shot angle.
 self.heading=r.angle;self.speed=r.speed;self.rot=r.angle
 self.img=r.homing and 'reimu_bullet_blue' or (r.slot==0 and 'reimu_bullet_red' or 'reimu_bullet_orange')
 self.vx=self.speed*cos(self.heading);self.vy=self.speed*sin(self.heading)
 -- enemybase calls kill after assigning killerenemy. Damage is settled there
 -- so all projectiles share the retail per-enemy/per-frame cap.
 self.dmg=nil
end
function Shot:frame()
 if self.row.homing then
  F.home(self,F.nearest(self.x,self.y,256));self.rot=self.heading
  self.vx=self.speed*cos(self.heading);self.vy=self.speed*sin(self.heading)
 end
 if self.timer>=15 and (self.x<-256 or self.x>256 or self.y<-288 or self.y>288) then Del(self) end
end
function Shot:render()
 -- Keep the installed shot artwork, whose long texture axis is horizontal.
 Render(self.img,self.x,self.y,self.heading,1,1)
end
function Shot:kill()
 if self.killerenemy then
  F.damage(self.killerenemy,self.row.damage)
  lstg.var.score=lstg.var.score+10
 end
end
F.Shot=Shot
local function emit(p,r,level,slow) New(Shot,p,r,level,slow) end
function F.emit(p)
 F.rows(p,p.slow==1,function(r,level,slow)emit(p,r,level,slow)end)
end
local sys=player_lib.system
local oldFrame=sys.frame
local bound=false
local function bind()
 if bound or not reimu_player then return end
 bound=true
 reimu_player.shoot=function(p)
  p.nextshoot=1;F.start(p);F.emit(p);p.fireEmitted=true
  if p.fireShort%3==0 then PlaySound('plst00',.3,p.x/1024) end
 end
end
function sys:frame(...)
 local p=self.player;bind()
 if p.class~=reimu_player then return oldFrame(self,...) end
 if p.fireShort==nil then
  p.fireShort,p.fireLong=-1,-1
  p.slist={{nil,nil,nil,nil}}
  for level=1,4 do
   local options={}
   for i,v in ipairs(D.options[level]) do options[i]={v[1],-v[2],v[3],-v[4]} end
   p.slist[level+1]=options
  end
  p.slist[6]=p.slist[5]
 end
 p.fireEmitted=false
 local result=oldFrame(self,...)
 local held=p.__shoot_flag or player_lib.debug_data.keep_shooting
 local holdMode=not MyResources or MyResources.rule('shoot_mode','hold')~='press'
 if holdMode and p.__death_state==0 and not p.dialog and p.fireShort>=0 and not p.fireEmitted then F.emit(p) end
 if p.__death_state==0 and not p.dialog then F.advance(p,held) end
 return result
end
Include('systems/th18-fire/bomb.lua')
if setting.th18_fire_test then Include('systems/th18-fire/probe.lua') end
