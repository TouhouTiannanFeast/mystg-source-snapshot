-- User-authored Stage3 story; original LE03 Shion/HSoB Kaguya/TH10 dialogue art.

local C=SixStageCampaign

local data=dofile('mod/SixStageCampaign/dialogue3/data.lua')

local D={data=data,active=false,art={kaguya='kaguya1',shion='shion04'}}

SixStageDialogue3=D

for key,a in pairs(data.art)do

 local name='six.dialogue.'..key

 LoadTexture(name,'mod/SixStageCampaign/dialogue3/'..a.file)

 LoadImage(name,name,0,0,a.w,a.h);SetImageCenter(name,a.cx,a.cy)

end

LoadTexture('six.dialogue.box','mod/SixStageCampaign/dialogue3/art/th10-ascii.png')

LoadImage('six.dialogue.red','six.dialogue.box',0,88,256,40)

LoadImage('six.dialogue.blue','six.dialogue.box',0,152,256,40)

-- Engine's TTF default render scale is1/2:36px face ->18px screen glyphs.

LoadTTF('six.dialogue.yahei','mod/SixStageCampaign/dialogue3/font/msyh.ttc',36)

LoadTTF('six.dialogue.symbol','mod/SixStageCampaign/dialogue3/font/ms-gothic.ttc',36)



function D.cancel()

 if D.player and IsValid(D.player)then D.player.dialog=D.previousDialog end

 for _,p in ipairs(D.hiddenHints or{})do if IsValid(p[1])then p[1].hide=p[2]end end

 D.hiddenHints=nil

 D.active=false;C.dialogueActive=false;D.player=nil

end

function D.show(which,scene)

 assert(not D.active,'nested Stage3 dialogue')

 D.which=which;D.pages=scene and scene.pages or data[which];D.scene=scene;D.page=1;D.age=0;D.pageAge=0;D.exit=nil

 D.cast=scene and{kaguya='kaguya',other=scene.other}or{kaguya='kaguya',other='shion'}

 D.held=GetKeyState(KEY.Z);D.shade={kaguya=0,shion=1}

 D.art={kaguya=D.defaultKaguyaPortrait and D.defaultKaguyaPortrait()or'kaguya1',shion='shion04'}

 for _,page in ipairs(D.pages)do if page.speaker=='kaguya'then D.art.kaguya=page.portrait;break end end

 if scene then D.art[D.cast.other]=scene.initial end

 D.player=player;D.previousDialog=IsValid(player)and player.dialog or nil

 if IsValid(player)then player.dialog=true end

 D.active=true;C.dialogueActive=true

 if which=='pre'then D.preStartTick=stage.current_stage.timer end

 D.hiddenHints={}

 for _,o in ObjList(GROUP_GHOST)do

  if o.class==hinter or o.class==hinter_bonus then D.hiddenHints[#D.hiddenHints+1]={o,o.hide};o.hide=true end

 end

 local p=D.pages[1];D.art[p.speaker]=p.portrait

 if p.speaker~='kaguya'then D.cast.other=p.speaker end

 if scene and scene.onPage then scene.onPage(p)end

 print('SIX DIALOGUE3 '..which..' pages='..#D.pages)

end

function D.advance()

 if D.exit or not D.active then return end

 if D.page<#D.pages then

  D.page=D.page+1;D.pageAge=0

  local p=D.pages[D.page];D.art[p.speaker]=p.portrait

  if p.speaker~='kaguya'then D.cast.other=p.speaker end

  if D.scene and D.scene.onPage then D.scene.onPage(p)end

 else D.exit=0 end

end

function D.update()

 D.age=D.age+1;D.pageAge=D.pageAge+1

 local down=GetKeyState(KEY.Z);local edge=down and not D.held;D.held=down

 local p=D.pages[D.page]

 for _,who in ipairs({'kaguya',D.cast.other})do

  D.shade[who]=D.shade[who]or 0

  local target=p.speaker==who and 1 or 0

  D.shade[who]=D.shade[who]+(target-D.shade[who])*.25

 end

 if D.exit then

  D.exit=D.exit+1

  if D.exit>=12 then

   if not D.scene then if D.which=='post'then D.postDone=true else D.preDone=true end end

   local post=D.which=='post'

   print('SIX DIALOGUE3 DONE '..D.which);D.cancel()

   -- The source stage issues FinishStage once. Resume that pending finish after

   -- the post-dialogue instead of waiting for the source to issue it again.

   if post and D.resumeFinish then stage.group.FinishStage()end

  end

 elseif D.pageAge>=360 or(D.pageAge>=90 and(edge or GetKeyState(KEY.CTRL or 17)))then D.advance()end

 if D.probeUpdate then D.probeUpdate()end

end

function D.beginEntrance()

 D.entryPlayer=player

 D.entryDialog=IsValid(player)and player.dialog or nil

 if IsValid(player)then player.dialog=true end

 -- Existing shots must not keep attacking during the noncombat entrance.

 for _,o in ObjList(GROUP_PLAYER_BULLET)do Del(o)end

 D.roadEndTick=stage.current_stage.timer

end

function D.endEntrance()

 if D.entryPlayer and IsValid(D.entryPlayer)then D.entryPlayer.dialog=D.entryDialog end

 D.entryPlayer=nil

end

C.updateDialogue=D.update

C.cancelDialogue=function()D.cancel();D.endEntrance()end

function D.practiceEntrance(class)

 D.beginEntrance();D.roadEndTick=nil;D.flightStartTick=stage.current_stage.timer

 local entrance=New(class);D.entrance=entrance

 for t=1,60 do

  local u=t/60;u=u*u*(3-2*u);entrance.y=280+(112-280)*u

  task.Wait(1)

 end

 D.show('pre');while D.active do task.Wait(1)end

 D.preEndTick=stage.current_stage.timer;task.Wait(90)

 D.combatTick=stage.current_stage.timer;D.endEntrance();Del(entrance);D.entrance=nil

end

-- Adapt only this source's exact entrance block in memory. The standalone

-- original remains byte-for-byte intact, including its combat data.

local previousText=C.sourceText

C.sourceText=function(path)

 if path~='mod/YuyukoStage3/root.lua'then return previousText and previousText(path)end

 local f=assert(io.open(path,'rb'));local code=f:read('*a');f:close()

 code=code:gsub('\r\n','\n')

 local old='    task.Wait(90)\n    local entrance=New(Entrance)'

 local start=assert(code:find(old,1,true),'Stage3 road entrance source changed')

 code=code:sub(1,start-1)..'    SixStageDialogue3.beginEntrance()\n    task.Wait(60)\n    SixStageDialogue3.flightStartTick=stage.current_stage.timer\n    local entrance=New(Entrance)'..code:sub(start+#old)

 old='    Del(entrance)'

 start=assert(code:find(old,1,true),'Stage3 entrance removal source changed')

 local replacement=[[    SixStageDialogue3.entrance=entrance

    SixStageDialogue3.show('pre')

    while SixStageDialogue3.active do task.Wait(1)end

    SixStageDialogue3.preEndTick=stage.current_stage.timer

    task.Wait(90)

    SixStageDialogue3.combatTick=stage.current_stage.timer

    SixStageDialogue3.endEntrance()

    Del(entrance)

    SixStageDialogue3.entrance=nil]]

 code=code:sub(1,start-1)..replacement..code:sub(start+#old)

 old="   else assert(R.specs[entry],'Unknown Stage3 entry')end"

 start=assert(code:find(old,1,true),'Stage3 practice entrance source changed')

 replacement="   else assert(R.specs[entry],'Unknown Stage3 entry')\n    if entry=='non1' then SixStageDialogue3.practiceEntrance(Entrance)end\n   end"

 return code:sub(1,start-1)..replacement..code:sub(start+#old)

end

local function glyphs(text,x,y,alpha,role)
 return SixStageTypography.draw(text,x,y,alpha,role)
end

function D.render()

 if not D.active then return end

 local p=D.pages[D.page]

 local fade=math.min(1,D.age/12)*(D.exit and(1-D.exit/12)or 1)

 local function portrait(who)

  if p.hideOtherPortrait and who~='kaguya'then return end

  local a=data.art[D.art[who]];local light=D.shade[who]or 0

  local c=math.floor(88+167*light)

  local scale=a.scale*(.96+.04*light)

  local x,y=who=='kaguya'and-84 or 88,-216-(1-light)*16

  if a.alignRightBottom then

   x=lstg.world.r-a.visibleRight*scale

   y=lstg.world.b+a.visibleBottom*scale

  end

  local images=a.layers or{{image='six.dialogue.'..D.art[who]}}

  for _,layer in ipairs(images)do

   local shade=math.floor(c*(layer.tint or 1))

   SetImageState(layer.image,'',Color(255*fade,shade,shade,shade))

   Render(layer.image,x,y,0,scale,scale)

  end

 end

 SetViewMode('world')

 local other=D.cast.other

 if D.art[other]then portrait(p.speaker=='kaguya'and other or'kaguya')end

 portrait(p.speaker)

 SetViewMode('ui')

 SetImageState('white','',Color(math.floor(232*fade),12,16,24))

 RenderRect('white',32,416,30,126)

 SetImageState('white','',Color(255,255,255,255))

 local box=p.speaker=='kaguya'and'six.dialogue.red'or'six.dialogue.blue'

 SetImageState(box,'',Color(255*fade,255,255,255));Render(box,224,57,0,1.5,1.6)

 local name=p.displayName

 if name==nil then name=D.scene and D.scene.names[p.speaker]or(p.speaker=='kaguya'and'辉夜'or'死宛')end

 glyphs(name,44,112,255*fade,'name')

 for i,line in ipairs(p.rows)do glyphs(line,44,86-(i-1)*22,255*fade)end

end

C.drawDialogue=D.render

local previousFinish=C.beforeFinish

C.beforeFinish=function()

 if previousFinish and previousFinish()then return true end

 if C.index==3 and D.enabled and D.spawned and not D.postPlayed then

  D.postPlayed=true;D.resumeFinish=true;D.show('post');return true

 end

 return false

end

local previousWrap=C.wrapSource

C.wrapSource=function(i,source)

 if previousWrap then previousWrap(i,source)end

 if i~=3 or not D.enabled then return end

 local init=source.init

 source.init=function(s,...)

  local initTask=stage.group.initTask

  stage.group.initTask=function(st,fn,...)

   return initTask(st,function(...)

    fn(...)

    -- Source task already waited120f after Boss removal. Insert the post-story

    -- here, before initTask's automatic stage-clear fade starts.

    if D.enabled and D.spawned and not D.postPlayed then

     D.postPlayed=true;D.resumeFinish=false;D.show('post')

     while D.active do task.Wait(1)end

    end

   end,...)

  end

  local result=init(s,...)

  stage.group.initTask=initTask

  return result

 end

end

local install=C.install

function C.install(i,classes)

 install(i,classes);C.cancelDialogue();D.enabled=false;D.spawned=false;D.preDone=false;D.postPlayed=false;D.postDone=false;D.resumeFinish=false

 D.entrance=nil;D.roadEndTick=nil;D.preEndTick=nil;D.combatTick=nil

 if i~=3 then return end

 D.enabled=true

 D.preEnabled=setting.y3_practice=='all'or setting.y3_practice=='non1'

 local bossClass

 for _,class in ipairs(classes)do

  local info=class.init and debug.getinfo(class.init,'S')

  local damage=class.base and class.base.take_damage

  local di=damage and debug.getinfo(damage,'S')

  if info and di and info.source:find('YuyukoStage3/root.lua',1,true)and di.source:find('YuyukoStage3/root.lua',1,true)then

   bossClass=class;local init=class.init

   class.init=function(o,...)init(o,...);o.name='死宛'end

  end

 end

 assert(bossClass,'missing private Stage3 Boss class')

 local new=New

 New=function(class,...)

  if class~=bossClass then return new(class,...)end

  if D.enabled and D.preEnabled and not D.preDone then

   D.beginEntrance()

   D.show('pre')

   while D.active do task.Wait(1)end

   task.Wait(90)

   D.endEntrance()

  end

  D.spawned=true

  return new(class,...)

 end

end

