# 四面关底：鸟澄珠乌（Torisumi Horou）

本模块用于 MySTG 的四面关底，保留现有永夜抄道中和道中魔理沙。
角色罗马音为 Torisumi Horou，来自真珠岛六面 `BOSS_ID_HOROU`、`character/Horou/dotHorou.png`。
此前误选四面德雀坊紫鸾（Siran）的实现已经退出活动模块；旧文件留在
`G:/MySTG/work/zuu4/misidentified-siran/`，其测试结果不能证明本版本正确。

## 七阶段顺序

下表保留原作资料；当前已经另行调整的血量、受伤倍率与最新火力对照，见 [行为与数值核对](audit06.md)。

| 阶段 | 来源（Normal） | 源生命／秒数 | 源射击伤害倍率 |
|---|---|---|---|
| 一非 | 真珠岛 `06b_Attack01` | 5777／70 | 240% |
| 一符 | 橙符「砂漠色の熱風」`06b_Spell01` | 777／77 | 20% |
| 二非 | 真珠岛 `06b_Attack02` | 5777／70 | 200% |
| 二符 | 赤符「朱塗りの矢羽はお前を選んだ！」`06b_Spell02` | 777／77 | 22.5% |
| 三非 | 锦上京 `Boss3_at` 与 `Boss4_at` 同时发射 | 16000 有效生命／60 | 100% |
| 三符 | 锦上京「ストーンゴッデス」`BossCard7` | 12000／120 | 100% |
| 终符 | 「黄金の島に響け朱鷺の歌」`06b_Spell07` | 7777／98 | 70.7% |

终符前不另加非符，沿用用户确认的七阶段结构。
真珠岛自带的入场计时暂停、羽弹展开、延迟轨迹激光、二符追踪箭与方形散射、
终符核弹、音符、鸟使魔、激光与血量／时间发狂分别写入对应模块。
原作七色 Z Bomb 系统不在现有 AEX 自机中；共鸣入口按普通自机路径返回。

三非全部初速、变速目标按原非符乘 0.2，发射间隔、数量及弹源距离保留在各自发射任务中。
锦上京 type48 统一使用真珠岛 `BGW_CHRYSTAL_M`（369–376）原图、32×32 画幅、
半径4圆形判定；未加载锦上京菱形弹图片或判定表。
羽弹使用真珠岛 `bullet_wing.png`，其动画与碰撞参数独立记录。

## 启动

- `G:/MySTG/start-stage4.cmd`：原四面道中后进入本关底。
- `G:/MySTG/start-stage4-boss.cmd` 或 `start-zuu4.cmd`：直接进入七阶段关底。
- `G:/MySTG/start-stage4-final.cmd`：新关底终符。
- `powershell -File G:/MySTG/start-zuu4.ps1 -Practice stone -Invincible`：单阶段观察。

`-Practice` 可选 `all / non1 / spell1 / non2 / spell2 / non3 / stone / final`，
`-Seed` 可指定固定随机种子；默认不启用无敌或测试加速。

## 文件与当前状态

`patterns.lua` 为七阶段数据，`horou.lua` 为六面一非、二非、一符与共享机制，
`horou-spells.lua` 为二符和终符，`th20.lua` 为融合三非与石之女神，
`runtime.lua` 与 `host.lua` 负责调度、伤害及四面接入，`animation.lua` 负责原作身体动作表、书与翅膀的分部动画。
`source/` 保存原脚本，`source-reference.json` 保存角色身份与素材来源。

早期只写入、暂停验证的状态已由后续启动修复和本次限定检查更新；旧的 `native-all.log`、
`source-check.log` 属于误选角色或早期代码，仍不得当作当前七阶段验收记录。

本次核对见 [audit06.md](audit06.md)：石之女神保留120秒与血量／时间切换四段，修复穿屏边界、
源弹分组和Bomb0.25；补身体完整动作表、眨眼、书与平板、翅膀分段拍动／眼球／展开／离场。
当前另行调整的HP/倍率保留，石之女神16000→8000的首段耐久与原作12000→8000不同。
Lua51局部检查、Stone全时限四段、四层采样、二非／一符动画原生运行与截图已通过。
原始日志位于 `work/logs/zuu4/*audit06*`，脚本为 `scripts/zuu4/verify-audit06.py` 与 `native-audit06.ps1`。

这不是整局或七阶段完整弹幕验收。原版完整背景、切入、Z Bomb和跨引擎逐帧像素一致性仍未完成；
随机移动插值与出生特效仍有适配边界。最新血量对终符发狂阈值的影响也未在本次修改。
