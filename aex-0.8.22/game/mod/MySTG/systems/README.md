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

## 2026-10-27 隐藏灵力、固定满火力

MySTG资源模式默认fixed_power=400，即4.0。HUD不再显示灵力标签、数字和对应分隔线；开局/跨关进入自机系统、每帧及中弹后立即恢复400，四个子机保持。GetPower不再增减火力；正数P拾取保持既有满P每单位100分，负数扣P不减火力或分数。原道具贴图、掉落数量及TH18道具暂不生效接口均未改。enabled=false仍回到旧模式。此项覆盖上文关于初始P和死亡掉P未改的说明。

实现仅在resource-config.lua、resources.lua、resource-ui.lua；显式测试power-probe.lua只在resources_power_test启用。scripts/resources/verify.py通过初始化/死亡/帧恢复、满P转分、金币/卡牌/输入和legacy检查；verify-power.ps1实际运行确认power400、support4、原死亡扣命仍保留、P拾取后400及HUD隐藏。日志work/logs/resources/power14-{unit,native}.log，截图power14-hud.jpg。

原版血量与伤害：以本关采用的虹龙洞四面Normal为例，普通阴阳玉/幽灵300～500，大阴阳玉1200，中型妖精1800/2000/3200，后半妖精2700/8000；当前依此前要求为这些值的1/10。原版满P为4.0，但攻击数值依机体和高低速不同。零售pl00.sht灵梦满P主弹14×2/3帧；高速追踪弹20×4/7帧；低速针弹7/8合计60/3帧。全弹命中、未扣单帧封顶的发射表理论值约1245.7/1760 HP每秒；当前AEX灵梦同条件约81/96。原版90的每帧伤害上限不是DPS。原始四个SHT的哈希、4P发射表与估算边界见work/logs/resources/power14-th18-reference.json。未调整本项目子弹伤害。
# 2026-10-27 原版血量与火力

灵梦普通射击与Bomb威力由 `th18-fire/runtime.lua` 接管，来源为虹龙洞零售版SHT与原程序伤害源逻辑；数值、验证和画面适配边界见 [th18-fire/README.md](th18-fire/README.md)。隐藏灵力、锁定4.0继续有效。第五面道中小怪恢复ECL原血量；诹访子的风神录来源非符/符卡恢复Extra血量，DS/天邪鬼血量及30秒时限保持当前值。

