from pathlib import Path
import json,re,hashlib,shutil
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue3';O=R/'work/logs/six-stages/shion-portraits-20261113';O.mkdir(parents=True,exist_ok=True)
for file in ['data.lua','source.json']:
 if not(O/('before-'+file)).exists():shutil.copy2(M/file,O/('before-'+file))
s=(M/'data.lua').read_text('utf-8-sig');out=s;records={}
for expr in ['03','04','06','07','08']:
 p=M/'art'/f'shion{expr}.png';im=Image.open(p).convert('RGBA');box=im.getchannel('A').getbbox();w,h=im.size
 a={'file':'art/'+p.name,'w':w,'h':h,'cx':(box[0]+box[2])/2,'cy':box[3],'scale':360/(box[3]-box[1])}
 serial='{'+','.join('['+json.dumps(k)+']='+json.dumps(v)for k,v in a.items())+'}'
 pat=r'(\["shion'+expr+r'"\]=)\{[^{}]*\}'
 out,n=re.subn(pat,lambda m:m[1]+serial,out);assert n==1
 records['shion'+expr]=dict(a,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),alpha_bbox=box,replaces='art/shion-'+expr+'.png')
(M/'data.lua').write_text(out,'utf-8')
source=json.loads((M/'source.json').read_text('utf-8-sig'));source['user_portrait_overrides']=records
(M/'source.json').write_text(json.dumps(source,ensure_ascii=False,indent=2),'utf-8')
(O/'mapping.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),'utf-8')
# Semantic readback: everything except these five art records must remain identical.
import sys
sys.path.insert(0,'G:/MySTG/work/six-stages-tools');from lupa.lua51 import LuaRuntime
l=LuaRuntime()
def plain(t):return{k:plain(v)for k,v in t.items()}if hasattr(t,'items')else t
old=plain(l.execute(s));new=plain(l.execute(out))
for key,a in records.items():
 assert new['art'][key]['file']==a['file']
 assert abs(new['art'][key]['scale']*(a['alpha_bbox'][3]-a['alpha_bbox'][1])-360)<1e-8
 old['art'][key]=new['art'][key]
assert old==new,'unrelated dialogue/art changed'
print('PASS all five new portrait mappings,360px alpha height, centered/bottom anchors; other text/art unchanged; PNG bytes preserved')
