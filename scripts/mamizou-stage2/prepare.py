"""Pin source spans and import original RGBA rectangles, without editing inputs."""
from pathlib import Path
import hashlib,json,re,shutil,struct
from importlib.machinery import SourceFileLoader
from PIL import Image
ROOT=Path('G:/MySTG'); MOD=ROOT/'aex-0.8.22/game/mod/MamizouStage2'
LIB=Path('G:/TouHou/MLforDanmu/data/local')
T13=LIB/'touhou/20261006-022841/th13_local-original-archive-candidate_3443fe0df11d/raw/st07bs.named.utf8.txt'
T185=LIB/'touhou/th185-20261010/th185_local-original-archive-candidate_5af133f02add/raw/boss22.named.utf8.txt'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def spans(p,names):
 text=p.read_text(encoding='utf-8');matches=list(re.finditer(r'^void (\w+)\([^\n]*\)\n\{',text,re.M));out=[]
 for i,m in enumerate(matches):
  if m[1] not in names:continue
  end=matches[i+1].start() if i+1<len(matches) else len(text)
  out.append(dict(name=m[1],first_line=text[:m.start()].count('\n')+1,last_line=text[:end].count('\n'),text=text[m.start():end]))
 assert {x['name'] for x in out}==set(names)
 return dict(path=str(p),sha256=sha(p),subroutines=out)
names13=['Boss1','Boss1_at','Boss2','Boss2_at','BossCard5','BossCard5_at','BossCard5_at2','BossCard5_at3','BossCard3_EtAt','BossCard4_EtAt','BossCard4_EtAt_at','BossCard10','BossCard10_at','BossCard10_EtAt','BossCard10_EtAt_at']
ref={'th13':spans(T13,names13),'th185':spans(T185,['Boss22BossCard1','Boss22BossCard1_at'])}
binary=SourceFileLoader('binary',str(ROOT/'scripts/mamizou-stage2/inspect-binary.py')).load_module()
types={}
for t in (8,18,19,32):
 data=binary.at(0x4bbe30+t*0x114,0x114)
 types[t]={'main_script':struct.unpack_from('<I',data)[0], 'radius':struct.unpack_from('<f',data,0x104)[0], 'sprites':[struct.unpack_from('<I',data,4+16*c)[0] for c in range(8 if t!=8 else 16)]}
ref['th13_type_table']={'executable':str(binary.p),'sha256':sha(binary.p),'base_va':'0x4bbe30','stride':276,'types':types,'evidence':'0x40eead loads type radius +0x104; 0x41009e type descriptor; 0x4100f2 main ANM script'}
assets=[]; rows=[]; art=MOD/'art';art.mkdir(exist_ok=True)
bank=LIB/'bullet-assets/20261010-all-works/th13_3443fe0df1'
manifest=json.loads((bank/'manifest.json').read_text(encoding='utf-8'))
byid={int(r['id'].split('sprite')[-1]):r for r in manifest['sprites'] if 'path' in r and r['id'].startswith('bullet.')}
def copy_sprite(sid,name,radius):
 row=byid[sid];src=bank/row['path'];assert sha(src)==row['sha256']
 dst=art/(name+'.png');shutil.copyfile(src,dst);w,h=Image.open(dst).size
 assets.append({'name':name,'source':str(src),'sha256':sha(src),'output':'art/'+dst.name,'sprite_id':sid})
 rows.append((name,w,h,radius))
for t,colors in ((18,(1,3,6)),(19,(4,)),(32,(1,3)),(8,(13,))):
 for c in colors:copy_sprite(types[t]['sprites'][c],f't{t}c{c}',types[t]['radius'])
def crop_atlas(spec,root,prefix,selected):
 text=spec.read_text(encoding='utf-8-sig')
 # Entry blocks stop before their following scripts; paths/rectangles stay exact.
 for entry in re.split(r'(?=^entry entry\d+ \{)',text,flags=re.M):
  path=re.search(r'    name: "([^"]+)"[,;]',entry)
  if not path:continue
  texture=root/path[1]
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1])
   if sid not in selected:continue
   x,y,w,h=map(lambda v:int(float(v)),m.groups()[1:]);img=Image.open(texture).convert('RGBA');crop=img.crop((x,y,x+w,y+h));name=prefix+str(sid);dst=art/(name+'.png');crop.save(dst)
   assert Image.open(dst).tobytes()==crop.tobytes()
   assets.append(dict(name=name,source=str(texture),source_sha256=sha(texture),rect=[x,y,w,h],output='art/'+dst.name,sha256=sha(dst)))
   rows.append((name,w,h,0 if sid<12 else 6.5))
crop_atlas(MOD/'source/st07enm.spec.txt',MOD/'source','th13-',list(range(12))+list(range(18,24)))
crop_atlas(MOD/'source/boss22.spec.txt',MOD/'source','th185-',list(range(15,18)))
lua=['-- Original local rectangles and executable type radii.','MamizouArt={}']
for name,w,h,r in rows:
 lua.append(f"LoadTexture('mz.{name}','art/{name}.png')")
 lua.append(f"LoadImage('mz.{name}','mz.{name}',0,0,{w},{h},{r},{r})")
 lua.append(f"MamizouArt['{name}']={{w={w},h={h},radius={r}}}")
(MOD/'assets.lua').write_text('\n'.join(lua)+'\n',encoding='utf-8')
(MOD/'reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(MOD/'asset-provenance.json').write_text(json.dumps(assets,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Pinned {len(names13)+2} source routines; exact TH13 type descriptors; {len(assets)} original sprites.')
