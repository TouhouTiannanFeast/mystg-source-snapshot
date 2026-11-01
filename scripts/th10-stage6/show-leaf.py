import re
from pathlib import Path
s=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3/bullet/animation.spec.txt').read_text(encoding='utf-8')
print(re.search(r'script script428 \{(.*?)\n\}',s,re.S)[1])
