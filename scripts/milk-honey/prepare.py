from pathlib import Path
import hashlib,json,re,shutil,struct
R=Path('G:/MySTG'); M=R/'aex-0.8.22/game/mod/MilkHoney'
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3')
E=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage07.named.utf8.txt')
text=E.read_text(encoding='utf-8'); spec=(B/'bullet/animation.spec.txt').read_text()
excerpt='\n\n'.join(re.search(r'void '+n+r'\([^)]*\)\s*\{.*?\n\}',text,re.S)[0] for n in ['BossCard7','BossCard7_at','BossCard7_at2'])
(M/'source/BossCard7.ecl.txt').write_text(excerpt,encoding='utf-8')
sprites=json.loads((B/'manifest.json').read_text(encoding='utf-8'))['sprites']; rows=[]
for sid in [336,337,338,339,72,215]:
 row=next(s for s in sprites if s['id'].endswith('.sprite'+str(sid)))
 shutil.copy2(B/row['path'],M/f'art/sprite{sid}.png');rows.append(row)
scripts='\n\n'.join(re.search(r'script script'+str(s)+r' \{.*?\n\}',spec,re.S)[0] for s in [373,104])
(M/'source/bullet-anm.txt').write_text(scripts,encoding='utf-8')
ref={'source':str(E),'source_sha256':hashlib.sha256(E.read_bytes()).hexdigest(),'archive_sha256':json.loads((B/'manifest.json').read_text(encoding='utf-8'))['source_sha256'],
 'card':{'HP':4500,'duration_frames':6300,'start':80,'secondary_start':180,'move_first':140,'move_period':120,'move_duration':60,'move_speed':1,'move_mode':4},
 'bullets':{'main':{'type':18,'color':0,'script':373,'collision_full_width':6,'sprites':[336,337,338,339]},'secondary':{'type':3,'color':8,'script':104,'collision_full_width':4,'sprite':72},'birth_frames':8,'birth_motion':'minus 4 initial velocities then half velocity during birth','cull_delay':240,'acceleration':0.032,'acceleration_frames':120},
 'engine_evidence':['upstream/th10/src/BulletManager.cpp: SpawnSingleBullet, default etNew flags 0x203','upstream/th10/src/BulletRuntime.cpp: half-speed birth, active transform then position integration','upstream/th10/src/BulletTransform.cpp:8192 sets culling timer without waiting','upstream/th10/src/EnemyEclDispatcher.cpp: etNew defaults and moveRand','retail th10.exe: sprite-script table 0x474170; collision-width table 0x4741e0'],
 'assets':rows,'limits':['AEX player collision/graze and RNG do not guarantee retail replay parity.','Boss uses existing engine placeholder sprite; original boss/scene/music are not imported.']}
(M/'source/reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared ECL excerpt, two original ANM scripts and six source-identical sprite crops.')
