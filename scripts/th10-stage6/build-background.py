from pathlib import Path
import ast,struct,re,json,shutil,hashlib,subprocess
R=Path('G:/MySTG');W=R/'work/th10-stage6';O=R/'aex-0.8.22/game/mod/TH10Stage6Normal'
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,bool):return 'true' if v else 'false'
 return str(v) if v is not None else 'nil'
source=Path('G:/TouHou/MLforDanmu/tools/extract_touhou_backgrounds.py').read_text(encoding='utf-8')
tree=ast.parse(source);nodes=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='binary_std' or isinstance(n,ast.Assign) and any(isinstance(t,ast.Name)and t.id in ['STD_NAMES','STD_FORMATS']for t in n.targets)]
ns={'struct':struct};exec(compile(ast.Module(body=nodes,type_ignores=[]),'<local binary std reader>','exec'),ns)
data=ns['binary_std']((W/'stage06.std').read_bytes())
spec=(W/'stage06.anm.txt').read_text(encoding='utf-8-sig');sprites={};scripts={};lines=['TH10S6BackgroundData={}']
refs=[]
for entry in re.split(r'(?=^entry entry\d+ \{)',spec,flags=re.M):
 m=re.search(r'name: "([^"]+)"',entry)
 if not m:continue
 src=W/m[1];dst=O/'art'/('bg-'+src.name);shutil.copy2(src,dst)
 tex='s6.bg.'+src.stem;lines.append(f'LoadTexture({lua(tex)},{lua(str(dst.relative_to(O)).replace(chr(92),"/"))})')
 refs.append({'file':str(src),'sha256':hashlib.sha256(src.read_bytes()).hexdigest()})
 for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
  i=int(m[1]);sprites[i]='s6.bg.sprite'+str(i);lines.append(f'LoadImage({lua(sprites[i])},{lua(tex)},{",".join(m.groups()[1:])})')
for m in re.finditer(r'script script(\d+) \{(.*?)\n\}',spec,re.S):
 body=m[2];first=body.split('+',1)[0];sid=re.search(r'ins_3\(sprite(\d+)\)',first);rot=re.search(r'ins_49\((.*?)\)',first);rgb=re.search(r'ins_52\((.*?)\)',first)
 scripts[int(m[1])]=dict(sprite=int(sid[1])if sid else None,rot=[float(s.strip().rstrip('f')) for s in rot[1].split(',')]if rot else [0,0,0],rgb=[int(s)for s in rgb[1].split(',')]if rgb else [255]*3)
data['scripts']=scripts;data['sprites']=sprites
lines.append('TH10S6BackgroundData='+lua(data))
(O/'background-assets.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
for n in ['stage06.std','stage06.std.txt','stage06.anm.txt']:shutil.copy2(W/n,O/'source'/n)
(O/'source/background-reference.json').write_text(json.dumps({'textures':refs,'std_roundtrip':data['instruction_bytes_roundtrip'],'quad_count':data['instance_quad_count']},indent=2),encoding='utf-8')
print('Background:',len(data['entries']),'objects,',data['instance_quad_count'],'instance quads, exact STD byte roundtrip')
