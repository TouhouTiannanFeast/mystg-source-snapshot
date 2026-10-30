"""Publish the audited values without modifying any gameplay configuration."""
from pathlib import Path
import json,hashlib
C=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/zuu4')
d=json.loads(Path('G:/MySTG/work/zuu4/audit06/firepower-report.json').read_text(encoding='utf-8'))
assert hashlib.sha256((C/'patterns.lua').read_bytes()).hexdigest()==d['phaseDataSHA256'],'Phase data changed: refresh the audit first.'
names={'non1':'一非','spell1':'一符','non2':'二非','spell2':'二符','non3':'融合三非','stone':'三符 石之女神','final':'终符'}
original={'non1':(5777,2.4),'spell1':(777,.2),'non2':(5777,2),'spell2':(777,.225),'final':(7777,.707)}
lines=['# 鸟澄珠乌 / 石之女神：行为、动画和火力核对', '',
'本报告按当前 `patterns.lua` 读回；该文件未在本次修复中修改。其值已与此前对话不同，不能沿用旧表。',
'原始脚本和原图均未改动。七阶段顺序、真珠岛菱形弹32×32及半径4、翅膀受击半径48保留。', '',
'## 石之女神 Normal', '',
'源文件：`source/th20-st06bs.ecl.txt:1623`，`BossCard7` 与 `_1/_2/_3`、`at/at2/at3/at4/at5`。',
'原作总血量12000、总时限7200帧（120秒）、Bomb伤害系数0.25。四段不是强制各30秒：达到血量阈值会提前切换；未达到时由原作计时兜底。', '',
'| 段 | 原作血量区间 | 本地当前血量区间 | 不射击时的原作进入帧 | 弹幕层 |',
'|---|---|---|---:|---|',
'| 1 | 12000→8000，需4000 | 16000→8000，需8000 | 120（前2秒入场） | 7方向青弹，间隔20帧，1.5→0.5，120帧减速，纵向穿屏一次 |',
'| 2 | 8000→5000，需3000 | 相同 | 1920 | 前层间隔24帧；加32方向蓝弹，每120帧，1.8→0.8 |',
'| 3 | 5000→2000，需3000 | 相同 | 3719 | 前层间隔28帧；加3方向紫弹，每13帧，3.8→1.2 |',
'| 4 | 2000→0，需2000 | 相同 | 5518 | 保留前三层；加红色自机狙，每8帧，3.8→2.2 |', '',
'各层弹源均包含原作随机角与有符号128半径偏移；切段清弹并将生命设置为下段起点。每200帧随机移动的框架保留。未修改原作Normal弹数、发射间隔、速度或总时限，本轮未降密度。',
'用户另行调整的当前16000总血量保留，因此第一段所需伤害是原作两倍；没有悄悄改回12000，也没有缩放三个现有阈值。', '',
'本次修复：',
'- 原逐帧计数先测试再等待；纠正旧移植累计1～3帧的切段误差。',
'- 原程序483270/4854d0确认：穿屏前需整个图形出屏，位移为448+图形高度；按替换后的32像素真珠岛图修正，判定半径仍4。',
'- etEx25写入bullet+0x44；47d85b等按该值将弹归入六条链表。旧代码只记为未使用的transformIndex3，现按原分组把紫/红层与青/蓝层分开渲染。该用途由本地原程序链表/分组访问推断，未声称原渲染管线逐像素重现。',
'- Bomb0.25原先仅写在配置中；现只对该符卡的Bomb伤害生效。th18-fire新增可选来源标记，其他目标和阶段的伤害/上限不变。', '',
'## 珠乌角色动画', '',
'对照 `source/lib_Anime.dnh.txt:200,370,722`、`lib_Horou.dnh.txt:176` 和 `lib_HorouEffect01..04`：',
'- 恢复待机、左右移、攻击1的4/5/6/7/14/15/16序列，攻击2/3的20..27正反收放书，持书/无书偏移30，180帧周期末9帧的眨眼偏移60。',
'- 体绘按源浮动sin(time×3)、幅度逐步至6；修正源ANIME_Y=-12在半尺寸坐标中实际偏移6，旧版为+12。',
'- 恢复三组翼根、8条纹理条带组成的非刚性拍翼、六片机械羽、游移眼睛/瞳孔与眨眼、四片翻转飞行翼、三层非匀速不灭翼。源翼优先级31..36均在身体41后方。',
'- 二非展开先在上方平板处出现，再接回身体；补书释放/收回动作、平板30帧展开、渐快旋转和HSV残影；终符翼碎片离场动画也已接入。',
'- 动画随机数单独保存，不消耗攻击随机数；原图完全保留。',
'这次修复角色/翅膀动作，不包含原版完整符卡背景、切入图、音乐、七色Z Bomb与对白；跨引擎逐帧像素一致性未验收。', '',
'## 血量与自机火力', '',
'先统一口径：折算耐久 = HP ÷ 当前受伤倍率；静态全命中击破秒数 = 折算耐久 ÷ 基础DPS。不含接近、散射丢弹、目标无敌、同帧上限、使魔多重命中、Bomb和属性追加伤害。',
'真珠岛使用同为灵梦的基础普通射击作参照：ShotPower_Common=(1+1.2)×0.4=0.88；主弹每6帧2发，4子机每12帧各1发；CreateShotPL的CheckShotPenetration对首次命中设2倍。故主弹35.2、追踪札70.4，合计105.6/秒。',
'源路径：HSoB readable/script/th_hsob/player/hsob/lib/{PlayerStateSetting,lib_Player,lib_PlayerShot}.dnh.utf8.txt；不同属性、其他三机及贯通多次判定不能套这个105.6。',
f'当前MySTG灵梦4P实际发射表读出：高速{d["currentReimuDPS"]["fast"]:g}/秒、低速{d["currentReimuDPS"]["slow"]:g}/秒；分别为上述真珠岛基准的12.12、16.67倍。每目标每帧90上限仍在。', '',
'| 阶段 | 当前HP | 当前受伤倍率 | 折算耐久 | 当前高速/低速静态秒数 | 原HSoB HP/倍率 | 原HSoB基准静态秒数 |',
'|---|---:|---:|---:|---:|---|---:|']
for row in d['phaseRatios']:
 key=row['phase'];src=original.get(key)
 orig=f'{src[0]} / {src[1]*100:g}%'if src else '不属真珠岛'
 secs=f'{src[0]/src[1]/105.6:.2f}'if src else '—'
 lines.append(f'| {names[key]} | {row["hp"]} | {row["rate"]*100:g}% | {row["effectiveHP"]:.2f} | {row["currentFastSeconds"]:.2f} / {row["currentSlowSeconds"]:.2f} | {orig} | {secs} |')
lines += ['', '真珠岛终符原作通关/练习为70.7%受伤倍率，单符练习另设100%；上表按通关值。105.6基准不含属性附加，所以终符可能算出超过98秒，不能据此断言原作无法击破。', '',
'## 锦上京火力如何比较', '',
'先前汇总把TH20 SHT格式列为未知。本次直接从所给th20.exe确认：4f9b80载入160组绝对偏移，表位于SHT+0x5d4；504d40按120字节记录读取，第二计时字段位于+0x32/+0x33（不能按TH18的+0x2a读取）。505bf2短计时到14、505cba长计时到119。52fc09按石灵索引×20选择发射组。',
'下面是pl00灵梦4P的普通主弹+高速/低速子弹发射表全命中和，不含石灵主动技能、强化、命中回调新增伤害与目标上限；表中的索引不是已核实的角色名字，避免错贴石灵名称。', '',
'| 石灵表索引 | 主弹DPS | 高速总DPS | 低速总DPS | 当前高速/原作 | 当前低速/原作 |',
'|---|---:|---:|---:|---:|---:|']
for r in d['th20SHT']['pl00']['fullPowerEmissionOnlyByWeaponIndex']:
 lines.append(f'| {r["index"]} | {r["base"]:g} | {r["fast"]:g} | {r["slow"]:g} | {1280/r["fast"]:.1%} | {1760/r["slow"]:.1%} |')
lines += ['',
'因此当前火力与TH20不是一个固定倍数：按普通发射表，高速约原作36.8%～90.4%，低速约56.8%～124.3%；激光/特殊技能的实战伤害还需按具体机体、石灵、距离和命中情境比较。两份原SHT哈希及逐行解码已写入work/zuu4/audit06/firepower-report.json，未把所有模式相加冒充单机输出。', '',
'## 验证与实际边界', '',
'- verify-audit06.py：Lua51语法；四段血量/计时切换、四弹层发射、半径4和整图出屏；身体各动作关键帧、28翼绘制块/原排序、半径48、动画RNG隔离；Stone Bomb0.25及其他伤害保持。',
'- native-audit06.ps1 -Practice stone：真实引擎跑完7201更新帧，四段进入与退出；non2/spell1各500帧；补充Stone快速切段采样，核看第四段四颜色层叠加。测试设置均恢复。',
'- 原始日志work/logs/zuu4/{unit,native-stone,native-non2,native-spell1,native-stone-layers}-audit06.log；截图zuu4-*-audit06-*.jpg。',
'- 不是整局回归；未逐帧并排捕获原TH20/HSoB；原生出生特效和随机移动插值仍为跨引擎实现，不能称完全一致。HSoB属性/Bomb防护、全终符弹幕与最新血量对发狂阈值的影响不在本次改动内。',
'- 普通发射表DPS不是实际Boss掉血实测，不应直接当作最终血量换算系数。', '',
'启动：G:/MySTG/start-zuu4.cmd；单看Stone用 powershell -File G:/MySTG/start-zuu4.ps1 -Practice stone -Invincible。']
(C/'audit06.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(C/'audit06.md')
