"""Build isolated TH10 stage06 Normal road from local, hash-pinned sources."""
from pathlib import Path
import re, json, hashlib, shutil, sys, subprocess, importlib.util
ROOT=Path('G:/MySTG'); OUT=ROOT/'aex-0.8.22/game/mod/TH10Stage6Normal'
ML=Path('G:/TouHou/MLforDanmu'); WORK=ROOT/'work/th10-stage6'
SRC=ML/'data/local/touhou/20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage06.named.utf8.txt'
BANK=ML/'data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3'
BINS=ML/'work/research/thtk-nightly-x64/thtk-bin-ci'
for p in [OUT,OUT/'source',OUT/'art',OUT/'se',WORK]:p.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,(list,tuple)):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if v is True:return 'true'
 if v is False:return 'false'
 if v is None:return 'nil'
 return str(v)
def save(name,s):(OUT/name).write_text(s,encoding='utf-8')
text=SRC.read_text(encoding='utf-8');matches=list(re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',text,re.M|re.S))
funcs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3]) for m in matches}
selected=set();todo=['MainSub1']
while todo:
 name=todo.pop()
 if name in selected:continue
 selected.add(name);body=funcs[name]['body']
 todo+=re.findall(r'@(\w+)\(',body)+re.findall(r'enmCreate\w*\("(\w+)"',body)
assert not any(n.startswith('Boss') or n in ['MapleEnemy','main'] for n in selected)
sys.path.insert(0,str(ROOT/'scripts/suwako5'))
import build as lowerer
chunks=['-- Generated from stage06 ECL; Normal only.','TH10S6Programs={th10={}};local P=TH10S6Programs.th10;local R=TH10S6Runtime']
commands=set();normal={}
for name in sorted(selected):
 fn=funcs[name].copy();lines=[];enabled=True
 for line in fn['body'].splitlines():
  if line.strip().startswith('!'):enabled=line.strip()=='!*' or 'N' in line;continue
  if enabled or line.strip().endswith(':') or re.match(r'\s*\+\d+:',line):lines.append(line)
 fn['body']='\n'.join(lines);normal[name]=fn
 code,cmd=lowerer.lower(fn);commands|=cmd
 # All difficulty selectors explicitly take Normal (index1), not Extra's defaults.
 code=code.replace('Suwako5Runtime','TH10S6Runtime')
 chunks.append('P['+lua(name)+']='+code)
save('programs.lua','\n'.join(chunks)+'\n')
shutil.copy2(SRC,OUT/'source/stage06.named.utf8.txt')
(OUT/'source/normal-closure.json').write_text(json.dumps(normal,indent=2),encoding='utf-8')
base=ROOT/'aex-0.8.22/game/mod/MySTG/stages/suwako5'
s=(base/'runtime.lua').read_text(encoding='utf-8').replace('Suwako5','TH10S6')
s=s.replace("if k=='ANGLE_PLAYER'", "if k=='DIFF' then return 1\n elseif k=='ABS_ANGLE_PLAYER' then return a.mirror and R.rad(pi-R.aim(a)) or R.aim(a)\n elseif k=='ANGLE_PLAYER'")
s=s.replace("elseif k=='setInvuln' then if a==R.boss then R.invuln=v[1] end", "elseif k=='setInvuln' then a.invuln=v[1]")
s=s.replace("elseif k=='movePosTime' then", "elseif k=='movePos' then a.x,a.y=v[1],v[2];a.positionTween=nil;a.orbit=nil\n elseif k=='moveCircleRel' then\n  local o=a.orbit or {x=a.x,y=a.y,angle=0,omega=0,radius=0,dr=0}\n  for i,key in ipairs({'angle','omega','radius','dr'})do if v[i]>-990 then o[key]=v[i] end end\n  a.orbit=o;a.speed=nil\n elseif k=='diffWait' then coroutine.yield(math.max(1,v[2]))\n elseif k=='etCountD' then local p=pat(a,v[1]);p.n,p.layers=v[3],v[7]\n elseif k=='etSpeedD' then local p=pat(a,v[1]);p.speed,p.speed2=v[3],v[7]\n elseif k=='playSound' then if R.onSound then R.onSound(v[1],a.x) end\n elseif k=='dropMain' then a.dropMain=v[1]\n elseif k=='dropClear' then a.dropExtra={}\n elseif k=='dropExtra' then a.dropExtra=a.dropExtra or {};a.dropExtra[v[1]]=v[2]\n elseif k=='dropArea' then a.dropArea={v[1],v[2]}\n elseif k=='anmSetMain' or k=='anmSetSprite' then a.anm=a.anm or {};a.anm[v[1]]=v[2];if v[1]==0 then a.poseStart=a.age end\n elseif k=='unknown361' then a.damageRamp=v[1]\n elseif k=='movePosTime' then")
# Route-specific hooks above must run before the inherited host-command ignore set.
begin=s.index(" elseif k=='playSound' then if R.onSound")
end=s.index(" elseif k=='movePosTime' then",begin)
hooks=s[begin:end];s=s[:begin]+s[end:]
s=s.replace(' elseif ignore[k] then return',hooks+'\n elseif ignore[k] then return')
s=s.replace("elseif k=='anmSetSprite' then", "elseif k=='anmSetSprite' and a.name=='BossBomb' then",1)
s=s.replace("elseif k=='moveVelTime' then tween", "elseif k=='moveVelTime' then tween")
s=s.replace("or v[3],v[4]})", "or v[3],v[4]<-990 and (a.speed or 0) or v[4]})")
s=s.replace("elseif k=='enmCreate' or k=='enmCreateA' then", "elseif k=='enmCreate' or k=='enmCreateA' or k=='enmCreateM' or k=='enmCreateAM' then")
s=s.replace("if k=='enmCreate' then x,y=x+a.x,y+a.y end", "if not k:find('A') then x,y=x+a.x,y+a.y end")
s=s.replace("child.hp=v[4];child.name=v[1];", "child.hp=v[4];child.dropMain=v[6];child.mirror=k:find('M')~=nil;child.name=v[1];child.born=R.tick;")
s=s.replace("if a.orbit then local o=a.orbit;o.angle", "if a.orbit then local o=a.orbit;o.angle")
s=s.replace("elseif a.speed then a.x=a.x+math.cos(a.angle)*a.speed;", "elseif a.speed then a.x=a.x+(a.mirror and -1 or 1)*math.cos(a.angle)*a.speed;")
# No boss/DS selection machinery in the road host.
start=s.index('function R.start(')
step=s.index('function R.step(',start)
s=s[:start]+'''function R.start(seed)
 R.actors={};R.hazards={};R.tick=0;R.instructions=0;R.coverage={};R.stats={bullets=0,lasers=0,actors=0};R.invuln=0
 R.random=function()return ran:Float(0,1)end;R.playerX,R.playerY=0,400
 R.spec={group='th10',id='road'};R.hp=1
 R.controller=R.newActor('th10',0,0);R.controller.controller=true;R.controller.name='RoadController';R.spawn(R.controller,'MainSub1',{},-2)
end
'''+s[step:]
s=s[:s.index('function R.step(')] # Road scheduler lives in road-runtime.lua.
s=s.replace('local o=a.orbit or {x=a.x,y=a.y,angle=0,omega=0,radius=0,dr=0}', 'local o=a.relativeOrbit or {angle=0,omega=0,radius=0,dr=0}')
s=s.replace('a.orbit=o;a.speed=nil','a.relativeOrbit=o')
s=s.replace('a.damageRamp=v[1]','a.entryTimer=v[1]')
s=s.replace('if v[1]==0 then a.poseStart=a.age end','if v[1]==0 then a.poseStart=a.age;a.walkMain=k==\'anmSetMain\' end')
s=s.replace('a.x,a.y=a.x+(a.offsetX or 0),a.y+(a.offsetY or 0)', '''if a.relativeOrbit then
  local o=a.relativeOrbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
  a.offsetX,a.offsetY=math.cos(o.angle)*o.radius,math.sin(o.angle)*o.radius
 end
 a.x,a.y=a.x+(a.offsetX or 0),a.y+(a.offsetY or 0)''')
save('runtime.lua',s)
s=(base/'projectiles.lua').read_text(encoding='utf-8').replace('Suwako5','TH10S6')
s=s.replace("if R.onShot then R.onShot(b) end", "if R.onShot then R.onShot(b) end")
save('projectiles.lua',s)
# Source textures and script-specific animation descriptors; white highlights are never tinted.
refs=[];assets={};anims={}
def archive(spec,folder,prefix):
 raw=spec.read_text(encoding='utf-8-sig');sprites={};scripts={}
 for entry in re.split(r'(?=^entry entry\d+ \{)',raw,flags=re.M):
  nm=re.search(r'name: "([^"]+)"',entry)
  if not nm:continue
  src=folder/nm[1];dst=OUT/'art'/f'{prefix}-{src.name}'
  shutil.copy2(src,dst);refs.append(dict(source=str(src),sha256=sha(src),output=str(dst.relative_to(OUT))))
  tex=f's6.{prefix}.{src.stem}';assets[tex]=str(dst.relative_to(OUT))
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1]);sprites[sid]=dict(tex=tex,rect=list(map(float,m.groups()[1:])))
  for m in re.finditer(r'script script(\d+) \{(.*?)\n\}',entry,re.S):scripts[int(m[1])]=m[2]
 return sprites,scripts
es=ROOT/'aex-0.8.22/game/mod/Stage2Full/source'
enemySprites,enemyScripts=archive(es/'enemy.spec.txt',es,'enemy')
bulletSprites,bulletScripts=archive(BANK/'bullet/animation.spec.txt',BANK/'bullet','bullet')
spriteDefs={'enemy':enemySprites,'bullet':bulletSprites}
# Keep exact selected ANM bodies for independent checks / future parity work.
baseMap={0:0,1:64,3:96,5:128};widths={0:4,1:6,3:4,5:4}
for typ,baseId in baseMap.items():
 for col in [2,4,6]:
  body=bulletScripts[baseId+col];active=body.split('ins_6([10000], 1);',1)[1].split('ins_64(1);')[0]
  death=body.split('ins_64(1);',1)[1]
  birth=body.split('ins_64(8);',1)[1].split('+15:',1)[0]
  anims[f'{typ}:{col}']=dict(script=baseId+col,width=widths[typ],body=int(re.search(r'ins_3\(sprite(\d+)\)',active)[1]),birth=int(re.search(r'ins_3\(sprite(\d+)\)',birth)[1]),cancel=int(re.search(r'ins_3\(sprite(\d+)\)',death)[1]),birthScale=3,deathScale=.4 if typ==0 else 1,deathFrames=8 if typ==0 else 16,add='ins_67(1)' in body.split('ins_64(7);')[0])
  (OUT/'source'/f'bullet-script{baseId+col}.txt').write_text(body,encoding='utf-8')
lines=['TH10S6Sprites={enemy={},bullet={}}']
for tex,file in assets.items():lines.append(f'LoadTexture({lua(tex)},{lua(file)})')
for group,ss in spriteDefs.items():
 for sid,row in ss.items():
  img=f's6.{group}.{sid}';rect=row['rect'];lines.append(f'LoadImage({lua(img)},{lua(row["tex"])},{",".join(map(str,rect))})');lines.append(f'TH10S6Sprites.{group}[{sid}]={lua(img)}')
lines.append('TH10S6BulletArt='+lua(anims))
lines.append('TH10S6Art={}')
for key,row in anims.items():
 typ,col=map(int,key.split(':'));rect=bulletSprites[row['body']]['rect']
 lines.append(f'TH10S6Art[{typ}]=TH10S6Art[{typ}] or {{}};TH10S6Art[{typ}][{col}]={{w={rect[2]},h={rect[3]}}}')
save('assets.lua','\n'.join(lines)+'\n')
# Exact original sound bytes; purpose aliases remain isolated to this mod.
dat=next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith('[th10]'))/'th10.dat'
listed=subprocess.run([str(BINS/'thdat.exe'),'-l','10',str(dat)],capture_output=True,check=True).stdout.decode('utf-8')
(OUT/'source/archive-list.txt').write_text(listed,encoding='utf-8')
names=sorted(set(re.findall(r'se_[a-zA-Z0-9_]+\.wav',listed)))
subprocess.run([str(BINS/'thdat.exe'),'-x','10',str(dat),'-C',str(OUT/'se'),*names],capture_output=True,check=True)
soundRefs=[dict(file=n,sha256=sha(OUT/'se'/n)) for n in names]
save('sound-assets.lua','\n'.join(f'LoadSound("s6.{n[3:-4]}","se/{n}")' for n in names)+'\n')
ref=dict(source=str(SRC),source_sha256=sha(SRC),archive=str(dat),archive_sha256=sha(dat),difficulty='Normal',functions=sorted(selected),commands=sorted(commands),art=refs,sounds=soundRefs,animations=anims,road_end=3668,adapter_sources=[dict(path=str(p),sha256=sha(p))for p in [base/'runtime.lua',base/'projectiles.lua',ROOT/'scripts/suwako5/build.py',es/'enemy.spec.txt']])
save('reference.json',json.dumps(ref,ensure_ascii=False,indent=2)+'\n')
print('Built',len(selected),'source functions;',len(names),'original sounds;',len(anims),'bullet ANM mappings')
