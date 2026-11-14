-- Current user DOCX screenplay; original stage mods and combat data stay intact.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local data=dofile('mod/SixStageCampaign/screenplay/data.lua')
SixStageScreenplay={data=data}
local P=SixStageScreenplay
LoadTexture('six.script.aya','mod/SixStageCampaign/screenplay/art/aya-th10.png')
for i=0,7 do LoadImage('six.script.aya.'..i,'six.script.aya',(i%4)*64,math.floor(i/4)*64,64,64)end
function D.defaultKaguyaPortrait()
 return C.index<=4 and'maskedreimu'or'kaguya1'
end
local textures={}
for key,a in pairs(data.art)do
 for j,layer in ipairs(a.layers)do
  local texture=textures[layer.file]
  if not texture then
   texture='six.script.texture.'..key
   LoadTexture(texture,'mod/SixStageCampaign/screenplay/'..layer.file)
   textures[layer.file]=texture
  end
  layer.image='six.script.'..key..'.'..j
  LoadImage(layer.image,texture,layer.x,layer.y,layer.cw,layer.ch)
  SetImageCenter(layer.image,layer.cx,layer.cy)
 end
 D.data.art[key]=a
end
for ch in pairs(data.fallback)do D.data.fallback[ch]=true end
for key,pages in pairs(data.scenes)do
 if key=='s3pre'then D.data.pre=pages
 elseif key=='s3post'then D.data.post=pages
 else S.data.scenes[key]=pages end
end
S.data.names.horou='珠乌'
-- s6battle deliberately remains the existing voice-only random laugh.
function P.beforeFive()
 local mode=setting.hsob5_boss_mode
 P.fiveIntro=not mode or mode=='non1'
 if not P.fiveIntro then return end
 P.player=player;P.oldDialog=IsValid(player)and player.dialog
 if IsValid(player)then player.dialog=true end
 S.play('s5off')
end
function P.afterFiveArrival()
 if not P.fiveIntro then return end
 S.play('s5pre');task.Wait(90)
 if IsValid(P.player)then P.player.dialog=P.oldDialog end
 P.player=nil;P.fiveIntro=false
end
local source=C.sourceText
C.sourceText=function(path)
 if path=='mod/Stage12Normal/stage2-run.lua'then
  local code=assert(source(path))
  local title="    if R.tick>=420 and R.tick<560 then RenderText('menu','STAGE 2',0,15,0.7,'centerpoint') end"
  local titleAt=assert(code:find(title,1,true),'Stage2 central title source changed')
  code=code:sub(1,titleAt-1)..code:sub(titleAt+#title)
  local old='            Stage2Flare.clean();task.Wait(60);afterMid=true'
  local at=assert(code:find(old,1,true),'Patchouli post-story source changed')
  return code:sub(1,at-1).."            SixStageStory46.play('s2hinapost')\n"..code:sub(at)
 end
 if path~='mod/HSoBStage5Normal/boss-link.lua'then return source and source(path)end
 local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
 local replacements={
  {' if self.timer>=90 then Del(self)end',' if self.timer>=90 and not SixStageScreenplay.fiveIntro then Del(self)end'},
  {" StopMusic('hs5.road')"," SixStageScreenplay.beforeFive()\n StopMusic('hs5.road')"},
  {' while IsValid(arrival)do task.Wait(1)end',' while IsValid(arrival)and arrival.timer<90 do task.Wait(1)end\n SixStageScreenplay.arrival=arrival;SixStageScreenplay.afterFiveArrival()\n if IsValid(arrival)then Del(arrival)end;SixStageScreenplay.arrival=nil'},
  {' R.bossActive=false;R.bossComplete=true'," if Zuu4Stage.current=='final'then SixStageStory46.play('s5post')end\n R.bossActive=false;R.bossComplete=true"}}
 for _,r in ipairs(replacements)do
  local at=assert(code:find(r[1],1,true),'Stage5 screenplay source changed: '..r[1])
  code=code:sub(1,at-1)..r[2]..code:sub(at+#r[1])
 end
 return code
end
local function midCard()
 local c=boss.move.New(0,96,1,MOVE_DECEL)
 c.init=function(o)
  task.New(o,function()
   S.play('s5mid')
   local p=player;local old=IsValid(p)and p.dialog
   if IsValid(p)then p.dialog=true end
   task.Wait(90)
   if IsValid(p)then p.dialog=old end
   Kill(o)
  end)
 end
 return c
end
local install=C.install
function C.install(i,classes)
 install(i,classes);P.fiveIntro=false;P.player=nil
 if i==2 then
  Stage2Flare.Boss.render=function(o)
   o._bosssys:render()
   Render('s2.hina-0',o.x,o.y,0,1.2,1.2)
  end
  Stage2Mystia.Boss.render=function(o)
   o._bosssys:render()
   local frame=math.floor(o.ani/4)%4
   if o.motionSpeed and o.motionSpeed>0.2 then frame=4+math.min(3,math.floor(o.ani/4)%4)end
   local facing=(o.moveAngle and cos(o.moveAngle)<0)and -1 or 1
   Render('six.script.aya.'..frame,o.x,o.y,0,facing,1)
  end
 end
 if i~=5 then return end
 local init=Zuu4Boss.init
 Zuu4Boss.init=function(o,mode,...)
  local original=boss.init
  boss.init=function(b,x,y,name,cards,...)
   local ids=mode and Zuu4Specs[mode]and{mode}or Zuu4Order
   for j,id in ipairs(ids)do if id=='non3'then table.insert(cards,j,midCard());break end end
   return original(b,x,y,name,cards,...)
  end
  init(o,mode,...);boss.init=original
 end
end
