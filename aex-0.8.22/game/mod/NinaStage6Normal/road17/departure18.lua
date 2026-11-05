-- Visual-only continuation of surviving tail frogs; cleanup still ends combat.
local H,P=TH11S6Host,TH11S6Presentation
local Exit=Class(object)
function Exit:init(a,x,y)
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false
 self.pose={name=a.name,age=a.age,poseStart=a.poseStart,anm=TH11S6Runtime.copy(a.anm)}
 self.sx,self.sy=x,224-y;self.tx=math.max(-144,math.min(144,x))
 self.x,self.y=x,y
 print('NINA ROAD FROG EXIT START x='..x..' y='..y)
end
function Exit:frame()
 local u=math.min(1,self.timer/90);u=u*u
 self.x=self.sx+(self.tx-self.sx)*u;self.y=224-(self.sy+(-72-self.sy)*u)
 self.pose.age=self.pose.age+1
 if self.timer>=90 then print('NINA ROAD FROG EXIT END y='..self.y);Del(self)end
end
function Exit:render()
 local a=self.pose;local image,rot,scale,alpha=P.ring(a)
 if image then SetImageState(image,'mul+add',Color(alpha,255,255,255));Render(image,self.x,self.y,rot,scale,scale)end
 local img,r,flip=P.enemy(a)
 SetImageState(img,'',Color(255,255,255,255));Render(img,self.x,self.y,r,flip,1)
end
function H.finishFrogs()
 for o in pairs(H.enemies)do
  local a=o.data
  if IsValid(o)and a.name=='RPhantom01'and not a.defeated and not a.offscreenRemoval
   and o.x>=-224 and o.x<=224 and o.y>=-240 and o.y<=256 then New(Exit,a,o.x,o.y)end
 end
end
H.FrogExit18=Exit
