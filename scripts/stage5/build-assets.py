from pathlib import Path
import sys,json,re,struct,subprocess,shutil,hashlib
from PIL import Image
ROOT=Path('G:/MySTG');OUT=ROOT/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5';WORK=ROOT/'work/stage5';WORK.mkdir(parents=True,exist_ok=True)
ML=Path('G:/TouHou/MLforDanmu');BG=ML/'data/local/backgrounds/th18-th185-20261026-v2/th18';BINS=ML/'work/research/thtk-nightly-x64/thtk-bin-ci'
sys.path.insert(0,str(ML/'tools'));from extract_touhou_backgrounds import parse_anm
sys.path.insert(0,str(ROOT/'work/suwako5/vendor'));import pefile

def run(args,cwd=None):
 p=subprocess.run(list(map(str,args)),cwd=cwd,capture_output=True);assert p.returncode==0,p.stderr;return p.stdout

def extract(game,anm):
 dest=WORK/f'th{game}'/Path(anm).stem;dest.mkdir(parents=True,exist_ok=True)
 gameDir=next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith(f'[th{game}]'))
 dat=next(gameDir.rglob(f'th{game}.dat'));run([BINS/'thdat.exe','-x',game,dat,'-C',dest,anm]);raw=dest/anm
 spec=run([BINS/'thanm.exe','-l',game,raw]).decode('utf-8');run([BINS/'thanm.exe','-x',game,raw],dest)
 (dest/'animation.spec.txt').write_text(spec,encoding='utf-8');return parse_anm(spec,dest,dest),dest

def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,(list,tuple)):return '{'+','.join(lua(x) for x in v)+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if v is None:return 'nil'
 if v is True:return 'true'
 if v is False:return 'false'
 return repr(v)

exe=next(next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith('[th18]')).rglob('th18.exe'));b=pefile.PE(str(exe)).get_memory_mapped_image()
refs=[];data={};textures={}

def archive(name,d,folder,ids=None):
 scripts={s['script_id']:s for s in d['scripts']}
 if ids is None:ids=set(scripts)
 else:
  ids=set(ids);todo=list(ids)
  while todo:
   s=scripts[todo.pop()]
   for i in re.findall(r'script(\d+)',s['raw_body']):
    i=int(i)
    if i not in ids:ids.add(i);todo.append(i)
 usedSprites=set();progs={}
 for sid in sorted(ids):
  s=scripts[sid];ls={x['label']:x['instruction_index']+1 for x in s['labels']};p=[]
  for row in s['program']:
   args=[]
   for x in row['arguments']:
    if isinstance(x,dict):x=x.get('sprite_reference',x.get('script_reference',x.get('label',x.get('source_expression',x))))
    if isinstance(x,str) and x in ls:x=ls[x]
    if isinstance(x,str) and re.fullmatch(r'(?:script|sprite)\d+',x):x=int(re.search(r'\d+',x)[0])
    args.append(x)
   if row['opcode']==300 and isinstance(args[0],int) and args[0]>=0:usedSprites.add(args[0])
   p.append([row['time'],row['opcode'],args])
  progs[sid]=p
 sprites={}
 for e in d['entries']:
  relevant=[s for s in e['sprites'] if s['sprite_id'] in usedSprites or name in ['bullet','ability','suwako']]
  if not relevant:continue
  if not e['texture']:continue
  src=folder/e['texture'];target=f'art/{name}-{e["entry_id"]}.png';dst=OUT/target;dst.parent.mkdir(exist_ok=True);shutil.copy2(src,dst)
  im=Image.open(src);tex=f'th18s5.{name}.{e["entry_id"]}';textures[tex]=[target,*im.size]
  refs.append({'source':str(src),'target':target,'sha256':hashlib.sha256(src.read_bytes()).hexdigest()})
  for s in relevant:sprites[s['sprite_id']]=[tex,*s['rect_xywh']]
 data[name]={'scripts':progs,'sprites':sprites}

enemy=json.loads((BG/'anm/enemy/animation.json').read_text(encoding='utf-8'));archive('enemy',enemy,BG,[40,53,56,59,91,105,214,251])
buldir=ML/'data/local/bullet-assets/20261010-all-works/th18_3949e7c01b/bullet';bul=parse_anm((buldir/'animation.spec.txt').read_text(encoding='utf-8'),buldir,buldir)
archive('bullet',bul,buldir,[28,40,42,43,72,73,101,112,113,120,121])
effect=json.loads((BG/'anm/effect/animation.json').read_text(encoding='utf-8'));archive('effect',effect,BG,[65])
ability,abdir=extract(18,'ability.anm');archive('ability',ability,abdir,[14])
suwako,sudir=extract(10,'stgenm07.anm');archive('suwako',suwako,sudir,[0,1,2,3,4])
bgd=json.loads((BG/'anm/st02wl/animation.json').read_text(encoding='utf-8'));archive('background',bgd,BG)
scene=next(s for s in json.loads((BG/'scenes.json').read_text(encoding='utf-8')) if s['id']=='st02.std')
std=[]
for row in scene['program']:
 a=[x.get('source_argb_u32') if isinstance(x,dict) else x for x in row['arguments']]
 if row['opcode']==1:a[0]=row['target_instruction_index']+1
 std.append([row['time'],row['opcode'],a])
data['scene']={'std':std,'entries':scene['entries']}
data['textures']=textures;data['bulletTypes']={}
for n in [5,7,8,18,19]:
 off=0xc5f90+n*0x118;script=struct.unpack_from('<I',b,off)[0]
 data['bulletTypes'][n]={'script':script,'colors':{c:struct.unpack_from('<I',b,off+4+c*16)[0] for c in range(16 if n in [5,7,8] else 8)},'spriteSets':{c:list(struct.unpack_from('<4I',b,off+4+c*16)) for c in range(16 if n in [5,7,8] else 8)},'radius':struct.unpack_from('<f',b,off+0x104)[0]}
data['itemTypes']={i:struct.unpack_from('<2i',b,0xb4020+i*8) for i in [1,2,9,16,17,18,19]}
# card database sprite field, keyed by card id, obtained through native 409310.
data['cardSprites']={i:struct.unpack_from('<I',b,0xc53f0+i*0x34)[0] for i in [3,4,5,6]}
(OUT/'data.lua').write_text('-- Generated original STD/ANM/art/native tables.\nTh18Stage5Data='+lua(data)+'\n',encoding='utf-8')
(OUT/'assets-source.json').write_text(json.dumps({'records':refs,'native':{'path':str(exe),'sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'bulletTable':'0x4c5f90 stride0x118 colors+4 stride16; sprite callback0x429a20','itemTable':'0x4b4020 stride8','cardSpriteTable':'0x4c53f0 stride0x34'}},ensure_ascii=False,indent=2),encoding='utf-8')
print('ASSETS',len(refs),'scripts',[(k,len(v['scripts'])) for k,v in data.items() if isinstance(v,dict) and 'scripts' in v]);print('CARD',data['cardSprites']);print('ANM opcodes',sorted({op[1] for k in ['enemy','background'] for p in data[k]['scripts'].values() for op in p}));print('suwako',[(i,p[:4]) for i,p in list(data['suwako']['scripts'].items())[:5]])

