from pathlib import Path
import hashlib,json,sys,io,contextlib
sys.path.insert(0,str(Path(__file__).parent));import inspect02 as n
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed')
src=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th08_local-original-archive-candidate_9d7edf43b8dd/raw/ecldata4b.named.utf8.txt')
s=src.read_text(encoding='utf8');s=s[s.index('sub Sub41()'):s.index('sub Sub47()')]
(M/'source/stardust03-ecl.txt').write_text(s,encoding='utf8')
windows=[(0x430012,0x55),(0x43013e,0x15),(0x430538,0x3b),(0x43141f,0x50),(0x4301db,0xc5),(0x4322b0,0x75),(0x40e390,0x19),(0x42067c,0x10),(0x4206c2,0x17),(0x422c7a,0xd6)]
out=io.StringIO()
with contextlib.redirect_stdout(out):
 for a,size in windows:print('\nWINDOW',hex(a));n.dump(a,size)
(M/'source/stardust03-native.txt').write_text(out.getvalue(),encoding='utf8')
ref={'source':str(src),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'native':str(n.P),'native_sha256':hashlib.sha256(n.raw).hexdigest(),
 'scope':'only Stardust Reverie Normal Sub41..46; shared host unchanged',
 'corrections':['initial blocking countdown280 then vector acceleration60; cyclic countdown200 then acceleration90; ProcessEx precedes countdown clear so acceleration beginsN+1',
 'SELF_ANGLE10069 at+2d94 is displacement heading; CIRCLE_ANGLE10077 at+2d9c is separate. Sample heading at birth and lock acceleration during countdown',
 'source pairs(color,type): (2,12),(4,13),(8,12),(6,13),(10,12),(13,13),(14,12), preserved in fan and delayed modes',
 'source loop720..1200: delayed emission300f, silence120f, fan60f; fan switches at420 and1140+480k',
 'existing same-card radial/angular schedule retained; all other cards/HP/time/assets/familiar protection unchanged'],
 'boundaries':'existing host initial even familiar distribution and float/scheduler are retained; no native replay or pixel parity claim'}
(M/'source/stardust03.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2),encoding='utf8')
print('PASS source Sub41..46 and native wait/vector/SELF_ANGLE evidence archived')
