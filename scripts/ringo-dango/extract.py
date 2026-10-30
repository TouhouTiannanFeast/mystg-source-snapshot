from pathlib import Path
import hashlib,json,shutil,sys,struct,runpy
root=Path('G:/MySTG'); mod=root/'aex-0.8.22/game/mod/RingoDango'; src=mod/'source'
corpus=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th15_local-original-archive-candidate_f3802e71db30/raw')
for name in ('st02bs.ecl','st02bs.named.utf8.txt','st02bs.numeric.txt'):
 shutil.copy2(corpus/name,src/name)
text=(src/'st02bs.named.utf8.txt').read_text(encoding='utf-8')
part=text[text.index('void BossCard2()'):text.index('void BossCard2_at2()')]
(src/'BossCard2.txt').write_text(part,encoding='utf-8')
assets=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th15_f3802e71db')
manifest=json.loads((assets/'manifest.json').read_text(encoding='utf-8'))
out=[]
for sprite,name in ((2,'pellet'),(100,'outline'),(370,'mentos')):
 candidates=[s for s in manifest['sprites'] if s['id'].startswith('bullet.') and s['id'].endswith('.sprite'+str(sprite))]
 assert len(candidates)==1,candidates
 s=candidates[0]; shutil.copy2(assets/s['path'],mod/(name+'.png')); out.append(s)
shutil.copy2(src/'stgenm/stage02/enm2.png',mod/'ringo.png')
files={str(p.relative_to(mod)):hashlib.sha256(p.read_bytes()).hexdigest() for p in src.glob('*') if p.is_file()}
pe=Path('G:/TouHou/[th15]+东方绀珠传+(汉化版+日文版)/th15.exe')
(src/'provenance.json').write_text(json.dumps({'archive':manifest['source'],'archive_sha256':manifest['source_sha256'],'exe':str(pe),'exe_sha256':hashlib.sha256(pe.read_bytes()).hexdigest(),'extracted_files':files,'bullet_sprites':out,'difficulty':'Normal','entry':'st02bs BossCard2 / BossCard2_at','unused_helper':'BossCard2_at2 is not called; excluded'},ensure_ascii=False,indent=2),encoding='utf-8')
print('Extracted BossCard2 closure, full st02bs ECL, original Ringo texture and three exact bullet sprites.')
