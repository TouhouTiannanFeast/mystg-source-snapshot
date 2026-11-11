-- Explicit whole-resource rewards. No generic stage bonus or fragments.
SixStageCampaignRoadBonus={done={},seenRoad={},cards=setmetatable({},{__mode='k'})}
local C,B=SixStageCampaign,SixStageCampaignRoadBonus
local roadRewards={[1]={1,1},[2]={1,1},[3]={1,2},[4]={0,3}}
function B.drop(lives,bombs,x,y)
 x=x or(lstg.world.l+lstg.world.r)/2;y=y or lstg.world.t+8
 local n=lives+bombs
 for i=1,n do New(i<=lives and item_extend or item_bomb,x+(i-(n+1)/2)*24,y)end
end
local function roadDone(i)
 if i==1 then return not setting.stage12_entry and th14 and th14.label=='Wakasagihime'
 elseif i==2 then return not setting.stage12_entry and Stage2Route and Stage2Route.phase=='Mamizou'
 elseif i==3 then
  if Y3Road and Y3Road.active then B.seenRoad[3]=true end
  return setting.y3_entry=='full'and B.seenRoad[3]and Y3Road and not Y3Road.active
 elseif i==4 then return setting.marisa_road and MarisaRoad14 and MarisaRoad14.state.phase=='entry'end
end
local function phase(b)
 local i=C.index;local card=b.current_card
 if i==1 and b.th14_phase=='scale'then return'boss'
 elseif i==2 and Stage2Mamizou and b.class==Stage2Mamizou.Boss then
  if Stage2Mamizou.state.phase==2 then return'spell1'end
  if Stage2Mamizou.state.phase==5 then return'boss'end
 elseif i==3 and card and card.name==Y3.specs.spell3.name then return'boss'
 elseif i==4 then
  if MarisaRabbit14 and b.class==MarisaRabbit14.Boss and MarisaRabbit14.state.phase=='spell'then return'rabbit'end
  if MarisaMixed.boss==b then return MarisaMixed.phase end
 elseif i==5 and Zuu4Stage.boss==b then return Zuu4Stage.current
 elseif i==6 then return NinaState.current end
end
local kill=boss.system.kill
boss.system.kill=function(s,...)
 local b=s.boss
 b.sixReward={stage=C.index,phase=phase(b),card=b.current_card,
  defeated=b.hp<=0 and not b.timeout,survival=b.time_sc==true}
 return kill(s,...)
end
boss.system.endChipBonus=function(s,x,y)
 local b=s.boss;local r=b.sixReward
 if not b.is_combat or not r or not r.card then return end
 local seen=B.cards[b]
 if not seen then seen={};B.cards[b]=seen end
 if seen[r.card]then return end;seen[r.card]=true
 local i,p,defeat=r.stage,r.phase,r.defeated
 local life,bomb=0,0
 if i==1 and p=='boss'then life=1
 elseif i==2 then
  if p=='spell1'then bomb=1 elseif p=='boss'and defeat then life,bomb=1,1 end
 elseif i==3 and p=='boss'and(defeat or r.survival)then life,bomb=1,2
 elseif i==4 and((p=='rabbit'and defeat)or p=='non3'or p=='final')then life=1
 elseif i==5 and p=='final'and defeat then bomb=3
 elseif i==6 and(p=='non3'or p=='final')then life=1 end
 if life+bomb>0 then B.drop(life,bomb,x,y);print('SIX RESOURCE stage='..i..' phase='..p..' life='..life..' bomb='..bomb)end
end
local after=AfterFrame
AfterFrame=function(...)
 after(...)
 local i=C.index;local reward=roadRewards[i]
 if reward and not B.done[i]and roadDone(i)then
  B.done[i]=true;B.drop(reward[1],reward[2])
  print('SIX ROAD RESOURCE stage='..i..' life='..reward[1]..' bomb='..reward[2])
 end
end
C.controllerAfter=AfterFrame
local install=C.install
function C.install(i,classes)
 install(i,classes);B.done[i]=nil;B.seenRoad[i]=nil;B.cards=setmetatable({},{__mode='k'})
end
