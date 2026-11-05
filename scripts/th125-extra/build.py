"""Build three isolated DS Extra attacks from original ECL and native sprite tables."""
from pathlib import Path
import sys,re,json,hashlib,shutil,struct,importlib.util
sys.dont_write_bytecode=True
R=Path('G:/MySTG'); O=R/'aex-0.8.22/game/mod/TH125Extra'
S=Path('G:/TouHou/MLforDanmu/data/local/touhou/th125-20261026/th125_local-original-archive-candidate_18fcf64c0a3e/raw')
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/th125-20261026/th125_18fcf64c0a')
BASE=R/'aex-0.8.22/game/mod/MySTG/stages/suwako5'
for p in [O/'source',O/'art',O/'art/player',R/'work/logs/th125-extra']:p.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,s):(O/n).write_text(s,encoding='utf-8')
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
# Import only the pure lowerer module. Do not run other projects' build scripts.
sys.path.insert(0,str(R/'scripts/suwako5'))
sp=importlib.util.spec_from_file_location('ds_lowerer',R/'scripts/suwako5/build.py');lower=importlib.util.module_from_spec(sp);sp.loader.exec_module(lower)
chunks=['-- Generated selected original DS ECL.','DSExtraPrograms={};local P=DSExtraPrograms;local R=DSExtraRuntime']
source=[];allcommands=set()
for num,file in [(2,'ecl27_a'),(7,'ecl26_c'),(8,'ecl27_c')]:
 src=S/(file+'.named.utf8.txt');text=src.read_text(encoding='utf-8')
 funcs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3])for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',text,re.M|re.S)}
 selected=set();todo=['Boss']
 while todo:
  n=todo.pop()
  if n in selected:continue
  selected.add(n);todo+=re.findall(r'@(\w+)\(',funcs[n]['body'])+re.findall(r'enmCreate\w*\("(\w+)"',funcs[n]['body'])
 group='ds'+str(num);chunks.append('P['+lua(group)+']={}')
 for n in sorted(selected):
  code,commands=lower.lower(funcs[n]);allcommands|=commands
  chunks.append('P['+lua(group)+']['+lua(n)+']='+code)
 shutil.copy2(src,O/'source'/src.name)
 source.append(dict(card=num,file=str(src),sha256=sha(src),functions=sorted(selected)))
save('programs.lua','\n'.join(chunks)+'\n')
# Local copy: existing Suwako runtime and lasers are never edited.
for filename in ['runtime.lua','projectiles.lua']:
 text=(BASE/filename).read_text(encoding='utf-8').replace('Suwako5','DSExtra')
 if filename=='runtime.lua':
  text=text.replace(" elseif ignore[k] then return", " elseif k=='setScreenShake' then if R.onShake then R.onShake(v[1],v[2],v[3])end\n elseif k=='playSound' then if R.onSound then R.onSound(v[1])end\n elseif ignore[k] then return")
  text=text.replace("elseif k=='FINAL_ANGLE' then return a.angle or 0", "elseif k=='FINAL_ANGLE' then return a.angle or 0\n elseif k=='ABS_ANGLE' then return a.orbit and a.orbit.angle or a.angle or 0\n elseif k=='DIST_PLAYER' then return math.sqrt((R.playerX-a.x)^2+(R.playerY-a.y)^2)")
  text=text.replace("R.photos=DSExtraPool.photoIndex(R.tick)","R.photos=DSExtraPool.photoIndex(R.tick,R.spec)")
  text=text.replace("R.boss=R.newActor(spec.group,0,spec.group:sub(1,3)=='isc' and 192 or 112)","R.boss=R.newActor(spec.group,spec.x,spec.y)")
  # DS circular paths are centered on the absolute moveAdd offset, not the
  # actor's current location. Keep the angle when the ECL passes its sentinel.
  old="elseif k=='moveCircle' then a.orbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],x=a.x,y=a.y}"
  new="""elseif k=='movePos' then a.x,a.y=v[1],v[2];a.positionTween=nil;a.orbit=nil;a.velocityTween=nil;a.speed=0;a.angle=a.angle or 0
 elseif k=='moveAdd' then
  if a.orbit then a.orbit.x,a.orbit.y=v[1],v[2] else a.x,a.y=a.x+v[1],a.y+v[2] end
 elseif k=='moveCircle' then
  local angle=v[1]<-990 and (a.orbit and a.orbit.angle or a.angle or 0) or v[1]
  a.orbit={angle=angle,omega=v[2],radius=v[3],dr=v[4],x=0,y=0};a.positionTween=nil
 elseif k=='moveCircleTime' then
  local o=assert(a.orbit,'orbit tween without orbit');o.tween={age=0,n=v[1],mode=v[2],from={o.omega,o.radius,o.dr},to={v[3],v[4],v[5]}}
 elseif k=='anmOnEt' then a.hidden=v[2]==1
 elseif k=='anmRotate' then a.drawAngle=v[2]"""
  assert old in text;text=text.replace(old,new)
  text=text.replace("if a.orbit then local o=a.orbit;o.angle=", "if a.orbit then local o=a.orbit;if o.tween then local v,done=advance(o.tween);o.omega,o.radius,o.dr=v[1],v[2],v[3];if done then o.tween=nil end end;o.angle=")
  # The spark inherits its parent's direction register, not its speed.
  # Keep final position after resetting speed with the source angle sentinel.
  text=text.replace("a.angle,a.speed=v[1],v[2];a.positionTween=nil;a.orbit=nil", "a.angle,a.speed=v[1]<-990 and (a.angle or 0) or v[1],v[2];a.positionTween=nil;a.orbit=nil;a.velocityTween=nil")
 save(filename,text)
save('pool.lua',"""DSExtraPool={};local P=DSExtraPool
P.specs={
 [2]={id=2,group='ds2',name='星符「奥尔特云」',boss='Marisa Kirisame',entry='Boss',hp=10000,frames=12000,x=-224,y=224,maxPhotos=4},
 [7]={id=7,group='ds7',name='梦符「梦想亚空穴」',boss='Reimu Hakurei',entry='Boss',hp=10000,frames=12000,x=-224,y=224,maxPhotos=4},
 [8]={id=8,group='ds8',name='彗星「Blazing Star」',boss='Marisa Kirisame',entry='Boss',hp=10000,frames=12000,x=0,y=-64,maxPhotos=3}}
function P.photoIndex(t,spec)return math.min(spec.maxPhotos,math.floor(math.max(0,t-60)/120))end
function P.rng(seed)local s=math.floor(seed or 1)%2147483647;if s<=0 then s=1 end;return function()s=(s*16807)%2147483647;return(s-1)/2147483646 end end
""")
# Sprite table: retail DS type stride 0x114, color stride 0x10; radius at+0x104.
exe=Path('G:/TouHou/MLforDanmu/data/local/touhou/th125-20261026/native-original/th125.exe');raw=exe.read_bytes()
pe=struct.unpack_from('<I',raw,60)[0];opt=pe+24;ss=struct.unpack_from('<H',raw,pe+20)[0];base=struct.unpack_from('<I',raw,opt+28)[0]
def at(va,n):
 for i in range(struct.unpack_from('<H',raw,pe+6)[0]):
  vs,addr,rs,off=struct.unpack_from('<4I',raw,opt+ss+i*40+8)
  if addr<=va-base<addr+max(vs,rs):return raw[off+va-base-addr:off+va-base-addr+n]
 raise ValueError(hex(va))
rows=json.loads((B/'manifest.json').read_text(encoding='utf-8'))['sprites'];assets=[];art={}
def sprite(group,sid):
 row=next(x for x in rows if x['id'].startswith(group+'.') and x['id'].endswith('.sprite'+str(sid)))
 name=group+'-'+str(sid);dst=O/'art'/(name+'.png')
 shutil.copy2(B/row['path'],dst);assets.append(dict(source=str(B/row['path']),target='art/'+dst.name,sha256=sha(dst)))
 return dict(image='dsx.'+name,path='art/'+dst.name,w=row['rect_xywh'][2],h=row['rect_xywh'][3])
native=[];bullet_spec=(B/'bullet/animation.spec.txt').read_text(encoding='utf-8')
for typ,col in [(16,6),(16,13),(11,2),(11,6),(23,3)]:
 va=0x4b0d48+typ*0x114;sid=struct.unpack('<I',at(va+4+col*16,4))[0];radius=struct.unpack('<f',at(va+0x104,4))[0]
 a=sprite('bullet',sid);a['radius']=radius
 script=struct.unpack('<I',at(va,4))[0]
 body=re.search(r'script script'+str(script)+r' \{(.*?)\n\}',bullet_spec,re.S)[1]
 spin=re.search(r'ins_53\(0.0f, 0.0f, ([^f)]+)f\)',body)
 if spin:a['spin']=-float(spin[1])*180/3.141592653589793
 art[f'{typ}:{col}']=a
 native.append(dict(type=typ,color=col,table=hex(va),sprite=sid,radius=radius))
for group,ids in [('enm26',[0,1,*range(2,14)]),('enm27',[0,1,*range(2,14),29]),('enemy',[139])]:
 for sid in ids:art[group+':'+str(sid)]=sprite(group,sid)
for group in ['enm26','enm27','enemy','bullet']:shutil.copy2(B/group/'animation.spec.txt',O/'source'/(group+'.anm.txt'))
save('assets.lua','DSExtraArt='+lua(art)+'\n')
# Original logical sound records map ID51 -> filename36 and ID67 ->56.
# Read both indirections from the pinned retail executable rather than guessing.
sounds=[];soundlines=['local names={}']
(O/'se').mkdir(exist_ok=True)
for logical,off in [(51,0xaba2c),(67,0xabbbc)]:
 record=struct.unpack_from('<5I',raw,off);assert record[0]==logical
 ptr=struct.unpack_from('<I',raw,0xabbe8+record[1]*4)[0]
 filename=at(ptr,64).split(b'\0')[0].decode('ascii')
 src=R/'work/th125-extra/raw'/filename;dst=O/'se'/filename;shutil.copy2(src,dst)
 name='dsx.sound'+str(logical)
 soundlines.append('LoadSound('+lua(name)+','+lua('se/'+filename)+');names['+str(logical)+']='+lua(name))
 sounds.append(dict(id=logical,record_file_offset=hex(off),record=list(record),filename_index=record[1],source=str(src),target='se/'+filename,sha256=sha(dst)))
soundlines.append("DSExtraSound=function(id,x)if names[id]then PlaySound(names[id],0.5,(x or 0)/192)end end")
save('sound.lua','\n'.join(soundlines)+'\n')
# Same current player as HSoB; stage-local fixed power hook changes name only.
player=R/'aex-0.8.22/game/mod/HSoBStage5Normal';playerrefs=[]
for name in ['player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 src=player/name;text=src.read_text(encoding='utf-8').replace('HSoB Stage5 Road@Normal','DS Extra@Extra')
 save(name,text);playerrefs.append(dict(file=name,source=str(src),source_sha256=sha(src),sha256=sha(O/name)))
for p in (player/'art/player').glob('*'):shutil.copy2(p,O/'art/player'/p.name)
ref=dict(game='TH125 Double Spoiler',archive='G:/TouHou/[th125] 东方文花帖DS (汉化版+日文版)/th125.dat',archive_sha256='18fcf64c0a3e3586158ffe4c88e0ac4d958b68e2d6410cd1361c5e4928127f3b',source=source,assets=assets,sounds=sounds,native_exe=str(exe),native_exe_sha256=sha(exe),native_bullets=native,commands=sorted(allcommands),player=playerrefs,adapters=['AEX shooting/Bomb/lives replaces photo completion; original lifeSet10000 and DS_timer12000 retained.','Successful-photo counter replaced by elapsed attack time: every120frames after60frame entrance, capped photos-1 (4/4/3).','Original enmCreate HP1 orbit emitters/sparks accept ordinary shooting instead of photography; sparks keep separate source hurt/contact rectangles.','Original textures; ANM animation subset and AEX collision/rendering; no retail RNG/replay/frame parity claim.','No original BGM or generic emitter default sounds imported; explicit source charge/rush sounds51/67 use native-table lookup.'])
save('source/reference.json',json.dumps(ref,ensure_ascii=False,indent=2))
print('Built three source ECL closures;',sum(len(s['functions'])for s in source),'routines;',len(assets),'source sprites; five native type/color mappings.')
