"""Current TH11 road validation entry: scoped change03 regression."""
from pathlib import Path
import json,hashlib,runpy
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
ref=json.loads((M/'reference.json').read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(Path(ref['source']))==ref['source_sha256']
for row in ref['art']:assert sha(M/row['output'])==row['sha256']
for row in ref['sounds']:assert sha(M/'se'/row['file'])==row['sha256']
runpy.run_path(str(R/'scripts/th11-stage6/verify03.py'))
runpy.run_path(str(R/'scripts/th11-stage6/verify04.py'))
