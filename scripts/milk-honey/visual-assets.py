from pathlib import Path
import json,shutil,hashlib
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MilkHoney'
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3')
rows=json.loads((B/'manifest.json').read_text(encoding='utf-8'))['sprites'];out=[]
for sid in [60,49,79,76]:
 r=next(s for s in rows if s['id'].endswith('.sprite'+str(sid)))
 shutil.copy2(B/r['path'],M/f'art/sprite{sid}.png');out.append(r)
ref={'revision':3,'mix':'per-layer every tenth bullet, no RNG consumed','sprites':{'yellow_ring':60,'red_ring':49,'white_rice':79,'yellow_rice':76},'assets':out,'pattern_sha256':hashlib.sha256((M/'pattern.lua').read_bytes()).hexdigest(),'collision':'unchanged main3/secondary2 halfsize, axis-aligned; draw-only rice rotation','heading':'native rice head local +Y; rotation = actual displacement angle -90degrees'}
(M/'source/visual-reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS four original sprite assets copied; pattern hash recorded.')
