# 第五面组装

双击 `G:\MySTG\start-stage5.cmd` 进入完整第五面。方向键移动，Z射击，Shift低速，X Bomb，Esc暂停。需要无敌时可运行 `powershell -ExecutionPolicy Bypass -File G:\MySTG\start-stage5.ps1 -Invincible`。

现有 `G:\MySTG\start-stage5-practice.cmd` 仍用于单独监测非符/符卡，无敌与结束后接下一张的选项保留。单卡入口直接进诹访子，不经过道中。

## 组装内容

- 关卡编号五面。道中是虹龙洞四面 Normal 的 MainFront、原版大阴阳玉、MainLatter；不搬四面关底山如。
- 关底接现有随机诹访子：15张符卡中抽4张，7个非符中抽4个；非符保持风神录原顺序。小小青蛙不输风雨及其非符继续排除。
- 背景复用已提取的虹龙洞二面 st02.std + st02wl.anm：40条STD指令、4个ANM程序、60个面片，保留滚动循环、2900帧后的动画变化、雾色/镜头变化、原生摇摆模式1及关底中断1。
- 普通敌机与大阴阳玉使用原 enemy.anm；敌弹使用原 bullet.anm 的类型5/7/8/18/19及对应颜色表、出生与消弹动画。诹访子使用风神录 stgenm07.anm 的本体与左右移动/回正动画。
- 不修改现有诹访子弹幕、血量1/10或每段30秒设置。虹龙洞新搬入的道中HP、时限与波次取原Normal脚本；大阴阳玉保留原脚本的不可受伤标志和2100帧超时，不擅自改成可击破。

## 掉落和清弹

保留原生type1火力道具、type2资金、type9消弹小点、type16/17/18/19资源小卡牌。资源小卡牌分别对应卡ID3/4/5/6，使用ability.anm script14与原卡图11/13/17/19。保留主掉落、额外数量、速破奖励衰减、散落范围、出生横坐标夹边、上抛/重力/终速、近距离吸附与上方回收线。type9保留分批显示延迟、上抛后自动回收。

道具拾取只发出 `Th18Stage5Host.onCollect(event)`，event保留type、card、source、x、y、tick；默认没有资金、火力、碎片或卡牌效果。后续TH18系统接这个接口即可，不必重写掉落。计数保留在Host.counts.spawned/collected。

敌机击破不自动清掉它发出的子弹。道中切段、道中Boss退场、关底入场按原ECL的etClear/etCancel和扩散清弹执行；纯消除与转小点分开。道中Boss击破/超时的两条掉落路径分开保留。原击破脚本有连续两次dropItems，原生只清main、不清extra，因此该分支保留P60/资金40，不自行“修正”为一半。

## 来源与文件

`route-source.json` 固定st04、st04mbs、default ECL源路径及SHA256；programs.lua由37个Normal子程序生成。`assets-source.json` 固定原图哈希和原exe表地址，data.lua保留原STD/ANM/精灵表。56张纹理原样复制，源目录只读。

执行模块：runtime.lua、projectiles.lua、route.lua；原图动画：anm.lua；二面背景：background.lua；敌机/道具/角色宿主：host.lua。入口集成仅涉及MySTG/root.lua和suwako5/stage.lua。

维护脚本在G:\MySTG\scripts\stage5：build-route.py、build-assets.py、verify-source.py、verify-resources.py、verify-native.ps1。构建脚本只更新生成数据；执行模块手工维护。

## 验证及边界

Lua5.1语法、所有引用ANM、全部二面背景循环和关底中断、Normal全道中和2100帧超时路径、原图/ECL哈希、既有诹访子卡池和数值检查通过。资源局部检查覆盖速破数量、重力、四类小卡牌拾取且不生效、消弹小点回收、清弹区分、敌死旧弹保留与清理。

原生运行分别检查人物/场景、前半道中、道中Boss击破收尾、后半道中和诹访子切换；最终完整超时分支也通过，原道中Boss在6276帧超时、道中在10258帧结束并进入诹访子；测试日志与截图在G:\MySTG\work\logs\stage5。自动测试的快速击破/截段开关仅由verify-native传入，普通启动器不启用。

这里接入的是选定Normal脚本与完整二面背景程序，不是整个TH18系统。原版商店、卡牌效果、资源结算、对话及音乐没有接入；继承当前项目的自机和操作。AEX负责最终投影、碰撞和透明混合，未做商业原作录像逐帧/逐像素比对。下一步试玩请重点核对大阴阳玉、后半绿色阴阳玉的发弹方向、二面背景转场和四种小卡牌外观。

2026-10-26 受击修正：自定义敌机帧更新需要把enemybase拦截的colli写入同步到引擎碰撞开关。已补齐；真实自机子弹验证首波小怪扣血、击破及原脚本掉落通过。此前整关快速扣血测试未覆盖这个连接，验证日志补充在work/logs/stage5/collision09-before.log和collision09-after.log。

2026-10-27 小怪血量调整：Cir00/01/02/03、Phantom01、GirlC01、GirlD01/02在创建时取原现值的1/10，覆盖上文关于道中HP沿用原值的说明。道中Boss和诹访子血量保持现状。实际数值与检查记录见work/logs/stage5/hp10.log；其余参数未调整。
