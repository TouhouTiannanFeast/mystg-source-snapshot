from pathlib import Path
import hashlib, json, shutil

ROOT = Path('G:/MySTG')
MOD = ROOT / 'aex-0.8.22/game/mod/RingoSeiran'
CORPUS = Path('G:/TouHou/MLforDanmu/data/local/touhou/th165-20261026')
RAW = CORPUS / 'th165_local-original-archive-candidate_dc0fde5b6c72/raw'
ART = Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/th165-20261026/th165_dc0fde5b6c')
files = []
def copy(src, dst):
    dst = MOD / dst
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    files.append({'source': str(src), 'path': str(dst.relative_to(MOD)),
                  'sha256': hashlib.sha256(dst.read_bytes()).hexdigest()})

for stem in ('ec_0803', 'ec_0204'):
    for suffix in ('.ecl', '.named.utf8.txt', '.numeric.txt'):
        copy(RAW / (stem + suffix), 'source/' + stem + suffix)
copy(ART / 'enm02/stgenm/02/enm1.png', 'art/seiran.png')
copy(ART / 'enm03/stgenm/03/enm2.png', 'art/ringo.png')
for char in ('enm02', 'enm03'):
    copy(ART / char / 'animation.spec.txt', 'source/' + char + '.anm.txt')
manifest = json.loads((ART / 'manifest.json').read_text(encoding='utf-8'))
# Native type1 uses sprite0+colour (small round). Added guns use THlib gun_bullet.
for sprite, name in ((4, 'dango-blue'), (2, 'dango-red'), (14, 'dango-pink')):
    candidates = [s for s in manifest['sprites'] if s['id'] == f'bullet.entry0.sprite{sprite}']
    assert len(candidates) == 1
    copy(ART / candidates[0]['path'], 'art/' + name + '.png')
# Existing white pixel is used solely by the local impact-ring renderer.
copy(ROOT / 'aex-0.8.22/game/mod/YuyukoStage3/art/pixel.png', 'art/pixel.png')
th07 = Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th07_local-original-archive-candidate_5fe8d7721915/raw/ecldata6.numeric.txt').read_text(encoding='utf-8', errors='replace')
(MOD / 'source/th07-Sub53.txt').write_text(th07[th07.index('sub Sub53()'):th07.index('sub Sub54()')], encoding='utf-8')
provenance = {
    'source': json.loads((CORPUS / 'build-provenance.json').read_text(encoding='utf-8')),
    'mapping': {'nonspell': 'ec_0803 / AttackFunc / BossCard1_at; 30s untitled',
                'spell': 'ec_0204 / AttackFunc / BossCard1_at; original70s, HP8000; custom title 西八「打你就像打蚂蚁」',
                'pursuit_reference': 'TH07 Sub53 samples target once and interpolates120f. Local Seiran uses smoothstep and a texture-anchor offset to put its native hammer at the sampled target; no original butterfly pattern.'},
    'files': files,
    'impact_pellets': {'count':12,'initial_speed':[6,12],'stop_frames':[8,20],'lifetime':90,'deceleration':'independent constant initial_speed/stop_frames','sprite':'existing type1 red','radius':2.4,'rng':'separate stream'},
    'adaptation': 'No photo mechanic/counterattacks. Seiran uses original firing ANM script5/6; invulnerable contact-dangerous familiar with body ellipse16x28,18 guns in6 equilateral triangle groups(radius5),speed2/THlib gun radius2.5,120f cadence,texture-anchor hammer hitbox and impact shake10f/2px are local choices. Default THlib player/background/gun_bullet; no added music.'
}
(MOD / 'source/provenance.json').write_text(json.dumps(provenance, ensure_ascii=False, indent=2), encoding='utf-8')
print('PASS: two original ECL closures, native character/bullet art and provenance copied.')
