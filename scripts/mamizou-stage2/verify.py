"""Independent source schedule comparison and real mod callbacks in a stub host.

This is headless execution, not original-game or AEX runtime parity.
"""
from pathlib import Path
import hashlib,importlib,json,math,re
try:
 from PIL import Image,ImageDraw
except ImportError:
 import site,sys
 sys.path.append(site.getusersitepackages())
 from PIL import Image,ImageDraw
ROOT=Path('G:/MySTG');MOD=ROOT/'aex-0.8.22/game/mod/MamizouStage2';LOG=ROOT/'work/logs/mamizou-stage2'
ref=json.loads((MOD/'reference.json').read_text(encoding='utf-8'))
for key in ('th13','th185'):
 assert hashlib.sha256(Path(ref[key]['path']).read_bytes()).hexdigest()==ref[key]['sha256']
for row in json.loads((MOD/'asset-provenance.json').read_text(encoding='utf-8')):
 p=MOD/row['output'];assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
sources={r['name']:r['text'].splitlines() for r in ref['th13']['subroutines']}
def native_non(name,limit):
 events=[]
 def run(name,t,spin=0):
  lines=sources[name];labels={l.strip()[:-1]:i for i,l in enumerate(lines) if re.match(r'^\w+:$',l.strip())};i=2;left=0;angle=0;count=0;speed=0;steps=0
  while i<len(lines) and t<limit:
   steps+=1;assert steps<50000
   l=lines[i].strip();i+=1
   m=re.match(r'wait\((\d+)\);',l)
   if m:t+=int(m[1]);continue
   m=re.match(r'@([A-Za-z0-9_]+)\((-?[\d.]+)f\);',l)
   if m:t=run(m[1],t,float(m[2]));continue
   m=re.match(r'etCount\(0, (\d+), 1\);',l)
   if m:count=int(m[1]);continue
   m=re.match(r'etSpeed\(0, ([\d.]+)f,',l)
   if m:speed=float(m[1]);continue
   if l=='%B = %RANDRAD;':angle=0;continue
   if l=='%B = %B + %A;':angle+=spin;continue
   if l=='$C = 60;':left=60;continue
   if l=='etOn(0);':
    # etAngle precedes the increment, so this emitted angle uses B-A.
    for k in range(count):events.append((t,speed,-(angle-spin+k*2*math.pi/count)*180/math.pi))
    continue
   m=re.match(r'(?:if \(1\) )?goto (\w+) @ \d+;',l)
   if m:i=labels[m[1]]+1;continue
   m=re.match(r'if \(\$C--\) goto (\w+) @ 0;',l)
   if m:
    old=left;left-=1
    if old:i=labels[m[1]]+1
    continue
   if l=='return;':break
  return t
 run(name,0)
 return events
results=[]
for backend in ('lua51','luajit21','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.execute('loadstring=loadstring or load')
 for f in MOD.glob('*.lua'):lua.execute('assert(loadstring(...))',f.read_text(encoding='utf-8-sig'))
 lua.execute((MOD/'pattern.lua').read_text(encoding='utf-8'));p=lua.globals().MamizouPattern
 non_counts=[]
 for phase,name in ((1,'Boss1'),(3,'Boss2')):
  original=native_non(name,3600);ported=[];base=0
  for t in range(3600):
   e=p.non(phase,t)
   if e:
    if e.age==0:base=0
    for k in range(3):ported.append((t,e.speed,base-k*120))
    base-=e.spin*180/math.pi
  assert len(original)==len(ported)
  assert all(a[0]==b[0] and abs(a[1]-b[1])<1e-6 and abs(a[2]-b[2])<1e-7 for a,b in zip(original,ported))
  non_counts.append(len(original))
 assert [p.ring_count(i) for i in range(1,7)]==[19,19,18,19,19,18]
 assert sum(p.random_keep(i) for i in range(1,361))==270
 assert sum(bool(p.bird(t)) for t in range(4200))==456
 assert sum(bool(p.frog(t)) for t in range(4200))==16
 # Execute the actual root callbacks, with engine resources checked on assignment.
 lua.execute((ROOT/'scripts/mamizou-stage2/host-harness.lua').read_text(encoding='utf-8'))
 lua.execute((MOD/'assets.lua').read_text(encoding='utf-8'))
 lua.execute((MOD/'root.lua').read_text(encoding='utf-8'))
 if backend=='lua51':
  frames=[]
  def sink(phase,t,objects,boss):
   frames.append({'phase':phase,'tick':t,'boss':[boss.x,boss.y],'shots':[{'x':o.x,'y':o.y,'img':o.img,'angle':o.rot or 0} for o in objects.keys()]})
  lua.globals().MamizouFrameSink=sink
 report=lua.globals().MamizouHarnessRun()
 results.append({'backend':backend,'non_source_events':non_counts,'bird_spawns':456,'frog_seed_volleys':16,'actual_callback_checks':json.loads(report)})
out={'status':'passed','scope':'source schedule, assets, Lua syntax and actual callback headless execution; no native/original runtime parity','results':results}
(LOG/'static-result.json').write_text(json.dumps(out,indent=2)+'\n')
(LOG/'headless-frames.json').write_text(json.dumps(frames,indent=2)+'\n')
sheet=Image.new('RGB',(384*5,488),(18,20,29));draw=ImageDraw.Draw(sheet)
for f in frames:
 off=(f['phase']-1)*384
 panel=Image.new('RGB',(384,448),(18,20,29))
 for shot in f['shots']:
  if abs(shot['x'])>224 or abs(shot['y'])>260:continue
  name=shot['img'].removeprefix('mz.')
  im=Image.open(MOD/'art'/(name+'.png')).convert('RGBA')
  if name.startswith('t8'):im=im.rotate(shot['angle'],resample=Image.Resampling.BICUBIC,expand=True)
  x=round(192+shot['x']-im.width/2);y=round(224-shot['y']-im.height/2)
  panel.paste(im,(x,y),im)
 im=Image.open(MOD/'art/th13-0.png').convert('RGBA');x,y=f['boss'];panel.paste(im,(round(192+x-im.width/2),round(224-y-im.height/2)),im)
 sheet.paste(panel,(off,0))
 draw.ellipse((off+189,371,off+195,377),fill='white')
 draw.rectangle((off,0,off+383,447),outline=(75,85,105));draw.text((off+10,456),f"Phase {f['phase']} / frame {f['tick']}",fill='white')
draw.text((10,475),'Headless callbacks; fixed player, seeded RNG; native rendering pending',fill=(170,180,195))
sheet.save(LOG/'headless-preview.png')
print(json.dumps(out,indent=2))
