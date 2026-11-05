"""Original TH10 Suwako body + user's current frog source, exact image copy."""
from pathlib import Path
import re,shutil,json,hashlib
R=Path('G:/MySTG');W=R/'work/th11-stage6/boss04';M=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
spec=(W/'stgenm07.anm.txt').read_text(encoding='utf-8-sig')
rows=[];lines=['TH11S6SuwakoSprites={}']
for filename,ids in [('stg7enm.png',range(15)),('stg7enm2.png',[30])]:
 src=W/'stgenm'/filename;dst=M/'milk/art'/filename;shutil.copy2(src,dst)
 tex='milk.original.'+src.stem;lines.append(f'LoadTexture("{tex}","milk/art/{filename}")')
 for sid in ids:
  q=re.search(r'sprite'+str(sid)+r': \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',spec)
  assert q
  img='milk.original.sprite'+str(sid);lines.append(f'LoadImage("{img}","{tex}",{",".join(q.groups())})');lines.append(f'TH11S6SuwakoSprites[{sid}]="{img}"')
 rows.append(dict(source=str(src),output=dst.relative_to(M).as_posix(),sha256=hashlib.sha256(src.read_bytes()).hexdigest(),origin='user revised frog (2026-11-03)' if filename=='stg7enm2.png' else 'original TH10'))
(M/'milk/actor-assets.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(M/'source/suwako04-reference.json').write_text(json.dumps(dict(archive='local TH10 stgenm07.anm',source_spec=str(W/'stgenm07.anm.txt'),source_spec_sha256=hashlib.sha256((W/'stgenm07.anm.txt').read_bytes()).hexdigest(),art=rows,body_scripts=[0,1,2,3,4],frog_script=19,frog_sprite=30,spawn_first=80,reset_period=120,frog_collision=False),indent=2),encoding='utf-8')
for sid in [0,1,2,3,4,19]:
 body=re.search(r'script script'+str(sid)+r' \{.*?\n\}',spec,re.S)[0]
 (M/'source'/f'suwako-anm{sid}.txt').write_text(body,encoding='utf-8')
print('Original Suwako body and current user frog copied byte-for-byte; original sprite30 crop/script19 retained')
