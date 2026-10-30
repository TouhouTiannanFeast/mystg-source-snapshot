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

## 2026-10-27 背景原生机制复核

此前虽然读取了全部STD/ANM数据，但绘制时把type4树冠也作为世界XY平面处理、统一打开距离雾，并整体关闭深度；这不能还原原版树林。原生运行通过仅证明能运行，不代表画面已还原。此次说明覆盖此前的渲染实现描述。

- 原版type4树冠：先投影中心，再按镜头右方向计算尺寸，始终朝向镜头；只使用Z旋转，忽略脚本的X/Y旋转。原版type8地面/雾层则使用完整三维矩阵。已分别执行，并修正地面UV在X=pi之前的Y符号。
- 原版只给type8开雾，type4树冠关闭雾。原exe初始化FOGTABLEMODE=0、FOGVERTEXMODE=3，采用逐顶点计算后插值的线性雾；已按此执行，而非统一按像素距离染色。机制说明：[Microsoft Vertex Fog](https://learn.microsoft.com/en-us/windows/win32/direct3d9/vertex-fog)、[Fog Formulas](https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas)。
- 原版按层、STD实例顺序、实例内部面片顺序绘制，采用LESSEQUAL深度比较。type8写深度，type4测试深度但不写深度；alpha测试为>=1/255。之前开关式处理会出现透明矩形遮挡，现已补齐这些独立状态。
- AEX公开精灵接口把深度测试和写入绑定在一起，因此新增background-native.hlsl专门绘制st02的60个原面片。shader使用原三张纹理；geometry由background-shader.py从原STD生成。background.lua继续执行原STD/ANM时间轴，传入镜头、雾与树冠动画状态。未改原纹理，也未改共用anm.lua。
- source头位置仍是包围盒中心，不加入面片世界坐标。场景保留36度FOV、近30/远8000、模式1摇摆、树冠2900帧后移动/变暗、雾色渐变、512帧滚动循环和关底中断1。

原exe的11处指令检查和地址保存在background-reference.json、work/logs/stage5/bg11-native-mechanism.log。局部检查通过：60面片源顺序、朝向与顶点、原图哈希、时间轴/循环/中断；此前小怪HP0.1、碰撞修复和诹访子30秒保持。背景专项原生捕获180/2176/2688/3100/3400/4300/6000及关底中断前后9张图，无道中或关底战斗；本机稳定约60FPS。日志work/logs/stage5/bg11-source.log与bg11-native.log。

另已打开原版Normal二面Practice观察前段树林构图与移动；用户物理Esc停止computer-use后未再操作原版窗口。原版后段未逐帧对照，D3D9/D3D11的采样、精度和边缘规则仍可能有细小差异，不宣称像素完全一致。

复查命令：python scripts/stage5/verify-background.py；powershell -File scripts/stage5/verify-background.ps1。普通试玩入口仍是G:\MySTG\start-stage5.cmd。

## 2026-10-27 山谷露出与道中Boss衔接纠正

用户提供原版后段画面后确认：中央应是明亮山谷，暗树冠只保留在两侧。上一次仍错误地放大了树冠：native47f289从4b9138读取0.5、47f29f先乘投影单位长度，再乘sprite尺寸/STD比例，之后才使用居中锚点。因此STD512x435实际对应256x217.5的相机朝向贴片；此前漏掉这个独立0.5，造成树冠覆盖中央山谷。现已修正CPU顶点与实际shader，并把检查期望改成原生推导值。

另补齐原版背景相机的408x472视口、裁切至384x448弹幕区的投影关系，依据41b9fb从supervisor camera3(4cd478)复制相机。原图、原颜色及非背景参数不变。

五面采用四面道中，前半时长与背景来源二面不同。当前由五面实际MBoss创建事件开始播放二面原始转场片段，而不是提前按二面总时长播放完。事件前循环原始森林滚动片段；事件后从源时间2176开始原镜头/雾/ANM程序，保留滚动相位，不跳屏。树冠在事件后724帧开始移动/变暗，1224帧完成，两侧暗树冠和中央明亮山谷分开保留。单卡练习入口不等待道中Boss。

验证：原exe半尺寸指令与常量读回；事件门控、滚动连续性、原始渐变/循环/关底中断；六个背景专项实际画面（登场前、登场、+600、+924、+1224与后段），约60FPS。山谷中央亮度114、两侧42/18（同一张图不同区域取样）；14个非背景Lua文件哈希不变，普通小怪HP0.1、诹访子30s和碰撞修复保留。证据work/logs/stage5/bg12-{source,native,preservation}.log及bg12-*.jpg。运行验证：verify-background.ps1 -Valley；试玩仍使用start-stage5.cmd。

剩余画面问题：树冠尺寸纠正后，前段顶部两角可露出底色，需继续对照原版背景表面的覆盖/合成；本次没有通过更改原色掩盖它。当前完成的是用户指出的山谷露出及道中Boss转场衔接，不宣称完整背景像素已完全一致。

## 2026-10-27 顶部蓝色底色修正

此前记录的顶部两角蓝色已修正。根因是把STD13写入的全局清屏色用于内场景；原版内场景在41c461使用Stage+0x390的当前雾色清屏。STD8在41d630写runtime+0x384，runtime=Stage+0xc，因此两者是同一fogColor字段。现仅把背景填充RGB改为当前原始雾色，未加遮挡贴图或改变树冠、山谷、时序。前段顶部蓝色像素检查为0，六个背景事件画面运行通过；证据bg13-check.log、bg13-native.log及bg13-forest/valley.jpg。上文关于蓝色边角未修复的记录由本条覆盖。


## 五面道中Boss金字塔外观
大阴阳玉外观替换为锦上京 enemy/enemy_stone.png 的大号金色金字塔（sprite356..360，script294的8帧轮换）。仅替换MBoss绘制，沿用旧本体的出生缩放、透明度和最终64×64尺寸；不再绘制阴阳玉和双环。原ANM继续更新并用于原有离场判断；血量、时限、移动、弹幕、判定、掉落和其他敌机不变。来源见art/th20-pyramid/source.json；试玩入口start-stage5.cmd。

## 五面分阶段启动器
双击 `G:/MySTG/start-stage5-sections.cmd`，选择完整五面、前半/后半八个出敌组、金字塔道中Boss、诹访子随机卡组第1～8阶段，或指定非符/符卡；可勾选无敌和固定随机种子。
道中组和道中Boss入口会继续后续道中及随机诹访子。诹访子第N阶段入口先按种子抽取原八阶段卡组，再从第N阶段打至结束；固定同一种子可复现卡组。指定卡牌入口沿用旧观察列表顺序续打，区别于随机八阶段。
从道中组进入时跳过此前出敌组，不生成旧敌机/旧弹；后半直接进入山谷背景状态。分段练习不复现此前玩家操作造成的随机数消耗或场上残留。无敌只关闭自机碰撞，不主动清弹，结束/退出恢复。普通完整入口、既有单卡入口及血量/时限/弹幕/素材均保留。
命令行示例：`powershell -File G:/MySTG/start-stage5-sections.ps1 -From mid -Invincible`；后半第1组为 `-From road-4`；关底第三阶段为 `-From boss-3 -Seed 123`。道中组编号road-0..7，其他起点full/mid/boss-1..8/card-卡牌ID。
验证：局部Lua51源脚本入口/实际init流程/无敌恢复、Windows PowerShell5语法与启动参数检查通过；日志work/logs/stage5/sections22-*。未启动整关，实际画面与完整操作等待试玩。


## 自然越界静默回收
道中和诹访子普通弹自然越界时标记offscreenRemoval，宿主仅注销对象，不调用会生成BulletBreak的框架bullet.del。主动清弹、Kill特效和掉落保留；越界范围、延迟回收、反弹/回场规则及激光行为不改。
