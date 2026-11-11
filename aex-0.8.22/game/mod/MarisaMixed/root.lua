Include('THlib.lua');Include('player.lua');Include('power-lock.lua')
Include('th08/host.lua');Include('stardust03.lua');Include('th08/boss.lua')
Include('ds/pool.lua');Include('ds/runtime.lua');Include('ds/projectiles.lua');Include('ds/programs.lua');Include('ds/assets.lua');Include('ds/sound.lua');Include('ds/host.lua')
Include('ssg-code.lua');Include('ssg.lua');Include('ssg-inspect04.lua');Include('art.lua');Include('th08-art02.lua');Include('th08-visual02.lua');Include('visual.lua')
Include('selected05-art.lua');Include('ssg-selected05.lua')
Include('audio14.lua')
if setting.marisa_road then Include('stage14.lua')end
local T,R,V=th08s4,SSG,MarisaVisual
local S={phase='none',age=0,ended=0};MarisaMixed=S
local order={'ssg','stardust','non1','milky','non3','comet','final'}
local names={ssg='秋霜玉 / 第一阶段',stardust='魔符「星尘幻想」',non1='永夜抄 / 一非',milky='魔符「银河」',non3='永夜抄 / 三非',comet='彗星「Blazing Star」',final='恋符「Master Spark」'}
local function clean()
 V.clear();T.clear(true);MarisaDS.clean()
end
local function ssgCard()
 local mode=setting.marisa_ssg_mode or'full'
 local selected=SSGSelected05.accept(mode)
 local frames=selected and SSGSelected05.frames(mode)or 3601
 local c=boss.card.New('',0,0,frames/60,30000,{0,0,0},false);c.t3=frames
 c.init=function(o)
  local seed=tonumber(setting.marisa_seed)or 20261106
  if selected then SSGSelected05.start(seed,mode)else SSGSelected05.stop();SSGInspect04.start(seed,mode)end
  task.New(o,function()
   while true do
    local px,py=319,400;if IsValid(player)then px,py=player.x+319,224-player.y end
    if SSGSelected05.active then SSGSelected05.step(px,py,o.hp)else R.step(px,py,o.hp)end
    o.x,o.y=R.body.x-319,224-R.body.y
    if setting.marisa_test and setting.marisa_test_branch=='selected05'and SSGSelected05.active then
     if S.age==450 then SSGSelected05.clock=1259 elseif S.age==700 then SSGSelected05.clock=2579 end
    end
    if setting.marisa_test and setting.marisa_test_branch=='homing'and not S.branchProbe and #R.bits==5 and R.tick>=950 then
     S.branchProbe=true;R.bitLaser(1);R.body.wait=nil;R.body.motion=nil;R.body.pc=0x8b9;R.body.ret=0x2a2
     S.bitTarget=R.bits[1];New(Y3Player.Shot,S.bitTarget.x-319,224-S.bitTarget.y,0,10000,true)
     New(Y3Player.Shot,o.x,o.y,0,10,true);S.probeHP=o.hp;S.probeTick=R.tick
    end
    if S.branchProbe and R.tick==S.probeTick+5 then
     assert(not S.bitTarget.dead and #R.bits==5,'green circles lost source actor under shooting')
     assert(S.probeHP-o.hp==8,'five-bit source boss damage reduction failed')
     print('MARISA SHOOT PASS bossDamage='..(S.probeHP-o.hp)..' bits='..#R.bits)
    end
    if R.done then o.hp=0;return end
    task.Wait(1)
   end
  end)
 end
 c.del=function()SSGSelected05.stop();V.clear()end
 return c
end
local function card(id)
 local c=id=='ssg'and ssgCard()or id=='comet'and MarisaDS.card(DSExtraPool.specs[8])or T.card(id=='final'and'master'or id)
 -- Keep the user's terminal HP/time while selecting Master Spark's attack.
 if id=='final'then c.hp=2500;c.t3=65*60 end
 local init,del=c.init,c.del
 c.init=function(o)
  clean();S.phase=id;S.age=0;S.forced=false;S.branchProbe=false;S.immuneProbe=nil;S.boss=o;o.mmPhaseAge=0;o.mmOldX=nil;o.mmPreviousHP=nil;o.mmEntryMove=false
  if id=='comet'then MarisaDS.state.current=8 end
  init(o);T.label=names[id];print('MARISA START '..id..' hp='..o.hp)
 end
 c.del=function(o)
  if del then del(o)end;clean();S.ended=S.ended+1;print('MARISA END '..id)
 end
 -- Original stardust's after routine leaves the stage because it was a midboss.
 -- Here the same live Boss continues to the requested non1; do not fly offscreen.
 if id=='stardust'then c.after=nil end
 return c
end
-- AEX Damage dispatches through obj.class.base.take_damage, so the private
-- intermediate base owns source damage reduction (an override on Boss is bypassed).
local MarisaBase=Class(boss)
function MarisaBase:take_damage(dmg)
 if self.mmEntryMove or(S.phase=='ssg'and SSGSelected05.entryProtected)then return end
 if S.phase=='ssg'then dmg=math.max(0,dmg-math.floor(#R.bits/2))end
 boss.take_damage(self,dmg)
end
local Boss=Class(MarisaBase)
function Boss:init()
 self.mmEntryMove=true
 local cards={boss.move.New(0,135,60,MOVE_DECEL)}
 local practice=setting.marisa_phase or 'all'
 for _,id in ipairs(order)do if practice=='all'or practice==id or(setting.marisa_test and practice=='fix02'and(id=='ssg'or id=='stardust'or id=='final'))then cards[#cards+1]=card(id)end end
 assert(#cards>1,'unknown Marisa practice selection')
 boss.init(self,-224,256,'Marisa Kirisame',cards,nil,'Normal');self.bound=false;self.a,self.b=24,16;self.fxr,self.fxg,self.fxb=180,100,255
 if setting.marisa_road and setting.marisa_test then assert(self.x< -192 and self.y>224,'Marisa must enter from outside');print('MARISA14 OFFSCREEN ENTRY '..self.x..','..self.y)end
end
function Boss:frame()
 boss.frame(self)
 S.age=S.age+1;T.frame=T.frame+1;self.mmPhaseAge=S.age
 if self.mmPreviousHP and self.hp<self.mmPreviousHP then self.mmHurt=6;if self.ani%3==0 then V.hit(self.x,self.y)end end
 self.mmPreviousHP=self.hp;self.mmHurt=math.max(0,(self.mmHurt or 0)-1)
 if self.mmEntryMove then self.dmg_factor=0
 elseif S.phase=='ssg'then
  local shield=IsValid(player)and(player.nextspell or 0)>0
  self.dmg_factor=(SSGSelected05.entryProtected or not R.body.damage or shield)and 0 or 1
 elseif S.phase=='comet'then self.dmg_factor=(DSExtraRuntime.invuln>0 or DSExtraRuntime.boss.hidden)and 0 or 1 end
 if setting.marisa_test and S.phase~='none'and not S.forced and not self.__is_waiting then
  if setting.marisa_test_branch=='fix02'then
   if not S.immuneProbe and S.phase=='ssg'and R.tick>=950 then
    for f in pairs(V.owned)do if f.data and f.data.bit then S.immuneProbe={o=f,hp=f.hp,at=S.age};New(Y3Player.Shot,f.x,f.y,0,1000000,true);assert(self.hp==30000,'opening HP changed');print('MARISA02 HP '..self.hp);break end end
   elseif not S.immuneProbe and S.phase=='stardust'and S.age>=330 then
    for f in pairs(T.phase_objects)do if f.owner==self and f.behavior then S.immuneProbe={o=f,hp=f.hp,at=S.age};New(Y3Player.Shot,f.x,f.y,0,1000000,true);break end end
   end
   if S.immuneProbe and S.age==S.immuneProbe.at+5 then local p=S.immuneProbe;assert(IsValid(p.o)and p.o.hp==p.hp and p.o.protect,'green circle shooting immunity failed');print('MARISA02 IMMUNITY '..S.phase..' hp='..p.o.hp)end
  end
  if setting.marisa_test_branch=='stardust03'and S.phase=='stardust'then
   for p in pairs(T.phase_objects)do
    if not S.s03Shot and p.wait==281 and p.age>0 and p.age<20 then S.s03Shot=p;S.s03Origin={x=p.x,y=p.y}end
    if p.owner==self and p.opt and p.opt.s03Type then
     if p.timer>=1022 and p.timer<1130 then
      S.s03QuietCount=S.s03QuietCount or T.stats.bullets
      assert(S.s03QuietCount==T.stats.bullets,'source silent expansion emitted bullets')
     elseif p.timer==1130 and not S.s03QuietPassed then S.s03QuietPassed=true;print('MARISA03 SILENCE PASS')end
    end
   end
   local p=S.s03Shot
   if p and IsValid(p)then
    if p.age<=281 then assert(math.abs(p.x-S.s03Origin.x)<0.0001 and math.abs(p.y-S.s03Origin.y)<0.0001,'source star moved during wait')
    elseif p.age>=342 and not S.s03DelayedPassed then
     assert(math.abs(math.sqrt(p.vx*p.vx+p.vy*p.vy)-60*0.016666668)<0.00001,'source star vector acceleration failed')
     S.s03DelayedPassed=true;print('MARISA03 DELAY/VECTOR PASS age='..p.age)
    end
   end
   if S.age>=1380 then assert(S.s03DelayedPassed and S.s03QuietPassed,'Stardust03 source checkpoints missing')end
  end
  local n=S.phase=='ssg'and(setting.marisa_test_branch=='guide13'and 560 or setting.marisa_test_branch=='selected05'and 1000 or setting.marisa_test_branch=='inspect04'and(SSGInspect04.current.kind=='body'and 500 or 850)or setting.marisa_test_branch=='homing'and 1300 or 1100)or S.phase=='comet'and 360 or S.phase=='final'and(setting.marisa_test_branch=='fix02'and 410 or 340)or(setting.marisa_test_branch=='stardust03'and 1380 or setting.marisa_test_branch=='fix02'and 400 or 250)
  if setting.marisa_road_test=='tail'then n=45 end
  if S.phase=='ssg'and S.age>=n and setting.marisa_test_branch=='homing'then assert(#R.homing==8,'homing emission missing');print('MARISA HOMING PASS beams='..#R.homing)end
  if S.age>=n then
   if setting.marisa_test_branch=='guide13'and S.phase=='ssg'then assert((SSGSelected05.stats.guideDraws or 0)>0,'warning never rendered');print('MARISA GUIDE13 PASS warningDraws='..SSGSelected05.stats.guideDraws)end
   if setting.marisa_test_branch=='selected05'then
    local st=SSGSelected05.stats
    assert(#st.stages==3 and st.skins.bigstar>0 and st.skins.smallstar>0,'selected patterns/art missing')
    assert(st.sounds>0 and st.laserDraws>0,'TH08 laser sound/render missing')
    print('SSG SELECTED05 NATIVE PASS stages='..#st.stages..' sound='..st.sounds..' laserDraws='..st.laserDraws)
   end
   if setting.marisa_test_branch=='inspect04'then
    local m=SSGInspect04.current;local count=0
    for _,set in ipairs({R.stats.branches,R.stats.bitBranches})do for helper,hits in pairs(set)do assert(helper==m.helper,'wrong inspection helper');count=count+hits end end
    assert(count>0 and(m.kind=='body'and #R.bits==0 or m.kind=='bit'and #R.bits==5),'inspection setup missing')
    print('SSG INSPECT PASS '..m.id..' calls='..count)
   end
   S.forced=true;print('MARISA CHECKPOINT '..S.phase..' age='..S.age);self.hp=0
  end
 end
end
function Boss:render()
 self._bosssys:render()
 if S.phase=='comet'and DSExtraRuntime.boss and DSExtraRuntime.boss.hidden then return end
 if S.phase=='ssg'then V.links()end
 V.body(self,S.phase=='ssg'and R.body or nil)
 if S.phase=='ssg'and SSGInspect04.current then
  RenderText('menu','SSG '..SSGInspect04.current.id..' / '..SSGInspect04.current.short,-180,-214,0.27,'left')
 end
end
stage.group.New('Normal','menu',{lifeleft=8,power=400,bomb=3},true,2)
stage.group.AddStage('Normal','Marisa Mixed@Normal',nil,true)
stage.group.DefStageFunc('Marisa Mixed@Normal','init',function(s)
 S.phase='none';S.ended=0
 stage.group.initTask(s,function()
  if setting.marisa_road then MarisaRoad14.run()else New(default_stage_background);task.Wait(60)end
  MarisaMusic14.start();local b=New(Boss)
  while IsValid(b)do
   if(setting.marisa_test or setting.marisa_invincible)and IsValid(player)then player.protect=1000 end
   task.Wait(1)
  end
  clean();MarisaMusic14.stop();if setting.marisa_road then MarisaRoad14.cleanup()end;task.Wait(90);print('MARISA COMPLETE ended='..S.ended)
  if setting.marisa_test then stage.QuitGame()else stage.group.FinishStage()end
 end)
end)
stage.group.DefStageFunc('Marisa Mixed@Normal','del',function()clean();MarisaMusic14.stop();if MarisaRoad14 then MarisaRoad14.cleanup()end end)
stage_init.frame=function(s)
 if s.timer==30 then lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3];stage.group.Start('Normal')end
end
if setting.marisa_test then
 local frame=FrameFunc
 FrameFunc=function()local ok,value=xpcall(frame,debug.traceback);if not ok then print('MARISA FRAME ERROR '..tostring(value));stage.QuitGame()end;return value end
 local render=RenderFunc;local captured={}
 RenderFunc=function()
  local ok,value=xpcall(render,debug.traceback);if not ok then print('MARISA RENDER ERROR '..tostring(value));stage.QuitGame();return end
  if S.phase~='none'then
   local at=setting.marisa_test_branch=='guide13'and{440,465,490,500,510,530}or setting.marisa_test_branch=='selected05'and{350,650,805,840,900}or setting.marisa_test_branch=='stardust03'and{350,520,800,1150,1320}or S.phase=='ssg'and{80,115,320,700,1050,1150,1250}or S.phase=='comet'and{320}or setting.marisa_test_branch=='fix02'and{180,220,280,340,390}or{220}
   for _,t in ipairs(at)do local key=S.phase..'-'..t;if S.age>=t and not captured[key]then captured[key]=true;local path='userdata/snapshot/marisa-mixed-'..key..'.jpg';lstg.Snapshot(path);print('MARISA SNAPSHOT '..path)end end
  end
 end
end
