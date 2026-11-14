from pathlib import Path
import sys,json,hashlib,shutil,struct,io
from PIL import Image
sys.path.insert(0,'G:/MySTG/work/six-stages-tools');from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign';O=R/'work/logs/six-stages/screenplay-20261113';OUT=M/'screenplay';OUT.mkdir(exist_ok=True);(OUT/'art').mkdir(exist_ok=True)
read=lambda p:p.read_text('utf-8-sig')
def plain(t):
 if hasattr(t,'items'):
  d={k:plain(v)for k,v in t.items()}
  if d and set(d)==set(range(1,len(d)+1)):return[d[i]for i in range(1,len(d)+1)]
  return d
 return t
l=LuaRuntime();old={n:plain(l.execute(read(M/f'dialogue{n}/data.lua')))for n in ['1','2','3','46']}
helper=read(R/'scripts/six-stages/prepare-dialogue3.py');ns={'Path':Path,'struct':struct,'json':json};exec(helper[helper.index('def glyph_checker'):helper.index('hasMS=')],ns);exec(helper[helper.index('def width('):helper.index("data={'pre':")],ns)
draft=json.loads(read(O/'scene-draft.json'));raw={k:v['rows']for k,v in draft.items()if k!='ending1'}
raw['s1open']=[{'speaker_label':'不显示名字','text':r[2],'paragraph':None}for r in json.loads(read(M/'dialogue1/text.json'))['s1open']]
# Split the exact Stage5 pre-story at the explicitly offscreen line; original flight follows.
raw['s5off']=raw['s5pre'][:3];raw['s5pre']=raw['s5pre'][3:]
raw['s6post']=[];raw['s6midpost']=[]
raw['s2hinapost']=[raw['s2mystiapre'].pop(0)]
# User requested complete-sentence pages instead of automatic overflow for Horou.
for i,row in enumerate(raw['s5pre']):
 if row['paragraph']==239:
  first,second=row['text'].split('。',1)
  raw['s5pre'][i:i+1]=[dict(row,text=first+'。」'),dict(row,text='「'+second)]
  break

who={'不显示名字':'kaguya','辉夜':'kaguya','变成光头辉夜——永夜抄版':'kaguya','若鹭姬':'wakasa','“键山雏”':'hina','米斯蒂娅':'mystia','二岩猯藏':'mamizou','猯藏':'tanuki','死宛':'shion','？？？':'shion','铃瑚':'ringo','清兰':'seiran','月兔':'rabbit','魔理沙':'marisa','鸟澄珠乌':'horou','珠乌':'horou','诹访子':'suwako','引发应迹的现神人——“早苗”':'fakesanae','“早苗”':'fakesanae','？？？？？':'kanako','模因与信息的化身——八坂神奈子':'kanako'}
KAGUYA_OVERRIDES={
 214:'kaguya1',220:'kaguya22',228:'kaguya11',236:'kaguya11',241:'kaguya11',
 253:'kaguya21',267:'kaguya11',268:'kaguya14',276:'kaguya11',282:'kaguya11',
 295:'kaguya11',297:'kaguya14',301:'kaguya22',305:'kaguya22',315:'kaguya22',
 323:'kaguya21',324:'kaguya21'}
known={}
for n,data in old.items():
 scenes=data.get('scenes',{}) if n!='3'else {'s3pre':data['pre'],'s3post':data['post']}
 for key,pages in scenes.items():
  for p in pages:known[(key,p['text'])]=p['portrait']
assets={};provenance=[]
def copy(src,name):
 src=Path(src);out=OUT/'art'/name;shutil.copy2(src,out);provenance.append({'file':'art/'+name,'source':str(src),'sha256':hashlib.sha256(out.read_bytes()).hexdigest()});return out
base='G:/TouHou/MLforDanmu/exports/dialogue-portraits-20261105/raw-textures/TH16-Reimu-face/pl00/face_pl00bs.png'
p=copy(base,'th16-reimu-body.png');layers=[]
# Native TH16 ANM effective body: original PNG xOffset80, THTX575x660.
# Render source strips with black tint over the head, fading into the original lower body.
for y in range(0,660,4):layers.append({'file':'art/th16-reimu-body.png','x':80,'y':y,'cw':575,'ch':min(4,660-y),'cx':287.5,'cy':660-y,'tint':max(0,min(1,(y+2-220)/240))})
assets['maskedreimu']={'layers':layers,'scale':360/660}
for key,file,outname in [('mystiahappy','鸟开心.png','mystia-happy.png'),('mystiaspecial','鸟face_st02sp.png','mystia-special.png')]:
 p=copy(M/'dialogue2/art'/file,outname);im=Image.open(p).convert('RGBA');box=im.getchannel('A').getbbox();w,h=im.size
 assets[key]={'layers':[{'file':'art/'+outname,'x':0,'y':0,'cw':w,'ch':h,'cx':(box[0]+box[2])/2,'cy':box[3]}],'scale':.9*360/(box[3]-box[1]),'alignRightBottom':True,'visibleRight':(box[2]-box[0])/2,'visibleBottom':0}
copy(R/'work/logs/six-stages/mystia-portraits-20261113/source/stgenm/stg4enm.png','aya-th10.png')
provenance[-1].update(archive='G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/th10.dat',entry='stgenm04.anm / stgenm/stg4enm.png',use='Aya field sprite:64x64 frames0..7; retain current Mystia4f cadence/motion facing')
cutout=R/'work/logs/six-stages/patchouli-portrait-20261113/cutout.png'
if cutout.exists():
 p=copy(cutout,'patchouli-hina.png');im=Image.open(p).convert('RGBA');box=im.getchannel('A').point(lambda a:255 if a>8 else 0).getbbox();w,h=im.size
 assets['patchoulihina']={'layers':[{'file':'art/patchouli-hina.png','x':0,'y':0,'cw':w,'ch':h,'cx':(box[0]+box[2])/2,'cy':box[3]}],'scale':360/(box[3]-box[1]),'alignRightBottom':True,'visibleRight':(box[2]-box[0])/2,'visibleBottom':0}
sys.path.insert(0,'G:/TouHou/MLforDanmu/tools');from danmakufu_archive import Archive
archivePath=next(p for p in Path('G:/TouHou/th_hsob_112').rglob('img.dat')if p.parent.name=='img');arc=Archive(archivePath)
for no in [1,2,3]:
 e=next(e for e in arc.entries if e['name'].replace('\\','/').lower()==f'character/horou/horou{no}.png')
 b=arc.read(e);out=OUT/'art'/f'horou-{no}.png';out.write_bytes(b);im=Image.open(io.BytesIO(b)).convert('RGBA');box=im.getchannel('A').getbbox();w,h=im.size
 assets[f'horou{no}']={'layers':[{'file':f'art/horou-{no}.png','x':0,'y':0,'cw':w,'ch':h,'cx':(box[0]+box[2])/2,'cy':box[3]}],'scale':360/(box[3]-box[1])}
 provenance.append({'file':f'art/horou-{no}.png','source':str(archivePath)+'!'+e['name'],'sha256':hashlib.sha256(b).hexdigest()})
def portrait(key,label,text,paragraph=None):
 speaker=who[label]
 if key=='s2hinapre'and 'patchoulihina'in assets:return 'patchoulihina'
 if key=='s2mystiapre'and speaker=='mystia':return 'mystiaspecial'if t=='「哎呀，咱全身上下散发的都是大新闻的气息！」'else'mystiahappy'
 if speaker=='kaguya':
  if label=='不显示名字':return 'maskedreimu'
  if paragraph in KAGUYA_OVERRIDES:return KAGUYA_OVERRIDES[paragraph]
  return 'kaguya21'if '！'in text and '？'not in text else'kaguya5'if'？'in text else'kaguya1'
 match=known.get((key,text))
 if match:return match
 if speaker=='horou':return 'horou3'if key=='s5post'else'horou1'
 if speaker=='shion':return 'shion03'if key=='s3post'else'shion08'
 if speaker=='marisa':return 'marisano'if text=='「你谁啊。」'else'marisadp'if key=='s4post'else'marisan2'
 return {'wakasa':'wakasano','hina':'hinano','mystia':'mystian2','mamizou':'mamizouno','tanuki':'tanukino','ringo':'ringodp'if'post'in key else'ringon2','seiran':'seirann2','rabbit':'rabbitn2','suwako':'suwakono','fakesanae':'fakesanaeno','kanako':'kanakono'}[speaker]
# Verify default portrait spellings against the original loaded banks.
allArt=set(assets)
for d in old.values():allArt.update(d['art'])
scenes={}
for key,rows in raw.items():
 pages=[]
 for i,row in enumerate(rows,1):
  label,t=row['speaker_label'],row['text'];speaker=who[label];art=portrait(key,label,t,row['paragraph']);assert art in allArt,(key,label,art)
  for lines in [ns['lines'](t)[j:j+2]for j in range(0,len(ns['lines'](t)),2)]:
   p={'speaker':speaker,'portrait':art,'line':i,'text':t,'rows':lines,'displayName':''if label=='不显示名字'else'辉夜'if speaker=='kaguya'else label}
   if row['paragraph']is not None:p['paragraph']=row['paragraph']
   if key=='s5off':p['hideOtherPortrait']=True
   pages.append(p)
 scenes[key]=pages
alltext=''.join(p['text']+p['displayName']for pages in scenes.values()for p in pages)
ms=ns['glyph_checker']('C:/Windows/Fonts/msgothic.ttc');cn=ns['glyph_checker']('C:/Windows/Fonts/simsun.ttc');fallback={c:True for c in set(alltext)if not ms(c)};assert all(cn(c)for c in fallback)
data={'scenes':scenes,'art':assets,'fallback':fallback}
(OUT/'data.lua').write_text('return '+ns['lua'](data)+'\n','utf-8');(OUT/'text.json').write_text(json.dumps(raw,ensure_ascii=False,indent=2),'utf-8')
(OUT/'source.json').write_text(json.dumps({'document':json.loads(read(O/'source-paragraphs.json'))['source'],'document_sha256':json.loads(read(O/'source-paragraphs.json'))['sha256'],'assets':provenance,'confirmed':{'mask':'TH16 Reimu original body; runtime black tint0 through native y220; linear fade to fullcolor y460; hidden name until Stage4 revelation','revelation':'At 吾乃永远与须臾的公主，辉夜大人！ switch to existing HSoB Kaguya with name; no bald edit','prologue':'retain original3lines','money_line':'start of Mystia scene','laugh':'voice only random','ending':'not implemented per user; human-readable manuscript only'},'counts':{k:len(v)for k,v in raw.items()}},ensure_ascii=False,indent=2),'utf-8')
print('Prepared exact script',sum(len(v)for v in raw.values()),'lines;',len(scenes),'scene nodes; ending excluded')
if cutout.exists():
 p=OUT/'source.json';source=json.loads(read(p));source['patchouli_portrait']=json.loads(read(R/'work/logs/six-stages/patchouli-portrait-20261113/image-edit.json'));p.write_text(json.dumps(source,ensure_ascii=False,indent=2),'utf-8')
