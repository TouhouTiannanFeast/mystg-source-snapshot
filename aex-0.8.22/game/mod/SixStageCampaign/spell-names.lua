-- Campaign-only display names; standalone mods retain their own names/data.
local C=SixStageCampaign
local install=C.install
local function named(factory,name)
 return function(...)
  local card=factory(...);card.name=name;return card
 end
end
function C.install(i,classes)
 install(i,classes)
 if i==1 then
  Stage1Context.card=named(Stage1Context.card,'求索「长上下文结界」')
  Stage1Anchor.card=named(Stage1Anchor.card,'転覆「道連れアンカー」')
 elseif i==4 then
  local specs=th08s4.phase_specs
  specs.stardust.name='魔符「スターダストレヴァリエ」'
  specs.milky.name='魔符「ミルキーウェイ」'
  specs.master.name='恋符「マスタースパーク」'
  DSExtraPool.specs[8].name='彗星「ブレイジングスター」'
 elseif i==5 then Zuu4Specs.stone.name='授权转噪「石之女神」'end
end
