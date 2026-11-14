-- TH16 complete expression portraits for the disguised player, stages1-4 only.
local C,D=SixStageCampaign,SixStageDialogue3
local E={};SixStageDialogueEmotions=E
local mapping={
 ['s1momijipost']={[1]='pr'},
 ['s1momijipre']={[1]='sp',[2]='sp'},
 ['s1open']={[1]='sp',[2]='dp',[3]='pr'},
 ['s1wakapost']={[3]='sp',[6]='dp'},
 ['s1wakapre']={[1]='n2',[3]='n2',[4]='sp',[5]='no',[7]='sp',[9]='an'},
 ['s2hinapost']={[1]='sw'},
 ['s2mamizoupost']={[3]='an',[6]='no',[8]='sp'},
 ['s2mamizoupre']={[2]='sp',[5]='n2',[8]='sp',[10]='dp',[11]='an'},
 ['s2mystiapre']={[2]='sw'},
 ['s3post']={[3]='sp',[6]='n2',[9]='n2',[12]='sp'},
 ['s3pre']={[2]='sp',[5]='sw',[6]='sw',[8]='n2',[12]='an'},
 ['s4post']={[2]='sp',[5]='sp',[6]='sp'},
 ['s4pre']={[2]='pr',[4]='dp',[6]='sp'},
 ['s4rabbitpost']={[5]='an'},
 ['s4rabbitpre']={[3]='sp',[5]='sw'},
}
E.mapping=mapping;E.changed=0
for _,key in ipairs({'an','dp','hp','n2','no','pr','sp','sw'})do
 local name='six.reimu.emotion.'..key
 LoadTexture(name,'mod/SixStageCampaign/dialogue-emotions/'..key..'.png')
 LoadImage(name,name,0,0,575,660);SetImageCenter(name,287.5,660)
 D.data.art['th16reimu'..key]={scale=360/660,layers={{image=name}}}
end
for scene,choices in pairs(mapping)do
 local pages=assert(SixStageScreenplay.data.scenes[scene],scene)
 for _,page in ipairs(pages)do
  if page.speaker=='kaguya'and page.portrait=='maskedreimu'then
   page.portrait='th16reimu'..assert(choices[page.line],scene..':'..page.line)
   E.changed=E.changed+1
  end
 end
end
local default=D.defaultKaguyaPortrait
function D.defaultKaguyaPortrait()
 if C.index<=4 then return'th16reimuno'end
 return default()
end
-- Shared D.render already draws the silent portrait first, speaker last,
-- and interpolates silent brightness to88/255; no overlay/tint on these layers.

-- The fish reacts with worry to the player's anger, not anger of her own.
local reaction=SixStageScreenplay.data.scenes.s1wakapre[10]
assert(reaction.line==10 and reaction.text=='「我操，用户彻底怒了」')
reaction.portrait='wakasapr'

-- Exact user wording correction; preserve the existing page layout.
for _,page in ipairs(SixStageScreenplay.data.scenes.s3pre)do
 if page.speaker=='kaguya'and page.line==6 then
  assert(page.text=='「怎么穿得起这么贵的衣服」')
  page.text='「怎么穿得起这么贵的c服」'
  for i,row in ipairs(page.rows)do page.rows[i]=row:gsub('衣服','c服')end
 end
end
