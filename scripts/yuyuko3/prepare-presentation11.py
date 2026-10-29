from pathlib import Path
import shutil,json
b=Path('G:/MySTG');m=b/'aex-0.8.22/game/mod/Le03Stage4Normal';out=m/'art/touhou-bullets';src=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th10_1fb1d0ffe3/sprites')
if 'function S.bodyRGB' in (m/'bullet-style.lua').read_text(encoding='utf-8-sig'):
 raise SystemExit('Already prepared; do not replace current manual refinements or backups.')
w=b/'work/research/yuyuko3-background/presentation11';w.mkdir(parents=True,exist_ok=True)
for n in ('host.lua','bullet-style.lua'):shutil.copy2(m/n,w/('road-'+n))
manifest=[]
# TH10 16-color scale uses paired dim/bright rows; 8-color butterfly is native colored.
for style,ids,entry in [('scale',[143,130,132,134,136,138,140,142],0),('butterfly',list(range(280,288)),1)]:
 for c,i in enumerate(ids):
  p=src/f'bullet.entry{entry}.sprite{i}.png';shutil.copy2(p,out/f'{style}-{c}.png');manifest.append({'file':f'{style}-{c}.png','source':str(p)})
(out/'colored-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
p=m/'bullet-style.lua';s=p.read_text(encoding='utf-8-sig');s=s.replace("elseif b.sourceAppear==2700 then b.style='butterfly' end","elseif b.sourceAppear==2700 or b.sourceAppear==3100 or b.sourceAppear==3500 then b.style='butterfly' end")
s=s.replace("if b.style then return 'le03.th.b.'..b.style end", "if b.style=='scale' or b.style=='butterfly' then\n  local col=(b.col or 0)%8\n  if b.tint then col=7 end\n  if b.rainbow then col=0 end\n  return 'le03.th.b.'..b.style..'.'..col\n end\n if b.style then return 'le03.th.b.'..b.style end")
s=s.replace("function S.load()", "function S.bodyRGB(b)\n if (b.style=='scale' or b.style=='butterfly') and not b.rainbow then return 255,255,255 end\n return S.rgb(b)\nend\nfunction S.load()\n for _,n in ipairs({'scale','butterfly'})do for col=0,7 do\n  local k='le03.th.b.'..n..'.'..col\n  LoadTexture(k,(Le03AssetRoot or 'art/')..'touhou-bullets/'..n..'-'..col..'.png')\n  local w,h=GetTextureSize(k);LoadImage(k,k,0,0,w,h)\n end end")
p.write_text(s,encoding='utf-8')
p=m/'host.lua';s=p.read_text(encoding='utf-8-sig').replace('if b.style then r,g,bl=Le03BulletStyle.rgb(b)end','if b.style then r,g,bl=Le03BulletStyle.bodyRGB(b)end')
s=s.replace('R.onShot=function(b)',"local soundTick=-1\nlocal function shotSound(b)\n -- One sound per emission frame, so a fan never stacks dozens of identical sounds.\n if b.age<=1 and soundTick~=R.tick then\n  soundTick=R.tick;PlaySound('tan00',0.3,math.max(-1,math.min(1,(b.x-192)/192)))\n end\nend\nR.onShot=function(b)")
s=s.replace('if b._host then return end;b._host=true','if b._host then return end;b._host=true;shotSound(b)')
s=s.replace('R.onLaser=function(b) if not b._host then b._host=true;New(Beam,b) end end','R.onLaser=function(b) if not b._host then b._host=true;shotSound(b);New(Beam,b) end end')
p.write_text(s,encoding='utf-8')

