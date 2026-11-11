from pathlib import Path
import json,shutil,hashlib
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8')
O=M/'art/selected05';O.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
rows=json.loads((B/'manifest.json').read_text(encoding='utf8'))['sprites'];art={};refs=[]
for i in range(6):
 row=next(r for r in rows if r['id']=='etama.entry0.sprite'+str(146+i));src=B/row['path'];dst=O/f'glow-{i}.png';shutil.copy2(src,dst)
 art['glow'+str(i)]={'path':dst.relative_to(M).as_posix(),'w':30,'h':30}
 refs.append({'name':'glow'+str(i),'source':str(src),'sha256':sha(src),'scale':1})
row=next(r for r in rows if r['id']=='etama.entry0.sprite13');src=B/row['path'];dst=O/'yellow-dot.png';shutil.copy2(src,dst)
art['yellowdot']={'path':dst.relative_to(M).as_posix(),'w':8,'h':8};refs.append({'name':'yellowdot','source':str(src),'sha256':sha(src)})
src=B/'etama/data/etama/etama3.png';im=Image.open(src);dst=O/'th08-blue-laser.png';im.crop((0,0,16,128)).save(dst)
art['laser']={'path':dst.relative_to(M).as_posix(),'w':16,'h':128};refs.append({'name':'laser','source':str(src),'sha256':sha(src),'rect':[0,0,16,128],'native_sprite221':[0,0,16,768],'note':'native height768 wraps the original128px strip6times; host repeats it to retained800px beam length'})
src=R/'work/marisa-mixed/change05/se_lazer00.wav';dst=M/'se/th08-se_lazer00.wav';shutil.copy2(src,dst)
refs.append({'name':'laserSound','source':str(src),'sha256':sha(src),'target':dst.relative_to(M).as_posix(),'note':'original TH08 standard laser sample used by playSound16 / Marisa non-directional laser'})
(M/'selected05-art.lua').write_text('SSGSelectedArt05='+lua(art)+'\n',encoding='utf8')
(M/'source/selected05-assets.json').write_text(json.dumps(refs,ensure_ascii=False,indent=2),encoding='utf8')
print('PASS exact original TH08 small-glow6palettes sprites146..151/laserstrip and se_lazer00 extracted')
