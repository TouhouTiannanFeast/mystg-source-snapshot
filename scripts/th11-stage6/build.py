"""Hash-pinned Normal ECL closure and original assets; no existing mod writes."""
from pathlib import Path
import re,json,shutil,hashlib,sys,runpy,struct,wave
R=Path('G:/MySTG');W=R/'work/th11-stage6';O=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
ML=Path('G:/TouHou/MLforDanmu');SRC=ML/'data/local/touhou/20261006-022841/th11_local-original-archive-candidate_3cb521c5d420/raw/stage06.named.utf8.txt'
BANK=ML/'data/local/bullet-assets/20261010-all-works/th11_3cb521c5d4/bullet'
BASE=R/'aex-0.8.22/game/mod/TH10Stage6Normal';MILK=R/'aex-0.8.22/game/mod/MilkHoney'
for p in [O,O/'art',O/'source',O/'se',O/'music',O/'milk',O/'milk/art']:p.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(list,tuple)):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if v is True:return 'true'
 if v is False:return 'false'
 if v is None:return 'nil'
 return str(v)
def save(n,s):(O/n).write_text(s,encoding='utf-8')
text=SRC.read_text(encoding='utf-8')
funcs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3])for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',text,re.M|re.S)}
selected=set();todo=['main']
while todo:
 n=todo.pop()
 if n in selected or n in ['Boss','MBoss','MapleEnemy']:continue
 selected.add(n);b=funcs[n]['body'];todo+=re.findall(r'@(\w+)\(',b)+re.findall(r'enmCreate\w*\("(\w+)"',b)
sys.path.insert(0,str(R/'scripts/suwako5'));import build as lowerer
chunks=['-- Generated TH11 stage06 Normal source instructions.','TH11S6Programs={th11={}};local P=TH11S6Programs.th11;local R=TH11S6Runtime'];commands=set()
for n in sorted(selected):
 fn=funcs[n].copy();lines=[];enabled=True
 for line in fn['body'].splitlines():
  if line.strip().startswith('!'):enabled=line.strip()=='!*' or 'N' in line;continue
  if enabled or line.strip().endswith(':') or re.match(r'\s*\+\d+:',line):lines.append(line)
 fn['body']='\n'.join(lines)
 if n=='main':
  old='dialogWait();\n    wait(1000);\n    @MainSub03();'
  assert old in fn['body']
  fn['body']=fn['body'].replace(old,'waitMidboss();\n    @MainSub03();',1)
 code,cmd=lowerer.lower(fn);commands|=cmd
 chunks.append('P['+lua(n)+']='+code.replace('Suwako5Runtime','TH11S6Runtime'))
save('programs.lua','\n'.join(chunks)+'\n')
shutil.copy2(SRC,O/'source/stage06.named.utf8.txt')
shutil.copy2(SRC.with_name('stage06mboss.named.utf8.txt'),O/'source/original-midboss.ecl.txt')
save('source/normal-closure.json',json.dumps({n:funcs[n]for n in sorted(selected)},indent=2))
# Preserve the complete current spell renderer/trajectory code; remove only
# standalone stage wiring, preceding nonspell, and standalone test hooks.
shutil.copy2(MILK/'pattern.lua',O/'milk/pattern.lua')
for p in (MILK/'art').glob('sprite*.png'):shutil.copy2(p,O/'milk/art'/p.name)
s=(MILK/'root.lua').read_text(encoding='utf-8')
s=s[s.index('local P=MilkHoneyPattern'):s.index("stage.group.New('Extra'")]
s=s.replace('    MilkHoneyNonspell.clean()\n','').replace("'art/sprite'","'milk/art/sprite'")
s=s.replace('{MilkHoneyNonspell.create(P),card}','{card}')
# Counters belong to the isolated stage, never the existing MilkHoney instance.
s=s.replace('MilkHoneyState=D','TH11S6MilkState=D').replace('setting.milk_test','setting.th11s6_milk_test')
s+="\nTH11S6Milk={Boss=Suwako,clean=clean,card=card,state=D}\n"
save('milk/boss.lua',s)
save('source/milk-reference.json',json.dumps({'source_root':str(MILK/'root.lua'),'source_root_sha256':sha(MILK/'root.lua'),'pattern_sha256':sha(MILK/'pattern.lua'),'hp':2250,'duration':3000,'nonspell_included':False},indent=2))
refs=[];assetlines=['TH11S6Sprites={enemy={},crow={},bullet={},bg={}}'];scripts={};spriteDefs={}
def archive(spec,folder,group):
 raw=spec.read_text(encoding='utf-8-sig');ss={};sc={}
 shutil.copy2(spec,O/'source'/(group+'.anm.txt'))
 for entry in re.split(r'(?=^entry entry\d+ \{)',raw,flags=re.M):
  m=re.search(r'name: "([^"]+)"',entry)
  if not m:continue
  src=folder/m[1];dst=O/'art'/(group+'-'+src.name);shutil.copy2(src,dst)
  refs.append(dict(source=str(src),sha256=sha(src),output=dst.relative_to(O).as_posix()))
  tex='th11s6.'+group+'.'+src.stem;assetlines.append('LoadTexture('+lua(tex)+','+lua(dst.relative_to(O).as_posix())+')')
  for m in re.finditer(r'sprite(\d+): \{ x: ([\d.]+), y: ([\d.]+), w: ([\d.]+), h: ([\d.]+) \}',entry):
   sid=int(m[1]);rect=list(map(float,m.groups()[1:]));ss[sid]=dict(tex=tex,rect=rect)
   img=f'th11s6.{group}.{sid}';assetlines.append(f'LoadImage({lua(img)},{lua(tex)},{",".join(map(str,rect))})');assetlines.append(f'TH11S6Sprites.{group}[{sid}]={lua(img)}')
 for m in re.finditer(r'script script(\d+) \{(.*?)\n\}',raw,re.S):sc[int(m[1])]=m[2]
 scripts[group]=sc;spriteDefs[group]=ss
archive(W/'enemy/animation.spec.txt',W/'enemy','enemy')
archive(W/'stgenm06/animation.spec.txt',W/'stgenm06','crow')
archive(BANK/'animation.spec.txt',BANK,'bullet')
archive(W/'stage06/animation.spec.txt',W/'stage06','bg')
native=runpy.run_path(str(R/'scripts/th11-stage6/inspect-native.py'));at=native['at']
anims={};nativeRows=[]
for typ,col in [(1,6),(1,4),(3,3),(3,13),(3,9),(4,6),(12,3)]:
 base=0x4a3ec0+typ*208;sid=struct.unpack('<i',at(base,4))[0];width=struct.unpack('<f',at(base+196,4))[0]
 bodySprite,birthSprite,cancelSprite=struct.unpack('<3i',at(base+4+col*12,12))
 body=scripts['bullet'][sid]
 active=body.split('ins_6([10000], 1);',1)[1] if 'ins_6([10000], 1);'in body else body
 active=active.split('ins_64(1);')[0]
 death=body.split('ins_64(1);',1)[1] if 'ins_64(1);'in body else body
 birth=body.split('ins_64(8);',1)[1] if 'ins_64(8);'in body else body
 def sprite(b):return int(re.search(r'ins_3\(sprite(\d+)\)',b)[1])
 anims[f'{typ}:{col}']=dict(script=sid,width=width,body=bodySprite,birth=birthSprite,cancel=cancelSprite or bodySprite,birthScale=5 if typ==12 else 3,deathFrames=14 if typ==12 else 16,add='ins_67(1)'in active)
 nativeRows.append(dict(type=typ,color=col,script=sid,body=bodySprite,birth=birthSprite,cancel=cancelSprite,width=width,table_address=hex(base)))
 save('source/bullet-script'+str(sid)+'.txt',body)
assetlines.append('TH11S6BulletArt='+lua(anims));assetlines.append('TH11S6Art={}')
for key,a in anims.items():
 typ,col=map(int,key.split(':'));rect=spriteDefs['bullet'][a['body']]['rect'];assetlines.append(f'TH11S6Art[{typ}]=TH11S6Art[{typ}]or{{}};TH11S6Art[{typ}][{col}]={{w={rect[2]},h={rect[3]}}}')
save('assets.lua','\n'.join(assetlines)+'\n')
save('source/native-bullet-table.json',json.dumps({'exe':str(native['P']),'exe_sha256':sha(native['P']),'rows':nativeRows},indent=2))
sounds=[]
for p in W.glob('se_*.wav'):
 shutil.copy2(p,O/'se'/p.name);sounds.append(dict(file=p.name,sha256=sha(p)))
save('sound-assets.lua','\n'.join('LoadSound('+lua('th11s6.'+p['file'][3:-4])+','+lua('se/'+p['file'])+')'for p in sounds)+'\n')
# musiccmt.txt explicitly identifies th11_14.wav as the sixth-stage theme.
comment=(W/'musiccmt.txt').read_text(encoding='cp932')
section=comment.split('@bgm/th11_14.wav',1)[1].split('@bgm/',1)[0]
assert '業火マントル' in section and '最終面' in section
save('source/music-comment.txt',section)
fmt=(W/'thbgm.fmt').read_bytes();row=next(fmt[i:i+52]for i in range(0,len(fmt)-51,52)if fmt[i:i+16].split(b'\0')[0]==b'th11_14.wav')
off,total,start,end=struct.unpack_from('<4I',row,16);encoding,ch,rate,byteRate,align,bits=struct.unpack_from('<HHIIHH',row,32)
assert encoding==1 and bits==16 and 0<start<end
music=native['P'].parent/'thbgm.dat'
with music.open('rb')as f:f.seek(off);pcm=f.read(end)
assert len(pcm)==end
with wave.open(str(O/'music/hellfire-mantle.wav'),'wb')as f:f.setnchannels(ch);f.setsampwidth(bits//8);f.setframerate(rate);f.writeframes(pcm)
save('music.lua',f"LoadMusic('th11s6.road','music/hellfire-mantle.wav',{end/byteRate:.15g},{(end-start)/byteRate:.15g})\n")
shutil.copy2(W/'thbgm.fmt',O/'source/thbgm.fmt')
save('source/music-reference.json',json.dumps(dict(source=str(music),track='th11_14.wav',offset=off,loopStart=start,loopEnd=end,byteRate=byteRate,output_sha256=sha(O/'music/hellfire-mantle.wav')),indent=2))
data=json.loads((W/'background.json').read_text(encoding='utf-8'));data['scripts']={}
for sid,b in scripts['bg'].items():
 first=b.split('+',1)[0];rot=re.search(r'ins_49\((.*?)\)',first);rgb=re.search(r'ins_52\((.*?)\)',first);alpha=re.search(r'ins_51\((\d+)\)',first)
 data['scripts'][sid]=dict(sprite=int(re.search(r'ins_3\(sprite(\d+)\)',b)[1]),rot=[float(s.strip().rstrip('f'))for s in rot[1].split(',')]if rot else [0,0,0],rgb=[int(s)for s in rgb[1].split(',')]if rgb else [255]*3,alpha=int(alpha[1])if alpha else 255)
data['sprites']={sid:f'th11s6.bg.{sid}'for sid in spriteDefs['bg']}
save('background-assets.lua','TH11S6BackgroundData='+lua(data)+'\n');shutil.copy2(W/'stage06.std',O/'source/stage06.std')
# Historical TH10-stage6 evidence retained; current scene selection is applied
# by build-extra-background.py below. Never overwrite its renderer here.
bg=(BASE/'background-assets.lua').read_text(encoding='utf-8').replace('TH10S6','TH11S6')
for p in (BASE/'art').glob('bg-*.png'):shutil.copy2(p,O/'art'/p.name)
for p in (BASE/'art').glob('bullet-*.png'):shutil.copy2(p,O/'art'/('mof-'+p.name))
defs=(BASE/'assets.lua').read_text(encoding='utf-8')
leaf=re.search(r'LoadImage\("s6.bullet.330","([^"]+)",([^\n]+)\)',defs)
tex=leaf[1];texpath=re.search(r'LoadTexture\("'+re.escape(tex)+r'","([^"]+)"\)',defs)[1]
bg+='\nLoadTexture("th11s6.mofleaf",'+lua('art/mof-'+Path(texpath).name)+')\n'
bg+='LoadImage("th11s6.mofleaf","th11s6.mofleaf",'+leaf[2]+')\n'
bg+='TH11S6BackgroundData.leaf="th11s6.mofleaf"\n'
save('background-assets.lua',bg)
for n in ['stage06.std','stage06.std.txt','stage06.anm.txt','background-reference.json']:
 shutil.copy2(BASE/'source'/n,O/'source'/('mof-'+n))
bgcode=(BASE/'background.lua').read_text(encoding='utf-8').replace('TH10S6','TH11S6')
# Hold the completed lake view through this longer road; the original adapter
# intentionally stopped at the boss-loop command. No new camera path is added.
bgcode=bgcode.replace("elseif op==1 then error('Road background should end before the boss loop')","elseif op==1 then s.pc=#D.program+1")
bgcode=bgcode.replace('TH11S6Sprites.bullet[330]','D.leaf')
save('source/background-selection.json',json.dumps({'user_request':'Use existing TH10 Stage6 road background','source':str(BASE/'background.lua'),'source_sha256':sha(BASE/'background.lua'),'assets_sha256':sha(BASE/'background-assets.lua'),'adaptation':'independent namespace/leaf texture; hold completed lake camera after source boss-loop boundary'},indent=2))
save('source/native-evidence.json',json.dumps({'exe':str(native['P']),'exe_sha256':sha(native['P']),'sound53':{'config_address':'0x4a34f0+53*8','wav_index':43,'pointer_table':'0x4a36b0','file':'se_cat01.wav'},'conditional_spawn':'0x412eb1 tests enemy-manager boss slot +0x1c','ellipse_dispatch':'0x414455','ellipse_position':'0x459670','ellipse_args':['phase','angular_speed','radius','radius_delta','axis_rotation','perpendicular_scale'],'separate_relative_motion':'0x411610 adds absolute0x68 and relative0x9c'},indent=2))
save('reference.json',json.dumps(dict(source=str(SRC),source_sha256=sha(SRC),difficulty='Normal',functions=sorted(selected),commands=sorted(commands),art=refs,sounds=sounds,animations=anims,unused_original_background_quads=data['instance_quad_count'],rendered_background='TH10Stage6Normal existing background; source/background-selection.json'),ensure_ascii=False,indent=2)+'\n')
print('Generated',len(selected),'functions;',len(refs),'atlases;',len(sounds),'sounds; original BGM; native bullet table',nativeRows)
runpy.run_path(str(R/'scripts/th11-stage6/build-extra-background.py'))
runpy.run_path(str(R/'scripts/th11-stage6/build-boss04.py'))
runpy.run_path(str(R/'scripts/th11-stage6/build-milk03.py'))
