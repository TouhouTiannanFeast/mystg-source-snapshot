from pathlib import Path
import json,re,struct,sys
sys.stdout.reconfigure(encoding='utf-8')
L=Path('G:/TouHou/MLforDanmu/data/local/lenen/native-complete-20261018/le04')
d=json.loads((L/'boss-algorithms.json').read_text('utf-8'))
for x in d['algorithms']:
 if x.get('boss_or_stage_id')==30 and x['phase_id'] in (3,7):
  print('SELECTED',x['phase_id'],x['spell_name_record'],x.get('contexts'))
c=json.loads((L/'referenced-constants.json').read_text('utf-8'))
for name in ['00508870','0050c300']:
 t=(L/f'functions/{name}.c').read_text('utf-8')
 for a in sorted(set(re.findall(r'DAT_([0-9a-f]{8})',t))):
  if a.startswith('009e'):
   x=c[a]; print(name,a,'f',x['float32_le'],'d',x['float64_le'])
t=(L/'functions/0044c090.c').read_text('utf-8')
for m in re.finditer(r'case 0x1e:',t): print('INIT',t[m.start():m.start()+8000])
