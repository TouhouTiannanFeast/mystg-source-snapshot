"""User-facing source/current HP table and exact asset gallery."""
from pathlib import Path
import json,re,html,shutil
from PIL import Image,ImageDraw,ImageFont
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/NinaStage6Normal';O=R/'work/nina-stage6/review03';O.mkdir(parents=True,exist_ok=True)
specs='\n'.join((M/n).read_text(encoding='utf-8-sig')for n in ['encounter-nina.lua','import10/specs.lua','import08/specs.lua'])
current=dict((k,int(v))for k,v in re.findall(r"id='([^']+)'[^\n]*?hp=(\d+)",specs))
rows=[('non1','一非','TH13 青娥 Hard 一符',1700,'Boss() 符卡练习 lifeSet(1700)'),('spell1','一符','TH13 青娥 Lunatic 二符',1700,'Boss() 符卡练习 lifeSet(1700)'),('non2','二非','TH10 早苗 Normal 道中非符',10000,'MBoss: 12900 - 2900'),('spell2','二符','TH10 早苗 Hard 摩西之奇迹',2400,'Boss2 留给 BossCard2 的阈值 2400'),('non3','三非','TH20 妮娜 Extra 三非',18000,'Boss3: 22000 - 4000'),('spell3','三符','TH11 早苗 Extra 米之浴',2200,'MBossCard3: lifeSet(2200)'),('non4','四非','TH08 永琳 Normal 道中非符',11400,'Sub17: 13000 - 1600'),('spell4','四符','TH17 袿姬 Normal 四符',2700,'Boss4 留给 BossCard4 的阈值 2700'),('final','终符','TH08 辉夜 Normal 七彩弹幕',2500,'Sub61: lifeSet(2500)'),('kanako','追加终符','TH10 神奈子 Normal 信仰之山',8200,'BossCard5: lifeSet(8200)')]
actors=[('诹访子（一非/一符）','活动时 4000；倒地脚本内部值 6000','对应芳香活动 4000；倒地内部值 6000','创建时 12000 会被卡初始化替换；倒地的 6000 不是可再击破的第二条血'),('诹访子（二非/二符）','上限 4000','此两段原作无此角色；参考芳香 4000','可挡自机弹；被击破后 240 帧复活；跨二非/二符保留状态'),('一非/一符 EvilBall01 控制球','10','10','源脚本保护/接触标志保留'),('二非 MBossDummy / Card1Dummy / Card1Dummy2','20','20','隐藏的发弹控制器'),('二符 Boss2Et_at / BossCard2_atEt','240','240','隐藏且受保护的发弹控制器'),('四非 黄色青蛙使魔','300','300（原为 type54 使魔）','只换外观，受弹与原有轨迹保留'),('四符 人马埴轮召唤物','3000','1000','BossCard4_AtEt；素材为 haniwa-28/29/30/red'),('终符 七只黄色青蛙','4000 / 2100 / 1000 / 1000 / 1000 / 2100 / 4000','相同创建值','原作和本模组均不可击破；数值不代表可耗尽生命'),('信仰之山 六色球/隐藏发弹控制器','240','240','BossCirR/G/B 2/4、BossCard5_atN/at2，原作保护标志保留'),('二符结束飞出的七只黄色青蛙','无血量','自定义过场，原作无对应','危险弹体，出屏自然消失')]
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',n)
im=Image.new('RGB',(1120,690),(24,29,39));d=ImageDraw.Draw(im);d.text((24,18),'当前符卡背景素材与四符召唤物',font=font(27),fill='white')
def paste(path,box,label):
 a=Image.open(path).convert('RGBA');a.thumbnail((box[2],box[3]));im.paste(a,(box[0],box[1]),a);d.text((box[0],box[1]+box[3]+8),label,font=font(17),fill=(224,230,240))
paste(M/'scenery/art/cdbg07a.png',(28,72,384,448),'TH11 cdbg07a：符卡底图')
paste(M/'scenery/art/cdbg07b.png',(440,72,256,256),'TH11 cdbg07b：叠加层')
for i,s in enumerate([28,29,30,"red"]):
 a=Image.open(M/f'art/haniwa-{s}.png').convert('RGBA');a=a.resize((a.width*2,a.height*2),Image.Resampling.NEAREST);im.paste(a,(750+i*85,95),a)
d.text((750,270),'四符：人马埴轮四色随机帧',font=font(20),fill='white');d.text((750,305),'每只 HP 3000（原作 1000）',font=font(18),fill=(224,230,240))
for i in range(3):
 a=Image.open(M/f'art/yellow-frog{i}.png').convert('RGBA');a=a.resize((a.width*2,a.height*2),Image.Resampling.NEAREST);im.paste(a,(750+i*110,405),a)
d.text((750,490),'现用黄色青蛙三帧',font=font(20),fill='white')
d.text((28,586),'上图为未改动的原素材。游戏中叠加层有缩放、渐显和 RGB 动画。',font=font(20),fill=(224,230,240))
d.text((28,625),'完整的当前 / 原作血量与来源证据见同目录 index.html。',font=font(20),fill=(224,230,240))
im.save(O/'assets.png')
td=lambda x:'<td>'+html.escape(str(x))+'</td>'
table=''.join('<tr>'+''.join(map(td,[label,src,current[k],orig,f'{current[k]/orig:.2f}×',proof]))+'</tr>'for k,label,src,orig,proof in rows)
atable=''.join('<tr>'+''.join(map(td,r))+'</tr>'for r in actors)
body=f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>渡里妮娜 · 素材与血量核对</title><style>body{{font:16px/1.6 'Microsoft YaHei',sans-serif;background:#161d28;color:#e8eef7;max-width:1200px;margin:32px auto;padding:0 24px}}table{{border-collapse:collapse;width:100%;margin:20px 0 36px}}td,th{{padding:9px;border:1px solid #435165;text-align:left}}th{{background:#25344a}}img{{max-width:100%}}a{{color:#90c7ff}}small{{color:#bdc9d9}}</style><h1>渡里妮娜：素材与血量核对</h1><p>当前血量已按2026-11-05指定数值更新；二、三、四非采用原作单段血量。</p><img src="assets.png"><h2>Boss 血量</h2><table><tr><th>阶段</th><th>原作来源</th><th>当前 HP</th><th>原作单段 HP</th><th>当前 / 原作</th><th>原作证据</th></tr>{table}</table><h2>使魔、召唤物与其他控制对象</h2><table><tr><th>对象</th><th>当前血量</th><th>原作对应值</th><th>说明</th></tr>{atable}</table><p>三非与米之浴没有额外有血量的可见召唤物。自机子弹、普通弹幕、激光本身不按敌人 HP 计量。源 Ecl_EtBreak 的 9999 为清弹控制对象创建参数，本移植未将它们生成为战斗敌人。</p><h2>实际游戏截图</h2>'''
for id,label in [('spell1','一符 Lunatic 与大菱形弹'),('spell2','正确的 Hard 摩西之奇迹'),('spell3','红米与其他颜色点弹'),('non4','四非大菱形弹与黄色青蛙'),('final','终符'),('non2','world06 原脚本背景')]:
 p=R/f'work/logs/nina-stage6/fix03-bg-final-nina-{id}-480.jpg' if id=='non2' else R/f'work/logs/nina-stage6/fix03-final-nina-{id}-480.jpg' if id=='spell1' else R/f'work/logs/nina-stage6/fix03-nina-{id}-480.jpg'
 if not p.exists():p=R/f'work/logs/nina-stage6/fix03-nina-{id}-320.jpg'
 if p.exists():shutil.copy2(p,O/(id+'.jpg'));body+=f'<h3>{label}</h3><img src="{id}.jpg">'
body+='</html>'
(O/'index.html').write_text(body,encoding='utf-8')
(O/'hp.json').write_text(json.dumps(dict(boss=[dict(id=k,label=label,source=src,current=current[k],original=orig,evidence=proof)for k,label,src,orig,proof in rows],actors=actors),ensure_ascii=False,indent=2),encoding='utf-8')
print(O/'index.html');print(O/'assets.png')
