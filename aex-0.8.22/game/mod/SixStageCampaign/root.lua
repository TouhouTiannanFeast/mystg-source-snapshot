Include('THlib.lua')

LoadTexture('six.yinyang','mod/SixStageCampaign/art/yinyang.png')

local w,h=GetTextureSize('six.yinyang')

LoadImage('six.yinyang','six.yinyang',0,0,w,h)

LoadTTF('six.card.font','assets/font/SourceHanSansCN-Bold.otf',24)

LoadSound('six.notice.appear','mod/SixStageCampaign/se/th18-notice.wav')

LoadSound('six.notice.confirm','mod/SixStageCampaign/se/th18-ok00.wav')

LoadTexture('six.notice','mod/SixStageCampaign/art/notice_bk.png')

LoadTexture('six.notice.cardcount','mod/SixStageCampaign/art/th18-notice01.png')

LoadImage('six.notice.cardcount','six.notice.cardcount',0,0,1024,256)

LoadImage('six.notice.left','six.notice',0,0,512,256)

LoadImage('six.notice.right','six.notice',512,0,512,256)

SetImageCenter('six.notice.left',512,128)

SetImageCenter('six.notice.right',0,128)

LoadTexture('six.items','mod/SixStageCampaign/art/th08-items.png')

for name,x in pairs({point=16,life=80,bomb=48})do

 LoadImage('six.item.'..name,'six.items',x,64,16,16,8,8)

end

LoadSound('six.marisa.charge','mod/SixStageCampaign/se/marisa-charge.wav')

Include('mod/SixStageCampaign/typography.lua')
Include('mod/SixStageCampaign/campaign.lua')

Include('mod/SixStageCampaign/adapters.lua')

Include('mod/SixStageCampaign/hit-effect.lua')

Include('mod/SixStageCampaign/road-bonus.lua')

Include('mod/SixStageCampaign/combat-review.lua')

Include('mod/SixStageCampaign/opening-anchor.lua')

Include('mod/SixStageCampaign/dialogue3.lua')

Include('mod/SixStageCampaign/background5.lua')
Include('mod/SixStageCampaign/background3-end.lua')

Include('mod/SixStageCampaign/dialogue46.lua')

Include('mod/SixStageCampaign/dialogue2.lua')

Include('mod/SixStageCampaign/dialogue1.lua')

Include('mod/SixStageCampaign/screenplay.lua')

Include('mod/SixStageCampaign/spell-names.lua')

Include('mod/SixStageCampaign/stone-audio.lua')

Include('mod/SixStageCampaign/sidebar16.lua')

Include('mod/SixStageCampaign/cards18.lua')

Include('mod/SixStageCampaign/continue-resources.lua')

Include('mod/SixStageCampaign/suwako-road-audio.lua')

Include('mod/SixStageCampaign/momiji-audio.lua')

Include('mod/SixStageCampaign/road4-death.lua')

if setting.six_story1_probe then Include('mod/SixStageCampaign/dialogue1/probe.lua')end

if setting.six_story2_probe then Include('mod/SixStageCampaign/dialogue2/probe.lua')end

if setting.six_story46_probe then Include('mod/SixStageCampaign/dialogue46/probe.lua')end

if setting.six_screenplay_probe then Include('mod/SixStageCampaign/screenplay/probe.lua')end

if setting.six_combat_probe then Include('mod/SixStageCampaign/probe-combat.lua')end

if setting.six_resource_probe then Include('mod/SixStageCampaign/probe-resources.lua')end

if setting.six_dialogue3_probe then Include('mod/SixStageCampaign/probe-dialogue3.lua')end

if setting.six_road4_death_probe then Include('mod/SixStageCampaign/probe-road4-death.lua')end

Include('mod/SixStageCampaign/marisa-audio.lua')

Include('mod/SixStageCampaign/marisa-shake.lua')

Include('mod/SixStageCampaign/pause-music.lua')
Include('mod/SixStageCampaign/preboss-music.lua')
Include('mod/SixStageCampaign/frontend/menu.lua')


Include('mod/SixStageCampaign/bomb-audio.lua')

Include('mod/SixStageCampaign/replay-result.lua')

Include('mod/SixStageCampaign/stage5-dialogue.lua')

Include('mod/SixStageCampaign/result-skin.lua')

Include('mod/SixStageCampaign/continue-replay.lua')

Include('mod/SixStageCampaign/dialogue-emotions.lua')
