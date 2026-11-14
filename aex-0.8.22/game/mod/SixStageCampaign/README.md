# 六面连战

双击 `G:/MySTG/start-six-stages.cmd`。启动面板可选起始面、已有 Boss 阶段或三面前半／后半道中，以及无敌和 1/4/8 倍速度。从所选入口结束后继续下一面，直至六面完成。三面后半从源5200开始（原第31波），不再列出逐波入口。

- F5：游戏中选面，上下选择，Z 确认，Esc 返回。
- F6：立即切换无敌；关闭后按原有碰撞规则生效，不额外留下无敌时长。
- F7：切换 1 / 4 / 8 倍速度。
- 原操作保留：方向键移动、Shift 低速、Z 射击、X Bomb、Esc 暂停。
- 普通面间是无文字、无操作提示的纯黑屏，至少 1 秒；黑屏期间不快进。

二面完成后，先在冻结的二面画面上显示获卡提示。使用 TH18.5 原始 `notice.anm` 的黑带贴图与 30 帧滑入／退出行为，等待松开并重新按 Z 确认；持续射击不会自动跳过。卡牌图片是用户提供的阴阳玉原图。提示结束后仍有 1 秒纯黑屏，再进入三面。未注册卡牌、增加装备或赋予任何能力；实际攻击切换由串联系统完成。

## 接入的当前源版本

| 面 | 直接读取的源目录 |
|---|---|
| 一、二 | `Stage12Normal`，保留现有锁 4P、纯贯穿射击及 `3/28` 伤害倍率 |
| 三 | `YuyukoStage3` + 实时依赖 `Le03Stage4Normal` 的当前 58 波道中 |
| 四 | `MarisaMixed` 当前完整道中、铃瑚／清兰、七阶段魔理沙；来自“复刻秋霜玉魔理沙攻击行为”对话 |
| 五 | `HSoBStage5Normal` 真珠岛三段道中＋珠乌七阶段；来自“添加鸟澄珠乌四面关底Boss”对话，直接依赖该对话的当前源版本 |
| 六 | `NinaStage6Normal` 当前完整道中及全部 Boss／追加终符 |

三面开始使用现有高速诱导／低速贯穿机体；残机、Bomb、分数、Graze 在换面时接续。直接从后面的某面启动时，按该入口原有初始残机和 Bomb 初始化。

## 本次指定统一规则

- 所有已生成的非残机／Bomb吃点，统一显示永夜抄蓝点并计分；包括框架小绿点、黄点，以及魔理沙道中原先不计分的私有掉落。保留生成数量和移动／吸收流程。
- 残机和 Bomb 掉落使用永夜抄原素材；碎片使用同款素材的75%显示尺寸。残机碎片、Bomb碎片均3个兑换1整份，余数接续；HUD分母同步为3。
- 删除游戏区域下方的小字阶段／操作提示，保留 Boss 名称、符卡名、对话和正常得分数字。
- 三面最后三只妖精均不能击破；仍按原1020帧发弹截止／向上离场，中央残机奖励保持一次。
- 魔理沙一非B3首次预警即播放一次蓄力，音量0.4→1.0；原3.30884秒WAV保留音高压缩到1.000秒，在预警60帧结束正式发射时停止。快进也不会让声音拖到正式激光之后。
- 神奈子终符9000→5400帧（150→90秒），HP48800及攻击不变。

以上均在 `adapters.lua` 中仅对连战版生效，原独立模组不覆盖。出界消弹效果检查见 `boundary-audit.md`；三面存在旧坐标误触发风险，本次只记录，没有改变消弹规则。

自机弹命中普通敌机或 Boss 时，按**实际弹种**补回各自原版受击表现，而不是按面数套同一张图：
- 主弹：TH10 灵梦B `pl00.anm` script6，sprite25..27（行144），30帧；三面以后主弹来自 TH13 图集 script10 的同一命中段，逐字节与 TH10 相同。
- 贯穿针：TH10 灵梦B `pl00b.sht` 的 option 行（anm=6/anm_hit=7 → script12），使用**独立的 TH10 针弹裁片**做20帧淡出，不是札弹火花；不再复用 `stage12.pierce`/`y3.player.pierce` 的图像名，避免特效把仍在飞行的针弹一起改透明。
- 诱导札：TH13 `pl00.anm` script12/13 札弹命中 sprite32..34（行160），连战重制为12帧、每4帧切图、沿命中方向的加算短闪，透明度平滑衰减；连战版会替换掉源 `hs5.player.charm.hit` 的粉色命中帧，避免把札弹画成针弹/主弹。
每组“子弹-敌机”只生成一次；四面魔理沙本战保留其源命中火花/遮罩，不重复叠加。实现在 `hit-effect.lua`，仅连战入口加载，源模组不改。

临时增补：每面道中结束时，在版面上方中央额外掉 **2 残 + 3 Bomb**（拾取物，不走直接加算）。实现在 `road-bonus.lua`，只加额外物品，不替换任何源奖励；练习/单 Boss 入口不触发。

四面道中小怪原来的 TH18 绿色掉落闪光（bullet animation 101 的 `Effect`）已移除；普通掉落现在统一显示蓝点，不再出现绿色光点。

当前掉落构成：残机整份、Bomb 整份、残机碎片（3→1 残）、Bomb 碎片（3→1 Bomb）、以及所有其它非资源点（统一为永夜抄蓝点并计分）。Power 由固定 4P/隐藏逻辑处理，不再作为独立资源显示。

源文件不复制、不覆盖。每面按需加载到 stage 资源池，换面时清理旧对象和音乐，再恢复上一面修改过的机体、UI、碰撞与暂停接口，避免不同模组互相串用。

## 验证范围

`G:/MySTG/scripts/six-stages/verify.py`：Lua 5.1 语法、实际控制层回调、选面／选阶段路由、无敌开关、快进、1 秒无文字黑屏、按键确认、接口隔离、资源接续，以及当前204个源Lua哈希读回。`verify-revision.py`实际执行原生道具类与三面末波宿主回调，检查计分、三碎片、无敌保护、HUD、音效及90秒读回。卡牌原图、TH18.5黑带及TH08道具整表字节一致。

`scripts/six-stages/native.ps1 -Probe`：真实引擎依次加载已纠正的六个完整入口，每面只运行180帧后测试换面；8倍速度下黑屏约1.01秒，六个机体绑定／资源检查通过。另做四面B3激光1200帧相关触发检查，3次蓄力均60帧准确停止；六面神奈子入口600帧检查确认真实卡片frames5400。道具断言／截图和HUD分母3已核对。测试会缩短运行流程，只验证组合接口，不等于完整通关。最新日志在 `G:/MySTG/work/logs/six-stages/revision/`。

仍需用户真实试玩：六面完整流程、Boss自然衔接、四面蓄力响度，以及三面是否会在正常弹速下出现已记录的边界闪光。当前交付是源码入口，未生成便携包。

2026-11-09 连战版魔理沙开场一非：总血量24000，A2/B1/B3各8000。某段提前打空时立即消除该段弹丸、激光及追踪光束并进入下一段，溢出伤害不扣下一段。绝对时间节点仍为第1261/2581帧，总3780帧；到时切换会舍弃旧段剩余血量，提前切换不会回退或重置总计时。开场保护、五使魔减伤及其他攻击数据保留，独立MarisaMixed未改。实现位于marisa-segments.lua，经adapters安装。
局部验证使用真实SSGSelected05调度与原私有/宿主伤害函数，覆盖第一段早破、第二段拖到原截止点、第二段早破、连续早破、溢出伤害、即时消弹及开场无敌；Lua51语法通过。日志work/logs/six-stages/marisa-segments/verify.log；未进行游戏内试玩。仍从start-six-stages.cmd选择四面开场Boss（ssg）验证手感。

## 椋庣褰曟爣棰樹笌閫夋嫨椤甸潰锛?026-11-10锛?
鍙屽嚮 `G:/MySTG/start-six-stages.cmd` 榛樿杩涘叆椋庣褰曟爣棰橀〉銆侴AME START 鈫?RANK SELECT 鈫?PLAYER SELECT 鈫?杩炴垬锛涙棤 WEAPON SELECT銆傚彧寮€鏀?Normal锛屽叾浣欎笁妗ｆ樉绀洪棶鍙凤紱瑙掕壊鍥哄畾鐏垫ⅵ锛屽乏鍙宠緭鍏ユ挱鏀惧師鐗?TH18.5 `se_invalid.wav`銆?
鏍囬椤?EXTRA START銆丮USIC ROOM銆丱PTION 浣跨敤鍘熺増鏆楄壊瀛楀浘涓斾笉鍙備笌涓婁笅鍏夋爣寰幆锛汫AME START銆丳RACTICE START銆丷EPLAY銆丳LAYER DATA銆丵UIT 淇濈暀鍏ュ彛銆侾RACTICE START 缁?Normal锛忕伒姊﹀悗浣跨敤褰撳墠杩炴垬闃舵鍒楄〃锛堝惈涓夐潰鍓嶏紡鍚庡崐閬撲腑锛夈€俁EPLAY 浣跨敤鐜版湁寮曟搸鍥炴斁鍒楄〃锛汸LAYER DATA 鏄剧ず褰撳墠妯＄粍宸叉湁鐨勬渶楂樺垎璁板綍锛屾病鏈夎櫄鏋勭粺璁°€?
`frontend/` 浣跨敤鏈湴鏃ユ枃椋庣褰?`th10.dat/title.anm` 鐨勫師濮嬭儗鏅€佸瓧鍥俱€侀毦搴︾墝鍜岀伒姊︾珛缁橈紱浣嶇疆渚濇嵁 scripts0/3..18/98/99/109..125锛岃繘鍏ワ紡閫€鍑哄拰閫変腑鍙嶉鍦?LuaSTG 鍐呭疄鐜般€傝彍鍗曢煶涔愪负椋庣褰曟爣棰樻洸 `th10_01.wav`锛屼娇鐢?`thbgm.fmt` 寰幆鐐癸紱鍏冲崱闊充箰涓嶆敼銆傛潵婧愬拰姣忎唤绱犳潗鍝堝笇瑙?`frontend/source.json`銆?
`start-six-stages.ps1 -Selector` 浠嶆墦寮€鍘熸潵鐨勯€夐樁娈碉紡鏃犳晫锛忛€熷害绐楀彛锛沗-NoMenu -Stage 4 -Entry ssg` 鍙洿鎺ヨ繘鎸囧畾闃舵銆傛父鎴忓唴 F5/F6/F7 淇濈暀锛屾爣棰橀〉闈㈡寜姝ｅ父閫熷害杩愯銆?
灞€閮ㄦ鏌ュ拰闅旂寮曟搸妫€鏌ュ凡瑕嗙洊锛氫笁椤硅彍鍗曡烦杩囥€丯ormal锛忕伒姊﹂攣瀹氥€佸彇娑堜笌杩斿洖銆佺粫杩囨鍣ㄩ〉杩涘叆鐪熷疄涓€闈㈠苟杩斿洖鏍囬銆佺粌涔犲垪琛ㄣ€佸洖鏀惧垪琛ㄥ拰鐜╁鏁版嵁鍏ュ彛銆傚師濮嬫棩蹇椾笌鍥涢〉鎴浘鍦?`G:/Modified_STG/work/logs/six-th10-menu/`銆傛湭鍋氬畬鏁村叚闈㈤€氬叧鎴栧師鐗堥€愬抚鍔ㄧ敾涓€鑷存€ч獙鏀躲€?


2026-11-10 菜单动画修正：标题选中项使用原版明／暗字图5帧交叉变化、2帧一段的左右抖动及粉红／白色变化；Z确认后22帧以2帧间隔交替灰白闪烁，再20帧缩小退场。难度页非Normal为原版卡片alpha轮廓的黑色阴影，中心只显示一个大黑问号。问号使用原EXE请求的系统字体MS Gothic，本机msgothic.ttc的字节副本位于frontend/ms-gothic.ttc；不是原版游戏内置字体。
字体调查：标题固定字样是title.anm图片，英文/数字另有ascii.anm位图字库；日文动态文字通过GDI CreateFontA/TextOutA和ＭＳ ゴシック绘制。原数据包无TTF/OTF/TTC，EXE无字体资源。提取的字图、系统字体副本及地址证据见G:/Modified_STG/work/six-th10-menu/font-evidence/README.md。菜单局部渲染断言及原生截图检查通过，日志在work/logs/six-th10-menu/animation/（位于Modified_STG）。

2026-11-10: title BGM = 錦の上の巫女 (TH20 th20_01.wav), replacing the earlier TH10 track. Source loop start 2.030113379s, end 98.029931973s. Original PCM preserved; menu volume and play/stop behavior unchanged. Source hashes in frontend/source.json; backup and verification in G:/Modified_STG/work/logs/six-th10-menu/title-music/.

2026-11-11 frontend update: Normal and fixed Reimu now use source selection jog/color and separate confirmation timelines (rank22f flash+20f shrink/exit; Reimu portrait30f/info32f flash+20f slide exit). Frontend gameplay entry passes through SixStageLoading using TH10 ascii.anm original loading.png (girl-praying/Now Loading/stars), scripts3..6 relative offsets/fades and2f particle emission. Loading has a campaign visibility floor of60 normal ticks, at least2 presented frames and1 elapsed second; this minimum is a readability guard, not a claimed original constant. The presented loading frame remains visible while existing synchronous source import runs; gameplay begins only when source.init completes. Direct debug/probe entry remains available; ordinary between-stage gaps unchanged. TH20 title BGM remains byte-identical.
Title labels are grayscale with alpha; original ins_52/57 supplies pink255/160/160. Active label uses additive color for white face/pink outline, with source grey-white confirmation. No separate pink mask image was found. This is reconstructed from native assets/ANM and the user's appearance reference; the original EXE did not start in this environment, so no pixel-by-pixel native comparison is claimed.
Native result: loading dispatch frames62, presented61, elapsed1.015s; source ready1.270s, then actual first-stage player/power400 verified. Logs, source evidence and inspected screenshots: G:/Modified_STG/work/logs/six-th10-menu/select-loading/.

2026-11-11 battle/resource review: Milky Way2300→12000; Master Spark rendered below stars (terminal HP2500 retained); Marisa practice now continues from chosen card through all later adjacent phases; all six finish routes gain an extra240 playable frames before the ordinary black gap. Five-road event/self/pickup sounds now use original TH10 WAV bytes; Horou Boss source bank retained. Horou final respawn clear filters to yellow feather548; yellow bird-trail636 lifetime60→30 per source, extra non-source bird rings removed while actual30f glow trail retained. See combat-resource-audit.md for complete current life/Bomb/fragment drops, pickup margins, current Marisa HP and source timeout comparison.
Verification: focused Lua51/control/source-function checks pass. Bounded native paths: genuine survival capture (cardget + success text), normal Milky timeout (fault + fail text, maxHP12000), practice Stardust→non1, active Spark/stars layering, Horou native respawn filter/tail correction, five-road128 TH10 audio events. Screenshots inspected; settings and campaign save restored. No full playthrough or portable package built. Logs work/logs/six-stages/combat-20261111/.

2026-11-11 latest resource rewrite supersedes the earlier2life3bomb/fragment descriptions: explicit stage-specific whole-item rewards, all fragments removed, life/Bomb auto-attract at60f, no Power/maximum-point HUD or growth. Blue points fixed10000; internal power400 only preserves existing shot damage. Master Spark12000; stage1 anchor terminal540→1080. TH10 original POC sprites mark the real collect line at stage1 start; TH12 anchor launch/return sound56 and impact sound57 plus60f/amplitude2 shake restored. Current complete matrix and preserved original rewards: resource-rules.md. Focused checks and bounded native opening/anchor/stage2/Marisa/Horou/Nina plus natural Stage3 survival pass; settings/save restored. No full playthrough.

2026-11-11 Stage3 story: added the user's exact17 pre/15 post Shion–Kaguya lines (17/16 layout pages). Correct LE03 Shion group06 only, HSoB Kaguya player portraits, original TH10 red/blue dialogue strips and native systemMS Gothic with original-system SimSun fallback. Prior Sese16/17 preview misidentification corrected before assets were installed. Full stage inserts story before Boss creation and after source cleanup/wait but before automatic clear fade; non1 practice includes pre-story, and any terminal completion includes post-story; other practice entries skip pre-story. Z release/repress advances; CTRL skips; dialogue runs live at1x regardless of battle speed; only the stage task waits. Road end waits60f, original60f flight remains visible during story, then90f before non1; player attacks disabled until combat begins. Stage3 Boss display nameShion/死宛, attacks/HP/player/rewards unchanged. Details/provenance dialogue3/README.md and source.json. Unit/source-function checks and bounded real-engine full dialogue chain +six forced card ends +240f handoff pass; screenshots inspected. No full manual route or replay dialogue-input validation.

2026-11-11 latest: Marisa Stardust after-motion now reuses direct Milky-practice entry landing(0,135), duration60f/MOVE_DECEL before non1, without adding cards or altering attacks/HP. Stage3 non1 practice plays pre-story using the existing entrance sprite/flight and90f post-story wait; all practice suffixes retain terminal post-story. Homing-ofuda impact is a campaign-authored12f additive fade/scale, following impact angle, using unchanged original TH13 sprites; main/piercing visuals, shot motion/collision/damage remain unchanged. Focused Lua51 plus bounded native return/non1-practice/final-practice/real-ofuda collision checks pass; settings/save restored. Screenshots/logs combat-20261111 and dialogue3-20261111. No full route playthrough.

2026-11-11 Stage4/6 story: added the user's91 lines across11 scenes (rabbit pre/post, Marisa pre/post; opening, milk-Suwako pre/post, Sanae pre/laugh/post, Kanako arrival). Confirmed Kanako says「公主，有何贵干？」. Original TH10/TH15 separate portrait layers, HSoB Kaguya, TH10 dialogue UI; original PNG bytes retained, TH15 ANM offset padding excluded at LoadImage. Dialogue runs live at1x with player attacks disabled; source phase tasks/road schedulers wait. Noncombat intro cards gate rabbit/Marisa/milk-Suwako; Nina/Kanako use original arrival objects. Opening laugh1 and one independently randomized battle laugh. Existing attack data/resources preserved. See dialogue46/README.md and source.json; original source mods remain read-only. Focused Lua51 and bounded native11-scene trigger checks, not full manual combat/replay verification.

2026-11-11 latest story portrait revision: Marisa uses original TH15 layered portraits, with face_pl01no for「你谁啊。」matching user image1. Pre-defeat fake Sanae uses original TH20 Watari Nina layers, post-defeat Sanae stays TH10. All Suwako dialogue portraits use the original supplied image2 bytes/alpha; only runtime bounds exclude transparent padding. Second battle laugh is audio-only and opens no dialogue page.91 original lines remain archived;90 lines/10 scenes are displayed plus1 voice-only event. Focused source/hash/crop/readback and bounded native4/6 target pages+audio pass; no full manual route.

2026-11-11 Stage1/2 story: Stage1 has22 lines/5 scenes including the3-line Kaguya prologue BEFORE Stage1 background/HUD/music, two Kaguya-only Momiji monologues (explicitly no Momiji portrait), Wakasagi pre/post; user correction「我现在只想敲你一棍子。」is Kaguya. Stage2 has43 lines/4 scenes: Hina-cosplay pre, Mystia pre, Mamizou pre/post. Original TH14 Wakasagi /TH10 Hina /TH08 Mystia /TH13 Mamizou portrait layers, shared HSoB Kaguya and TH10 UI. Native60f entries and attack data preserved; source tasks await story and90f gates. Mystia tail clock pauses only across added story; Stage1 resource-guide animation waits through prologue then appears on actual opening. Gift dialogue -> unchanged240f pickup -> original YinYang notice, with pure piercing retained through Stage2. Focused Lua51 and bounded native scenes/target screenshots pass (test-only road cuts/forced card ends); no full route/replay check. Details dialogue1/README.md and dialogue2/README.md.

2026-11-11 identity correction: previous st06enm portrait was Iwanaga Ariya, mistakenly labeled Watari Nina. Pre-defeat fake Sanae now uses the actual EX Watari Nina from st07enm (blonde, shell seat), verified against original TH20 omake and native target screenshot. Post-defeat Sanae and all other plot/gameplay unchanged. Assets watari-nina-bs/no.png and original head rectangle310,83,304,213; targeted native boss-entry-only check, no road/combat run.

2026-11-11：彗星「Blazing Star」改为30秒不可击破耐久时符；无miss无Bomb坚持到时限结束收取。保留原弹幕、时限和阶段顺序。帕秋莉对话移至本人原60帧飞入后，结束90帧后开始原攻击；原隐形发生器段保持原流程。修复直接选择魔理沙练习时剧情模块读取未加载道中宿主的入口报错。当前续关无次数限制；续关计数字段最多记9，并不限制继续续关。

2026-11-13 剧本已按《纯糖全关对话.docx》和随后确认更新。当前实际对白与遮脸/身份揭露演出见 screenplay/README.md、screenplay/data.lua 与 screenplay.lua；原 dialogue1/2/3/46 素材继续复用。Ending文稿不实装；六面开战大笑仅播放随机音频。未重新打包。
