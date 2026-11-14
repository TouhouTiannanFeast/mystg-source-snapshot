from pathlib import Path
import sys,hashlib,json,struct,shutil,io
from PIL import Image
sys.path.insert(0,'G:/TouHou/MLforDanmu/tools')
from dxarchive_v6 import Archive as LenArchive
from danmakufu_archive import Archive as DnhArchive
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue3'
LOG=R/'work/logs/six-stages/dialogue3-20261111'
M.mkdir(parents=True,exist_ok=True);(M/'art').mkdir(exist_ok=True);(M/'font').mkdir(exist_ok=True)
def sha(b):return hashlib.sha256(b).hexdigest()
pre=[
 ('shion','08','「啊哈—好棒呢～这里都快被令人舒服的气味充满了……」'),
 ('kaguya','5','「你是……幽幽子？」'),
 ('shion','04','「是小死宛哦♪ 你好啊，美味的人类♪」'),
 ('shion','08','「你是来陪我玩的吗？」'),
 ('kaguya','13','「紫苑？我记得紫苑可是蓝色头发的哦。而且每天都愁眉苦脸的。」'),
 ('shion','04','「小死宛才不会愁眉苦脸哟—」'),
 ('shion','06','「这里的气息♪ 如此令人愉悦♪ 」'),
 ('kaguya','7','「据我所知，幽灵明明是最纯洁的……然而这家伙竟然正在疯狂吞噬身边的污秽！」'),
 ('shion','08','「不仅是生命力，我连死灵也能一起吸收掉哦~」'),
 ('kaguya','7','「这下白玉文明恐怕是凶多吉少了……」'),
 ('shion','07','「我可以让你也从永生的桎梏中解放哦」'),
 ('shion','08','「只要让我尝一口你的灵魂♪ 」'),
 ('kaguya','5','「我也要死吗……」'),
 ('shion','07','「你以为还能回去吗？」'),
 ('shion','06','「一闻到你的气味，就想好好品尝一番了♪」'),
 ('kaguya','21','「吃你个头，幽灵就该去吃线香」'),
 ('shion','04','「让我把你从生的苦痛中解放♪ 将你的一切，吞噬殆尽！」'),
]
post=[
 ('shion','03','「啊，好强大的对手♪」'),
 ('shion','03','「虽然没有阿玄那么厉害，但还是输了呢—」'),
 ('kaguya','11','「咦，竟然没有恢复正常？」'),
 ('shion','07','「这个身体的主人，是自愿被我凭依的哟♪」'),
 ('shion','08','「我是来自无现里的小死宛♪」'),
 ('kaguya','5','「无现里？」'),
 ('shion','04','「对哦—」'),
 ('shion','08','「有一天，我远远闻到这里散发着食物的香气♪ 所以我暂时离开阿玄，凭依到这个世界的居民身上来玩—」'),
 ('kaguya','1','「那小死宛知道这些气息的源头在哪里吗？」'),
 ('shion','07','「哼～宛宛不知道哦—不过那个人好像和我有着同样的气味~」'),
 ('shion','03','「诞生自无数生命与个体的聚集之中—」'),
 ('kaguya','1','「原来如此……」'),
 ('shion','08','「既然已经输了，那宛宛就要回去找阿玄了哦—」'),
 ('shion','06','「再见~这位永远在追逐着生死的公主♪」'),
 ('kaguya','11','「欸？这是什么意思……」'),
]
art={};records=[]
le=LenArchive(Path('G:/TouHou/Le03_1_21a/dat.led'))
hsPath=next(p for p in Path('G:/TouHou/th_hsob_112').rglob('img.dat')if p.parent.name=='img')
hs=DnhArchive(hsPath)
for who,archive,prefix,ids in [
 ('shion',le,'img/talk/talk_06_',['03','04','06','07','08']),
 ('kaguya',hs,'character/Kaguya/kaguya',['1','5','7','11','13','21'])]:
 lookup={e['name'].replace('\\','/').lower():e for e in archive.entries}
 for expr in ids:
  source=prefix+expr+'.png';key=source.lower()
  if key not in lookup:
   matches=[e for k,e in lookup.items()if k.endswith('/'+key)]
   assert len(matches)==1,source;e=matches[0]
  else:e=lookup[key]
  blob=archive.read(e);dest=M/'art'/f'{who}-{expr}.png';dest.write_bytes(blob)
  im=Image.open(io.BytesIO(blob)).convert('RGBA');box=im.getchannel('A').getbbox();w,h=im.size
  assert box
  art[who+expr]={'file':'art/'+dest.name,'w':w,'h':h,'cx':(box[0]+box[2])/2,'cy':box[3],
                 'scale':360/(box[3]-box[1])}
  records.append({'file':dest.relative_to(M).as_posix(),'archive':str(archive.path),
                  'entry':e['name'],'sha256':sha(blob),'width':w,'height':h,'alpha_bbox':box})
blob=(LOG/'source/ascii/ascii.png').read_bytes();(M/'art/th10-ascii.png').write_bytes(blob)
records.append({'file':'art/th10-ascii.png','archive':'G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/th10.dat',
                'entry':'ascii.anm / ascii/ascii.png','sha256':sha(blob),
                'sprites':{'red':[0,88,256,40],'blue':[0,152,256,40]}})

def glyph_checker(path):
 b=Path(path).read_bytes();base=struct.unpack_from('>I',b,12)[0]if b[:4]==b'ttcf'else 0
 n=struct.unpack_from('>H',b,base+4)[0]
 tables={b[base+12+16*i:base+16+16*i].decode():struct.unpack_from('>II',b,base+20+16*i) for i in range(n)}
 cmap=tables['cmap'][0];a=None
 for i in range(struct.unpack_from('>H',b,cmap+2)[0]):
  p,e,o=struct.unpack_from('>HHI',b,cmap+4+8*i);pos=cmap+o
  if p==3 and e==1 and struct.unpack_from('>H',b,pos)[0]==4:a=pos
 assert a
 n=struct.unpack_from('>H',b,a+6)[0]//2;end=a+14;start=end+2*n+2;delta=start+2*n;ran=delta+2*n
 def exists(ch):
  code=ord(ch)
  if code>65535:return False
  idx=next(i for i in range(n)if struct.unpack_from('>H',b,end+2*i)[0]>=code)
  if code<struct.unpack_from('>H',b,start+2*idx)[0]:return False
  d=struct.unpack_from('>h',b,delta+2*idx)[0];r=struct.unpack_from('>H',b,ran+2*idx)[0]
  return ((code+d)&65535)!=0 if r==0 else struct.unpack_from('>H',b,ran+2*idx+r+2*(code-struct.unpack_from('>H',b,start+2*idx)[0]))[0]!=0
 return exists
hasMS=glyph_checker('C:/Windows/Fonts/msgothic.ttc');hasCN=glyph_checker('C:/Windows/Fonts/simsun.ttc')
alltext=''.join(t for _,_,t in pre+post)+'死宛辉夜'
fallback={ch:True for ch in set(alltext)if not hasMS(ch)}
assert all(hasCN(ch)for ch in fallback),repr([ch for ch in fallback if not hasCN(ch)])
for name,source in [('ms-gothic.ttc','C:/Windows/Fonts/msgothic.ttc'),('simsun.ttc','C:/Windows/Fonts/simsun.ttc')]:
 shutil.copyfile(source,M/'font'/name)
 records.append({'file':'font/'+name,'source':source,'sha256':sha((M/'font'/name).read_bytes())})

def width(ch):return .5 if ord(ch)<128 else 1
def lines(text):
 result=[];line='';used=0
 for ch in text:
  if line and used+width(ch)>20:
   if ch in '，。！？、」♪…～—'and len(line)>1:
    last=line[-1];result.append(line[:-1]);line=last;used=width(last)
   else:result.append(line);line='';used=0
  line+=ch;used+=width(ch)
 if line:result.append(line)
 return result
def pages(rows):
 result=[]
 for index,(who,expr,text)in enumerate(rows,1):
  wrapped=lines(text)
  for i in range(0,len(wrapped),2):
   result.append({'speaker':who,'portrait':who+expr,'line':index,'text':text,'rows':wrapped[i:i+2]})
 return result
def lua(v):
 if isinstance(v,dict):return'{'+','.join('['+lua(k)+']='+lua(val)for k,val in v.items())+'}'
 if isinstance(v,list):return'{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,bool):return'true'if v else'false'
 if isinstance(v,(int,float)):return str(v)
 return json.dumps(v,ensure_ascii=False)
data={'pre':pages(pre),'post':pages(post),'art':art,'fallback':fallback}
(M/'data.lua').write_text('-- Original user text; only layout adds line/page breaks.\nreturn '+lua(data)+'\n',encoding='utf8')
(M/'text.json').write_text(json.dumps({'pre':pre,'post':post},ensure_ascii=False,indent=2),encoding='utf8')
provenance={'shion_identity':'LE03 stage6 talk speaker6 named シオン -> img/talk/talk_06_*.png; groups16/17(Sese) excluded',
 'archives':{'le03':{'file':str(le.path),'sha256':sha(le.blob)},'hsob':{'file':str(hs.path),'sha256':sha(hs.blob)}},
 'text_font':'TH10 Japanese EXE uses system MS Gothic; Chinese missing glyphs use SimSun, present in native Windows FontLink for MS Gothic. No font is claimed embedded in TH10.',
 'fallback_glyphs':sorted(fallback),'font_evidence':'G:/Modified_STG/work/six-th10-menu/font-evidence/font-evidence.json; registry FontLink/SystemLink/MS Gothic',
 'assets':records,'user_lines':{'pre':len(pre),'post':len(post)},'layout_pages':{'pre':len(data['pre']),'post':len(data['post'])}}
(M/'source.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2),encoding='utf8')
# Preserve the user's later no-hyphen replacement portraits when regenerating.
__import__('runpy').run_path(str(R/'scripts/six-stages/replace-shion-portraits.py'))
# Preserve the user's bald Kaguya portraits when regenerating.
__import__('runpy').run_path(str(R/'scripts/six-stages/replace-kaguya-portraits.py'))
print(json.dumps({'lines':provenance['user_lines'],'pages':provenance['layout_pages'],'assets':len(records),'fallback_glyphs':len(fallback)}))
