from pathlib import Path
import re,json,shutil,hashlib
from integrate02 import host02
from integrate03 import boss03
from PIL import Image
R=Path('G:/MySTG'); M=R/'aex-0.8.22/game/mod/MarisaMixed'
mods=M.parent; S=Path('G:/TouHou/MLforDanmu/data/local/seihou')
refs={}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(src,dst):
 dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);refs[str(dst.relative_to(M))]={'source':str(src),'sha256':sha(src)}
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
for f in ['player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 copy(mods/'TH125Extra'/f,M/f)
 if f=='power-lock.lua':(M/f).write_text((M/f).read_text(encoding='utf8').replace('DS Extra@Extra','Marisa Mixed@Normal'),encoding='utf8')
for p in (mods/'TH125Extra/art/player').rglob('*'):
 if p.is_file():copy(p,M/'art/player'/p.relative_to(mods/'TH125Extra/art/player'))
for f in ['host.lua','boss.lua']:
 copy(mods/'MySTG/stages/th08_stage4'/f,M/'th08'/f)
 if f=='host.lua':(M/'th08'/f).write_text(host02((M/'th08'/f).read_text(encoding='utf8')),encoding='utf8')
 if f=='boss.lua':(M/'th08'/f).write_text(boss03((M/'th08'/f).read_text(encoding='utf8')),encoding='utf8')
for f in ['runtime.lua','projectiles.lua','programs.lua','pool.lua','assets.lua','sound.lua']:
 copy(mods/'TH125Extra'/f,M/'ds'/f)
 if f in ['assets.lua','sound.lua']:
  p=M/'ds'/f;p.write_text(p.read_text(encoding='utf8').replace('art/','ds/art/').replace('se/','ds/se/'),encoding='utf8')
for folder in ['art','se']:
 for p in (mods/'TH125Extra'/folder).glob('*'):
  if p.is_file():copy(p,M/'ds'/folder/p.name)
host=(mods/'TH125Extra/root.lua').read_text(encoding='utf8')
host=host[host.index('local R,P,A='):]
prefix=host[:host.index('local Background=')]
card=host[host.index('local function card(spec)'):host.index('local Boss=')]
(M/'ds/host.lua').write_text(prefix+card+'\nMarisaDS={card=card,clean=clean,state=S}\n',encoding='utf8')
assets=S/'ssg-marisa-phase1-assets-20261106'
art={}
for row in json.loads((assets/'manifest.json').read_text(encoding='utf8'))['crops']:
 src=assets/row['path']; dst=M/'art/ssg'/row['path'];copy(src,dst)
 art[row['path'][:-4]]={'path':dst.relative_to(M).as_posix(),'w':row['width'],'h':row['height']}
for p in (assets/'audio').glob('*.wav'):copy(p,M/'se'/p.name)
copy(assets/'manifest.json',M/'source/ssg-assets.json')
corp=S/'ssg-marisa-20261106-v2'
for f in ['readable/24_STG7.ECL.txt','raw/24_STG7.ECL','manifest.json']:
 copy(corp/f,M/'source/ssg'/Path(f).name)
for p in (corp/'engine-evidence').rglob('*'):
 if p.is_file():copy(p,M/'source/engine'/p.relative_to(corp/'engine-evidence'))
code={};lines=(corp/'readable/24_STG7.ECL.txt').read_text().splitlines()
for line in lines:
 m=re.match(r'0x([0-9a-f]+): (\w+)\s*(.*)',line)
 if not m:continue
 addr=int(m[1],16)
 if not(0x10a<=addr<0x2c6 or 0x5c4<=addr<0xa6a or 0xb37<=addr<0xbd3):continue
 args=[int(v.strip(),0)for v in m[3].split(',')if v.strip()]
 code[addr]=[m[2],args]
# Store explicit successor addresses: no reconstructed labels or guessed lengths.
alladdr=[int(m[1],16)for l in lines if (m:=re.match(r'0x([0-9a-f]+):',l))]
for addr,row in code.items():row.append(alladdr[alladdr.index(addr)+1])
(M/'ssg-code.lua').write_text('SSGCode='+lua(code)+'\n',encoding='utf8')
# Source TH08 human/high-speed familiar: enemy ANM script70, green sprite122.
im=Image.open(M/'source/th08/data/stgenm/enemy.png')
im.crop((32,224,64,256)).save(M/'art/green-circle.png')
art['green-circle']={'path':'art/green-circle.png','w':32,'h':32}
refs['art/green-circle.png']={'source':'source/th08/enemy.anm script70 sprite122','rect':[32,224,32,32],'sha256':sha(M/'art/green-circle.png')}
(M/'art.lua').write_text('MarisaArt='+lua(art)+'\n',encoding='utf8')
(M/'source/reuse.json').write_text(json.dumps(refs,ensure_ascii=False,indent=2),encoding='utf8')
print('PASS copied private TH08/DS current snapshots, source script table',len(code),'instructions, art',len(art))
import runpy
runpy.run_path(str(R/'scripts/marisa-mixed/assets02.py'),run_name='__main__')
