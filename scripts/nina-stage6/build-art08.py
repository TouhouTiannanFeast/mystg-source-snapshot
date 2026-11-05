from pathlib import Path
import shutil,json,hashlib
from PIL import Image
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal');bank=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites')
out=['Nina08LocalArt={}'];refs=[]
for sid in list(range(16,48))+[54]+list(range(136,152)):
 src=bank/('etama.entry0.sprite'+str(sid)+'.png');dst=M/'art'/('th08-'+str(sid)+'.png');shutil.copy2(src,dst);w,h=Image.open(dst).size
 out.append('Nina08LocalArt['+str(sid)+']={image="nina.th08.etama.'+str(sid)+'",path="art/th08-'+str(sid)+'.png",w='+str(w)+',h='+str(h)+',radius=4}')
 refs.append(dict(source=str(src),target=dst.relative_to(M).as_posix(),sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
for i,n in enumerate([22,23,21]):
 src=M.parent/'TH11Stage6Normal/art/frog09'/('th12-'+str(n)+'-y.png');dst=M/'art'/('yellow-frog'+str(i)+'.png');shutil.copy2(src,dst);w,h=Image.open(dst).size
 out.append('Nina08LocalArt['+str(1000+i)+']={image="nina.yellow-frog'+str(i)+'",path="art/yellow-frog'+str(i)+'.png",w='+str(w)+',h='+str(h)+'}')
 refs.append(dict(source=str(src),target=dst.relative_to(M).as_posix(),sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
out+=['function Nina08Art.lookup(t,c) return Nina08LocalArt[(t==2 and 16 or t==3 and 32 or 136)+c]end','Nina08Art.actor.familiar=Nina08LocalArt[54]']
(M/'art08-local.lua').write_text('\n'.join(out),encoding='utf-8');(M/'source/art08-local.json').write_text(json.dumps(refs,indent=2),encoding='utf-8')
print('Copied33 TH08 original slices; mapping/collision adapted as documented')
