from pathlib import Path
import re,shutil,json
base=Path('G:/MySTG');m=base/'aex-0.8.22/game/mod/YuyukoStage3';w=base/'work/research/yuyuko3-background'
art=m/'art/background';art.mkdir(parents=True,exist_ok=True)
for p in [* (w/'background/stage04').glob('*.png'),*(w/'data/eff00').glob('*.png')]:shutil.copy2(p,art/p.name)
src=m/'source/background';src.mkdir(parents=True,exist_ok=True)
for n in ('std.txt','anm.txt','eff06.txt'):shutil.copy2(w/n,src/n)
def lua(x):
 if isinstance(x,dict):return '{'+','.join('['+lua(k)+']='+lua(v) for k,v in x.items())+'}'
 if isinstance(x,(list,tuple)):return '{'+','.join(map(lua,x))+'}'
 if isinstance(x,str):return json.dumps(x)
 return str(x)
def num(s):
 s=s.strip()
 if s.startswith('#'):return int(s[1:-2],16)
 return float(s[:-1]) if s.endswith('f') else int(s)
txt=(w/'std.txt').read_text();std=[];time=0
for line in txt.split('SCRIPT:')[1].splitlines():
 if re.match(r'^\d+:',line):time=int(line.split(':')[0])
 match=re.search(r'ins_(\d+)\((.*?)\);',line)
 if match:
  op=int(match[1]);args=list(map(num,match[2].split(',')))
  if op==1:args[0]=next(i+1 for i,c in enumerate(std) if c[0]==args[1])
  std.append([time,op,args])
groups=[]
for chunk in txt.split('ENTRY:')[1:]:
 pos=list(map(float,re.search(r'Position: (.*)',chunk)[1].split()))
 script=int(re.search(r'Script_index: (\d+)',chunk)[1]);faces=[list(map(float,s.split()))[1:4] for s in re.findall(r'FACE: (.*)',chunk)]
 groups.append(dict(pos=pos,script=script,layer=script,width=1024,height=512,faces=faces))
p=dict(textures={'y3.bg.ground':['art/background/stage04a.png',512,512],'y3.bg.cloud':['art/background/stg4bg2.png',256,256]},sprites={0:['y3.bg.ground',0,0,1024,512],1:['y3.bg.cloud',0,0,1024,512]},std=std,groups=groups,anm={})
for i,chunk in enumerate((w/'anm.txt').read_text().split('script ')[1:]):
 code=[]
 for op,args in re.findall(r'ins_(\d+)\((.*?)\);',chunk.split('+10000:')[0]):
  code.append([0,int(op),[num(v.replace('sprite','')) for v in args.split(',')]])
 code.append([0,3,[]]);p['anm'][i]=code
(m/'background-program.lua').write_text('Y3BackgroundProgram={'+lua(p)+'}\n',encoding='utf-8')
player=(base/'aex-0.8.22/game/mod/Stage12Normal/background-player.lua').read_text(encoding='utf-8').replace('Stage12BackgroundPlayer','Y3BackgroundPlayer').replace('Stage12BackgroundProgram','Y3BackgroundProgram')
player=player.replace("elseif op==400 then", "elseif op==312 then -- Source texture filtering/wrap; sampler configured on load.\n  elseif op==404 then a.rgb=copy(v)\n  elseif op==400 then")
player=player.replace('local color=Color(alpha,255,255,255)','local rgb=a.rgb or {255,255,255};local color=Color(alpha,rgb[1],rgb[2],rgb[3])')
(m/'background-player.lua').write_text(player,encoding='utf-8')
