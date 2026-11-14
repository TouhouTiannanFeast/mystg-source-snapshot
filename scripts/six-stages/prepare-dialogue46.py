from pathlib import Path
import json,hashlib,shutil,runpy
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue46';S=R/'work/logs/six-stages/dialogue46-20261111/source'
M.mkdir(exist_ok=True);(M/'art').mkdir(exist_ok=True)
# Only definitions are reused; do not rerun the Stage3 asset preparation.
p=(R/'scripts/six-stages/prepare-dialogue3.py').read_text(encoding='utf-8-sig')
ns={'struct':__import__('struct'),'json':json,'Path':Path};exec(p[p.index('def glyph_checker'):p.index('hasMS=')],ns)
exec(p[p.index('def width('):p.index("data={'pre':")],ns)
raw={
's4rabbitpre':"""ringo|操。！
seiran|操操操。！
kaguya|这些家伙是月兔？
kaguya|连月兔们也抵挡不了这海量的污秽吗？
rabbit|西八。！
kaguya|这野兔魔了
kaguya|只好通通打醒了！""",
's4rabbitpost':"""ringo|咦？
ringo|刚才发生了什么？
seiran|呜哇——好恶心的污秽味道！这究竟是哪里？
kaguya|喂，你们两个
kaguya|还能想起的最后一件事是什么
ringo|哇，是公主大人！
seiran|已经变成了地上人的公主……要不我们假装没看见吧
kaguya|你们两个叽里咕噜地说什么呢
seiran|呜……没什么！
seiran|还请您假装从没遇到过我们。
ringo|月都命令我们必须清除见到的叛徒。
ringo|但我们并不想因此和公主大人打起来……""",
's4pre':"""marisa|喂！站住！
kaguya|嗯？叫我干什么
marisa|你谁啊。
kaguya|我是前来解决异变的巫女（笑）
marisa|你不是竹林里那个死宅公主吗？你怎么穿着灵梦的衣服？
marisa|怎么看都像是被污秽控制了吧？
kaguya|啊哦，你听我解释。
marisa|没有解释的必要了！
marisa|让我帮你恢复清醒！看招
kaguya|这下小伙可惨了。""",
's4post':"""marisa|我输了，怎么会……
kaguya|这下肯听我解释了吗？
kaguya|我只是怕被月都的人发现行踪，所以才穿了这身衣服隐藏身份……
marisa|原来如此，让我白高兴一场……
marisa|不过，你这身衣服确实很容易让人误会啊。
kaguya|说起来你也是出来调查异变的吗？
marisa|对啊，我刚刚才结束调查，从浅间净秽山那边回来。
marisa|没想到路上发现许多妖精都被一股莫名其妙的力量污染了神智。
marisa|我正准备继续起身前去调查呢。
kaguya|等等，你说的浅间净秽山是怎么回事？
marisa|要不你去找早苗问问吧。她好像知道很多事情。
marisa|我本来还打算继续问问她的。
marisa|结果她突然慌慌张张地跑掉了。
kaguya|她去了哪里？
marisa|不知道。好像是往守矢神社的方向去了。
kaguya|守矢神社……
marisa|你要去找她吗？
kaguya|看来只能这样了。
marisa|那我就先回家了。
marisa|输了的话，还是回去吃点心比较好。
kaguya|你倒是挺悠闲的。
marisa|肚子饿了嘛。""",
's6open':"""kaguya|这里的污秽浓度已经高得惊人了。
kaguya|看来这里就是污秽的源头。
kaguya|嗯？什么比动静……""",
's6midpre':"""suwako|……
kaguya|这作者都特么往游戏里做了点啥
kaguya|根本就没有这样的生物""",
's6midpost':"""kaguya|逃走了？
kaguya|千万别回来了""",
's6pre':"""kaguya|早苗？
kaguya|终于找到你了。
kaguya|魔理沙跟我说，你可能知道异变的原因。
fakesanae|我是早苗！
kaguya|不好……早苗身上的污秽浓度太高，都要溢出来了！
fakesanae|我才是早苗！
kaguya|完蛋，又疯了一个""",
's6battle':"""suwako|哈哈哈哈哈哈哈哈哈！""",
's6post':"""sanae|啊……
sanae|咦？我怎么会躺在地上？
kaguya|你终于恢复正常了。
sanae|辉夜小姐？
sanae|您为什么会在这里？
kaguya|我是被魔理沙忽悠来的。
kaguya|你刚才被海量的污秽控制了。
sanae|我记得我一直在调查浅间净秽山的事情……
sanae|但是，我突然感受到神社正在面临巨大的威胁，就急急忙忙回来了。
sanae|当我刚踏进守矢神社的时候，就失去意识了……
kaguya|看来你也只是一个受害人。""",
's6kanako':"""kanako|哎呀？没想到会有客人远道来访。
sanae|神奈子大人！
kanako|公主，有何贵干？
kaguya|你们的神社，正源源不断地涌出海量的污秽冲击外界啊……
kaguya|这件事情，你知道吗？
kanako|啊？你说什么？我没有听清。麻烦重复一遍。
kaguya|明明自家的巫女都得了失心疯了，你却这样慢悠悠地现身……
kaguya|恐怕你是故意的吧！
kanako|我只是想帮幻想乡一把。
kaguya|果然是你这讨人嫌的家伙……霸山占林又妄图侵占山下的神社的神
kaguya|就让我来惩治你！
kanako|我劝你不要不识好歹。
kanako|妨碍我收集信仰的家伙，我会一个一个地连根拔起！"""}
names={'kaguya':'辉夜','ringo':'铃瑚','seiran':'清兰','rabbit':'月兔','marisa':'魔理沙','suwako':'诹访子','sanae':'早苗','fakesanae':'“早苗”','kanako':'神奈子'}
scenes={};texts={};portraits={};files={}
def asset(rel,name=None):
 dest=M/'art'/(name or Path(rel).name)
 if not dest.exists():shutil.copyfile(S/rel,dest)
 files[dest.name]={'source':str(S/rel),'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()}
 im=Image.open(dest);return {'file':'art/'+dest.name,'w':im.width,'h':im.height}
def art(who,expr):
 key=who+expr
 if key in portraits:return key
 orig={'rabbit':'ringo','fakesanae':'nina'}.get(who,who)
 if orig=='suwako':
  layer=asset('C:/Users/Renko/AppData/Local/Temp/codex-clipboard-c12c3dda-0eb1-42e3-aee8-36d6cc00ee17.png','frog-user.png')
  layer.update(x=260,y=122,cw=446,ch=960,cx=223,cy=960)
  portraits[key]={'layers':[layer],'scale':360/960}
 elif orig=='marisa':
  body=asset('face/pl01/face_pl01bs.png');head=asset('face/pl01/face_pl01'+expr+'.png')
  # TH15 body/header offsets are120/0 and236/40 in the original ANM.
  body.update(x=120,y=0,cw=580,ch=660,cx=290,cy=660)
  head.update(x=236,y=40,cw=280,ch=244,cx=290-(236-120),cy=660-40)
  portraits[key]={'layers':[body,head],'scale':360/660}
 elif orig=='nina':
  folder='G:/TouHou/MLforDanmu/data/local/bullet-assets/th20-20261027/th20_9db8d7c43f/st07enm/face/enemy7/'
  body=asset(folder+'face01bs.png','watari-nina-bs.png');head=asset(folder+'face01no.png','watari-nina-no.png')
  body.update(cx=480,cy=880)
  head.update(x=310,y=83,cw=304,ch=213,cx=480-310,cy=880-83)
  portraits[key]={'layers':[body,head],'scale':360/880}
 elif orig in ('ringo','seiran'):
  num='02'if orig=='ringo'else'01';folder='face/enemy'+str(int(num))+'/'
  body=asset(folder+'face'+num+'bs.png');head=asset(folder+'face'+num+expr+'.png')
  dx,dy=(26,0)if orig=='ringo'else(180,112)
  body.update(cx=body['w']/2,cy=body['h']);head.update(cx=body['cx']-dx,cy=body['cy']-dy,x=dx,y=dy,cw=head['w']-dx,ch=head['h']-dy)
  portraits[key]={'layers':[body,head],'scale':360/body['h']}
 else:
  folder,num=('face/pl01/','_pl01')if orig=='marisa'else('face/enemy'+{'sanae':'5','suwako':'7','kanako':'6'}[orig]+'/',{'sanae':'05','suwako':'07','kanako':'06'}[orig])
  up=asset(folder+'face'+num+expr+'_u.png');down=asset(folder+'face'+num+'no_d.png')
  full=up['h']+down['h'];up.update(cx=up['w']/2,cy=full);down.update(cx=down['w']/2,cy=down['h'])
  portraits[key]={'layers':[down,up],'scale':360/full}
 return key
for scene,body in raw.items():
 rows=[]
 for line in body.splitlines():
  who,t=line.split('|',1)
  if who=='kaguya':expr='21'if('！'in t and '？'not in t)else'5'if'？'in t else'1'
  else:
   expr='no'
   if 'post'in scene:expr='dp'if who not in ('seiran',)else'n2'
   if scene=='s4rabbitpre':expr='n2'if who in('ringo','rabbit')else'an'
   if scene=='s4pre'and who=='marisa':expr='no'if t=='你谁啊。'else'an'if'！'in t else'n2'
   if scene=='s6post'and who=='sanae':expr='sw'if'？'in t else'dp'
   if who=='kanako':expr='dp'if('不识好歹'in t or'连根拔起'in t)else'no'
   if who=='suwako'and scene=='s6battle':expr='pr'
  portrait=who+expr if who=='kaguya'else art(who,expr)
  rows.append((who,expr,'「'+t+'」'))
  if who!='kaguya':assert portrait in portraits
 texts[scene]=rows;scenes[scene]=ns['pages'](rows)
alltext=''.join(t for rows in texts.values()for _,_,t in rows)+''.join(names.values())
hasMS=ns['glyph_checker']('C:/Windows/Fonts/msgothic.ttc');hasCN=ns['glyph_checker']('C:/Windows/Fonts/simsun.ttc')
fallback={c:True for c in set(alltext)if not hasMS(c)};assert all(hasCN(c)for c in fallback)
data={'scenes':scenes,'art':portraits,'names':names,'fallback':fallback,'voiceOnly':{'s6battle':True}}
(M/'data.lua').write_text('return '+ns['lua'](data)+'\n',encoding='utf-8')
(M/'text.json').write_text(json.dumps(texts,ensure_ascii=False,indent=2),encoding='utf-8')
(M/'source.json').write_text(json.dumps({'assets':files,'source':'TH15 pl01 Marisa and st01enm/st02enm rabbits; TH20 st07enm EX Watari Nina before defeat (st06enm is Iwanaga Ariya, previously misidentified); TH10 stgenm05/06 Sanae after defeat and Kanako; user image2 for Suwako. Original PNG bytes, separate layers and runtime ANM crops.','watari_identity':'Original TH20 omake.txt(cp932): EX Boss Watari Nina / 渡里ニナ -> st07enm. Stage6 Iwanaga Ariya -> st06enm; previous source identity was wrong.','confirmed_speaker':'公主，有何贵干？=神奈子','head_offsets':'TH15 script8/9 and ANM X/Y-Offset: Ringo(26,0), Seiran(180,112). thanm PNG includes white offset padding; LoadImage crops the effective THTX262x186 /222x212 rectangles without editing source PNGs.','counts':{k:len(v)for k,v in texts.items()},'voice_only':['s6battle'],'marisa_reference':'Image1 matches TH15 face_pl01no (small open mouth, no sweat/question/laugh symbol); used for 你谁啊。','suwako_reference':'User image2 bytes preserved; runtime rectangle260,122,446,960 is the original alpha bounding box; RGB and alpha bytes are unchanged, no white/black background is added.'},ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared',len(scenes),'scenes',sum(map(len,texts.values())),'lines',len(portraits),'portrait variants')

