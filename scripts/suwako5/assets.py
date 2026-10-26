"""Copy source-identical TH10 static sprites; keep an explicit mapping manifest."""
from pathlib import Path
import json,re,shutil,hashlib
from source_audit import OUT
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3')
rows=json.loads((B/'manifest.json').read_text(encoding='utf-8'))['sprites']
spec=(B/'bullet/animation.spec.txt').read_text(encoding='utf-8')
# Verified TH10 v1.00a table 0x474170, with full collision widths at 0x4741e0.
bases=[0,64,80,96,112,128,144,160,176,192,208,224,275,283,291,299,307,347,373,315,323,331,339,240,48,374,243]
width=[4,6,6,4,4,4,4,4,4,0,4,6,10,8,8,8,8,28,6,10,8,8,8,6,4,6,4]
art=OUT/'art';art.mkdir(exist_ok=True);manifest=[];lines=['Suwako5Art={}']
for typ,base in enumerate(bases):
 lines.append(f'Suwako5Art[{typ}]={{}}')
 colors=8 if typ in [12,13,14,15,16,19,20,21,22] else 16
 for col in range(colors):
  match=re.search(r'script script'+str(base+col)+r' \{(.*?)\n\}',spec,re.S)
  if not match:continue
  body=match[1]
  if 'ins_6([10000], 1);' in body:body=body.split('ins_6([10000], 1);',1)[1]
  body=body.split('ins_64(1);',1)[0]
  sprites=re.findall(r'ins_3\(sprite(\d+)\)',body)
  if not sprites:continue
  # First sprite in the active section, excluding birth and death interrupts.
  sid=int(sprites[0]);row=next((s for s in rows if s['id'].endswith('.sprite'+str(sid))),None)
  if not row:continue
  dest=art/f'th10-{sid}.png'
  if not dest.exists():shutil.copy2(B/row['path'],dest)
  lines.append(f'Suwako5Art[{typ}][{col}]={{image="suwako5.th10-{sid}",width={width[typ]},w={row["rect_xywh"][2]},h={row["rect_xywh"][3]}}}')
  manifest.append({'type':typ,'color':col,'script':base+col,'sprite':sid,'path':str(B/row['path']),'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()})
(OUT/'art.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(OUT/'art-reference.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('Copied',len(list(art.glob('*.png'))),'unchanged TH10 sprite crops;',len(manifest),'type/color mappings.')
ds=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/th125-20261026/th125_18fcf64c0a')
side={}
for part,sprite in [('glow','enm23.entry8.sprite36'),('core','enm23.entry9.sprite37')]:
 src=ds/f'sprites/{sprite}.png';target=f'art/ds-bomb-{part}.png';shutil.copy2(src,OUT/target)
 side[part]={'source':str(src),'sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'target':target,'anm_scripts':[26,27,28]}
anm=ds/'enm23/animation.spec.txt'
side['ANM']={'source':str(anm),'sha256':hashlib.sha256(anm.read_bytes()).hexdigest(),'scripts':{n:re.search(r'script script'+str(n)+r' \{(.*?)\n\}',anm.read_text(encoding='utf-8'),re.S)[1] for n in [26,27,28]}}
(OUT/'side-art-reference.json').write_text(json.dumps(side,ensure_ascii=False,indent=2),encoding='utf-8')
print('Copied original DS BossBomb ANM26/27/28 sprite36/37 and preserved animation source.')
# Remove only unused intermediate PNGs created by this asset builder, inside art/.
keep={f'th10-{r["sprite"]}.png' for r in manifest}|{'ds-bomb-core.png','ds-bomb-glow.png'}
for path in art.glob('*.png'):
 if (path.name.startswith('th10-') or path.name=='ds-bomb.png') and path.name not in keep:
  assert path.resolve().parent==art.resolve()
  path.unlink()
