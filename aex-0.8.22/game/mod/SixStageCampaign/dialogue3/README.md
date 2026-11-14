# 三面死宛／辉夜剧情（2026-11-11）

本对话只作用于SixStageCampaign。完整三面（含前／后半道中检查点接完整关底）在道中结束后等待60模拟帧，沿用原60帧飞入过程，在入场精灵仍留场且Boss战斗对象尚未创建时播放战前对话；对话结束再等待90帧才创建Boss并开始一非；六阶段全部结束，原关卡清理和120帧等待完成后、自动淡出开始前播放战后对话。对话结束才继续原有流程，随后保留额外240帧可操作拾取时间。

用户原稿为战前17句、战后15句。原句、标点、空格保留；Markdown中的转义 `\~` 按字面 `~` 显示。只做排版换行，最长战后一句分两页，最终为战前17页、战后16页。正文与表情映射在 `text.json`，实际排版在 `data.lua`。

**身份更正：死宛是灵烈传第6组立绘 `img/talk/talk_06_*.png`**。原作 `text_dat/talk_dat/talk_6_1_0.txt` 的说话人编号6明确标为シオン。先前预览中误认的第16／17组是国主雀巳相关立绘，未进入模组资产。已直接从 `G:/TouHou/Le03_1_21a/dat.led` 提取第6组03、04、06、07、08表情的原PNG字节：沉思／败后、开心、带音符的调笑、平静、眨眼。

辉夜按用户更正采用**真珠岛自机对话立绘**，不是魔宝城／宝天京或永夜抄立绘。从本地HSoB `img/img.dat` 中 `character/Kaguya/kaguya{1,5,7,11,13,21}.png` 提取原PNG：普通、疑惑／担忧、冒汗省略号、惊疑、无奈、生气。表情按各句情绪分配，未重画或合成表情。

对话底纹直接来自风神录 `ascii.anm` 的 `ascii/ascii.png`：sprite228（0,88,256,40，红）与229（0,152,256,40，蓝）。辉夜用红底，死宛用蓝底；按当前画面和中文两行排版缩放。未制作替代对话框美术。

风神录EXE调用Windows系统 **ＭＳ ゴシック／MS Gothic**，原游戏包没有内嵌TTF。这里沿用本机同一 `msgothic.ttc` 字库；原稿有40个字形不在MS Gothic的第一字面中，按本机MS Gothic的FontLink中包含的宋体 `simsun.ttc` 补字。字库来源明确为系统文件，未声称它们是从风神录数据包导出。正文采用当前引擎对应18屏幕像素的加载字号，逐字阴影；非发言者压暗，切换发言时平滑提亮。

按 **Z** 翻页，按住 **Ctrl** 快速跳过。开场按住射击Z不会自动跳掉第一句，需松开再按；持续按住Z不会连续翻页。剧情按正常界面速度运行，F7的战斗快进不会加速剧情。剧情期间游戏正常运行，自机可移动、道具继续运动和拾取、背景与场上对象持续更新；只让源关卡任务等待剧情，不启动下一阶段。道中结束到一非开始前一直禁止自机射击和Bomb，入口处清除已有自机子弹；对话结束后的90帧也保持该限制。剧情期间每显示帧运行一次模拟，结束后恢复原战斗快进倍率。临时隐藏Extend／Bonus等提示，结束恢复。从一非练习进入时，沿用原60帧飞入精灵播放战前剧情，结束后等待90帧开战；其他Boss阶段练习跳过战前剧情。练习模式在终符结束后同样播放战后剧情。三面Boss的显示名为“死宛”；原攻击、符卡、场内身体素材、自机射击、奖励、血量与阶段顺序未改变。

实现文件：父目录 `dialogue3.lua`；`campaign.lua` 增加可选剧情渲染、正常速度更新、阶段完成、源任务收尾和源文本加载接口；`dialogue3.lua` 仅在内存中精确替换三面源文件的入场等待与精灵删除块，原始模组文件保持不变；`root.lua` 加载模块。来源档案／原PNG及字体SHA256见 `source.json`。

验证：

- `G:/MySTG/scripts/six-stages/verify-dialogue3.py`：原稿32句逐字符拼接一致；所有分页不超过两行／每行20个全角单位；只使用Shion06组；源文件哈希；实际控制器的按住Z、松开重按、Ctrl跳过、8倍战斗下正常剧情更新、中途练习跳过战前但保留终符后剧情、切面取消；战后任务收尾与240帧等待顺序。
- `native-dialogue3.ps1`：真实引擎战前17页→原关底六阶段→战后16页→240帧拾取路径通过；正文、双方发言／明暗、正确死宛立绘及战后场景截图已查看。该探针在测试标记下提前结束道路和各卡，不是完整弹幕通关验证。
- 测试后恢复 `userdata/setting.json` 和连战存档 `User.json`。日志、已检查截图：`G:/MySTG/work/logs/six-stages/dialogue3-20261111/`。剧情回放按键同步尚未单独验证。

仍用 `G:/MySTG/start-six-stages.cmd` 进入完整三面体验。

2026-11-11 live-timing verification: native asserts roadGap=60, original flight=60, combatGap=90; scene/player timers advance1f during story even with8x battle, entrance remains visible, held shooting produces no player bullets. Full pre17/post16 sequence and240f handoff pass. Only bounded trigger path tested.

2026-11-11 practice verification: native non1 entry completes pre17pages ->6 forced cards ->post16pages ->240f pickup; native spell3 entry skips pre, completes1 forced card ->post16pages ->240f pickup. Entry sprite remains visible and engine updates continue. Logs native-non1.log/native-spell3.log; no full combat validation.
