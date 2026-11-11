from pathlib import Path
import json,hashlib,shutil,struct
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue2';S=R/'work/logs/six-stages/dialogue2-20261111/source'
M.mkdir(exist_ok=True);(M/'art').mkdir(exist_ok=True)
p=(R/'scripts/six-stages/prepare-dialogue3.py').read_text(encoding='utf-8-sig');ns={'Path':Path,'struct':struct,'json':json}
exec(p[p.index('def glyph_checker'):p.index('hasMS=')],ns)
exec(p[p.index('def width('):p.index("data={'pre':")],ns)
raw={
's2hinapre':'''kaguya|这里好热闹啊
kaguya|这是什么活动？
hina|那边的红白！
hina|你买票了吗？
kaguya|键山雏？
hina|没有购买门票的话，我可是不会把你放进去的哟。
kaguya|原来还要钱的啊……
hina|你在说什么？
hina|这是我的工作。
kaguya|工作？
hina|既然你执意要打扰我，那就用魔法让你安静下来吧。
kaguya|真是令人头疼。''',
's2mystiapre':'''mystia|号外号外！一手新闻！新鲜现拍！
kaguya|夜雀也被污染了吗？
mystia|咦？你在说什么？
kaguya|你身上的并没有很多污秽……奇怪
mystia|哎呀，咱全身上下散发的都是新闻的气息！
mystia|来吧，接受采访！
kaguya|看来这家伙也被奇怪的东西控制了。''',
's2mamizoupre':'''mamizou|哎呀呀
mamizou|这不是永远亭的公主吗？
kaguya|你是？
mamizou|你好你好，俺的cn是大狸子
mamizou|大家都叫俺猯藏老师
kaguya|请问这里到底是在干什么
tanuki|这里是人里举办的漫展。
tanuki|老身今天受邀来当官方妆娘，替大家提供服务。
kaguya|妆娘……？
tanuki|就是替别人化妆、打扮，帮她们变成自己喜欢的角色。
kaguya|原来如此……
kaguya|就是说，你就是导致所有人发生奇怪变化的凶手吧！
tanuki|好像有什么误会……
kaguya|你亲口承认了，还想抵赖吗？''',
's2mamizoupost':'''tanuki|咳咳，嗯咳咳——
tanuki|让俺先喘口气吧。
kaguya|还想拖延时间吗？
tanuki|老身刚才不是已经说过了吗？
tanuki|这里不过是人里的漫展，老身只是负责帮大家化妆罢了。
kaguya|那么，最近幻想乡里发生的那些变化，和你没有关系？
tanuki|大概如此。老身也不知道究竟是谁在捣鬼。
tanuki|不好意思让你误会了，这张能力卡牌就送给你当赔礼吧。
kaguya|这是什么？
tanuki|能够让弹幕追踪目标的卡牌。希望它能带你找到最终的答案。'''}
# Same character, separate user speaker labels where requested.
names={'kaguya':'辉夜','hina':'“键山雏”','mystia':'米斯蒂娅','mamizou':'二岩猯藏','tanuki':'猯藏'}
art={};records={};scenes={};texts={}
def asset(rel):
 src=S/rel;dest=M/'art'/src.name
 if not dest.exists():shutil.copyfile(src,dest)
 records[dest.name]={'source':str(src),'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()}
 im=Image.open(dest);return {'file':'art/'+dest.name,'w':im.width,'h':im.height}
def portrait(who,expr):
 key=who+expr
 if key in art:return key
 if who=='hina':
  up=asset('face/enemy2/face02'+expr+'_u.png');down=asset('face/enemy2/face02no_d.png')
  up.update(cx=128,cy=320);down.update(cx=128,cy=64);a={'layers':[down,up],'scale':360/320}
 elif who=='mystia':
  face=asset('data/face/st02/face_st02'+expr+'.png')
  face.update(x=1,y=1,cw=126,ch=254,cx=63,cy=254)
  a={'layers':[face],'scale':360/254}
 else:
  body=asset('face/enemy7/face07bs.png');head=asset('face/enemy7/face07'+expr+'.png')
  body.update(cx=96,cy=340);head.update(cx=96,cy=340);a={'layers':[body,head],'scale':360/340}
 art[key]=a;return key
for key,body in raw.items():
 rows=[]
 for line in body.splitlines():
  who,text=line.split('|',1)
  if who=='kaguya':expr='21'if'！'in text else'5'if'？'in text else'1'
  elif who=='hina':expr='an'if'魔法'in text else'no'if'？'in text else'n2'
  elif who=='mystia':expr='sp'if'？'in text else'n2'
  else:expr='dp'if key.endswith('post')and('喘'in text or'咳'in text)else'n2'if('cn'in text or'漫展'in text)else'no'
  if who!='kaguya':portrait(who,expr)
  rows.append((who,expr,'「'+text+'」'))
 texts[key]=rows;scenes[key]=ns['pages'](rows)
alltext=''.join(t for rows in texts.values()for _,_,t in rows)+''.join(names.values())
ms=ns['glyph_checker']('C:/Windows/Fonts/msgothic.ttc');cn=ns['glyph_checker']('C:/Windows/Fonts/simsun.ttc')
fallback={c:True for c in set(alltext)if not ms(c)};assert all(cn(c)for c in fallback)
data={'scenes':scenes,'names':names,'art':art,'fallback':fallback}
(M/'data.lua').write_text('return '+ns['lua'](data)+'\n',encoding='utf-8')
(M/'text.json').write_text(json.dumps(texts,ensure_ascii=False,indent=2),encoding='utf-8')
(M/'source.json').write_text(json.dumps({'assets':records,'source':'TH10 stgenm02 Hina appearance for cosplay; TH08 face_st02 native dialogue sprites; TH13 st07enm Mamizou body/expression layers. Original PNG bytes; native TH08 sprite rectangle1,1,126,254.','counts':{k:len(v)for k,v in texts.items()},'handoff':'Gift dialogue precedes unchanged240f pickup window and original stage2->3 YinYang card notice/player swap.'},ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared',sum(map(len,texts.values())),'lines',len(scenes),'scenes',len(art),'portraits')
