-- Stage2 story adapters; original Stage12Normal files remain read-only.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local data=dofile('mod/SixStageCampaign/dialogue2/data.lua')
local A={data=data,holdMystia=false}
SixStageDialogue2=A
for key,a in pairs(data.art)do
 for j,v in ipairs(a.layers)do
  v.image='six.story2.'..key..'.'..j
  LoadTexture(v.image,'mod/SixStageCampaign/dialogue2/'..v.file)
  LoadImage(v.image,v.image,v.x or 0,v.y or 0,v.cw or v.w,v.ch or v.h)
  SetImageCenter(v.image,v.cx,v.cy)
 end
 D.data.art[key]=a
end
for key,pages in pairs(data.scenes)do S.data.scenes[key]=pages end
for key,name in pairs(data.names)do S.data.names[key]=name end
for ch in pairs(data.fallback)do D.data.fallback[ch]=true end
function A.waitBeforeBattle()
 local p=player;local was=IsValid(p)and p.dialog
 if IsValid(p)then p.dialog=true end
 task.Wait(90)
 if IsValid(p)then p.dialog=was end
end
local function intro(key,x,y)
 local c=boss.move.New(x,y,1,MOVE_DECEL)
 c.init=function(o)
  if key=='s2mystiapre'then A.holdMystia=true end
  task.New(o,function()
   S.play(key);A.waitBeforeBattle();A.holdMystia=false;Kill(o)
  end)
 end
 return c
end
local function insert(class,key,x,y)
 local init=class.init
 class.init=function(o,start,...)
  if key=='s2mamizoupre'and start and start~=1 then return init(o,start,...)end
  local original=boss.init
  boss.init=function(b,bx,by,name,cards,...)
   table.insert(cards,2,intro(key,x,y)) -- after the original60f movement
   return original(b,bx,by,name,cards,...)
  end
  init(o,start,...);boss.init=original
 end
end
local source=C.sourceText
C.sourceText=function(path)
 if path~='mod/Stage12Normal/stage2-run.lua'then return source and source(path)end
 local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
 local replacements={
  {"Stage2Mamizou.clean();phase('Complete');R.finished=true","SixStageStory46.play('s2mamizoupost');Stage2Mamizou.clean();phase('Complete');R.finished=true"}}
 for _,r in ipairs(replacements)do
  local a=assert(code:find(r[1],1,true),'Stage2 story source changed: '..r[1])
  code=code:sub(1,a-1)..r[2]..code:sub(a+#r[1])
 end
 return code
end
local install=C.install
function C.install(i,classes)
 install(i,classes);A.holdMystia=false
 if i~=2 then return end
 insert(Stage2Flare.Boss,'s2hinapre',0,134)
 insert(Stage2Mystia.Boss,'s2mystiapre',0,112)
 insert(Stage2Mamizou.Boss,'s2mamizoupre',0,112)
 local tail=Stage12Tail.run
 Stage12Tail.run=function(b,spawn,alive,wait,stats)
  return tail(b,spawn,alive,function(n)
   for _=1,n do
    while S.active or A.holdMystia do task.Wait(1)end
    wait(1)
   end
  end,stats)
 end
end
