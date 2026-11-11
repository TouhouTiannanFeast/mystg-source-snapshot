"""Extract only the owning original TH08 star sprites and Normal Final Spark."""
from pathlib import Path
import json,re,shutil,hashlib,sys,struct
from PIL import Image
sys.path.insert(0,str(Path(__file__).parent));import inspect02 as native
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed')
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8')
O=M/'art/th08-02';O.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
manifest=json.loads((B/'manifest.json').read_text(encoding='utf8'));rows={int(r['id'].split('sprite')[-1]):r for r in manifest['sprites'] if 'path'in r and r['id'].startswith('etama.')}
art={};crops=[]
for sid in range(246,270):
 row=rows[sid];src=B/row['path'];dest=O/f'star-{sid}.png';shutil.copy2(src,dest)
 im=Image.open(dest);art[str(sid)]={'path':dest.relative_to(M).as_posix(),'w':im.width,'h':im.height}
 crops.append({'sprite':sid,'source':str(src),'sha256':sha(src),'rect':row['rect_xywh']})
src=M/'source/th08/data/player00/player01b.png';im=Image.open(src);im.crop((1,0,256,128)).save(O/'final-spark.png')
art['spark']={'path':'art/th08-02/final-spark.png','w':255,'h':128}
(M/'th08-art02.lua').write_text('TH08Art02='+lua(art)+'\n',encoding='utf8')
spec=(M/'source/th08/stg4benm.spec02.txt').read_text(encoding='utf-8-sig')
beam_scripts={}
for sid in range(10,14):
 body=re.search(r'script script'+str(sid)+r' \{(.*?)\n\}',spec,re.S)[1];beam_scripts[str(sid)]=body
 assert 'ins_82(1)'in body and 'sprite12'in body and '2.3f'in body
etext=(B/'etama/animation.spec.txt').read_text(encoding='utf8');star_scripts={}
for sid in range(107,111):star_scripts[str(sid)]=re.search(r'script script'+str(sid)+r' \{(.*?)\n\}',etext,re.S)[1]
table={}
for typ in range(12,16):
 address=0x4b4ad8+typ*20;table[str(typ)]={'address':hex(address),'fields':list(struct.unpack('<5I',native.raw[native.off(address):native.off(address)+20]))}
 assert table[str(typ)]['fields'][0]==107+typ-12
ref={'scope':'five user corrections only','native_exe':str(native.P),'native_sha256':sha(native.P),'bullet_table':table,'star_scripts':star_scripts,'star_crops':crops,'small_colors':16,'big_colors':8,
 'spark_texture':{'source':str(src),'sha256':sha(src),'rect':[1,0,255,128],'crop_sha256':sha(O/'final-spark.png')},'spark_scripts':beam_scripts,
 'spark_source_ECL':'ecldata4b.named.utf8.txt Sub67/Sub70..73: 295px center, four Normal scripts10..13, quadratic60f center travel; preserve existing collision and attack schedule',
 'familiar_policy':'TH08 high-speed circles use human-mode immunity. SSG source durability intentionally superseded by user request: all displayed green magic circles are permanent until phase cleanup.'}
(M/'source/visual02.json').write_text(json.dumps(ref,ensure_ascii=False,indent=2),encoding='utf8')
print('PASS original TH08 type12..15 -> ANM107..110;16 small/8 big palettes; four Normal Spark scripts10..13 and exact255x128 texture')
