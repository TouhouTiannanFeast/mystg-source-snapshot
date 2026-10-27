from pathlib import Path
import json
root=Path('G:/MySTG');base=root/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5'
source=Path('G:/TouHou/MLforDanmu/data/local/backgrounds/th18-th185-20261026-v2/th18/scenes.json')
s=next(x for x in json.loads(source.read_text(encoding='utf-8'))if x['id']=='st02.std')
rows=[]
for e in s['entries']:
 for inst in e['instances']:
  for q in e['quads']:
   assert q['type']==0
   pos=[a+b for a,b in zip(inst['position'],q['position'])]
   rows.append((e['layer_source_field'],inst['source_offset'],q['source_offset'],pos+[q['animation_script_id']],[q['width'],q['height'],q['width']/512,1]))
rows.sort(key=lambda x:x[:3]);assert len(rows)==60
fmt=lambda v:'float4('+','.join(str(float(x)) for x in v)+')'
head='// Generated from original st02.std source instance/quad order. Native render modes4/8.\n'
head+='static const float4 geometry[60]={'+','.join(fmt(x[3]) for x in rows)+'};\n'
head+='static const float4 dimensions[60]={'+','.join(fmt(x[4]) for x in rows)+'};\n'
body=(root/'scripts/stage5/background-shader-body.hlsl').read_text(encoding='utf-8')
(base/'background-native.hlsl').write_text(head+body,encoding='utf-8')
print('Generated 60 source quads, source layer/instance/quad order; original textures unchanged.')
