-- Damage-only alignment to HSoBStage5Normal/player-data.lua, scale1.
-- Keep PlayerExtensions Reimu's original cadence, projectiles and movement.
RingoSeiranPlayer={dps={675,855,945,1125,1170}}
local P=RingoSeiranPlayer
function P.shoot(self)
 local power=math.min(4,math.max(0,math.floor(lstg.var.power/100)))
 local scale=P.dps[power+1]/(60+power*(self.slow==1 and 9 or 5.25))
 PlaySound('plst00',0.3,self.x/1024)
 self.nextshoot=4
 New(reimu_bullet_red,'reimu_bullet_red',self.x+10,self.y,24,90,2*scale)
 New(reimu_bullet_red,'reimu_bullet_red',self.x-10,self.y,24,90,2*scale)
 if self.support>0 then
  if self.slow==1 then
   for i=1,4 do if self.sp[i] and self.sp[i][3]>0.5 then
    New(reimu_bullet_orange,'reimu_bullet_orange',self.supportx+self.sp[i][1]-3,self.supporty+self.sp[i][2],24,90,0.3*scale)
    New(reimu_bullet_orange,'reimu_bullet_orange',self.supportx+self.sp[i][1]+3,self.supporty+self.sp[i][2],24,90,0.3*scale)
   end end
  elseif self.timer%8<4 then
   local num=power+1
   for i=1,4 do if self.sp[i] and self.sp[i][3]>0.5 then
    New(reimu_bullet_blue,'reimu_bullet_blue',self.supportx+self.sp[i][1],self.supporty+self.sp[i][2],8,self.anglelist[num][i],self.target,900,0.7*scale)
   end end
  end
 end
end
local original=player_lib.system.frame
function player_lib.system:frame(...)
 if self.player.class==reimu_player then self.player.class.shoot=P.shoot end
 return original(self,...)
end
