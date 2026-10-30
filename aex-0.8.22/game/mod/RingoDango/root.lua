Include('THlib.lua')
Include('pattern.lua')
local P=RingoDangoPattern
for _,kind in ipairs({'pellet','outline','mentos'}) do LoadImageFromFile('dango.'..kind,kind..'.png') end
LoadTexture('dango.ringo','ringo.png')
for i=0,22 do
 local x,y
 if i<=7 then x,y=i*64,0 elseif i<=12 then x,y=(i-8)*64,80
 elseif i<=17 then x,y=(i-13)*64,160 else x,y=(i-18)*64,240 end
 LoadImage('dango.ringo.'..i,'dango.ringo',x,y,64,80)
end
local D={owned={},world=nil,finished=false,tick=-1}
local function clean()
 if D.world then for _,b in ipairs(D.world.bullets) do b.dead=true end;D.world.bullets={} end
 for o in pairs(D.owned) do if IsValid(o) then Del(o) end end
 D.owned={}
end
local Shot=Class(bullet)
function Shot:init(b)
 bullet.init(self,ball_small,COLOR_RED,false,true);bullet.skip_fade_in(self)
 self.bullet=b;self.x,self.y=b.x,b.y;self.bound=false;self.rect=false
 self.img='dango.'..b.kind;self.a,self.b=P.radius[b.kind],P.radius[b.kind]
 self.vx,self.vy=0,0;D.owned[self]=true
end
function Shot:frame()
 local b=self.bullet
 if b.dead then Del(self);return end
 self.x,self.y=b.x,b.y;self.img='dango.'..b.kind
 self.a,self.b=P.radius[b.kind],P.radius[b.kind]
 self.rot=b.kind=='mentos' and 0 or b.angle*180/math.pi+90
end
function Shot:kill() self.bullet.dead=true;D.owned[self]=nil;bullet.kill(self) end
function Shot:del() self.bullet.dead=true;D.owned[self]=nil;bullet.del(self) end
local card=boss.card.New('兔符「团子影响力」',0,0,40,2400,{0,0,0},false)
card.init=function(o)
 clean();D.world=P.new(function() return ran:Float(0,1) end);D.finished=false
 task.New(o,function()
  while true do
   D.tick=D.world.t
   if setting.dango_test then
    player.protect=1000;o.hp=P.hp
    player.x=60*sin(D.tick*0.4);player.y=-160
   end
   local previous=D.world.nextId
   o.lastX=o.x;o.x,o.y=P.step(D.world,o.x,o.y,player.x,player.y)
   o.moving=D.world.move~=nil
   for _,b in ipairs(D.world.bullets) do if b.id>previous then New(Shot,b) end end
   if setting.dango_test and D.tick==1100 then o.hp=0 end
   task.Wait(1)
  end
 end)
end
card.del=function()
 local s=D.world and D.world.stats
 clean();D.finished=true
 if setting.dango_test then
  assert(s.rings==19 and s.pellet==2660 and s.mentos==9,'source schedule mismatch')
  assert(s.influenced>0 and s.bounces>0,'influence/bounce never triggered')
  assert(next(D.owned)==nil and #D.world.bullets==0,'cleanup failed')
  print(string.format('DANGO PASS tick=%d rings=%d pellet=%d mentos=%d influenced=%d bounces=%d cleanup=0',D.tick,s.rings,s.pellet,s.mentos,s.influenced,s.bounces))
 end
end
local Ringo=Class(boss)
function Ringo:init()
 boss.init(self,0,96,'Ringo',{card},nil,'Normal');self.a,self.b=20,20
end
function Ringo:render()
 self._bosssys:render()
 local frame=({0,1,2,1})[math.floor(self.ani/7)%4+1]
 if self.moving then
  local right=self.x>=(self.lastX or self.x)
  frame=(right and 10 or 15)+({0,1,2,1})[math.floor(self.ani/4)%4+1]
 end
 Render('dango.ringo.'..frame,self.x,self.y)
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Dango Influence@Normal',nil,true)
stage.group.DefStageFunc('Dango Influence@Normal','init',function(s)
 stage.group.initTask(s,function()
  New(default_stage_background);task.Wait(60)
  local b=New(Ringo);while IsValid(b) do task.Wait(1) end
  clean();task.Wait(120)
 end)
end)
stage.group.DefStageFunc('Dango Influence@Normal','del',clean)
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
if setting.dango_test then
 local oldFrame=FrameFunc;local finish=0
 FrameFunc=function()
  local signal=oldFrame()
  if D.finished then finish=finish+1;if finish==60 then stage.QuitGame() end end
  return signal
 end
 local oldRender=RenderFunc;local captured={}
 RenderFunc=function()
  oldRender()
  for _,t in ipairs({180,320,600}) do
   if D.tick>=t and not captured[t] then captured[t]=true;lstg.Snapshot('userdata/snapshot/ringo-dango-'..t..'.jpg') end
  end
 end
end
