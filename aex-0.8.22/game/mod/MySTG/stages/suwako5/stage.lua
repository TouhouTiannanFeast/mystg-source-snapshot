-- Ordinary shooting host for the source-driven stage-five boss encounter.
local R,P=Suwako5Runtime,Suwako5Pool
local S={owned={},finished=false,phase=0}
Suwako5Stage=S
local prefix='stages/suwako5/'
local loaded={}
for _,colors in pairs(Suwako5Art) do for _,v in pairs(colors) do
 if not loaded[v.image] then
  local path=prefix..'art/'..v.image:sub(9)..'.png'
  LoadTexture(v.image,path);local w,h=GetTextureSize(v.image);LoadImage(v.image,v.image,0,0,w,h);loaded[v.image]=true
 end
end end
for _,part in ipairs({'core','glow'}) do
 local name='suwako5.ds-bomb-'..part
 LoadTexture(name,prefix..'art/ds-bomb-'..part..'.png');LoadImage(name,name,0,0,254,254)
end
local function own(o)S.owned[o]=true;return o end
local function clean()
 R.clearHazards(false)
 for o in pairs(S.owned) do if IsValid(o) then Del(o) end end
 S.owned={}
end
local NativeBomb=Class(object)
function NativeBomb:init(a)
 self.data=a;self.group=GROUP_INDES;self.layer=LAYER_ENEMY_BULLET-1;self.bound=false;self.colli=false;self.vx,self.vy=0,0;own(self)
end
function NativeBomb:frame()
 local a=self.data;if a.dead then Del(self);return end
 self.x,self.y=a.x,224-a.y
 self.a,self.b=(a.hitW or 0)/2,(a.hitH or 0)/2;self.rect=true
 self.colli=a.hitW~=nil and R.bitAnd(a.flags or 0,2)==0
end
function NativeBomb:render()
 local a=self.data
 if not a.visualStart then return end
 local t=R.tick-a.visualStart
 -- Source ANM26 spawns ANM27 at0/4/8, ANM28 at0; ANM28 adds27 at20/24/28.
 for _,birth in ipairs({0,4,8,20,24,28}) do
  local age=t-birth
  if age>=0 and age<130 then
   local scale=age<10 and (0.1+0.3*(age/10)^2) or (0.4+0.4*(1-(1-(age-10)/120)^2))
   local alpha=age<70 and 255 or 255*(1-(age-70)/60)
   SetImageState('suwako5.ds-bomb-glow','mul+add',Color(alpha,255,255,255))
   Render('suwako5.ds-bomb-glow',self.x,self.y,0,scale,scale)
  end
 end
 if t<160 then
  local scale,alpha
  if t<20 then scale=1-0.9*(t/20)^2;alpha=192*(t/20)^2
  elseif t<30 then scale=0.1+0.4*((t-20)/10)^2;alpha=192
  elseif t<120 then scale=0.5+0.4*(1-(1-(t-30)/90)^2);alpha=192
  else scale=0.9*(1-((t-120)/40)^2);alpha=192 end
  SetImageState('suwako5.ds-bomb-core','mul+add',Color(alpha,0,0,255))
  Render('suwako5.ds-bomb-core',self.x,self.y,0,scale,scale)
 end
end
function NativeBomb:del()S.owned[self]=nil end
function NativeBomb:kill()self.data.dead=true;S.owned[self]=nil end
R.onActor=function(a)if a.name=='BossBomb' then New(NativeBomb,a) end end
local NativeShot=Class(bullet)
function NativeShot:init(b)
 bullet.init(self,grain_b,math.max(1,math.min(16,(b.color or 0)+1)),false,true)
 bullet.skip_fade_in(self);self.data=b;self.bound=false;self.vx,self.vy=0,0;own(self)
end
-- DS/ISC static families are a provisional visual adapter, explicitly documented.
local modernTypes={[0]=0,[4]=1,[8]=3,[10]=5,[18]=11,[21]=23,[31]=17}
function NativeShot:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y,self.vx,self.vy=b.x,224-b.y,0,0
 local typ=b.group=='th10' and b.typ or (modernTypes[b.typ] or b.typ)
 local row=Suwako5Art[typ];local art=row and (row[b.color] or row[0])
 if art then self.img=art.image;self.a,self.b=art.width/2,art.width/2 end
 self.rect=b.group=='th10';self.colli=b.collidable~=false
 self.group=(b.bombProof or 0)>0 and GROUP_INDES or GROUP_ENEMY_BULLET
 self.heading=-(b.angle or 0)*180/math.pi-90;self.rot=0
 self.hscale,self.vscale=1,1
 if b.birth and b.age<b.birth then
  local u=b.age/b.birth;local scale=1+2*(1-u)^2;self.hscale,self.vscale=scale,scale
 end
 self._a=255
end
function NativeShot:render()self.rot=self.heading or 0;bullet.render(self);self.rot=0 end
function NativeShot:del()S.owned[self]=nil;bullet.del(self) end
function NativeShot:kill()self.data.dead=true;S.owned[self]=nil;bullet.kill(self) end
local NativeLaser=Class(laser)
function NativeLaser:init(b)
 local l=b.laser;laser.init(self,math.max(1,math.min(16,b.color+1)),b.x,224-b.y,-b.angle*180/math.pi,0,l.length,0,l.width,0,0)
 self.data=b;self.bound=false;laser.TurnOn(self,1);own(self)
end
function NativeLaser:frame()
 local b=self.data;if b.dead then Del(self);return end
 self.x,self.y,self.rot=b.x,224-b.y,-b.angle*180/math.pi
 self.l2=b.laser.length;self.colli=b.collidable~=false
 laser.frame(self)
end
function NativeLaser:del()S.owned[self]=nil end
function NativeLaser:kill()self.data.dead=true;S.owned[self]=nil end
R.onShot=function(b)New(b.laser and NativeLaser or NativeShot,b) end
local function card(spec,index)
 local c=boss.card.New(spec.name,0,0,spec.frames/60,spec.hp,{0,0,0},spec.group=='th10' and spec.name~='')
 c.t3=spec.frames
 c.init=function(o)
  clean();R.start(spec,S.seed+index*7919);R.boss.f[0]=R.aim(R.boss);S.phase=index;S.current=spec.id
  print('SUWAKO5 PHASE '..index..' '..spec.id..' hp='..spec.hp..' frames='..spec.frames)
  task.New(o,function()
   while true do
    local px,py=0,400;if IsValid(player) then px,py=player.x,224-player.y end
    R.step(px,py,o.hp);R.stepHazards();o.x,o.y=R.boss.x,224-R.boss.y
    if setting.suwako5_test_progress then
     local progress=math.min(5,math.floor(R.tick/100))
     o.hp=math.min(o.hp,spec.hp*(1-progress/6))
     if o.suwako5_progress~=R.photos then o.suwako5_progress=R.photos;print('SUWAKO5 HP STAGE '..spec.id..' '..R.photos) end
    end
    -- The original survival/photo completion flags do not disable shooting here.
    if R.invuln>0 then o.dmg_factor=0 end
    if o.hp<spec.hp then o.suwako5_damaged=true end
    if setting.suwako5_test and R.tick>=setting.suwako5_test_frames then
     if setting.suwako5_test_shoot then assert(o.suwako5_damaged,'ordinary shooting did not damage '..spec.id) end
     o.hp=0
    end
    task.Wait(1)
   end
  end)
 end
 c.del=function(o)
  if setting.suwako5_test_progress then assert(R.photos==5,'DS blood-volume progression incomplete '..spec.id) end
  if setting.suwako5_test_shoot then assert(o.suwako5_damaged,'shooting damage missing '..spec.id);print('SUWAKO5 SHOOT PASS '..spec.id) end
  print('SUWAKO5 END '..spec.id..' tick='..R.tick..' bullets='..R.stats.bullets..' lasers='..R.stats.lasers)
  clean();assert(next(S.owned)==nil,'stage-five object cleanup failed')
 end
 return c
end
local Suwako=Class(boss)
function Suwako:init(phases)
 local cards={};for i,spec in ipairs(phases) do cards[i]=card(spec,i) end
 boss.init(self,0,112,'Suwako Moriya',cards,nil,'Normal');self.a,self.b=24,24
end
function Suwako:render()
 self._bosssys:render();Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.3,1.3)
end
local stageName='Stage 5 Suwako@Normal'
stage.group.AddStage('Normal',stageName,{lifeleft=4,power=400,bomb=3},true)
stage.group.DefStageFunc(stageName,'init',function(s)
 S.finished=false;S.phase=0
 S.seed=tonumber(setting.suwako5_seed) or ran:Int(1,2147483646)
 local phases
 if setting.suwako5_test_plan then phases={};for _,id in ipairs(setting.suwako5_test_plan) do phases[#phases+1]=P.find(id) end
 elseif setting.suwako5_practice then phases={P.find(setting.suwako5_practice)} else phases=P.draw(S.seed,4) end
 local ids={};for _,p in ipairs(phases) do ids[#ids+1]=p.id end
 print('SUWAKO5 DRAW seed='..S.seed..' '..table.concat(ids,','))
 stage.group.initTask(s,function()
  New(default_stage_background);task.Wait(60)
  local b=New(Suwako,phases)
  while IsValid(b) do if setting.suwako5_test and IsValid(player) then player.protect=1000 end;task.Wait(1) end
  clean();S.finished=true;print('SUWAKO5 COMPLETE phases='..#phases);task.Wait(120)
 end)
end)
stage.group.DefStageFunc(stageName,'del',clean)
if setting.suwako5_autostart then
 stage_init.frame=function(s)
  if s.timer==30 then
   lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
   stage.group.PracticeStart(stageName)
  end
 end
end
if setting.suwako5_test then
 if setting.suwako5_test_shoot then player_lib.debug_data.keep_shooting=true end
 local oldMenu=stage_menu.frame
 stage_menu.frame=function(s)oldMenu(s);if S.finished and s.timer>=30 then stage.Set('stage.quit') end end
 local oldRender=RenderFunc;local captured={}
 RenderFunc=function()
  oldRender()
  if S.current and R.tick>(setting.suwako5_test_progress and 650 or 200) and not captured[S.current] then
   captured[S.current]=true;local path='userdata/snapshot/suwako5-'..S.current..'.jpg';lstg.Snapshot(path);print('SUWAKO5 SNAPSHOT '..path)
  end
 end
end
