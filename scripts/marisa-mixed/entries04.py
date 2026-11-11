from pathlib import Path
import json
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
l=LuaRuntime();l.execute('SSGCode={}')
l.execute((M/'ssg-inspect04.lua').read_text(encoding='utf8'))
I=l.globals().SSGInspect04
rows=[]
for _,id in sorted(I.order.items()):
 row=I.modes[id]
 rows.append(dict(id=id,name=row.name,short=row.short,kind=row.kind,helper=f'0x{row.helper:x}',route=f'0x{row.route:x}'))
(M/'source/ssg-inspect04.json').write_text(json.dumps(dict(modes=rows,scope='fixed selection routing only; original helpers untouched',hp=10000,frames=3601),ensure_ascii=False,indent=2),encoding='utf8')
folder=R/'秋霜玉魔理沙攻击检查';folder.mkdir(exist_ok=True)
for row in rows:
 p=folder/(row['id']+'-'+row['name'].split('：')[-1]+'.cmd')
 p.write_text('@echo off\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\\start-marisa-mixed.ps1" -Practice ssg -SSGMode '+row['id']+' -Invincible\n',encoding='ascii')
for p in [R/'start-marisa-mixed.ps1',R/'start-marisa-ssg-inspect.ps1']:
 p.write_text(p.read_text(encoding='utf-8-sig'),encoding='utf-8-sig')
lines=['# 秋霜玉魔理沙：攻击检查','',
 '双击本目录对应编号的CMD，只重复这一种攻击。默认自机无敌，Boss血量30000。A2/B1/B3为调整后21/22/20秒版本，其余编号保留旧参考。',
 '也可双击上一级的start-marisa-ssg-inspect.cmd，在列表中选择编号并开关自机无敌。',
 '游戏底部显示相同编号。Z射击、Shift低速、X使用Bomb、Esc暂停；结束游戏后再开另一项。','',
 '| 编号 | 对应行为 | 原脚本入口 |','|---|---|---|']
lines += ['|{id}|{name}|{helper}|'.format(**r)for r in rows]
lines+=['','A项不会召出僚机；B项跳过前两轮本体攻击，召出原来的五僚机后，只重复指定组合。B3/B4仍包含原来与激光配套的点弹。各项不交叉随机选择；选中攻击内部原有的随机方向、移动、发弹、音效和特效保留。',
 '这些是便于沟通的检查编号，不是原作符卡名。完整七段的一非现为A2→B1→B3，分别21/22/20秒。',
 'A2：半速，最大圆球→黄色大星弹，中等圆球→每波统一红/紫/蓝、逐波轮换的小星弹，最小子弹删除，恢复星弹原数量，连射间隔延长至4/3，压缩波间等待，A2现持续21秒。B1：22秒（最后2秒停火）、半速，五使魔分别固定红/紫/蓝/青/黄小星弹，保留永夜抄发弹音效。B3：半速，中号圆弹→小星弹，偶数轮只发激光，使用永夜抄普通蓝色激光及发射端光晕、原激光音效，提前60帧显示逐渐延长的金色无判定引导线并播放蓄力音效，激光30帧逐渐延长并覆盖预警线；B3使魔转速减半。']
(folder/'说明.md').write_text('\n'.join(lines)+'\n',encoding='utf8')
print('PASS generated10 individual entries and shared selector data; UTF8-BOM PowerShell files')
