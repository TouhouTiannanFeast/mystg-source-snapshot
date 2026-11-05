"""Private source compiler for Nina's TH13 Hard, TH17 Normal, TH20 Extra attacks."""
from pathlib import Path
import re,json,sys,shutil,hashlib,struct,subprocess
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/NinaStage6Normal';B=R/'aex-0.8.22/game/mod/TH13Seiga4'
sys.dont_write_bytecode=True
sys.path.insert(0,str(R/'scripts/suwako5'));import build as lower
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
def save(n,s):
 p=M/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def branch(body,diff):
 active=True;stack=[];out=[]
 for line in body.splitlines():
  s=line.strip()
  if s.startswith('!'):active=s=='!*' or diff in s[1:];continue
  if not active and not s.endswith(':') and not s.startswith('+'):continue
  m=re.fullmatch(r'(.+);',s)
  if m and not any(s.startswith(x)for x in ('var ','return','goto ','if ','unless ','@'))and not re.match(r'\w+\(',s)and not re.match(r'[$%]\w+\s*=',s):stack.append(m[1]);continue
  refs=re.findall(r'\[-(\d+)(?:\.0f)?\]',s)
  if refs and not stack:raise ValueError((s,stack))
  if refs:s=re.sub(r'\[-(\d+)(?:\.0f)?\]',lambda m:'('+stack[-min(int(m[1]),len(stack))]+')',s);del stack[-max(map(int,refs)):]
  out.append(s)
 assert not stack,stack
 return '\n'.join(out)
alias={'enemy_invincible_timer':'setInvuln','enemy_life_set':'lifeSet','bullet_cancel_radius':'etCancel','bullet_clear_radius':'etClear','enemy_bomb_shield':'bombShield','phase_timer_clear':'timerReset','async_stop_all':'killAllAsync','spellcard_end':'spellEnd','laser_clear_all':'laserCancel','effect_sound':'playSound','move_velocity_abs':'moveVel','move_velocity_abs_interp':'moveVelTime','move_position_abs_interp':'movePosTime','anm_source':'anmSelect','anm_set_slot_main':'anmSetMain','move_bounds_set':'moveLimit','callback_ex':'setInterrupt','ecl_time_sub':'wait','move_rand_interp_abs':'moveRand','anm_play_attack':'anmPlay','shooter_reset':'etNew','shoot_aim_mode':'etAim','bullet_sprite':'etSprite','bullet_count':'etCount','shoot_angle':'etAngle','bullet_speed':'etSpeed','bullet_effects_add':'etEx','bullet_effects':'etExSet','shoot_now':'etOn','enemy_kill_all_stones':'enmKillAll'}
registers={'PHASE_TIMEOUT':'TIMEOUT','PLAYER_DEATHS':'MISS_COUNT','PLAYER_BOMBS_USED':'BOMB_COUNT','SPELL_CAPTURE':'CAPTURE','EI0':'I0','RAND_ANGLE':'RANDRAD','RAND_FLOAT_SIGNED':'RANDF2'}
oldexpr=lower.expr
def expr(s):
 s=re.sub(r'\$GI(\d+)',r'R.gi[\1]',s)
 s=re.sub(r'\$(MISS_COUNT|BOMB_COUNT|CAPTURE)',r'R.shared.\1',s)
 return oldexpr(s.replace('$ID','a.id'))
lower.expr=expr
base=Path('G:/TouHou/MLforDanmu/data/local/touhou')
sources={'th13':(B/'source/st04bs.named.utf8.txt','H',['BossCard1','BossCard2','BossMiyako1','BossMiyako2','BossMiyakoDead']), 'th17':(base/'20261006-022841/th17_local-original-archive-candidate_109c193c492f/raw/st06bs.named.utf8.txt','N',['BossCard4']), 'th20':(base/'th20-20261027/th20_local-original-archive-candidate_9db8d7c43fba/raw/st07bs.named.utf8.txt','L',['Boss3'])}
chunks=['NinaCorePrograms={};local R=NinaCoreRuntime'];refs={};closures={}
for group,(src,diff,entries) in sources.items():
 text=src.read_text(encoding='utf-8-sig')
 if group=='th20':
  for a,b in alias.items():text=re.sub(r'\b'+a+r'\b',b,text)
  for a,b in registers.items():text=re.sub(r'\b'+a+r'\b',b,text)
  # TH20 effect codes are enum indices rather than bit masks.
  def effects(m):
   args=m[2].split(',');i=3 if m[1]=='etExSet' else 2;v=int(args[i]);args[i]=' '+str({1:2,3:8,21:2097152,30:-2147483648}.get(v,v));return m[1]+'('+','.join(args)+');'
  text=re.sub(r'(etExSet|etEx)\(([^\n]*)\);',effects,text)
 fs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3])for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',text,re.M|re.S)}
 seen=set();todo=entries.copy()
 while todo:
  n=todo.pop()
  if n in seen or n in ['BossItem','Ecl_EtBreak']:continue
  seen.add(n);fs[n]['body']=branch(fs[n]['body'],diff);body=fs[n]['body'];todo+=re.findall(r'@(\w+)\(',body)+re.findall(r'(?:enmCreate\w*\(|enmCall\([^,]+, )"(\w+)"',body)
  if n.startswith('BossMiyako'):todo+=re.findall(r'setInterrupt\([^\n]*"(\w+)"',body)
 chunks+=['NinaCorePrograms.'+group+'={};local P=NinaCorePrograms.'+group];commands=set();closure={}
 for n in sorted(seen):
  fn=fs[n].copy();b=fn['body'];b=re.sub(r'@BossItem\([^\n]*\);','nop();',b)
  b=re.sub(r'diffF\((%\w+), ([^,]+), ([^,]+), ([^,]+), ([^)]+)\);',lambda m:m[1]+' = '+m[4 if diff=='H'else 3]+';',b)
  b=re.sub(r'enmPos\((%\w+), (%\w+), ([^)]+)\);',r'\1 = R.actorX(\3);\n\2 = R.actorY(\3);',b)
  b=b.replace('enmKillAll();','clearMinors();')
  fn['body']=b;code,cmd=lower.lower(fn);commands|=cmd;chunks.append('P['+lua(n)+']='+code);closure[n]=fn
 save('source/'+group+'-original.txt',src.read_text(encoding='utf-8-sig'));save('source/'+group+'-closure.json',json.dumps(closure,ensure_ascii=False,indent=2));closures[group]=closure
 refs[group]=dict(source=str(src),sha256=sha(src),difficulty=diff,routines=sorted(seen),commands=sorted(commands))
save('programs.lua','\n'.join(chunks))
for n in ['runtime.lua','projectiles.lua','encounter.lua']:
 s=(B/n).read_text(encoding='utf-8').replace('Seiga','NinaCore')
 if n=='encounter.lua':s=s.replace("R.yoshika=R.newActor('th13'", "if spec.group:sub(1,4)~='th13' then R.yoshika=nil;return end\n R.yoshika=R.newActor(spec.group")
 save(n,s)
for n in ['player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 save(n,(B/n).read_text(encoding='utf-8').replace('Seiga Four@Normal','Nina Six@Normal'))
shutil.copytree(B/'art/player',M/'art/player',dirs_exist_ok=True)
# Source source sprites for all selected TH13 colors; additional banks below.
art={};assetref=[]
def copyart(key,src,radius=4):
 dst=M/'art'/(key.replace(':','-')+'.png');dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);w,h=Image.open(dst).size
 art[key]=dict(image='nina.'+key,path=dst.relative_to(M).as_posix(),w=w,h=h,radius=radius);assetref.append(dict(target=dst.relative_to(M).as_posix(),source=str(src),sha256=sha(dst)))
for key,v in json.loads('{}').items():pass
# TH13 binary descriptors are pinned by the pre-existing verified importer.
sys.path.insert(0,str(R/'scripts/mamizou-stage2'));import importlib.util
spec=importlib.util.spec_from_file_location('binary',R/'scripts/mamizou-stage2/inspect-binary.py');binary=importlib.util.module_from_spec(spec);spec.loader.exec_module(binary)
bank=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th13_3443fe0df1')
manifest=json.loads((bank/'manifest.json').read_text(encoding='utf-8'));rows={int(v['id'].split('sprite')[-1]):v for v in manifest['sprites']if v['id'].startswith('bullet.')and 'path'in v}
for typ in [5,9,10,18,19,20,21]:
 data=binary.at(0x4bbe30+typ*0x114,0x114)
 for col in range(8 if typ>=18 else 16):
  sid=struct.unpack_from('<I',data,4+col*16)[0]
  if sid in rows:copyart('th13:'+str(typ)+':'+str(col),bank/rows[sid]['path'],struct.unpack_from('<f',data,0x104)[0])
copyart('curve',B/'art/curve8.png')
def crops(bank,folder,prefix):
 txt=(bank/folder/'animation.spec.txt').read_text(encoding='utf-8-sig')
 for entry in re.split(r'(?=^entry entry\d+ \{)',txt,flags=re.M):
  path=re.search(r'name: "([^"]+)"',entry)
  if not path:continue
  im=Image.open(bank/folder/path[1]).convert('RGBA')
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1]);x,y,w,h=map(lambda v:int(float(v)),m.groups()[1:]);key=prefix+':'+str(sid);p=M/'art'/(key.replace(':','-')+'.png');im.crop((x,y,x+w,y+h)).save(p);art[key]=dict(image='nina.'+key,path=p.relative_to(M).as_posix(),w=w,h=h,radius=4)
 cropsref=dict(source=str(bank/folder),sha256=sha(bank/folder/'animation.spec.txt'));refs[prefix]=cropsref
bank20=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/th20-20261027/th20_9db8d7c43f');crops(bank20,'st07enm','nina')
bank17=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th17_109c193c49')
# TH17 native descriptor stride changed from 0x114 to 0x118.
sys.path.insert(0,str(R/'work/suwako5/vendor'));import pefile
exe17=next(next(p for p in Path('G:/TouHou').iterdir()if p.name.startswith('[th17]')).rglob('th17.exe'));pe=pefile.PE(str(exe17));memory=pe.get_memory_mapped_image()
manifest17=json.loads((bank17/'manifest.json').read_text(encoding='utf-8'));rows17={int(v['id'].split('sprite')[-1]):v for v in manifest17['sprites']if v['id'].startswith('bullet.')and 'path'in v}
for typ,col in [(4,4),(31,4),(31,6)]:
 off=0xaf3c0+typ*0x118;sid=struct.unpack_from('<I',memory,off+4+col*16)[0];radius=struct.unpack_from('<f',memory,off+0x104)[0]
 copyart('th17:'+str(typ)+':'+str(col),bank17/rows17[sid]['path'],radius)
 refs['native17:'+str(typ)+':'+str(col)]=dict(exe=str(exe17),sha256=sha(exe17),descriptor_rva=hex(off),sprite=sid,radius=radius)
manifest20=json.loads((bank20/'manifest.json').read_text(encoding='utf-8'));rows20={int(v['id'].split('sprite')[-1]):v for v in manifest20['sprites']if v['id'].startswith('bullet.')and 'path'in v}
copyart('th20:12:6',bank20/rows20[230]['path'],2.4)
refs['th20-visual-adaptation']='type12 arrowhead uses original bullet sprite230; native TH20 descriptor/radius not yet verified, radius2.4 from same-family prior titles'
work17=R/'work/nina-stage6/th17';work17.mkdir(parents=True,exist_ok=True)
bins=Path('G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci')
dat=next(next(p for p in Path('G:/TouHou').iterdir()if p.name.startswith('[th17]')).rglob('th17.dat'))
def run(args,cwd=None):
 p=subprocess.run(list(map(str,args)),cwd=cwd,capture_output=True);assert p.returncode==0,p.stderr;return p.stdout
run([bins/'thdat.exe','-x',17,dat,'-C',work17,'st06enm.anm']);run([bins/'thanm.exe','-x',17,work17/'st06enm.anm'],work17)
(work17/'animation.spec.txt').write_text(run([bins/'thanm.exe','-l',17,work17/'st06enm.anm']).decode('utf-8'),encoding='utf-8')
crops(work17.parent,'th17','haniwa')
# Descriptor scan performed separately for newer executables by asset-types.py.
for prefix,folder in [('suwako','stg7enm.png'),('suwakoDown','stg7enm3.png'),('frog','stg7enm2.png')]:
 work=R/'work/th11-stage6/boss04';txt=(work/'stgenm07.anm.txt').read_text(encoding='utf-8-sig');im=Image.open(work/'stgenm'/folder).convert('RGBA')
 entry=next(e for e in re.split(r'(?=^entry entry\d+ \{)',txt,flags=re.M)if 'name: "stgenm/'+folder+'"'in e)
 for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
  sid=int(m[1]);x,y,w,h=map(lambda v:int(float(v)),m.groups()[1:]);key=prefix+':'+str(sid);p=M/'art'/(key.replace(':','-')+'.png');im.crop((x,y,x+w,y+h)).save(p);art[key]=dict(image='nina.'+key,path=p.relative_to(M).as_posix(),w=w,h=h)
for src in (R/'work/th11-stage6/boss04').glob('*.txt'):shutil.copy2(src,M/'source'/src.name)
save('assets.lua','NinaCoreArt='+lua(art));save('source/reference.json',json.dumps(dict(sources=refs,assets=assetref),ensure_ascii=False,indent=2))
print('Built source programs', {k:len(v)for k,v in closures.items()})




