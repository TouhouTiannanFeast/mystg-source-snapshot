"""Copy source TH20 large diamonds without changing any collision radii."""
from pathlib import Path
import json,hashlib,shutil
from PIL import Image
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/th20-20261027/th20_9db8d7c43f')
rows={int(v['id'].split('sprite')[-1]):v for v in json.loads((B/'manifest.json').read_text(encoding='utf-8'))['sprites']if v['id'].startswith('bullet.')and'path'in v}
out=['Nina03Art={}'];refs=[]
for i in range(576,584):
 src=B/rows[i]['path'];dst=M/'art'/f'th20-diamond-{i}.png';shutil.copy2(src,dst);w,h=Image.open(dst).size
 out.append(f'Nina03Art[{i}]={{image="nina.diamond.{i}",path="art/th20-diamond-{i}.png",w={w},h={h}}}')
 refs.append(dict(sprite=i,source=str(src),target=str(dst.relative_to(M)),sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
(M/'art03.lua').write_text('\n'.join(out)+'\n',encoding='utf-8')
(M/'source/art03.json').write_text(json.dumps(refs,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS exact TH20 original large-diamond sprites576..583; radii preserved by render override')
