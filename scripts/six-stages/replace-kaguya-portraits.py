from pathlib import Path
import json,re,hashlib,shutil,sys
from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign/dialogue3';O=R/'work/logs/six-stages/kaguya-portraits-20261113';O.mkdir(parents=True,exist_ok=True)
# User-provided 512x512 bald Kaguya expressions; one-to-one with the original IDs.
OVERRIDES={'1':'光头辉夜普通-1.png','5':'光头辉夜流汗-5.png','11':'光头辉夜疑问-11.png','14':'光头辉夜开心-14.png','21':'光头辉夜愤怒-21.png','22':'光头辉夜侧视-22.png'}
# The old 1024px portraits used this scale for the 360px dialogue frame; the new
# images are half-size, so double it to keep the same full-frame height/anchor.
SCALE=0.3589232303090728*2
for file in ['data.lua','source.json']:
 if not(O/('before-'+file)).exists():shutil.copy2(M/file,O/('before-'+file))
s=(M/'data.lua').read_text('utf-8-sig');out=s;records={}
for expr,name in OVERRIDES.items():
 p=M/'art'/name
 im=Image.open(p).convert('RGBA');box=im.getchannel('A').getbbox();w,h=im.size
 assert (w,h)==(512,512),(p,w,h)
 a={'file':'art/'+p.name,'w':w,'h':h,'cx':(box[0]+box[2])/2,'cy':box[3],'scale':SCALE}
 serial='{'+','.join('['+json.dumps(k,ensure_ascii=False)+']='+json.dumps(v,ensure_ascii=False)for k,v in a.items())+'}'
 pat=r'(\["kaguya'+expr+r'"\]=)\{[^{}]*\}'
 out,n=re.subn(pat,lambda m:m[1]+serial,out);assert n==1
 records['kaguya'+expr]=dict(a,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),alpha_bbox=box,replaces='art/kaguya-'+expr+'.png')
(M/'data.lua').write_text(out,'utf-8')
source=json.loads((M/'source.json').read_text('utf-8-sig'))
overrides=source.get('user_portrait_overrides',{});overrides.update(records);source['user_portrait_overrides']=overrides
(M/'source.json').write_text(json.dumps(source,ensure_ascii=False,indent=2),'utf-8')
(O/'mapping.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),'utf-8')
# Semantic readback: everything except these six art records must remain identical.
sys.path.insert(0,'G:/MySTG/work/six-stages-tools');from lupa.lua51 import LuaRuntime
l=LuaRuntime()
def plain(t):return{k:plain(v)for k,v in t.items()}if hasattr(t,'items')else t
old=plain(l.execute(s));new=plain(l.execute(out))
for key,a in records.items():
 assert new['art'][key]['file']==a['file']
 assert abs(new['art'][key]['scale']-SCALE)<1e-15
 old['art'][key]=new['art'][key]
assert old==new,'unrelated dialogue/art changed'
print('PASS six bald Kaguya portrait mappings; original full-frame scale and bottom anchor; other text/art unchanged; PNG bytes preserved')
