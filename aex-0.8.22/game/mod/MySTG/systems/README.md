# 资源系统试作

主模组 MySTG 默认启用；照常双击 G:\MySTG\start-stage5.cmd 或 start-mystg.cmd。Stage12Normal 的旧练习入口未改。

- 蓝点、绿点原掉落槽现在都产金币，每个 1 金币；金币与分数分开保存，不再增加旧信仰/点值。
- 消弹小点显示为黄点，每个 500 分，保留原来的运动和吸收行为。
- P 点保留；满 P 后每单位 100 分，沿用现有达到满 P 那次也转分的行为。初始 P、死亡掉 P 和掉落表均未改。
- 旧信仰收集连击停用，HUD 点值栏改为金币；旧实现和素材仍在引擎包中。
- 符卡奖分等其他来源保持现状；本次不作全局分数平衡。

配置：systems/resource-config.lua 的 enabled=false 后重启即可回到旧系统。starting_cards={'tap_shot'} 可试验点按射击；默认空列表，保持长按射击。该例每次按下允许一次现有武器发射调用，保留原武器弹数/冷却；冷却、对话或死亡期间的按下不缓存。不是花映冢蓄力系统。

卡牌接入：MyResources.cards 中声明规则，MyResources.equip/remove/has 管理持有，MyResources.rule 读取机制规则。状态在 lstg.var.my_resources（金币及卡牌ID表），随局跨关，新局重置。暂未加入商店、价格、随机卡池或正式获取途径，不自动装备例卡。未来规则在对应机制处接入，不通过散落的卡牌名称判断实现。冲突按卡牌ID排序，后者覆盖。

验证：python scripts/resources/verify.py（测试依赖位于 work/resource-test-deps）。实际试玩请检查金币与黄点识别、满P收P加分，以及例卡的按住/松开再按行为。原版美术暂用现有图标金色处理，数值为初版占位。
