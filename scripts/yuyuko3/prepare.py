from pathlib import Path
import re,json,hashlib,shutil
from PIL import Image
R=Path('G:/MySTG'); M=R/'aex-0.8.22/game/mod/YuyukoStage3'
E=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th07_local-original-archive-candidate_5fe8d7721915/raw/ecldata6.numeric.txt')
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th07_5fe8d77219')
L=Path('G:/TouHou/MLforDanmu/data/local/lenen/native-complete-20261018/le04')
for p in [M/'art',M/'source']:p.mkdir(parents=True,exist_ok=True)
t=E.read_text('cp932'); subs=[2,34,35,38,39,40,41,42,50,51,62,64,65,66,67,68,69,70,71]
(M/'source/th07-selected.ecl.txt').write_text('\n\n'.join(re.search(r'sub Sub'+str(n)+r'\(\).*?\n\}',t,re.S)[0] for n in subs),'utf-8')
for name in ['00508870','0050c300','0044c090','005910f0','0062add0']:
 for ext in ['c','asm']:shutil.copy2(L/f'functions/{name}.{ext}',M/f'source/le04-{name}.{ext}')
shutil.copy2(L/'referenced-constants.json',M/'source/le04-constants.json')
shutil.copy2(R/'work/yuyuko3/art/data/stgenm/stg6enm2.png',M/'art/yuyuko.png')
spec=(B/'etama/animation.spec.txt').read_text('utf-8'); manifest=json.loads((B/'manifest.json').read_text('utf-8'))
rows=manifest['sprites']; art={}
for typ in [0,1,3,5,6,8,10]:
 body=re.search(r'script '+('0 ' if typ==10 else '')+'script'+str(25 if typ==10 else typ)+r' \{.*?\n\}',spec,re.S)[0]
 base=int(re.search(r'ins_3\(sprite(\d+)\)',body)[1]); count=8 if typ in [8] else (4 if typ==10 else 16)
 for col in range(count):
  sid=base+col; entry=1 if typ==10 else 0
  if typ==10 and col==0:
   Image.open(B/'etama/data/etama/etama2.png').crop((0,0,64,64)).save(M/'art/th07-10-0.png')
   art['10-0']={'entry':1,'sprite':0,'rect':[0,0,64,64]};continue
  row=next(s for s in rows if s['id']==f'etama.entry{entry}.sprite{sid}')
  shutil.copy2(B/row['path'],M/f'art/th07-{typ}-{col}.png');art[f'{typ}-{col}']={'entry':entry,'sprite':sid,'path':row['path']}
LB=Path('G:/TouHou/MLforDanmu/data/local/lenen/20261018-supplement/le04/raw/img/bullet')
for typ in [3,10,12]:shutil.copy2(LB/f'b{typ:03d}.png',M/f'art/le04-{typ}.png')
src=R/'work/yuyuko3/th07/src/th07'
for name in ['EnemyEclInstr.cpp','BulletManager.cpp','EclManager.cpp']:
 shutil.copy2(src/name,M/f'source/th07-{name}')
shutil.copy2(R/'work/yuyuko3/th07/LICENSE',M/'source/th07-reference-LICENSE')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ref={'th07_ecl':str(E),'th07_ecl_sha256':sha(E),'th07_reference':{'repository':'https://github.com/some100/th07','commit':'4878bf0e42a9280ef44735eb0517d4fda7cb6e04'},'le04_executable_sha256':json.loads((L/'boss-dispatch.json').read_text('utf-8'))['source_sha256'],'mapping':{'non1':'TH07 Sub34/35 Normal','spell1':'TH07 Sub50/51 Normal','non2':'LE04 boss30 phase7 FUN_0050c300 Normal; title removed','spell2':'LE04 boss30 phase3 FUN_00508870 Normal','non3':'TH07 Sub38/39/40/41/42 Normal','spell3':'TH07 Sub62/64..71 Easy; EX0/8'},'bullet_art':art}
(M/'source/reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2),'utf-8')
print('Prepared selected original routines, source constants, TH07 reference and original Yuyuko/bullet images.')
