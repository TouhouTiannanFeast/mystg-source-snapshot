local V={owned={}};MarisaVisual=V
for key,row in pairs(MarisaArt)do
 local name='mm.'..key;row.image=name;LoadTexture(name,row.path);LoadImage(name,name,0,0,row.w,row.h)
end
for key,row in pairs(TH08Art02)do
 local name='mm.th08.'..key;row.image=name;LoadTexture(name,row.path);LoadImage(name,name,0,0,row.w,row.h)
end
local sounds={ [1]='01_TAME',[2]='02_LASER',[4]='04_BOMB',[6]='06_HIT',[12]='12_JOINT',[15]='15_BOSSBOMB',[17]='17_HLASER'}
for id,name in pairs(sounds)do LoadSound('mm.se'..id,'se/'..name..'.wav')end
SSG.onSound=function(id,a)if sounds[id]then PlaySound('mm.se'..id,0.4,((a.x or 319)-319)/192)end end
local function draw(key,x,y,rot,scale,alpha,blend)
 local row=assert(MarisaArt[key],key);SetImageState(row.image,blend or '',Color(alpha or 255,255,255,255));Render(row.image,x,y,rot or 0,scale or 1,scale or 1)
end
V.draw=draw
function V.circle(x,y,t,scale,alpha)draw('green-circle',x,y,t*15,scale or 1,alpha,'mul+add')end
local function ring(x,y,r,shade)
 SetImageState('white','',Color(255,shade,shade,255))
 for i=0,63 do
  local d,e=i*360/64,(i+1)*360/64
  Render4V('white',x+r*cos(d),y+r*sin(d),0.5,x+r*cos(e),y+r*sin(e),0.5,x+(r-1)*cos(e),y+(r-1)*sin(e),0.5,x+(r-1)*cos(d),y+(r-1)*sin(d),0.5)
 end
end
function V.body(o,a)
 if a and not a.visible then return end
 local anim,speed,t=1,10,o.ani
 if a then anim,speed,t=a.anim,a.animSpeed,a.animTick
 else
  local dx=o.x-(o.mmOldX or o.x);o.mmOldX=o.x
  if math.abs(dx)>0.1 then anim=dx>0 and 5 or 4;speed=6
  elseif o.mmPhaseAge and o.mmPhaseAge<36 then anim,speed,t=2,6,o.mmPhaseAge end
 end
 if anim==6 then anim=0 end -- Exit spin is not used between the requested live Boss phases.
 local n=({[0]=4,[1]=4,[2]=6,[3]=2,[4]=2,[5]=2})[anim]or 4
 local frame=math.floor(t/math.max(1,speed))
 if anim==2 then frame=math.min(n-1,frame)else frame=frame%n end
 draw(string.format('body/anm%02d_frame%02d',anim,frame),o.x,o.y)
 if (o.mmHurt or 0)>0 then
  local mask=a and a.mask or(anim==3 and 8 or anim==4 and 9 or anim==5 and 10 or 7)
  draw(string.format('body/anm%02d_frame00',mask),o.x,o.y,0,1,100)
 end
 -- Original INT5 bomb evasion barrier, drawn procedurally in BOSS.CPP.
 if a and a.barrier and IsValid(player)and(player.nextspell or 0)>0 then
  for j=0,5 do ring(o.x,o.y,80+(30+j*4)*sin(a.age*4*360/256),(5-j)*51)end
 end
end
local function own(o)V.owned[o]=true;return o end
function V.clear()
 for o in pairs(V.owned)do if IsValid(o)then Del(o)end end;V.owned={}
end
local Effect=Class(object)
function Effect:init(x,y,kind)self.x,self.y=x,y;self.kind=kind;self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY_BULLET+1,false,false;own(self)end
function Effect:frame()if self.timer>=(self.kind=='hit'and 6 or 48)then Del(self)end end
function Effect:render()
 local f=self.kind=='hit'and math.min(5,self.timer)or math.min(7,math.floor(self.timer/6))
 draw(self.kind=='hit'and string.format('effects/hit-spark_frame%02d',f)or string.format('effects/bullet-delete-%d_frame%02d',self.kind=='small'and 8 or 16,f),self.x,self.y)
end
function Effect:del()V.owned[self]=nil end
function V.hit(x,y)New(Effect,x,y,'hit')end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,COLOR_PURPLE,false,true);bullet.skip_fade_in(self);self.data=b;self.bound=false;self.vx,self.vy=0,0;own(self)
 self.x,self.y=b.x-319,224-b.y;self.a,self.b,self.rect=2,4,true
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y,self.vx,self.vy=b.x-319,224-b.y,0,0;self.rot=0
end
function Shot:render()
 if SSGSelected05 and SSGSelected05.drawBullet(self.data)then return end
 local b=self.data;local suffix=b.c>=48 and 'extra'or b.c>=16 and 'large'or 'small'
 draw(string.format('bullets/color%02d_%s',b.c,suffix),b.x-319,224-b.y)
end
function Shot:del()V.owned[self]=nil end
function Shot:kill()self.data.dead=true;New(Effect,self.x,self.y,self.data.c<16 and 'small'or 'large');V.owned[self]=nil end
SSG.onBullet=function(b)New(Shot,b)end
local Bit=Class(enemy)
function Bit:init(a)
 enemy.init(self,15,a.hp,false,false,true);self.data=a;self.a,self.b=12,12;self.bound=false;self.x,self.y=a.x-319,224-a.y;own(self)
 self.protect=true;self.homingExcluded=true
end
function Bit:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.protect=true;self.homingExcluded=true;enemybase.frame(self);a.hp=self.hp
 self.x,self.y,self.vx,self.vy=a.x-319,224-a.y,0,0
end
function Bit:render()V.circle(self.x,self.y,self.timer)end
function Bit:kill()self.data.dead=true;SSG.onSound(4,self.data);V.hit(self.x,self.y);V.owned[self]=nil end
function Bit:del()V.owned[self]=nil end
SSG.onBit=function(a)New(Bit,a)end
-- Source polygon beams are rendered in bands. Collision follows the original
-- 2/3 beam width, warnings and closing bands never receive collision.
local Beam=Class(object)
function Beam:init(b)
 self.data=b;self.bound=false;self.group=GROUP_INDES;self.layer=LAYER_ENEMY_BULLET;self.colli=false;own(self)
 self.rect=true;self.a,self.b=400,0
end
function Beam:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.layer=SSGSelected05 and SSGSelected05.laserWarning(b)and(LAYER_ENEMY_BULLET+5)or LAYER_ENEMY_BULLET
 local length=b.selected05Laser and SSGSelected05.laserLength(b)or 800
 local d=-b.d*360/256;self.x,self.y=b.x-319+length/2*cos(d),224-b.y+length/2*sin(d);self.rot=d
 self.a,self.b,self.colli=length/2,b.width*2/3,b.width>0 and length>0 and b.state=='open'
end
local function band(x,y,d,length,width,color)
 local dx,dy=cos(d),sin(d);local nx,ny=-dy*width,dx*width
 SetImageState('white','',color)
 Render4V('white',x+nx,y+ny,0.5,x+length*dx+nx,y+length*dy+ny,0.5,x+length*dx-nx,y+length*dy-ny,0.5,x-nx,y-ny,0.5)
end
function V.links()
 local bits=SSG.bits;local n=#bits
 for i,a in ipairs(bits)do
  local b=bits[(i-1+(n>=5 and 2 or 1))%n+1]
  local dx,dy=b.x-a.x,a.y-b.y
  band(a.x-319,224-a.y,math.atan2(dy,dx)*180/math.pi,math.sqrt(dx*dx+dy*dy),0.5,Color(180,204,204,255))
 end
end
local function cap(x,y,r,c)
 SetImageState('white','',c)
 for j=0,15 do local d,e=j*22.5,(j+1)*22.5
  Render4V('white',x,y,0.5,x+r*cos(d),y+r*sin(d),0.5,x+r*cos(e),y+r*sin(e),0.5,x,y,0.5)
 end
end
function Beam:render()
 if SSGSelected05 and SSGSelected05.drawLaser(self.data)then return end
 local b=self.data;local d=-b.d*360/256;local x,y=b.x-319,224-b.y
 local colors={{160,50,180},{30,150,40},{40,60,220}};local c=colors[b.color+1]
 local width=math.max(0.45,b.width)
 band(x,y,d,800,width,Color(220,c[1],c[2],c[3]));band(x,y,d,800,math.max(0.2,width*0.75),Color(245,220,220,255))
end
function Beam:del()V.owned[self]=nil end
SSG.onBeam=function(b)New(Beam,b)end
local Homing=Class(object)
function Homing:init(b)
 self.data=b;self.bound=false;self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET;self.colli=false;own(self)
end
function Homing:frame()
 local b=self.data;if b.dead then Del(self);return end
 if IsValid(player)then
  for _,p in ipairs(b.points)do
   if math.abs(player.x-(p.x-319))<16/3 and math.abs(player.y-(224-p.y))<16/3 then player.class.colli(player,self);break end
  end
 end
end
function Homing:render()
 local points=self.data.points
 cap(points[1].x-319,224-points[1].y,8,Color(220,60,60,200))
 cap(points[1].x-319,224-points[1].y,4,Color(245,235,235,255))
 for j=1,25,4 do
  local p,q=points[j],points[math.min(28,j+4)];local x,y=p.x-319,224-p.y;local dx,dy=q.x-p.x,p.y-q.y;local len=math.sqrt(dx*dx+dy*dy);local d=math.atan2(dy,dx)*180/math.pi
  local w=math.max(2,8-math.floor(j/4));band(x,y,d,len,w,Color(220,60,60,200));if j<=13 then band(x,y,d,len,math.max(1,4-math.floor(j/4)),Color(245,235,235,255))end
 end
end
function Homing:del()V.owned[self]=nil end
SSG.onHoming=function(b)New(Homing,b)end
-- The inherited TH08 behaviors retain their movement, HP and fire schedules.
function th08s4.Familiar:render()V.circle(self.x,self.y,self.timer)end
