"""Selected retail TH13 stage4 ECL + exact local ANM assets, isolated output."""
from pathlib import Path
import re,sys,json,hashlib,shutil,struct,importlib.util
from PIL import Image
sys.dont_write_bytecode=True
R=Path('G:/MySTG');O=R/'aex-0.8.22/game/mod/TH13Seiga4';W=R/'work/th13-seiga4'
SRC=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th13_local-original-archive-candidate_3443fe0df11d/raw/st04bs.named.utf8.txt')
BANK=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th13_3443fe0df1')
for p in [O/'source',O/'art',O/'art/player']:p.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,s):(O/n).write_text(s,encoding='utf-8')
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
def normal(body):
 active=True;stack=[];out=[]
 for line in body.splitlines():
  s=line.strip()
  if s.startswith('!'):active=s=='!*' or 'N' in s[1:];continue
  if not active and not s.endswith(':') and not s.startswith('+'):continue
  m=re.fullmatch(r'(.+);',s)
  if m and not any(s.startswith(x)for x in ('var ','return','goto ','if ','unless ','@'))and not re.match(r'\w+\(',s)and not re.match(r'[$%]\w+\s*=',s):stack.append(m[1]);continue
  refs=re.findall(r'\[-(\d+)(?:\.0f)?\]',s)
  if refs:
   s=re.sub(r'\[-(\d+)(?:\.0f)?\]',lambda m:'('+stack[-int(m[1])]+')',s);del stack[-max(map(int,refs)):]
  out.append(s)
 assert not stack,stack
 return '\n'.join(out)
text=SRC.read_text(encoding='utf-8')
fs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=normal(m[3]))for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',text,re.M|re.S)}
entries=['Boss1','BossCard1','Boss2','BossCard2','BossMiyako1','BossMiyakoDead']
seen=set();todo=entries.copy()
while todo:
 n=todo.pop()
 if n in seen or n=='Ecl_EtBreak':continue
 seen.add(n);b=fs[n]['body']
 todo+=re.findall(r'@(\w+)\(',b)+re.findall(r'(?:enmCreate\w*\(|enmCall\([^,]+, )"(\w+)"',b)
 # Yoshika interrupts are executed locally; boss phase interrupts belong to AEX.
 if n.startswith('BossMiyako'):todo+=re.findall(r'setInterrupt\([^\n]*"(\w+)"',b)
sys.path.insert(0,str(R/'scripts/suwako5'));import build as lower
# The generic lowerer is a pure input. Add only output operands/global registers
# and Normal float selection locally; do not alter shared generated artifacts.
oldexpr=lower.expr
def expr(s):
 s=re.sub(r'\$GI(\d+)',r'R.gi[\1]',s)
 s=re.sub(r'\$(MISS_COUNT|BOMB_COUNT|CAPTURE)',r'R.shared.\1',s)
 s=s.replace('$ID','a.id')
 return oldexpr(s)
lower.expr=expr
chunks=['-- Original retail TH13 Normal instruction timelines.','SeigaPrograms={th13={}};local P=SeigaPrograms.th13;local R=SeigaRuntime'];commands=set();normalized={}
for n in sorted(seen):
 fn=fs[n].copy();b=fn['body']
 b=re.sub(r'diffF\((%\w+), ([^,]+), ([^,]+), ([^,]+), ([^)]+)\);',r'\1 = \3;',b)
 b=re.sub(r'enmPos\((%\w+), (%\w+), ([^)]+)\);',r'\1 = R.actorX(\3);\n\2 = R.actorY(\3);',b)
 b=b.replace('enmKillAll();','clearMinors();') # preserve the second Boss (Yoshika)
 fn['body']=b;code,cmd=lower.lower(fn);commands|=cmd;chunks.append('P['+lua(n)+']='+code);normalized[n]=fn
save('programs.lua','\n'.join(chunks)+'\n');shutil.copy2(SRC,O/'source'/SRC.name)
save('source/normal-closure.json',json.dumps(normalized,ensure_ascii=False,indent=2))
save('source/commands.json',json.dumps(sorted(commands),indent=2))
# Freeze a private scheduler/projectile baseline; the extension handles TH13
# globals, actor interrupts, curved-laser history and velocity-step transforms.
BASE=R/'aex-0.8.22/game/mod/TH125Extra'
s=(BASE/'runtime.lua').read_text(encoding='utf-8').replace('DSExtra','Seiga')
s=s.replace("elseif k=='RANDF'", "elseif k=='RANDF'")
s=s.replace("elseif k=='LIFE' then return R.hp", "elseif k=='LIFE' then return a.hp or R.hp")
s=s.replace("local indexed=a.group=='th10' or a.group:sub(1,2)=='ds' or k:find('Set')", "local indexed=a.group=='th10' or a.group:sub(1,2)=='ds' or k:find('Set')")
save('runtime.lua',s)
s=(BASE/'projectiles.lua').read_text(encoding='utf-8').replace('DSExtra','Seiga')
s=s.replace("elseif k=='step' then error('step transform is outside selected source')", "elseif k=='step' then b.active[#b.active+1]={kind='step',age=0,n=r.i,angle=r.r,speed=r.s}")
s=s.replace("elseif k=='wait' then keep=s.age<s.n", "elseif k=='step' then if s.age>=s.n then b.angle=resolve(b,s.angle);b.speed=s.speed;velocity(b);keep=false end\n  elseif k=='wait' then keep=s.age<s.n")
# TH13 curves are moving point histories; the local extension supplies their
# mesh/collision, rather than interpreting negative line-laser lengths.
s=s.replace("if b.laser then w,h=math.max(b.laser.length,b.laser.width),math.max(b.laser.length,b.laser.width) end", "if b.laser then w,h=math.max(b.laser.length or 0,b.laser.width),math.max(b.laser.length or 0,b.laser.width) end")
save('projectiles.lua',s)
spec=importlib.util.spec_from_file_location('binary',R/'scripts/mamizou-stage2/inspect-binary.py');binary=importlib.util.module_from_spec(spec);spec.loader.exec_module(binary)
manifest=json.loads((BANK/'manifest.json').read_text(encoding='utf-8'));rows={int(x['id'].split('sprite')[-1]):x for x in manifest['sprites']if x['id'].startswith('bullet.')and 'path'in x}
art={};assets=[];native=[]
for typ,col in [(20,3),(21,3),(9,6),(9,13),(18,5),(10,8),(10,10),(5,2)]:
 data=binary.at(0x4bbe30+typ*0x114,0x114);sid=struct.unpack_from('<I',data,4+col*16)[0];radius=struct.unpack_from('<f',data,0x104)[0]
 row=rows[sid];src=BANK/row['path'];name=f't{typ}c{col}';dst=O/'art'/(name+'.png');shutil.copy2(src,dst);w,h=Image.open(dst).size
 art[f'{typ}:{col}']=dict(image='sg.'+name,path='art/'+dst.name,w=w,h=h,radius=radius)
 assets.append(dict(source=str(src),target='art/'+dst.name,sha256=sha(dst)));native.append(dict(type=typ,color=col,sprite=sid,radius=radius))
row=rows[534];src=BANK/row['path'];dst=O/'art/curve8.png';shutil.copy2(src,dst)
art['curve']=dict(image='sg.curve',path='art/curve8.png',w=256,h=16)
assets.append(dict(source=str(src),target='art/curve8.png',sha256=sha(dst)))
for group,folder in [('seiga','boss'),('yoshika','yoshika'),('enemy','enemy')]:
 anm=W/folder/'animation.spec.txt';txt=anm.read_text(encoding='utf-8-sig');shutil.copy2(anm,O/'source'/(group+'.anm.txt'))
 for entry in re.split(r'(?=^entry entry\d+ \{)',txt,flags=re.M):
  path=re.search(r'name: "([^"]+)"',entry)
  if not path:continue
  src=W/folder/path[1];im=Image.open(src).convert('RGBA')
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1]);x,y,w,h=map(lambda v:int(float(v)),m.groups()[1:])
   if group=='enemy' and sid not in range(139,147):continue
   name=group+'-'+str(sid);dst=O/'art'/(name+'.png');im.crop((x,y,x+w,y+h)).save(dst)
   art[group+':'+str(sid)]=dict(image='sg.'+name,path='art/'+dst.name,w=w,h=h)
   assets.append(dict(source=str(src),source_sha256=sha(src),rect=[x,y,w,h],target='art/'+dst.name,sha256=sha(dst)))
save('assets.lua','SeigaArt='+lua(art)+'\n')
shutil.copy2(BANK/'bullet/animation.spec.txt',O/'source/bullet.anm.txt')
player=[]
for n in ['player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 src=BASE/n;save(n,src.read_text(encoding='utf-8').replace('DS Extra@Extra','Seiga Four@Normal'))
 player.append(dict(source=str(src),target=n,sha256=sha(O/n)))
for src in (BASE/'art/player').iterdir():
 if src.is_file():shutil.copy2(src,O/'art/player'/src.name)
ref=dict(source=str(SRC),source_sha256=sha(SRC),archive=str(binary.p.with_name('th13.dat')),archive_sha256=manifest['source_sha256'],exe=str(binary.p),exe_sha256=sha(binary.p),routines=sorted(seen),native=native,assets=assets,player=player,difficulty='Normal',background=False,music=False)
save('source/reference.json',json.dumps(ref,ensure_ascii=False,indent=2));print('BUILT',len(seen),'routines;',len(assets),'exact source sprites; commands:',sorted(commands))
