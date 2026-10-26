"""Prepare one stage, pin local source and embed existing approved attacks."""
from pathlib import Path
import json,re,hashlib,shutil,runpy,struct
from PIL import Image
ROOT=Path('G:/MySTG');MOD=ROOT/'aex-0.8.22/game/mod/Stage2Full';BANK=Path('G:/TouHou/MLforDanmu/data/local')
SRC=BANK/'touhou/20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage02.named.utf8.txt'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
text=SRC.read_text(encoding='utf-8');subs={}
ms=list(re.finditer(r'^void (\w+)\([^\n]*\)\n\{',text,re.M))
for i,m in enumerate(ms):subs[m[1]]=text[m.end():ms[i+1].start() if i+1<len(ms) else len(text)].rsplit('}',1)[0]
events=[]
def schedule(name,offset=0):
 t=offset;enabled=True
 for line in subs[name].splitlines():
  line=line.strip()
  if line.startswith('!'):enabled=line=='!*' or 'N' in line;continue
  m=re.match(r'\+(\d+):',line)
  if m:t+=int(m[1]);continue
  if not enabled:continue
  m=re.match(r'enmCreate(A\w*)\("(\w+)", (-?[\d.]+)f, (-?[\d.]+)f, (\d+), (\d+), (\d+)\);',line)
  if m:events.append(dict(t=t,flags=m[1],name=m[2],x=float(m[3]),y=float(m[4]),hp=int(m[5]),score=int(m[6]),drop=int(m[7]),source=name))
  m=re.match(r'@(MainSub\d+)\(\) async;',line)
  if m:schedule(m[1],t)
schedule('main');events.sort(key=lambda e:e['t'])
assert len([e for e in events if e['name']=='Girl01'])==14
assert len([e for e in events if e['name']=='Girl02'])==1
assert len([e for e in events if e['name'].endswith('Girl00C')])==16
lines=['Stage2Schedule={']
for e in events:
 lines.append('{t=%d,name=%s,x=%s,y=%s,hp=%d,mirror=%s,postmid=%s},'%(e['t'],json.dumps(e['name']),e['x'],e['y'],e['hp'],'true' if 'M' in e['flags'] else 'false','true' if 'F' in e['flags'] else 'false'))
lines.append('}')
(MOD/'schedule.lua').write_text('\n'.join(lines)+'\n')
(MOD/'source/route-events.json').write_text(json.dumps(events,indent=2)+'\n')
shutil.copyfile(SRC,MOD/'source/stage02.named.utf8.txt')
rows=[];assets=[];(MOD/'art').mkdir(exist_ok=True)
def crop(spec,prefix,ids):
 for entry in re.split(r'(?=^entry entry\d+ \{)',spec.read_text(encoding='utf-8-sig'),flags=re.M):
  p=re.search(r'name: "([^"]+)"',entry)
  if not p:continue
  src=MOD/'source'/p[1]
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1])
   if sid not in ids:continue
   r=list(map(lambda s:int(float(s)),m.groups()[1:]));x,y,w,h=r
   dst=MOD/'art'/f'{prefix}{sid}.png';Image.open(src).convert('RGBA').crop((x,y,x+w,y+h)).save(dst)
   rows.append((prefix+str(sid),w,h));assets.append(dict(path=str(src),sha256=sha(src),rect=r,out=str(dst.relative_to(MOD)),output_sha256=sha(dst)))
crop(MOD/'source/enemy.spec.txt','enemy-',list(range(48))+list(range(49,61))+list(range(96,108)))
crop(MOD/'source/stgenm02.spec.txt','hina-',list(range(16)))
# Exact TH10 type/color sprite mapping from etama main ANM scripts.
bank=BANK/'bullet-assets/20261010-all-works/th10_1fb1d0ffe3'
manifest=json.loads((bank/'manifest.json').read_text(encoding='utf-8'))
byid={int(r['id'].split('sprite')[-1]):r for r in manifest['sprites'] if r.get('path') and r['id'].startswith('bullet.')}
for sid in (50,54,58,61,67,77,98,102,106,109):
 r=byid[sid];src=bank/r['path'];dst=MOD/'art'/f'bullet-{sid}.png';shutil.copyfile(src,dst);w,h=Image.open(src).size
 rows.append((f'bullet-{sid}',w,h));assets.append(dict(path=str(src),sha256=sha(src),out=str(dst.relative_to(MOD)),output_sha256=sha(dst)))
(MOD/'assets.lua').write_text('\n'.join("LoadTexture('s2.%s','art/%s.png')\nLoadImage('s2.%s','s2.%s',0,0,%d,%d)"%(n,n,n,n,w,h) for n,w,h in rows)+'\n')
orig=ROOT/'aex-0.8.22/game/mod'
components=[]
for folder,dest,cls,api in [('MamizouStage2','mamizou','Mamizou','Mamizou'),('RoyalFlareFollow','flare','Patchouli','Flare'),('MystiaAyaNon3EasyLarge','mystia','Mystia','Mystia')]:
 src=orig/folder;out=MOD/dest;out.mkdir(exist_ok=True)
 for p in src.iterdir():
  if p.is_file() and p.suffix=='.png':shutil.copyfile(p,out/p.name)
 if folder=='MamizouStage2':
  shutil.copytree(src/'art',out/'art',dirs_exist_ok=True)
  shutil.copyfile(src/'pattern.lua',out/'pattern.lua')
  (out/'assets.lua').write_text((src/'assets.lua').read_text(encoding='utf-8').replace("'art/","'mamizou/art/"),encoding='utf-8')
 if folder.startswith('Mystia'):shutil.copyfile(src/'pattern.lua',out/'pattern.lua')
 code=(src/'root.lua').read_text(encoding='utf-8').split('local Hud=Class(object)')[0]
 code=code.replace("Include('THlib.lua')",'').replace("Include('assets.lua')",f"Include('{dest}/assets.lua')").replace("Include('pattern.lua')",f"Include('{dest}/pattern.lua')")
 code=re.sub(r"(LoadTexture\('[^']+',')([^']+)(('\)))",lambda m:m[1]+dest+'/'+m[2]+m[3],code)
 code=code.replace("'th08-large-'","'mystia/th08-large-'")
 if api=='Mamizou':reset='clean();D.stats={};D.finished=false;D.ringIndex=0;D.randomIndex=0'
 elif api=='Flare':reset='clean();for k,v in pairs(D) do if type(v)=="number" then D[k]=0 end end;D.tick=-1;D.phases={};D.finished=false;D.arrived=false;D.moveTick=0;D.stationaryChecks=0;D.centerChecks=0'
 else:reset='clean();for k,v in pairs(D) do if type(v)=="number" then D[k]=0 end end;D.tick=-1;D.finished=false'
 code+=f'\nStage2{api}={{Boss={cls},clean=clean,state=D,'+('card=card,' if api!='Mamizou' else 'cards=cards,')+f'reset=function() {reset} end}}\n'
 (out/'attack.lua').write_text(code,encoding='utf-8')
 components.append(dict(component=folder,source=str(src/'root.lua'),source_sha256=sha(src/'root.lua'),embedded_sha256=sha(out/'attack.lua')))
b=runpy.run_path(str(ROOT/'scripts/stage2-full/inspect-binary.py'))
types={t:{'script_base':struct.unpack('<I',b['at'](0x474170+4*t,4))[0],'collision_full_width':struct.unpack('<f',b['at'](0x4741e0+4*t,4))[0]} for t in (2,3,5)}
ref=dict(th10_source=str(SRC),th10_sha256=sha(SRC),events=len(events),components=components,assets=assets,th10_types=types,changes={'human_fairies':'all 36 post-title pre-midboss fairies: 16 Girl00C + 20 Girl00B','rice_speed':3,'rice_count':7,'sunflowers':14,'removed':'Girl02 at4964','mystia':'Easy large provisional','difficulty':'Normal','midboss_appearance':'Patchouli throughout'})
(MOD/'reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Prepared',len(events),'source spawn events, 14 sunflowers, 36 human fairies; embedded 3 existing attacks.')
