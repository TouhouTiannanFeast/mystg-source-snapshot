-- Original Suwako body art; frog is visual only, behind Boss and projectiles.
TH11S6Suwako={}
local A=TH11S6Suwako
local Frog=Class(object)
function A.frogScale(t)
 if t<80 then return 0 end
 local age=(t-80)%120
 if age<20 then local u=age/20;return 1.5*(1-(1-u)^2)
 elseif age<40 then return 1.5-.5*((age-20)/20)^2 end
 local u=(age-40)/60
 return u<=1 and 1+.1*(1-math.cos(math.pi*u)) or 1.2-.1*(1-math.cos(math.pi*(u-1)))
end
function Frog:init(owner,state)
 self.owner,self.state=owner,state;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY-1
 self.bound=false;self.colli=false;self.x,self.y=owner.x,owner.y
end
function Frog:frame()
 if not IsValid(self.owner)then Del(self);return end
 self.x,self.y=self.owner.x,self.owner.y
end
function Frog:render()
 local scale=A.frogScale(self.state.tick)
 if scale>0 then
  local img=TH11S6SuwakoSprites[30];SetImageState(img,'',Color(255,255,255,255));Render(img,self.x,self.y,0,scale,scale)
 end
end
function A.startSpell(owner,state)A.clean();A.frog=New(Frog,owner,state)end
function A.clean()if A.frog and IsValid(A.frog)then Del(A.frog)end;A.frog=nil end
function A.body(o)
 local dx=o.x-(o.th11LastBodyX or o.x);o.th11LastBodyX=o.x
 local direction=math.abs(dx)>.1 and(dx>0 and 1 or -1)or 0
 if direction~=o.th11BodyDirection then o.th11BodyDirection=direction;o.th11WalkStart=o.ani end
 local sid,flip=math.floor(o.ani/7)%4,1
 if direction~=0 then sid=4+math.min(2,math.floor((o.ani-(o.th11WalkStart or o.ani))/4));flip=direction<0 and -1 or 1 end
 local img=TH11S6SuwakoSprites[sid];SetImageState(img,'',Color(255,255,255,255));Render(img,o.x,o.y,0,flip,1)
end
A.Frog=Frog
