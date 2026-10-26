Stage12Art.attach(th14.Wakasagi,'wakasagi')
Stage12Art.attach(Stage1Momiji.Boss,'momiji')
Stage12Art.attach(Stage2Flare.Boss,'patchouli')
Stage12Art.attach(Stage2Mystia.Boss,'mystia')
Stage12Art.attach(Stage2Mamizou.Boss,'mamizou')

local itemInit=item.init
function item:init(x,y,t,...)
 itemInit(self,x,y,t,...)
 if ({[1]=true,[2]=true,[4]=true,[5]=true,[6]=true,[8]=true})[t] then
  local a,b,rect=self.a,self.b,self.rect
  self.img='u.item-'..t;self.a,self.b,self.rect=a,b,rect
 end
end

-- Install before native class registration, rather than during first bullet init.
Stage12Art.installBulletRender(th14.Bullet)
Stage12Art.installBulletRender(Stage1Momiji.Shot)
Stage12Art.installBulletRender(Stage1Context.Shot)
