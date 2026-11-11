from pathlib import Path
import json,hashlib,shutil,struct
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue1';S=R/'work/logs/six-stages/dialogue1-20261111/source'
M.mkdir(exist_ok=True);(M/'art').mkdir(exist_ok=True)
p=(R/'scripts/six-stages/prepare-dialogue3.py').read_text(encoding='utf-8-sig');ns={'Path':Path,'struct':struct,'json':json}
exec(p[p.index('def glyph_checker'):p.index('hasMS=')],ns);exec(p[p.index('def width('):p.index("data={'pre':")],ns)
raw={
's1open':'''kaguya|时间停滞……拒绝变化吗？
kaguya|这种感觉，倒是有些熟悉呢。
kaguya|难道月都那边又在谋划什么？''',
's1momijipre':'''kaguya|空气中污秽的气息已经浓郁得快要凝结成实体了……
kaguya|如此多的污秽是从哪里来的？''',
's1momijipost':'''kaguya|这个天狗已经被污秽侵蚀了精神，失去理智了''',
's1wakapre':'''kaguya|哎哟，人鱼？
wakasa|你好，我能帮什么忙吗？
kaguya|刚才的大狗和这条人鱼的身上都有浓烈的污秽气息……
kaguya|到底是怎么回事？
kaguya|你遇到什么事了？
wakasa|您好，我无法回答这个问题。换个话题试试吧。
kaguya|？
wakasa|服务器繁忙，请稍后重试。
kaguya|我现在只想敲你一棍子。
wakasa|我操，用户彻底怒了''',
's1wakapost':'''wakasa|呜……身上好痛
wakasa|这是哪里？
kaguya|你不记得刚才发生什么了吗？
wakasa|总觉得脑袋里有好多声音……
wakasa|好像有谁一直在和我说话。
kaguya|究竟是什么东西，能够把别人的精神变成这样呢？'''}
names={'kaguya':'辉夜','wakasa':'若鹭姬'};art={};records={};scenes={};texts={}
def asset(rel):
 src=S/rel;dest=M/'art'/src.name
 if not dest.exists():shutil.copyfile(src,dest)
 records[dest.name]={'source':str(src),'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()}
 im=Image.open(dest);return {'file':'art/'+dest.name,'w':im.width,'h':im.height}
def portrait(expr):
 key='wakasa'+expr
 if key not in art:
  body=asset('face/enemy1/face01bs.png');head=asset('face/enemy1/face01'+expr+'.png')
  body.update(cx=350,cy=660);head.update(x=168,y=18,cw=228,ch=148,cx=350-168,cy=660-18)
  art[key]={'layers':[body,head],'scale':360/660}
for key,body in raw.items():
 rows=[]
 for line in body.splitlines():
  who,text=line.split('|',1)
  if who=='kaguya':expr='21'if'棍子'in text else'5'if'？'in text else'7'if('精神'in text or'污秽'in text)else'1'
  else:
   expr='no'
   if '无法回答'in text or'服务器'in text:expr='pr'
   if '棍子'in text or'用户彻底怒'in text:expr='an'
   if key=='s1wakapost':expr='sp'if'痛'in text or'哪里'in text else'pr'
   portrait(expr)
  rows.append((who,expr,'「'+text+'」'))
 texts[key]=rows;scenes[key]=ns['pages'](rows)
alltext=''.join(t for rows in texts.values()for _,_,t in rows)+''.join(names.values())
ms=ns['glyph_checker']('C:/Windows/Fonts/msgothic.ttc');cn=ns['glyph_checker']('C:/Windows/Fonts/simsun.ttc')
fallback={c:True for c in set(alltext)if not ms(c)};assert all(cn(c)for c in fallback)
data={'scenes':scenes,'names':names,'art':art,'fallback':fallback}
(M/'data.lua').write_text('return '+ns['lua'](data)+'\n',encoding='utf-8')
(M/'text.json').write_text(json.dumps(texts,ensure_ascii=False,indent=2),encoding='utf-8')
(M/'source.json').write_text(json.dumps({'assets':records,'source':'Original TH14 st01enm Wakasagihime body/expression PNG layers. Header offset168,18, effective228x148; no source pixels edited.','momiji':'User explicitly requests no Momiji portrait. Her pre/post scenes contain only Kaguya and use no right-hand portrait. Field Momiji remains unchanged.','counts':{k:len(v)for k,v in texts.items()}},ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared',sum(map(len,texts.values())),'lines',len(scenes),'scenes; Momiji portrait assets=0')
