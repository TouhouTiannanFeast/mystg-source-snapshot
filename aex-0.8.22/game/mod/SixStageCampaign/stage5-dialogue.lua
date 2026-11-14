-- New Stage5 document; all other story scenes and combat sources stay intact.
local C,D,S=SixStageCampaign,SixStageDialogue3,SixStageStory46
local data=dofile('mod/SixStageCampaign/stage5-dialogue/data.lua')
local M={active=false,age=0};SixStageDialogue5=M
for key,pages in pairs(data)do S.data.scenes[key]=pages;SixStageScreenplay.data.scenes[key]=pages end
for _,n in ipairs({1,2,3,6,9,10})do
 local name='six.horou.doc.'..n;local file='mod/SixStageCampaign/stage5-dialogue/horou'..n..'.png'
 LoadTexture(name,file);LoadImage(name,name,0,0,1024,1024)
 local cx,cy,scale=470,996,360/751
 if n==1 then cx,cy,scale=528.5,889,360/836 end
 SetImageCenter(name,cx,cy)
 D.data.art['horou'..n]={scale=scale,layers={{image=name}}}
end
-- TH20 st06r0.msg entry2: centered portrait-free text at(192,150),
-- 30-frame lead,120-frame text intervals,30-frame close; ECL waits for it.
function M.play()
 if S.played.s5mid then return end
 S.played.s5mid=true;S.active=true;S.current='s5mid'
 D.beginEntrance();M.active=true;M.age=0
 for t=1,300 do M.age=t;task.Wait(1)end
 M.active=false;D.endEntrance();S.active=false;S.current=nil
end
local play=S.play
function S.play(key,...)
 if key=='s5mid'then return M.play()end
 return play(key,...)
end
local draw=C.drawDialogue
function C.drawDialogue(...)
 draw(...)
 if not M.active then return end
 local index=M.age>=30 and M.age<270 and(math.floor((M.age-30)/120)+1)or nil
 if not index then return end
 local text=data.s5mid[index].text
 local chars={};for ch in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do chars[#chars+1]=ch end
 SetViewMode('ui')
 for row=1,math.ceil(#chars/20)do
  local line=table.concat(chars,'',(row-1)*20+1,math.min(row*20,#chars))
  local width=0;for ch in line:gmatch('[%z\1-\127\194-\244][\128-\191]*')do width=width+(#ch==1 and 9 or 18)end
  SixStageTypography.draw(line,224-width/2,314-(row-1)*24,255,'body')
 end
end
local install=C.install
function C.install(i,classes)
 install(i,classes);M.active=false;M.age=0
end
local cancel=C.cancelDialogue
function C.cancelDialogue(...)
 M.active=false;return cancel(...)
end
