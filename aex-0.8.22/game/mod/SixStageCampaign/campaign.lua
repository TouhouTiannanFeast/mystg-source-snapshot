-- Live composition: original stage files are deliberately never copied or edited.
SixStageCampaign={index=0,entry=setting.six_entry or 'full',god=setting.six_invincible==true,
 speed=tonumber(setting.six_speed)or 1,first=true,visited=0}
local C=SixStageCampaign
C.speed=(C.speed==4 or C.speed==8)and C.speed or 1
C.names={'Misty Lake@Normal','Stage Two@Normal','Yuyuko Stage3@Normal',
 'Marisa Mixed@Normal','HSoB Stage5 Road@Normal','Nina Six@Normal'}
C.modules={'Stage12Normal','Stage12Normal','YuyukoStage3','MarisaMixed','HSoBStage5Normal','NinaStage6Normal'}
local nativeInclude=Include
local moduleRoot
local cacheKeys={}
local changedGlobals={}
local savedTables={}
local gap=stage.New('SixStageGap',false,true)
local core={}
for _,key in ipairs({'New','AddStage','DefStageFunc','Start','PracticeStart','FinishStage','FinishReplay'})do core[key]=stage.group[key]end

local function copy(t)local r={};for k,v in pairs(t)do r[k]=v end;return r end
local function restore(t,values)
 for k in pairs(t)do if values[k]==nil then t[k]=nil end end
 for k,v in pairs(values)do t[k]=v end
end
local function captureTables()
 C.baseline=true
 local seen={}
 local function save(t)
  if type(t)~='table'or seen[t]then return end
  seen[t]=true;savedTables[#savedTables+1]={t,copy(t)}
 end
 for _,v in pairs(_G)do if type(v)=='table'and v.is_class then save(v)end end
 save(item);save(player_lib.system);save(player_lib.debug_data)
 save(ui);save(ui.menu);save(ext.pausemenu);save(lstg.lstg_ui)
end
local function restoreSource()
 for _,s in ipairs(savedTables)do restore(s[1],s[2])end
 for k,s in pairs(changedGlobals)do _G[k]=s.value end
 changedGlobals={}
 for k in pairs(cacheKeys)do lstg.included[k]=nil end
 cacheKeys={}
 moduleRoot=nil
end
local function fileExists(path)return lstg.FileManager.FileExist(path)end
local function pathFor(path)
 if moduleRoot and type(path)=='string'and not path:match('^mod/')and fileExists(moduleRoot..path)then return moduleRoot..path end
 return path
end
-- Both immediate and deferred asset loads retain their source-relative paths.
for _,key in ipairs({'LoadTexture','LoadMusic','LoadSound','LoadTTF','LoadFX','LoadFont'})do
 local original=_G[key]
 if original then _G[key]=function(name,path,...)return original(name,pathFor(path),...)end end
end
Include=function(path)
 local resolved=pathFor(path)
 if resolved:match('^mod/')then cacheKeys[resolved]=true end
 if C.sourceText then
  local code=C.sourceText(resolved)
  if code then return assert(loadstring(code,'@'..resolved))()end
 end
 return nativeInclude(resolved)
end

local function configure(i)
 local seed=tonumber(setting.six_seed)or 20261107
 -- Clear only the entry/test options owned by the composed routes.
 for _,key in ipairs({'stage12_entry','th14_practice','th08_practice','y3_test','nina_test','marisa_test',
 'stage12_test','th08_autotest','zuu4_test','th18_stage5_test','th18_stage5_collision_test',
 'th18_stage5_background_test','th18_stage5_test_scenery','marisa_road_test','rs_test','rs_hammer_test','hsob5_test'})do setting[key]=nil end
 setting.y3_full=true;setting.y3_entry='full';setting.y3_practice='all';setting.y3_seed=seed
 setting.marisa_road=true;setting.marisa_phase='all';setting.marisa_ssg_mode='full';setting.marisa_seed=seed
 setting.rs_practice='all';setting.rs_seed=seed;setting.nina_phase='all';setting.nina_seed=seed
 if setting.six_probe_b3 and i==4 then setting.marisa_road=false;setting.marisa_phase='ssg';setting.marisa_ssg_mode='B3'end
 setting.stage12_invincible=false;setting.y3_invincible=false;setting.zuu4_invincible=false
 setting.nina_invincible=false;setting.marisa_invincible=false;setting.rs_invincible=false
 setting.hsob5_from=1;setting.hsob5_boss_only=false;setting.hsob5_boss_mode=nil
 setting.hsob5_seed=seed;setting.hsob5_invincible=false
 if C.entry~='full'then
  if i<=2 then setting.stage12_entry=C.entry
  elseif i==3 then
   local entry=({['road-front']='road-0',['road-back']='road-5200'})[C.entry]or C.entry
   setting.y3_entry=entry;setting.y3_practice=entry:match('^road%-')and'all'or entry
  elseif i==4 then setting.marisa_road=false;setting.marisa_phase=C.entry
  elseif i==5 then
   local part=tonumber(C.entry)
   setting.hsob5_from=part or 3;setting.hsob5_boss_only=not part
   setting.hsob5_boss_mode=C.entry~='boss'and not part and C.entry or nil
  else setting.nina_phase=C.entry end
 end
end

local function import(i)
 if not C.baseline then captureTables()end
 restoreSource();configure(i)
 moduleRoot='mod/'..C.modules[i]..'/'
 local before=copy(_G)
 local realStages=stage.stages
 local captured={}
 stage.stages=captured
 stage.group.New=function()return{}end
 stage.group.AddStage=function(_,name,items)
  local s={name=name,stage_name=name,item_init=items,frame=stage.group.frame,render=stage.group.render}
  captured[name]=s;return s
 end
 stage.group.DefStageFunc=function(name,key,f)assert(captured[name],name)[key]=f end
 local initFrame=stage_init.frame
 local originalClass=Class;local classes={}
 Class=function(...)local c=originalClass(...);classes[#classes+1]=c;return c end
 Include('root.lua')
 Class=originalClass
 stage.stages=realStages;stage_init.frame=initFrame
 for key,f in pairs(core)do stage.group[key]=f end
 if C.install then C.install(i,classes)end
 -- Record only globals changed during import, not runtime state such as player/lstg.var.
 for key,value in pairs(_G)do if before[key]~=value then changedGlobals[key]={value=before[key]}end end
 for key,value in pairs(before)do if _G[key]==nil then changedGlobals[key]={value=value}end end
 local result=assert(captured[C.names[i]],'missing source stage '..C.names[i])
 if C.wrapSource then C.wrapSource(i,result)end
 local originalCollision=reimu_player.colli
 function reimu_player:colli(other)
  if C.god then return end
  return originalCollision(self,other)
 end
 C.stage12Shoot=i<=2 and reimu_player.shoot or nil
 lstg.RegisterAllGameObjectClass()
 print('SIX IMPORT '..i..' '..C.modules[i]..' entry='..C.entry)
 return result
end

function C.go(i,entry)
 if C.cancelDialogue then C.cancelDialogue()end
 C.clearWait=nil
 if not ext.pause_menu:IsKilled()then
  ext.pause_menu:ResumeSound();ext.pause_menu.kill=true;ext.pause_menu.task={}
 end
 C.target=math.max(1,math.min(6,i));C.entry=entry or'full'
 if C.index==2 and C.target==3 and not C.reward then
  -- TH18 notice.anm: slide30, wait for fresh confirmation, exit30.
  C.reward={age=0,blocked=GetKeyState(KEY.Z)or GetKeyState(KEY.ENTER)}
  PlaySound('six.notice.appear',1,0,true)
  print('SIX CARD NOTICE enter yinyang presentation-only')
  return
 end
 stage.Set('SixStageGap','none')
end
local function finishNow()
 if C.index<6 then C.go(C.index+1)else C.complete=true;stage.Set('SixStageGap','none')end
end
local function finish()
 if C.leaving then return end
 if C.beforeFinish and C.beforeFinish()then return end
 C.leaving=true;C.clearWait=240
 C.clearStartTick=stage.current_stage and stage.current_stage.timer
 print('SIX PICKUP WINDOW stage='..C.index..' frames=240')
end
function C.updateClearWindow()
 if not C.clearWait then return end
 if type(C.clearStartTick)=='number'and stage.current_stage.timer==C.clearStartTick then return end
 C.clearWait=C.clearWait-1
 if C.clearWait<=0 then C.clearWait=nil;finishNow()end
end
stage.group.FinishStage=finish
core.FinishStage=finish
local normalStart=core.Start
core.Start=function(name)
 if name=='Normal'or type(name)=='table'and name.name=='Normal'then
  C.first=true;C.complete=false;C.entry='full';C.clearWait=nil;C.clearStartTick=nil
 end
 return normalStart(name)
end
stage.group.Start=core.Start
stage.group.New('Normal','menu',{lifeleft=2,power=400,bomb=3},true,2)
for i,name in ipairs(C.names)do
 local s=stage.group.AddStage('Normal',name,nil,true)
 s.init=function(self)
  C.index=i;C.leaving=false;C.clearWait=nil;C.visited=C.visited+1
  C.complete=false
  local source=import(i)
  self.source=source
  -- Initialize once when starting at any selector entry; carry resources thereafter.
  local oldInit=_init_item
  _init_item=function(st)
   if C.first then
    local practice=lstg.var.is_practice;lstg.var.is_practice=true;oldInit(st);lstg.var.is_practice=practice
    lstg.var.lifeleft=i<=2 and 2 or 8
    lstg.var.bomb=3;lstg.var.power=400;C.first=false
    C.initialLives=lstg.var.lifeleft;C.initialBomb=lstg.var.bomb
   end
  end
  source.init(self)
  if C.frontLoading then
   print(string.format('SIX LOADING ready stage=%d elapsed=%.3f',i,os.clock()-C.frontLoading.started))
   C.frontLoading=nil
  end
  _init_item=oldInit
  C.entry='full'
  print('SIX START '..i..' lives='..tostring(lstg.var.lifeleft)..' bomb='..tostring(lstg.var.bomb)..' power='..tostring(lstg.var.power))
 end
 s.del=function(self)
  if self.source and self.source.del then self.source.del(self)end
  -- No old audio/road callback may run after its stage resources are removed.
  local globalMusic,stageMusic=EnumRes('bgm')
  for _,pool in ipairs({globalMusic,stageMusic})do for _,name in pairs(pool)do StopMusic(name)end end
  if StopSound then StopSound('six.marisa.charge')end
  AfterFrame=C.controllerAfter
 end
end

function gap:init()
 self.frames=0
 self.seconds=1
 -- The stage resource pool and all old objects have already been destroyed.
 print('SIX GAP '..C.index..' -> '..tostring(C.target or'complete'))
end
function gap:frame()
 self.frames=self.frames+1
 if self.frames>=self.seconds*60 and os.clock()-self.clockStart>=self.seconds then
  print(string.format('SIX GAP PASS frames=%d elapsed=%.3f',self.frames,os.clock()-self.clockStart))
  if C.complete then if setting.six_probe then print('SIX PROBE PASS');stage.QuitGame()else stage.Set('menu','none')end
  else stage.Set(C.names[C.target],'none')end
 end
end
-- os.clock on Windows measures elapsed wall time; also count 60 normal ticks.
local gapInit=gap.init
function gap:init()gapInit(self);self.clockStart=os.clock()end
function gap:render()
 SetViewMode('ui');RenderClear(Color(255,0,0,0))
end

local held={}
local function press(key)
 local down=GetKeyState(key);local edge=down and not held[key];held[key]=down;return edge
end
local frame=FrameFunc
FrameFunc=function(...)
 if stage.current_stage.stage_name=='menu'or stage.current_stage.stage_name=='SixStageLoading'then return frame(...)end
 if C.dialogueActive then C.updateDialogue();return frame(...)end
 if C.reward then
  local r=C.reward;r.age=r.age+1
  local down=GetKeyState(KEY.Z)or GetKeyState(KEY.ENTER)
  if not down then r.blocked=false end
  if setting.six_probe and r.age==70 then C.snapshot='six-yinyang-card'end
  if not r.exit and r.age>=30 and((down and not r.blocked)or(setting.six_probe and r.age==100))then
   r.exit=0;PlaySound('six.notice.confirm',1,0,true);print('SIX CARD NOTICE confirmed')
  end
  if r.exit then
   r.exit=r.exit+1
   if r.exit>=30 then C.reward=nil;stage.Set('SixStageGap','none');print('SIX CARD NOTICE exit')end
  end
  return
 end
 if press(KEY.F6)then C.god=not C.god end
 if press(KEY.F7)then C.speed=C.speed==1 and 4 or(C.speed==4 and 8 or 1)end
 if press(KEY.F5)then C.select=not C.select;C.choice=C.index>0 and C.index or 1 end
 if C.select then
  if press(KEY.UP)then C.choice=(C.choice+4)%6+1 end
  if press(KEY.DOWN)then C.choice=C.choice%6+1 end
  if press(KEY.Z)then C.select=false;C.complete=false;C.go(C.choice)end
  if press(KEY.ESCAPE)then C.select=false end
  return
 end
 return frame(...)
end
local doFrame=DoFrame
DoFrame=function(...)
 local name=stage.current_stage.stage_name
 local n=(C.dialogueActive or name=='SixStageGap'or name=='menu'or name=='init'or name=='SixStageLoading')and 1 or C.speed
 for _=1,n do
  doFrame(...)
  if stage.next_stage or stage.current_stage.stage_name=='SixStageGap'or C.dialogueActive then break end
 end
end
local after=AfterFrame
AfterFrame=function(...)
 after(...)
 C.updateClearWindow()
 if setting.six_probe and C.index>0 and stage.current_stage.name==C.names[C.index]then
  local s=stage.current_stage
  if s.timer==90 then
   assert(IsValid(player),'no live player')
   if C.index<=2 then assert(player.class.shoot==C.stage12Shoot,'stage12 shot changed')
   else assert(player.class.shoot==Y3Player.shoot,'homing shot missing')end
   assert(lstg.var.lifeleft==C.initialLives and lstg.var.bomb==C.initialBomb,'resource carry failed')
   print('SIX SHOT PASS '..C.index)
   if setting.six_items_probe then
    for n,cls in ipairs({item_point,item_faith,item_faith_minor,item_extend,item_chip,item_bomb,item_bombchip})do
     local o=New(cls,-160+(n-1)*48,0);o.attract=0;o.group=GROUP_GHOST;o.colli=false
     assert(o.img=='six.item.'..(n<=3 and'point'or n<=5 and'life'or'bomb'),'pickup image not unified')
    end
    C.snapshot='six-unified-items'
   end
  end
  local limit=setting.six_probe_b3 and C.index==4 and 1200 or(C.index==6 and setting.nina_phase=='kanako'and 600 or 180)
  if s.timer==limit then finish()end
 end
end
C.controllerAfter=AfterFrame
local render=RenderFunc
RenderFunc=function(...)
 render(...)
 lstg.BeginScene()
 SetViewMode('ui')
 if stage.current_stage.stage_name~='SixStageResult'and stage.current_stage.stage_name~='SixStageGap'and stage.current_stage.stage_name~='menu'and stage.current_stage.stage_name~='SixStageLoading'and not C.reward and not C.dialogueActive then
  RenderText('menu','F5 STAGE  /  F6 GOD '..(C.god and'ON'or'OFF')..'  /  F7 SPEED '..C.speed..'x',320,466,0.3,'centerpoint')
 end
 if C.reward then
  local r=C.reward
  -- Original notice.anm scripts1..4, all native coordinates divided by2.
  -- Anchor switches from left on entry to right on exit; only the leading
  -- feather is visible, not two permanent decorative end pieces.
  local u=math.min(1,(r.exit or r.age)/30)
  local textEase=1-(1-u)^2
  local bandEdge=r.exit and(640.5-769*u*u)or(767.5-768*u*u)
  local left=r.exit and bandEdge-648 or bandEdge
  local textX=r.exit and(-640*textEase)or(768*(1-textEase))
  local alpha=r.exit and math.floor(255*(1-u))or 255
  SetImageState('white','',Color(192,0,0,0));RenderRect('white',left,left+648,176,304)
  SetImageState('white','',Color(255,255,255,255))
  if r.exit then
   SetImageState('six.notice.right','',Color(192,255,255,255))
   Render('six.notice.right',640-768*u*u,240,0,0.5,0.5)
  else
   SetImageState('six.notice.left','',Color(192,255,255,255))
   Render('six.notice.left',768*(1-u*u),240,0,0.5,0.5)
  end
  SetImageState('six.notice.cardcount','',Color(alpha,255,255,255))
  SixStageTypography.draw('获得了能力卡牌「阴阳玉」。',textX+64,250,alpha,'body',true)
  SixStageTypography.draw('按 Z 键继续',textX+64,212,alpha,'body')
  SetImageState('six.cards18.orb','',Color(alpha,255,255,255));Render('six.cards18.orb',textX+566,240,0,1,1)
 end
 if C.select then
  SetImageState('white','',Color(240,12,18,36))
  RenderRect('white',110,530,110,410)
  SetImageState('white','',Color(255,255,255,255))
  RenderText('menu','SELECT STAGE / Z CONFIRM / ESC BACK',320,380,0.4,'centerpoint')
  for i=1,6 do RenderText('menu',(i==C.choice and'> 'or'')..'STAGE '..i,320,360-i*30,0.5,'centerpoint')end
 end
 if C.drawDialogue then C.drawDialogue()end
 lstg.EndScene()
 if C.snapshot then
  local path='userdata/snapshot/'..C.snapshot..'.jpg';lstg.Snapshot(path);print('SIX SNAPSHOT '..path);C.snapshot=nil
 end
end
function C.prepareMenu()
 if C.cancelDialogue then C.cancelDialogue()end
 restoreSource()
 C.clearWait=nil;C.clearStartTick=nil
 C.index=0;C.first=true;C.complete=false;C.leaving=false;C.select=false
end
function C.begin(index,entry)
 if not C.baseline then captureTables()end
 C.clearWait=nil;C.clearStartTick=nil
 C.first=true;C.complete=false;C.leaving=false;C.entry=entry or'full'
 lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
 lstg.var.is_practice=false
 C.target=math.max(1,math.min(6,tonumber(index)or 1))
 stage.Set(C.names[C.target],'none')
end
stage_init.frame=function(s)
 if s.timer==30 then
  if setting.six_direct or setting.six_probe then C.begin(setting.six_stage,setting.six_entry)
  else stage.Set('menu','none')end
 end
end
if setting.six_probe then
 local f,r=FrameFunc,RenderFunc
 FrameFunc=function()local ok,v=xpcall(f,debug.traceback);if not ok then print('SIX ERROR '..tostring(v));stage.QuitGame()end;return v end
 RenderFunc=function()local ok,v=xpcall(r,debug.traceback);if not ok then print('SIX ERROR '..tostring(v));stage.QuitGame()end;return v end
end
