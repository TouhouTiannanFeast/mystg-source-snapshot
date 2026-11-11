Include('THlib.lua')
LoadTexture('six.yinyang','mod/SixStageCampaign/art/yinyang.png')
local w,h=GetTextureSize('six.yinyang')
LoadImage('six.yinyang','six.yinyang',0,0,w,h)
LoadTTF('six.card.font','assets/font/SourceHanSansCN-Bold.otf',24)
LoadTexture('six.notice','mod/SixStageCampaign/art/notice_bk.png')
LoadImage('six.notice.left','six.notice',0,0,512,256)
LoadImage('six.notice.right','six.notice',512,0,512,256)
SetImageCenter('six.notice.left',512,128)
SetImageCenter('six.notice.right',0,128)
LoadTexture('six.items','mod/SixStageCampaign/art/th08-items.png')
for name,x in pairs({point=16,life=80,bomb=48})do
 LoadImage('six.item.'..name,'six.items',x,64,16,16,8,8)
end
LoadSound('six.marisa.charge','mod/SixStageCampaign/se/marisa-charge.wav')
Include('mod/SixStageCampaign/campaign.lua')
Include('mod/SixStageCampaign/adapters.lua')
Include('mod/SixStageCampaign/hit-effect.lua')
Include('mod/SixStageCampaign/road-bonus.lua')
Include('mod/SixStageCampaign/combat-review.lua')
Include('mod/SixStageCampaign/opening-anchor.lua')
Include('mod/SixStageCampaign/dialogue3.lua')
Include('mod/SixStageCampaign/dialogue46.lua')
Include('mod/SixStageCampaign/dialogue2.lua')
Include('mod/SixStageCampaign/dialogue1.lua')
if setting.six_story1_probe then Include('mod/SixStageCampaign/dialogue1/probe.lua')end
if setting.six_story2_probe then Include('mod/SixStageCampaign/dialogue2/probe.lua')end
if setting.six_story46_probe then Include('mod/SixStageCampaign/dialogue46/probe.lua')end
if setting.six_combat_probe then Include('mod/SixStageCampaign/probe-combat.lua')end
if setting.six_resource_probe then Include('mod/SixStageCampaign/probe-resources.lua')end
if setting.six_dialogue3_probe then Include('mod/SixStageCampaign/probe-dialogue3.lua')end
Include('mod/SixStageCampaign/frontend/menu.lua')
