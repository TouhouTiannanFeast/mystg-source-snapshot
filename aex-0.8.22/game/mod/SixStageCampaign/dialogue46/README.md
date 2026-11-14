# 四面／六面剧情

只在 SixStageCampaign 中加载，原始 MarisaMixed／NinaStage6Normal 文件保持不变。用户原稿归档共91句，分11个节点；按最新要求，第二次大笑改为纯声音，因此实际显示90句／10段对话，加1个声音节点；除用户确认的「公主，有何贵干？」归神奈子外，未改写台词。`text.json` 保存逐句原稿及表情，`data.lua` 只增加分页和图层定位。

四面：月兔战前7句、战后12句；魔理沙战前10句、战后22句。月兔开战前插入非战斗对话卡；战后在后半道中开始前播放。魔理沙在原入场移动结束后播放战前剧情，对话后等待90帧开战；终符结束后、清理道路／音乐之前播放战后剧情。普通练习中从一非（ssg）开始包含战前剧情，其他阶段略过战前；完成终符仍播放战后剧情。

六面：开幕3句，在第三句之前播放一次奶蛙笑声；道中诹访子战前3句、败后2句；“早苗”战前7句；第二次大笑只随机播放原有4种声音之一（独立表现随机数，不消耗攻击随机流），不调用对话界面或追加停留；早苗败后11句；神奈子入场13句，再进入已有神奈子终符。现有Nina登场演出中的场内角色保留，对话插在演出收尾。月兔／诹访子战前使用非战斗卡，模型和背景照常更新；对话期间禁止自机射击／Bomb，阶段发弹任务尚未开始，道中调度器等待剧情。诹访子退场期间同样阻止下一批敌人提前启动。对话后保留原有资源和240帧关底拾取窗口。

界面沿用三面：风神录原红蓝底纹，原系统MS Gothic及缺字宋体；Z松开重按翻页，Ctrl连续跳过。场景按1倍正常更新，不冻结游戏；战斗快进倍率在剧情结束后恢复。

素材：辉夜继续使用真珠岛自机立绘。魔理沙改用本地TH15 `pl01.anm`；「你谁啊。」使用图1对应的`face_pl01no`（微张嘴、无头顶符号）。败前“早苗”使用TH20 EX面 `st07enm.anm`的渡里妮娜（原作名渡里ニナ，金发、坐在贝壳上），败后早苗和神奈子继续使用TH10 `stgenm05/06.anm`。所有诹访子对话立绘均使用用户图2 `frog-user.png` 原字节，按原透明区域(260,122,446,960)绘制，保留透明通道，无白底／黑边。铃瑚／清兰取自本地TH15 `st02enm.anm`／`st01enm.anm`。所有PNG原字节保留，身体／表情及上下半身分层在运行时绘制，未制作AI图像或覆盖原图。TH15导出的PNG包含X/Y定位偏移填充，铃瑚(26,0)、清兰(180,112)；按ANM有效THTX区域裁取262×186／222×212进行加载，排除导出填充白条并对齐表情。TH15魔理沙身体偏移(120,0)、表情(236,40)，按差值对齐；TH20 EX面妮娜表情使用(310,83,304,213)有效区域。来源、定位依据和哈希见 `source.json`；TH10／15原始ANM及提取记录位于 `work/logs/six-stages/dialogue46-20261111/source`。

实现：`../dialogue46.lua` 提供剧情和仅内存中的源语句替换；`../dialogue3.lua` 增加可选的多角色／分层绘制；`../root.lua` 加载。未修改攻击卡血量、时限、弹道、数量或资源规则。

检查：`verify-dialogue46.py` 核对91句、11段、分页、原PNG哈希、定位范围及全部5个适配源文件的Lua51语法；`verify-dialogue3.py` 检查共享界面改动后的三面控制流程。`native-dialogue46.ps1 -Stage 4/6` 使用显式测试开关，提前结束道路／战斗以检查全部剧情触发、实时更新、自机禁攻、笑声事件、阶段交接与240帧拾取窗口。相关截图已查看，设置及存档已恢复；这不是完整手动弹幕通关，回放输入同步未单独检查。

启动：`G:/MySTG/start-six-stages.cmd`，选择完整四面／六面。日志及截图：`G:/MySTG/work/logs/six-stages/dialogue46-20261111/`。

2026-11-11 portrait revision verification: native s4pre page3 matches supplied Marisa reference; s6pre page4 shows Nina; s6midpre shows the supplied transparent frog; s6post retains Sanae. Voice-only battle laugh asserts no active dialogue overlay and starts once before non1. Bounded Stage4/6 paths pass; no full playthrough. Logs verify-portraits.log/native-4.log/native-6.log; settings/save restored.

2026-11-11身份更正：前次错误地把st06enm磐永阿梨夜标成渡里妮娜。本次直接核对原作omake.txt的角色设定，EX面Watari Nina对应st07enm。新增watari-nina-bs/no.png保留原PNG字节，原始表情偏移(310,83)，304×213；败后早苗及其他角色／台词不变。目标Boss入场实机截图已检查，未运行道路或战斗；日志native-6-portrait.log与verify-watari-identity.log。
