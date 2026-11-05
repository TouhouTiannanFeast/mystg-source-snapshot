"""Extract only the local TH11 resources used by the new stage."""
from pathlib import Path
import subprocess, json, ast, struct
R=Path('G:/MySTG'); W=R/'work/th11-stage6'; M=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
B=Path('G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci')
D=next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith('[th11]'))/'th11.dat'
W.mkdir(parents=True,exist_ok=True)
def call(args,**kw):
 p=subprocess.run(list(map(str,args)),capture_output=True,check=True,**kw);return p.stdout
names=['enemy.anm','stgenm06.anm','stage06.anm','stage06.std','thbgm.fmt','musiccmt.txt']
listing=call([B/'thdat.exe','-l','11',D]).decode()
(W/'archive-list.txt').write_text(listing,encoding='utf-8')
names+=sorted(set(__import__('re').findall(r'se_\w+\.wav',listing)))
call([B/'thdat.exe','-x','11',D,'-C',W,*names])
for name in ['enemy','stgenm06','stage06']:
 p=W/name;p.mkdir(exist_ok=True)
 (p/'animation.spec.txt').write_bytes(call([B/'thanm.exe','-l','11',W/(name+'.anm')]))
 call([B/'thanm.exe','-x','11',W/(name+'.anm')],cwd=p)
source=Path('G:/TouHou/MLforDanmu/tools/extract_touhou_backgrounds.py').read_text(encoding='utf-8')
tree=ast.parse(source)
nodes=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='binary_std' or isinstance(n,ast.Assign) and any(isinstance(t,ast.Name)and t.id in ['STD_NAMES','STD_FORMATS']for t in n.targets)]
ns={'struct':struct};exec(compile(ast.Module(body=nodes,type_ignores=[]),'<std reader>','exec'),ns)
data=ns['binary_std']((W/'stage06.std').read_bytes())
(W/'background.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
print('Extracted',len(names),'archive members; background program:')
for p in data['program']:print(p['time'],p['opcode'],p['arguments'])
print('objects',len(data['entries']),'quads',data['instance_quad_count'])
