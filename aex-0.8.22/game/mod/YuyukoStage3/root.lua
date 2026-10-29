Include('THlib.lua')
Include('music.lua')
Include('player.lua')
Include('player-ui.lua')
Include('runtime.lua')
Include('th07.lua')
Include('le04.lua')
Include('background.lua')
if setting.y3_full then
 Include('road/host.lua')
end
local R=Y3
local S={owned={},ended=0,finished=false,current=nil,damage=0}
Y3Host=S
LoadTexture('y3.yuyuko','art/yuyuko.png')
for i=0,2 do
 LoadImage('y3.idle'..i,'y3.yuyuko',i*48,0,48,80)
 LoadImage('y3.move'..i,'y3.yuyuko',i*48,80,48,80)
end
for _,typ in ipairs({3,10,12})do
 local name='y3.le04.'..typ
 LoadTexture(name,'art/le04-'..typ..'.png')
 local w,h=GetTextureSize(name)
 for col=0,7 do LoadImage(name..'.'..col,name,col*w/8,0,w/8,h)end
end
LoadImage('y3.fan','y3.yuyuko',0,256,512,256)
LoadTexture('y3.le04.birth','art/le04-birth.png')
for col=0,7 do LoadImage('y3.le04.birth.'..col,'y3.le04.birth',col*20,0,20,20)end
-- Native TH10 scale artwork, using the same eight-color palette as the road.
for col=0,7 do
 local name='y3.scale.'..col
 LoadTexture(name,'art/th10-scale/'..col..'.png')
 local w,h=GetTextureSize(name);LoadImage(name,name,0,0,w,h)
end
for _,typ in ipairs({0,1,3,5,6,8,10})do
 local n=typ==8 and 8 or(typ==10 and 4 or 16)
 for col=0,n-1 do
  local name='y3.b'..typ..'.'..col
  LoadTexture(name,'art/th07-'..typ..'-'..col..'.png')
  local w,h=GetTextureSize(name);LoadImage(name,name,0,0,w,h)
 end
end
for col=0,15 do
 local name='y3.small.'..col
 LoadTexture(name,'art/th10-small/'..col..'.png')
 local w,h=GetTextureSize(name);LoadImage(name,name,0,0,w,h)
end
-- A private one-pixel texture for source-effect circle outlines.
LoadTexture('y3.pixel','art/pixel.png');LoadImage('y3.line','y3.pixel',0,0,1,1)
local function clean()
 R.clear();local list={};for o in pairs(S.owned)do list[#list+1]=o end
 for _,o in ipairs(list)do if IsValid(o)then Del(o)end end
 S.owned={}
end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,grain_b,1,false,true);bullet.skip_fade_in(self)
 self.data=b;self.bound=false;self.vx,self.vy=0,0;S.owned[self]=true
 self.x,self.y=b.x-192,224-b.y
end
function Shot:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y=b.x-192,224-b.y;self.vx,self.vy=0,0
 local n=b.typ==8 and 8 or(b.typ==10 and 4 or 16)
 if b.le04 then self.img='y3.le04.'..b.nativeType..'.'..b.nativeColor
 else self.img='y3.b'..b.typ..'.'..(b.col%n)end
 if not b.le04 and b.typ==3 then self.img='y3.small.'..(b.col%16)end
 if b.le04 and b.nativeType==12 then self.img='y3.scale.'..(b.nativeColor%8)end
 if b.le04 and(b.nativeType==3 or b.nativeType==10)then self.img='y3.b8.'..(b.nativeColor%8)end
 if R.id=='non2' and b.le04 and(b.nativeType==3 or b.nativeType==10) and b.nativeColor%8==5 then self.img='y3.b8.2'end
 local radius=({[0]=2,[1]=3,[3]=3,[5]=2,[6]=2,[8]=2.5,[10]=12,[12]=3})[b.typ]
 if b.le04 then radius=b.nativeType==10 and 8 or 2.5 end
 self.a,self.b,self.rect=radius*b.scale,radius*b.scale,not b.le04
 self.colli=b.birth<=0
 self.heading= -b.angle*180/math.pi-90;self.rot=0
 self.hscale,self.vscale=b.scale,b.scale
 if b.birth>0 then local u=b.birth/32;self.hscale=b.scale*(1+u);self.vscale=self.hscale end
end
function Shot:render()
 local b=self.data
 local alpha=b.alpha
 SetImageState(self.img,b.typ==10 and 'mul+add' or '',Color(math.max(0,math.min(255,alpha)),255,255,255))
 Render(self.img,self.x,self.y,self.heading,self.hscale,self.vscale)
end
function Shot:del()self.data.dead=true;S.owned[self]=nil;bullet.del(self)end
function Shot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self)end
local soundTick=-1
local function shotSound(b)
 if soundTick~=R.tick then
  soundTick=R.tick;PlaySound('tan00',0.3,math.max(-1,math.min(1,(b.x-192)/192)))
 end
end
R.onShot=function(b)shotSound(b);New(Shot,b)end
local Beam=Class(laser)
function Beam:init(b)
 laser.init(self,b.col==4 and 2 or 4,b.x-192,224-b.y,-b.angle*180/math.pi,0,b.length,0,b.width,0,0)
 self.data=b;self.bound=false;self.alpha=1;S.owned[self]=true
end
function Beam:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x=b.x-192+b.start*math.cos(b.angle);self.y=224-b.y-b.start*math.sin(b.angle)
 self.rot=-b.angle*180/math.pi
 self.l1,self.l2,self.l3=0,b.length,0
 local visual,offset,length,width,active=R.laserGeometry(b)
 self.w=width;self.alpha=1;self.colli=active
 local gx,gy=self.x,self.y
 self.x=b.x-192+offset*math.cos(b.angle);self.y=224-b.y-offset*math.sin(b.angle);self.l2=length
 laser.frame(self)
 self.x,self.y,self.l2,self.w=gx,gy,b.length,visual
end
function Beam:render()
 local b=self.data
 local width=R.laserGeometry(b)
 if b.dead or width<=0 then return end
 -- TH07 script11 uses sprite48+color (same source image as bullet type3).
 -- Stretch the entire transparent sprite, preserving both tapered ends.
 local image='y3.b3.'..(b.col%16)
 local offset=b.start+b.length/2
 SetImageState(image,'mul+add',Color(255,255,255,255))
 Render(image,b.x-192+offset*math.cos(b.angle),224-b.y-offset*math.sin(b.angle),
  -b.angle*180/math.pi-90,width/16,b.length/16)
end
function Beam:del()self.data.dead=true;S.owned[self]=nil end
function Beam:kill()self.data.dead=true;S.owned[self]=nil end
R.onLaser=function(b)shotSound(b);New(Beam,b)end
local function circle(x,y,r,color)
 SetImageState('y3.line','mul+add',color)
 for i=0,119 do
  local a,b=i*math.pi/60,(i+1)*math.pi/60
  local x1,y1=x+r*math.cos(a),y+r*math.sin(a)
  local x2,y2=x+r*math.cos(b),y+r*math.sin(b)
  Render('y3.line',(x1+x2)/2-192,224-(y1+y2)/2,-math.atan2(y2-y1,x2-x1)*180/math.pi,math.sqrt((x2-x1)^2+(y2-y1)^2),1.5)
 end
end
local function filledCircle(x,y,r,color)
 SetImageState('y3.line','',color)
 local cx,cy=x-192,224-y
 for i=0,119 do
  local a,b=i*math.pi/60,(i+1)*math.pi/60
  Render4V('y3.line',cx,cy,0,cx+r*math.cos(a),cy-r*math.sin(a),0,
   cx+r*math.cos(b),cy-r*math.sin(b),0,cx,cy,0)
 end
end
local Effects=Class(object)
function Effects:init()self.group=GROUP_GHOST;self.layer=LAYER_ENEMY_BULLET-5;self.bound=false;self.colli=false end
function Effects:render()
 for _,e in ipairs(R.birthEffects)do
  local scale,alpha,active=R.birthGeometry(e)
  if active then
   local image='y3.le04.birth.'..e.col%8
   SetImageState(image,'',Color(alpha,255,255,255))
   Render(image,e.x-192,224-e.y,0,scale,scale)
  end
 end
 if R.circle then local c=R.circle;circle(c.x,c.y,c.r,Color(140,128,192,255))end
 if R.circles then for i,c in ipairs(R.circles)do
  local red,green,blue=255,55,55;if i==2 then red,green,blue=55,55,255 end
  filledCircle(c.x,c.y,c.r,Color(40,red,green,blue))
  circle(c.x,c.y,c.r,Color(130,red,green,blue))
 end end
end
local function card(id)
 local spec=R.specs[id]
 local lifeRewarded=false
 local c=boss.card.New(spec.name,spec.survival and spec.time or 0,spec.survival and spec.time or 0,spec.time,spec.hp,{0,0,0},false)
 c.init=function(o)
  lifeRewarded=false
  clean();S.current=id;S.damage=0
  R.start(id,tonumber(setting.y3_seed)or 20261029,o.x+192,224-o.y)
  print('Y3 START '..id..' hp='..spec.hp..' frames='..(spec.time*60)..' title='..spec.name)
  task.New(o,function()
   while true do
    local px,py=192,400;if IsValid(player)then px,py=player.x+192,224-player.y end
    R.step(px,py);o.x,o.y=R.boss.x-192,224-R.boss.y
    if setting.y3_test and R.tick>=(tonumber(setting.y3_test_frames)or 900)then o.hp=0 end
    task.Wait(1)
   end
  end)
 end
 c.del=function(o)
  if id=='spell2' and (o.hp<=0 or o.timeout) and not lifeRewarded then
   lifeRewarded=true;New(item_extend,o.x,o.y)
  end
  if setting.y3_test_shoot then assert(S.damage>0,'Yuyuko did not receive real player-shot damage')end
  if setting.y3_test_player then
   print('Y3 PLAYER FIRE CHECK high_raw='..tostring(Y3Player.highDamage)..' slow_raw='..tostring(Y3Player.slowDamage)..' actual='..S.damage)
   assert(S.damage>856.71111111122*3,'Yuyuko firepower still near the old default')
   assert((Y3Player.highDamage or 0)>0 and(Y3Player.slowDamage or 0)>0,'high/slow emission missing')
   print('Y3 PLAYER FIRE PASS high_raw='..Y3Player.highDamage..' slow_raw='..Y3Player.slowDamage..' actual='..S.damage)
  end
  print('Y3 END '..id..' ticks='..R.tick..' shots='..R.counts.shots..' lasers='..R.counts.lasers..' damage='..S.damage)
  S.ended=S.ended+1;clean();assert(next(S.owned)==nil,'Y3 owned objects leaked')
 end
 return c
end
local Damage=Class(boss)
local Yuyuko=Class(Damage)
function Yuyuko:init(mode)
 local ids=R.order
 if mode and mode~='all'then
  assert(R.specs[mode],'Unknown Yuyuko phase');ids={}
  local started=false
  for _,id in ipairs(R.order)do
   if id==mode then started=true end
   if started and(setting.y3_full or id==mode)then ids[#ids+1]=id end
  end
 end
 local cards={};for _,id in ipairs(ids)do cards[#cards+1]=card(id)end
 boss.init(self,0,112,'Saigyouji Yuyuko',cards,New(Y3Background.spell),'Normal');self.a,self.b=16,24
end
function Damage:take_damage(dmg)
 local spec=R.specs[S.current]
 if spec then
  if spec.survival then return end
  -- Our shooter already uses TH10 damage units. Do not apply TH07's
  -- additional spell divisor to those units. Keep the timed opening defense.
  if R.tick<spec.hold then dmg=dmg/9 end
  local before=self.hp;boss.take_damage(self,dmg);S.damage=S.damage+(before-self.hp)
 end
end
function Yuyuko:render()
 self._bosssys:render()
 local moving=R.motion and math.abs(R.motion.dx)>0.1
 local frame=moving and math.min(2,math.floor(self.ani/3)%3)or 0
 local image='y3.'..(moving and 'move' or 'idle')..frame
 Render(image,self.x,self.y+4*sin(self.ani*4),0,moving and(R.motion.dx<0 and -1 or 1)or 1,1)
end
local Hud=Class(object)
function Hud:init()self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function Hud:render()
 local text='STAGE 3 / READY'
 if Y3Road and Y3Road.active then
  local wave,total,frame=Y3Road.position()
  text=string.format('ROAD / WAVE %d/%d / FRAME %d',wave,total,frame)
 elseif S.current then
  local names={non1='NON 1',spell1='SPELL 1',non2='NON 2',spell2='SPELL 2',non3='NON 3',spell3='SPELL 3'}
  text=string.format('BOSS / %s / FRAME %d',names[S.current]or S.current,R.tick)
 elseif S.finished then text='STAGE 3 / COMPLETE' end
 RenderText('menu',text,0,-185,0.24,'centerpoint')
 RenderText('menu','Arrows / Shift slow / Z shoot / X bomb / Esc',0,-205,0.22,'centerpoint')
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Yuyuko Stage3@Normal',nil,true)
stage.group.DefStageFunc('Yuyuko Stage3@Normal','init',function(s)
 clean();S.current=nil;S.finished=false;S.ended=0;R.circles=nil
 if Y3Road then Y3Road.active=false end
 stage.group.initTask(s,function()
  local entry=setting.y3_entry or 'full'
  local roadEntry=setting.y3_full and(entry=='full' or entry:match('^road%-%d+$'))
  Y3Music.play(roadEntry and 'road' or 'boss')
  New(Y3Background.stage);New(Effects);New(Hud);task.Wait(60)
  if setting.y3_full then
   local entry=setting.y3_entry or 'full'
   if entry=='full' or entry:match('^road%-%d+$')then
    Y3Road.run(tonumber(entry:match('^road%-(%d+)$'))or 0)
   else assert(R.specs[entry],'Unknown Stage3 entry')end
  end
  if setting.y3_test_player then Y3Player.probe()end
  Y3Music.play('boss')
  local b=New(Yuyuko,setting.y3_practice or 'all')
  while IsValid(b)do
   if(setting.y3_test or setting.y3_invincible)and IsValid(player)then player.protect=1000 end
   task.Wait(1)
  end
  clean();Y3Music.stop();S.current=nil;S.finished=true;print('Y3 COMPLETE phases='..S.ended);task.Wait(120)
 end)
end)
stage.group.DefStageFunc('Yuyuko Stage3@Normal','del',function()Y3Music.stop();if Y3Road then Y3Road.clean()end;clean()end)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
if setting.y3_test then
 if setting.y3_test_shoot then player_lib.debug_data.keep_shooting=true end
 local oldFrame=FrameFunc;local finish=0
 FrameFunc=function()
  local signal=oldFrame()
  if S.finished then finish=finish+1;if finish==60 then stage.QuitGame()end end
  return signal
 end
 local oldRender=RenderFunc;local captured={}
 RenderFunc=function()
  oldRender()
  if S.current and R.tick>=600 and not captured[S.current]then
   captured[S.current]=true;lstg.Snapshot('userdata/snapshot/yuyuko3-'..S.current..'.jpg')
  end
 end
 if setting.y3_fast then local old=DoFrame;DoFrame=function(...)for i=1,4 do old(...)end end end
end
