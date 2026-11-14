from pathlib import Path
import re,json,hashlib
M=Path('G:/MySTG/aex-0.8.22/game/mod/SixStageCampaign/road5-background')
def lua(x):
 if isinstance(x,str):return json.dumps(x)
 if isinstance(x,(int,float)):return str(x)
 if isinstance(x,list):return '{'+','.join(lua(v)for v in x)+'}'
 return '{'+','.join('['+lua(k)+']='+lua(v)for k,v in x.items())+'}'
models={}
for name in ['b','e','fa','fb']:
 s=(M/('world05'+name+'.mqo')).read_text('cp932')
 faces=[]
 for obj in re.split(r'(?m)^Object ',s)[1:]:
  vertices=[list(map(float,line.split()))for line in re.search(r'\bvertex (\d+) \{(.*?)\n\s*\}',obj,re.S)[2].strip().splitlines()]
  for line in re.search(r'\bface (\d+) \{(.*?)\n\s*\}',obj,re.S)[2].strip().splitlines():
   ids=list(map(int,re.search(r'V\((.*?)\)',line)[1].split()));uv=list(map(float,re.search(r'UV\((.*?)\)',line)[1].split()))
   face=[vertices[j]+[uv[i*2],uv[i*2+1]]for i,j in enumerate(ids)]
   if len(face)==3:face.append(face[-1])
   assert len(face)==4
   faces.append(face)
 texture=Path(re.search(r'tex\("(.*?)"\)',s)[1]).name
 models[name]={'texture':texture,'faces':faces}
(M/'meshes.lua').write_text('return '+lua(models)+'\n','utf-8')
print('Converted original MQO faces', {n:len(m['faces'])for n,m in models.items()})
