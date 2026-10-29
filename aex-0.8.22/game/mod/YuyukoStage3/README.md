# 幽幽子三面关底：独立测试

启动 `G:/MySTG/start-yuyuko3.cmd`，直接进入六阶段关底。
方向键移动、Shift 低速、Z 射击、X Bomb、Esc 暂停。
默认完整六段、灵梦B贯穿机体、8残机、满火力、3 Bomb；默认不启用无敌或测试加速。

单段观察：

```powershell
powershell -File G:/MySTG/start-yuyuko3.ps1 -Practice spell1
powershell -File G:/MySTG/start-yuyuko3.ps1 -Practice spell3 -Invincible
```

`Practice`：`all / non1 / spell1 / non2 / spell2 / non3 / spell3`。
`-Seed` 固定本模块随机种子。此模块独立于现有关卡，未接入三面道中。

## 顺序和来源

| 阶段 | 来源 | 本入口生命 / 时限 |
|---|---|---|
| 一非 | TH07 Normal 二非，Sub34 + 周期 Sub35 | 29000 / 60秒 |
| 一符 | 亡舞「生者必滅の理 -死蝶-」，Sub50/51，Normal | 3000 / 65秒 |
| 二非 | LE04 Shion_07「吸魂」，Normal，0050c300 | 15000 / 70秒，无标题 |
| 二符 | LE04 Shion_03 生死「Eros Thanatos」，Normal，00508870 | 8000 / 70秒 |
| 三非 | TH07 Normal 四非，Sub38..42 | 19800 / 60秒 |
| 三符 | TH07 Easy「返魂蝶 一分咲」，Sub62、64..71及原生EX回调 | 67秒耐久，射击不能提前结束 |

一非生命取源脚本 32000→3000 的差值；三非取22000→2200差值。
一符继承源回调阈值3000。连缘生命使用Boss初始化表的基值15000/8000，
**没有套用连缘原引擎的千倍生命单位、队伍、路线、装备和模式倍率**；
自机现使用下述灵梦B原始伤害单位，伤害与击破秒数仍受命中及Boss防御影响。
TH07一符射击伤害按源逻辑 /7，三段TH07临时防御按源逻辑 /9。

## 本轮实现

- 一非保留十一帧周期三路弹与逐渐缩短间隔的自机狙大玉。
- 一符保留三帧周期、四族交错、红大玉停顿再狙、蝶弹停顿转向和旋转反转。
- 二非移除符卡标题和符卡身份，保留50帧两族发射、前100帧左右弯曲、
  收缩范围外渐隐并转为脉冲透明度。
- 二符保留两圆的旋转位置、不同发射时点和数量、排斥后吸引的顺序及一次加速。
- 三非保留四个周期弹组、移动时发射、蝶弹环和60帧停顿再狙。
- 三符保留Easy起始20发及每轮增加3发、六组蝶环、六束起始激光及后续每轮增加2束、
  激光预警/扫动和弹幕变向、67秒耐久。
- 原始幽幽子图、妖妖梦弹图、连缘b003/b010/b012弹图分别载入。
- 阶段结束、退出与重开会清理模块拥有的子弹、激光、调度和圆圈效果。

## 验证及边界

`scripts/yuyuko3/verify.py`：单一Lua 5.1后端语法检查、六段完整时长调度、
首波数量和关键时点、连缘透明状态/吸引加速、有限数值、清理与重置。
`scripts/yuyuko3/verify-native.ps1`：实际引擎六段各900帧、阶段切换、截图、清理与正常退出。
另以 `-Practice non1 -Shoot` 验证真实自机子弹能够扣血。
原始日志及六段截图在 `G:/MySTG/work/logs/yuyuko3/`。

这是依据本地原脚本/反汇编和TH07引擎参考源码进行的Lua跨引擎移植，
尚未与原作录像或运行轨迹逐帧对照，不作原版精确复刻声明。
随机数、原作自机、擦弹、Bomb反馈和出生动画仍受AEX运行方式影响；
连缘圆圈特效简化为轮廓，未导入原作背景或音乐。
TH07 EX1原生回调对部分颜色没有显式初始化转向量：这里首次用0并保留回调遍历中的前值，
不保证复现原程序未初始化栈值。激光保留源代码的预警/收尾中点小判定、
主发射阶段整束判定及收尾前30帧仍可判定的规则；AEX自机判定与擦弹反馈仍不同。

`source/reference.json` 固定来源路径、SHA256、阶段身份与贴图映射。
`source/th07-selected.ecl.txt` 保存指定源段；连缘的C伪码和汇编成对保存。
TH07参考来自 https://github.com/some100/th07 ，固定提交
`4878bf0e42a9280ef44735eb0517d4fda7cb6e04`，许可证随附。

下一步：先完整试玩一次，重点记录「亡舞」停顿转向、无标题二非的渐隐、
「Eros Thanatos」两圆改弹、终符激光预警与耐久压力；再依据实际记录决定是否调整。

## 2026-10-29 自机机体与原作火力尺度修正

依照用户此前在“设计随机符卡抽取机制”中确认的原则：敌机保持原作血量单位时，
射击也按原作平均秒伤适配。本入口采用与一二面相同的风神录灵梦B机体：
原 `pl00b.sht` 射击行、四子机位置、24/28弹速、16帧循环内每3帧发射和原贴图。
本体弹普通命中消失，子机御札贯穿，每颗御札对每个敌人只扣一次血。

一二面的伤害缩放3/28服务于其已缩放血量；本入口使用原始伤害缩放1。
满P每批总伤害52，每16帧6批，名义全弹路命中输出为
`52 × 6 / 16 × 60 = 1170血/秒`。这以所选风神录灵梦B为基准，
不混用此前虹龙洞灵梦高速/低速机体的秒伤。
Boss的/7符卡防御、/9临时防御及耐久终符机制保留，因此实战扣血低于原始发射总量。
本轮未修改Boss生命、时限、弹幕、Bomb、被弹、掉落或Power经济。

运行时通过实际自机逻辑系统绑定射击，避免自机扩展插件重载覆盖机体设置。
单一Lua5.1后端验证SHT/贴图哈希、原表一致性、1170秒伤、贯穿重复抑制及迟加载绑定；
原生引擎双靶验证各100→90，并在一非900帧中执行高速/低速射击：
实际扣血11663.4，旧默认射击同条件基线856.7111。
两者均使用一非原29000血、60秒及同一弹幕。未重新遍历其余阶段或整关。
证据：`work/logs/yuyuko3/player02-{unit,native}.log`。

### 2026-10-29 试玩反馈修正（FIX-03）
- 保留用户手调 runtime.lua 的全部 hp/time/hold 数值。
- 一符取消对 TH10 自机伤害再除以7的适配，保留开场 hold 期间 /9。该选择是混合机体适配；不代表 TH07 原作没有符卡减伤。此前一符5000血/35秒在 /7 下理论输出也只有约5500，实战易超时。
- 二非删除变透明和透明度脉动，保留前100帧的弯曲。
- 二符 type12 剑弹显示换成一二面同款 TH10 鳞弹，使用 art/scale-0..15.png；沿用原 type12 运动和判定。
- 二符两种圆周发弹追加20帧渐显，期间不碰撞；速度、生成节拍和圆周位置不变。原始00508870确有400半径圆周发弹与0xb效果调用；20帧是本项目显示适配，原版出生动画时长/效果未确认。
- 返魂蝶激光偏转保留蝴蝶弹型，不再切换针弹。参考源码 EX8 本身确有切换模板5的操作，此处按用户要求改编，不宣称原作完全没有此操作。
- 局部验证：python scripts/yuyuko3/verify-fix03.py，日志 work/logs/yuyuko3/fix03.log；检查语法、一符常态/开场伤害、二非不透明和曲线、二符180枚圆周弹渐显标记及20枚鳞弹、返魂蝶实际激光偏转后保持蝴蝶。未启动全关，渐显与贴图效果待真人试玩。

### 2026-10-29 FIX-04：原位出生特效与蝶弹
- 替代FIX-03临时渐显。00508870.asm确认0xb调用第一个double为009ecd50=1.0，即variant1；0040e0c0初始化固定位置、scale4、alpha50；00414f30每帧scale减0.3、alpha加15，10帧结束。0060f870确认variant1使用b033原图、20x20分片（8色），已复制为art/le04-birth.png。
- 特效使用源col（0/1/2），不跟随飞行弹移动。飞行弹本身立即按原轨迹运行，不增加无敌/延迟；不再有revealFrames。所有二符出生调用（含type12）均有特效。保留静态出生光点与飞行弹分离的原逻辑。
- 二非、二符的b003小圆弹（半径2.5）和b010大圆弹（半径8）飞行显示统一换为TH07蝶弹，朝向每帧随b.angle更新；保留各自原判定、速度、数量和曲线。二符type12继续显示鳞弹。
- 一符伤害本次未再改动。TH07 EnemyManager.cpp中原作符卡对逐帧汇总射击伤害/7（小于等于7且非零时取1）；不是血量回复。混合TH10机体已取消额外/7，开场/9仍保留。
- python scripts/yuyuko3/verify-fix04.py通过：语法，出生原位/缩放/alpha/10帧消失与飞行弹独立运动，两批200枚弹的出生数量，非符隔离，实际Shot:frame四个方向的蝶弹/鳞弹贴图与原判定。日志work/logs/yuyuko3/fix04.log；未做实机画面对照，渲染顺序精确到原作帧的差异尚未验证。

### 2026-10-29 FIX-05：返魂蝶突然变向的根因修正
- 重要更正：此前README与FIX-03关于返魂蝶调用EX8的说法错误。Sub70/71执行ins_124([10000])，124实际为ECL_SPAWN_ITEM；ECL_RUN_EX_INS为121。源码枚举见source/th07-EclManager.hpp，分派见source/th07-EclManager.cpp；后者实际调用g_ItemManager.SpawnItem。Sub70/71无ins_121/122。
- 移除th07.lua的familiar错误实现及其调用：它把道具种类8/0/1误认成EX8/EX0/EX1，导致激光附近突然转向、错误变针弹，以及后续全屏重设速度与曲线。FIX-03仅取消针弹外观，未解决误译，本次纠正。
- 保留Sub64/65/66的蝶弹自身渐进曲线与加减速、所有发弹数量/时间/激光及用户调参。原使魔掉落道具仍未接入当前attack-only宿主，本次未扩展资源系统。
- 局部验证python scripts/yuyuko3/verify-final05.py通过：来源opcode与子程序调用核对；当前返魂蝶40秒完整2400帧，4605枚弹/66激光，913625次逐帧弹轨迹检查，无突然转向/外部改速/弹型转换；最大单帧转角0.0104719755弧度，符合原曲线指令。Lua语法通过；runtime/root/le04/player相关文件SHA256保持一致。日志work/logs/yuyuko3/final05.log。未启动实机，最终画面需用户试玩。

### 2026-10-29 完整三面：LE03道中 → 幽幽子（FULL-06）

双击 G:/MySTG/start-stage3.cmd。窗口可选完整三面、每个道中出敌时间点、关底六阶段，勾选“开启无敌”后开始。选择起点后会继续至关底结束，不会只打选中的一张卡。

命令行示例（G:/MySTG目录）：
- .\start-stage3.cmd -From full -Invincible
- .\start-stage3.cmd -From road-9500 -Invincible
- .\start-stage3.cmd -From spell2 -Invincible
- .\start-stage3.cmd -From road-4500 -Seed 42
- .\start-stage3.cmd -NoMenu（完整三面，不弹选择窗口）

road-N支持任意0至9500帧（60帧一秒）；菜单列出原表全部不同出敌时间点。道中中途启动为空场，跳过此前波次；不模拟此前残留敌机/子弹、资源消耗和随机数历史。Boss阶段中途启动同样用默认8残机、3Bomb、满P。

道中源：G:/MySTG/aex-0.8.22/game/mod/Le03Stage4Normal的当前可玩版本；constants/movement/firing/runtime/schedule和art逐文件原样复制至road/，host.lua仅移除独立stage/重复自机加载并加入衔接。未使用G:/Modified_STG的开发副本覆盖当前可玩版本。敌弹/妖精素材、HP、弹速、出敌表均保留；道中仍有原移植记录里的背景、音乐、掉落和原作特殊暂停未完整还原等限制。

贯穿灵梦B与当前幽幽子完全共用player*.lua、runtime.lua、th07.lua、le04.lua，不维护第二份Boss数值；未来手调本目录runtime.lua即可同时影响完整入口和原Boss入口。旧start-yuyuko3和start-le03-normal仍可单独试玩。

衔接：道中全部敌机自然结束后删除道中所属敌机/子弹/激光，等待一帧完成删除，再创建幽幽子；不重建自机，不重置当前火力/残机/Bomb。无敌覆盖道中及关底。

验证：python scripts/yuyuko3/verify-full06.py，源代码/贴图哈希一致、实际road.run末波9500→10822结束且清理、无敌保护、六种Boss后缀序列及旧单卡入口保持、Lua语法PASS；start-stage3.ps1语法PASS。日志work/logs/yuyuko3/full06-unit.log。实机接缝结果另记。

FULL-06实机结果：scripts/yuyuko3/verify-full06-native.ps1通过；最后道中波次→清理→六阶段Boss（每阶段60测试帧）→正常退出，日志work/logs/yuyuko3/full06-native.log。测试后精确恢复原userdata/setting.json。未跑完整道中长流程，也未逐个启动菜单63波；菜单语法和路由数据已检查，GUI实际交互待用户试玩。

2026-10-29启动器编码修复：Windows PowerShell5.1将无BOM UTF8中文误读为ANSI，导致双击解析失败；现为UTF8 BOM，cmd显式STA并在错误时暂停。实际powershell.exe的解析及70选项菜单构建已通过，work/logs/yuyuko3/launcher07.log。

### 2026-10-29 LASER-08：返魂蝶激光外形
- root.lua新增Beam:render，仅替换显示：按原ins82类型1→ANM script11→sprite48+color，使用现有原图y3.b3.{4,8}整张拉伸，以光束中点定位、横向width/16、纵向length/16，原图透明边缘形成收尖端部。此前只用AEX激光中段且端部长度0，造成矩形截断。
- Beam:frame、runtime.lua和所有激光长度/宽度/旋转/预警/消退/判定保持现状。
- verify-laser08.py通过，实际渲染方法两色/四方向/预警消退宽度/中心和缩放检查、Lua语法；work/logs/yuyuko3/laser08.log。
- 原生仅返魂蝶900帧正常退出，native-spell3.log；截图yuyuko3-spell3.jpg已查看（截图点为细预警/过渡光束，未覆盖完整粗光束画面），不宣称完成原作逐帧画面对照。

### 2026-10-29 SHARED-09：完整入口共用道中源目录
- 替代FULL-06复制副本方案。YuyukoStage3/road/host.lua现在仅为薄适配器，直接Include mod/Le03Stage4Normal/中的constants、movement、bullet-style、firing、runtime、schedule和host；素材也从该目录读取。旧road文件/素材保留但不再加载。
- 原道中root.lua里的显示/敌机/子弹宿主原样提取为同目录host.lua，两个入口共用。bullet-style.lua和enemy-art.lua仅增加资源根前缀，未改最新速度、波次选择、贴图和动画数值。后续修改该道中目录的上述公共文件，重启完整入口即可生效；无需再复制。
- start-stage3.ps1波次菜单也改为读取Le03Stage4Normal/schedule.lua。Boss、自机和手调runtime.lua不变。
- verify-shared09.py通过实际共享Include路径、末波运行与清场、无敌和Boss后缀、Lua语法检查。实机shared09-integration.log确认直接加载最新版东方敌机/米弹/鳞弹/蝶弹素材，道中9500→10822清场接入关底；该次运行在二符开头结束，未取得六阶段完整退出断言，因此只计共享模块和接缝验证通过，不计全关通关。
- 原道中独立入口360帧原生启动/正常退出PASS：shared09-standalone.log；两个入口均已检查。

### 背景（STAGE3-BACKGROUND-10）
- 三面完整入口与幽幽子独立练习入口均使用天空璋四面背景；符卡期间显示妖妖梦幽幽子符卡背景，收符后由Boss系统恢复场景背景。
- 场景来源：TH16 st04.std、st04wl.anm，三层贴图、相机/雾色变化和UV滚动；符卡来源：TH07 eff06.anm，滚动底层eff06b.png与树影eff06.png。
- 原始脚本导出保存在source/background/；资源为art/background/。播放器限定于这些背景指令。STD FACE首字段是标记，后三字段才是坐标。
- 任意道中入口按所选帧快进背景；直接Boss练习使用原背景Boss循环起点8130帧。只接入背景，不修改战斗数据。
- 检查：python scripts/yuyuko3/verify-background10.py；局部非符/符卡实机650帧检查及截图见work/logs/yuyuko3/background10-*。未逐帧对照原作整关背景演出。

### TUNING-13 (2026-10-29)
- 二非仅把nativeColor=5的蝶弹显示为紫色y3.b8.2，不影响二符和其他颜色。
- 终符实际位移速度=原速度乘0.75后四舍五入到两位小数；沿原方向移动，保留原速度指令/角度、发弹时序与数量。激光未改。例：0.5→0.38，0.8→0.60。
- 二符以前仅绘制轮廓，现补半透明红/蓝色面。颜色依据源效果0x4b的255/55/55与55/55/255；填充alpha40为本移植显示值，未宣称原作完全同等渲染。圆心、半径与判定不变。
- 验证：Lua51逐帧175013次位移缩放/角度和弹数对照PASS；二符650帧实机及填色截图PASS。日志tuning13-unit.log、tuning13-spell2.log。

### MUSIC-14 (2026-10-29)
- 道中：それぞれの思惑と足跡 - トリック・ノスタルジー；Boss：幽雅に咲かせ、墨染の桜 ～ Border of Life - 黄昏フロンティア, 上海アリス幻樂団。使用用户指定Tencent目录的MP3，保留源文件。
- music/road.wav、boss.wav为44100Hz双声道PCM转换，整曲循环；来源哈希与时长在music/manifest.json。未指定独立循环点，整曲结束从头播放。
- 完整三面道中入口播放road，进入幽幽子时切boss；直接Boss练习播放boss且不在换符时重启。结束/离开停止，暂停后可恢复。
- 局部检查music14-unit.log及原生解码/道中到Boss切歌/暂停恢复music14-native.log均PASS。未运行整关或等待完整歌曲播放完毕。

### POWER-15 / SMALL-16 / HP-17（2026-10-29）
- 固定4P，隐藏火力栏并屏蔽P道具；掉命不降火力。
- 道中HP改为风神录同类大小妖精量级：小型80/100/120，普通大型600，后段较强大型1500。临时道中伤害×3已撤回，最终与Boss均为原射击倍率1。HP源记录在共用Le03Stage4Normal/source/health-reference.json。
- 道中曲音频增加6.02dB并限峰0.98，时长/循环点不变；Boss曲未改。
- 关底TH07 type3小玉使用TH10原版16色sprite48..63。来源字节哈希位于art/th10-small/manifest.json。仅活体小玉图像选择改变；返魂蝶激光仍使用y3.b3原图，连缘蝶弹/鳞弹及碰撞不变。
- 检查日志hp17-small16-unit.log、hp17-native.log；已核对隐藏火力栏截图。原生600血大妖精约1.28秒击破，掉命保持4P；未跑全关。

### 位置显示（POSITION-HUD-18）
完整三面和Boss测试入口底部常驻位置文字：道中为 `ROAD / WAVE 26/63 / FRAME 3100`，波次按去重排序后的出敌时间计算，开场首次出敌前为0/63；检查点启动保留原时间轴。Boss为 `BOSS / NON 2 / FRAME 123` 或 `SPELL 2`，帧数在每个非/符开始时重置。使用原有底部文字位置，不改战斗数据。重启 start-stage3.cmd 生效。局部验证：scripts/yuyuko3/verify-position18.py。

### SPELL2-SCALE-19
二符链状type3弹由蝶弹贴图改为现有风神录鳞弹y3.scale，颜色/飞行朝向保留；二非蝶弹及二符原type12鳞弹不变。出生动画、判定及运动数据不变。局部Lua51语法和8色实际Shot.frame选择检查PASS，work/logs/yuyuko3/scale19.log；未启动实机。

### SPELL2-SCALE-20：纠正SCALE-19范围错误
SCALE-19错误地将二符圆周type3蝶弹全部换为鳞弹，已删除该覆盖行。现在圆周type3恢复蝶弹，Boss本体type12发射组继续使用鳞弹；颜色、朝向、判定和运动均保持。实际Shot.frame两类8色映射及Lua51语法检查PASS，日志scale20.log，未启动整局。SCALE-19的type3“链状”归类错误，以本条为准。

### SPELL2-SCALE-ASSET-21：实际纹理纠正
前述SCALE-20仅确认资源名，未验证图片。旧art/scale-*.png实际来自Stage12 arrow（16色，原加载错误写作16x14），不是道中当前使用的TH10鳞弹。现在y3.scale加载独立art/th10-scale/{0..7}.png，逐字节复制道中TH10彩色鳞弹，按实际14x16完整加载；type12用nativeColor%8对应蓝/青/绿，圆周type3映射保持。旧文件保留。仅二符650帧原生运行成功，600帧截图scale21-spell2.jpg已查看，本体周围明确显示鳞弹。8色原图/尺寸及实际Shot.frame检查PASS，scale21-unit.log；无战斗参数改动。

### REWARDS-ENTRY-22（2026-10-30）
二符被击破或超时结束时在Boss位置掉1个完整残机；每次进入二符最多一次，不要求无伤收符，其他阶段/提前清理不发。共享道中第30波被击破或自然离场也掉1完整残机，开场10只小妖精新增20帧缩放渐显；现有战斗数值不变。修改主安装，start-stage3.cmd重启生效。局部Lua51真实card.del与道中奖励去重/超时隔离、出场动画值检查PASS；work/logs/yuyuko3/reward22-unit.log。未启动整局。
