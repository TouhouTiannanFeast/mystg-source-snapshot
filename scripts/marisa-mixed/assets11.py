from pathlib import Path
import json,hashlib,shutil
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
B=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8')
rows=json.loads((B/'manifest.json').read_text(encoding='utf8'))['sprites'];out=[];lua=[]
for key,num in [('laser11',158),('laser11glow',148)]:
 row=next(x for x in rows if x['id']=='etama.entry0.sprite'+str(num))
 src=B/row['path'];dst=M/'art/selected05'/f'{key}.png';shutil.copy2(src,dst)
 w,h=row['rect_xywh'][2:]
 lua.append('SSGSelectedArt05.'+key+'={path="art/selected05/'+key+'.png",w='+str(int(w))+',h='+str(int(h))+'}')
 out.append(dict(sprite=num,path=str(src),sha256=hashlib.sha256(src.read_bytes()).hexdigest()))
p=M/'selected05-art.lua';s=p.read_text(encoding='utf8')
s='\n'.join(x for x in s.splitlines()if not x.startswith('SSGSelectedArt05.laser11'))
p.write_text(s+'\n'+'\n'.join(lua)+'\n',encoding='utf8')
(M/'source/laser11.json').write_text(json.dumps(dict(assets=out,evidence='TH08 SpawnLaserPattern0x430f20: body script10+type sprite152+color; secondary sprite146+map[color]. Bluecolor6 yields158 and148. Draw0x432bb8..432ea0 renders both VMs; origin glow scale width/16. Replaces erroneous specialglyphsprite221.',warning='last30f of existing60f charge, noncolliding, no firetime change'),indent=2),encoding='utf8')
print('PASS original standard blue laser sprite158 and origin glow148 extracted')
