"""TH10 Extra original scene, isolated player parity and narrow provenance."""
from pathlib import Path
import subprocess,re,runpy,json,ast,struct,shutil,hashlib
R=Path('G:/MySTG');O=R/'aex-0.8.22/game/mod/TH11Stage6Normal';W=R/'work/th11-stage6/ex-background';B=Path('G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci')
D=next(p for p in Path('G:/TouHou').iterdir()if p.name.startswith('[th10]'))/'th10.dat'
S=R/'aex-0.8.22/game/mod/HSoBStage5Normal'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,bool):return 'true' if v else 'false'
 return str(v)if v is not None else 'nil'
def call(args,**kw):return subprocess.run(list(map(str,args)),capture_output=True,check=True,**kw).stdout
W.mkdir(parents=True,exist_ok=True)
if not(W/'stage07.std').exists():
 call([B/'thdat.exe','-x','10',D,'-C',W,'stage07.std','stage07.anm'])
 (W/'stage07.anm.txt').write_bytes(call([B/'thanm.exe','-l','10',W/'stage07.anm']))
 call([B/'thanm.exe','-x','10',W/'stage07.anm'],cwd=W)
source=Path('G:/TouHou/MLforDanmu/tools/extract_touhou_backgrounds.py').read_text(encoding='utf-8');tree=ast.parse(source)
nodes=[n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name=='binary_std'or isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id in ['STD_NAMES','STD_FORMATS']for t in n.targets)]
ns={'struct':struct};exec(compile(ast.Module(body=nodes,type_ignores=[]),'<std>','exec'),ns)
data=ns['binary_std']((W/'stage07.std').read_bytes());spec=(W/'stage07.anm.txt').read_text(encoding='utf-8-sig')
sprites={};scripts={};refs=[];lines=[]
for entry in re.split(r'(?=^entry entry\d+ \{)',spec,flags=re.M):
 m=re.search(r'name: "([^"]+)"',entry)
 if not m:continue
 p=W/m[1];dst=O/'art'/('ex-'+p.name);shutil.copy2(p,dst)
 refs.append({'source':str(p),'sha256':sha(p),'output':dst.relative_to(O).as_posix()})
 tex='th11s6.ex.'+p.stem;lines.append('LoadTexture('+lua(tex)+','+lua(dst.relative_to(O).as_posix())+')')
 # Source UV spans512px over256px textures. Clamping smears the lower half.
 lines.append('SetTextureSamplerState('+lua(tex)+',"linear+wrap")')
 for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
  sid=int(m[1]);sprites[sid]='th11s6.ex.sprite'+str(sid);lines.append('LoadImage('+lua(sprites[sid])+','+lua(tex)+','+','.join(m.groups()[1:])+')')
for m in re.finditer(r'script script(\d+) \{(.*?)\n\}',spec,re.S):
 body=m[2];first=body.split('+',1)[0];sprite=re.search(r'ins_3\(sprite(\d+)\)',first);rot=re.search(r'ins_49\((.*?)\)',first);rgb=re.search(r'ins_52\((.*?)\)',first);alpha=re.search(r'ins_51\((\d+)\)',first)
 scripts[int(m[1])]=dict(sprite=int(sprite[1])if sprite else None,rot=[float(x.strip().rstrip('f'))for x in rot[1].split(',')]if rot else [0,0,0],rgb=[int(x)for x in rgb[1].split(',')]if rgb else [255]*3,alpha=int(alpha[1])if alpha else 255,deleted='ins_1();'in first,source=body)
data['sprites']=sprites;data['scripts']=scripts;lines.append('TH11S6BackgroundData='+lua(data))
leaf=R/'aex-0.8.22/game/mod/TH10Stage6Normal/art/bullet-etama2.png';dst=O/'art/ex-leaf-atlas.png';shutil.copy2(leaf,dst)
refs.append(dict(source=str(leaf),sha256=sha(leaf),output=dst.relative_to(O).as_posix()))
lines+=['LoadTexture("th11s6.ex.leaf","art/ex-leaf-atlas.png")','LoadImage("th11s6.ex.leaf","th11s6.ex.leaf",0,224,32,32)','TH11S6BackgroundData.leaf="th11s6.ex.leaf"']
(O/'background-assets.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
for p in [W/'stage07.std',W/'stage07.anm.txt']:shutil.copy2(p,O/'source'/('ex-'+p.name))
(O/'source/background-selection.json').write_text(json.dumps(dict(user_request='Use TH10 Extra background',source=str(W/'stage07.std'),source_sha256=sha(W/'stage07.std'),anm_source=str(W/'stage07.anm.txt'),anm_sha256=sha(W/'stage07.anm.txt'),archive=str(D),archive_sha256=sha(D),textures=refs,quad_count=data['instance_quad_count']),indent=2),encoding='utf-8')
playerrefs=[]
for name in ['player.lua','player-config.lua','player-data.lua','power-lock.lua']:
 p=S/name;content=p.read_bytes()
 if name=='power-lock.lua':content=content.replace(b'HSoB Stage5 Road@Normal',b'Subterranean Animism 6@Normal')
 (O/name).write_bytes(content);playerrefs.append(dict(source=str(p),source_sha256=sha(p),output=name,output_sha256=sha(O/name),adaptation='stage name only'if name=='power-lock.lua'else 'byte-identical'))
for p in (S/'art/player').rglob('*'):
 if p.is_file():
  dst=O/'art/player'/p.relative_to(S/'art/player');dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
  playerrefs.append(dict(source=str(p),source_sha256=sha(p),output=dst.relative_to(O).as_posix(),output_sha256=sha(dst)))
(O/'source/player-reference.json').write_text(json.dumps(dict(reference_thread='01a17978-1050-77c3-b9af-a24946393240',reference_mod=str(S),files=playerrefs),indent=2),encoding='utf-8')
ref=json.loads((O/'reference.json').read_text(encoding='utf-8'));ref['rendered_background']='TH10 Extra stage07.std/anm; source/background-selection.json';ref['player_reference']='current HSoBStage5Normal; source/player-reference.json';(O/'reference.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(W/'scene.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
print('Extra scene',len(data['entries']),'objects',data['instance_quad_count'],'quads; player files',len(playerrefs))
for p in data['program']:print(p['time'],p['opcode'],p['arguments'],p.get('target_instruction_index'))
print('ANM scripts',scripts)
