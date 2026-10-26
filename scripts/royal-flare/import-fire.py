"""Decode the local TH06 split RGB/alpha texture into AEX's RGBA format.

No resizing, recoloring, synthesized pixels or overwrite of source archives.
"""
from pathlib import Path
import hashlib
import json
from PIL import Image

source = Path('G:/TouHou/MLforDanmu/data/local/touhou/th06-classic-20261010-v2/raw/峠杺嫿CM')
game = Path('G:/MySTG/aex-0.8.22/game/mod')
rgb_path, alpha_path = source/'etama3.png', source/'etama3_a.png'
rgb = Image.open(rgb_path).convert('RGB')
alpha = Image.open(alpha_path).getchannel('R')
assert rgb.size == alpha.size == (256, 256)
rgba = rgb.convert('RGBA')
rgba.putalpha(alpha)
assert rgba.getpixel((1, 193))[3] == 0
assert rgba.getpixel((15, 208))[3] == 253
assert rgba.convert('RGB').tobytes() == rgb.tobytes()
assert rgba.getchannel('A').tobytes() == alpha.tobytes()
for mod in ('RoyalFlareOrbit', 'RoyalFlareFollow'):
    output = game/mod/'th06-fire-local.png'
    rgba.save(output)
    (game/mod/'fire-source.json').write_text(json.dumps({
        'rgb_source': str(rgb_path), 'alpha_source': str(alpha_path),
        'rgb_sha256': hashlib.sha256(rgb_path.read_bytes()).hexdigest(),
        'alpha_sha256': hashlib.sha256(alpha_path.read_bytes()).hexdigest(),
        'output_sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
        'format': 'RGBA; RGB unchanged, A from alpha red channel',
        'animation': 'etama3.anm script7 sprites118..121, 5 ticks each',
        'collision_radius': [2, 2],
    }, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
print('TH06 RGB/alpha decoding PASS: exact source channels, no color/size edits.')
