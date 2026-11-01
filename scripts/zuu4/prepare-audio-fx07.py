"""Read local HSoB archives; install encounter-local copies with provenance."""
from pathlib import Path
import sys,re,json,hashlib,subprocess,wave,shutil,struct
sys.path.insert(0,'G:/TouHou/MLforDanmu/tools')
from danmakufu_archive import Archive
C=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/zuu4')
W=Path('G:/MySTG/work/zuu4/audio-fx07');W.mkdir(parents=True,exist_ok=True)
S=Path('G:/TouHou/MLforDanmu/data/local/danmakufu/20261018-added/hsob/readable/script/th_hsob')
origin=next(Path('G:/TouHou/th_hsob_112').glob('*/dnh/script/th_hsob'))
ff='G:/Tools/NapCat/py/QQbot/tools/ffmpeg/ffmpeg-9.0.1-essentials_build/bin/ffmpeg.exe'
manifest=[]
def save(data,dest,source,virtual):
 dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
 manifest.append(dict(source=str(source),virtual=virtual,output=str(dest.relative_to(C)),sha256=hashlib.sha256(data).hexdigest()))
se=Archive(origin/'se/se.dat')
names=re.findall(r'seDIR\s*~\s*"([^"]+)"',(S/'system/ControlSound.dnh.utf8.txt').read_text('utf-8-sig'))
required={names[i] for i in (0,1,2,3,4,5,6,11,12,13,14,15,17,18,19,20,21,22,24,26,27)}
for e in se.entries:
 if e['name'] in required:
  data=se.read(e);raw=W/e['name'];raw.write_bytes(data);dest=C/'audio/se'/e['name']
  dest.parent.mkdir(parents=True,exist_ok=True)
  subprocess.run([ff,'-v','error','-nostdin','-y','-i',str(raw),'-c:a','pcm_s16le',str(dest)],check=True)
  manifest.append(dict(source=str(se.path),virtual=e['name'],source_sha256=hashlib.sha256(data).hexdigest(),output=str(dest.relative_to(C)),sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),conversion='PCM s16le; original sample rate/channels'))
music=Archive(origin/'music/music.dat');e=next(e for e in music.entries if e['name']=='hsob_6boss.ogg')
data=music.read(e);raw=W/'hsob_6boss.ogg';raw.write_bytes(data);out=C/'audio/hsob_6boss.wav'
subprocess.run([ff,'-v','error','-nostdin','-y','-i',str(raw),'-ar','48000','-ac','2','-c:a','pcm_s16le',str(out)],check=True)
with wave.open(str(out))as w: assert w.getnframes()>=12570074 and w.getframerate()==48000
manifest.append(dict(source=str(music.path),virtual=e['name'],source_sha256=hashlib.sha256(data).hexdigest(),output=str(out.relative_to(C)),sha256=hashlib.sha256(out.read_bytes()).hexdigest(),loop_start=1082253,loop_end=12570074,sample_rate=48000))
img=Archive(origin/'img/img.dat')
images=['effect/'+n+'.png' for n in ('power_effect','particle','expcloud','explode2','explode3','circle','bulleteffect')]
images+=['world/stg6img/BG06b_'+n+'.png' for n in 'abcd']
images+=['world/stg6img/BG06a'+n+'_lite.png' for n in ('0','1','2')]
images+=['character/Horou/horou1.png','system/BulletBreak.png','white.png']
for name in images:
 e=next(e for e in img.entries if e['name']==name);save(img.read(e),C/'art/fx'/Path(name).name,img.path,name)
native=Path('G:/TouHou/MLforDanmu/data/local/touhou/th20-20261027');blob=(native/'native-original/th20.exe').read_bytes()
pe=struct.unpack_from('<I',blob,60)[0];opt=pe+24;ib=struct.unpack_from('<I',blob,opt+28)[0];ns=struct.unpack_from('<H',blob,pe+6)[0];sz=struct.unpack_from('<H',blob,pe+20)[0]
sections=[struct.unpack_from('<4I',blob,opt+sz+i*40+8)for i in range(ns)]
def offset(va):
 for vs,v,rs,r in sections:
  if ib+v<=va<ib+v+rs:return r+va-ib-v
 raise ValueError(hex(va))
soundrows={}
for i in (5,6,27,54):
 addr=struct.unpack_from('<I',blob,offset(0x5aedf0+i*4))[0];k=offset(addr);name=blob[k:blob.index(0,k)].decode('ascii');soundrows[i]=name
 src=native/'auxiliary-raw'/name;dest=C/'audio'/('th20-'+name)
 subprocess.run([ff,'-v','error','-nostdin','-y','-i',str(src),'-c:a','pcm_s16le',str(dest)],check=True)
 manifest.append(dict(source=str(src),virtual='native sound table VA5aedf0 +4*'+str(i),source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),output=str(dest.relative_to(C)),sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),conversion='PCM s16le; original sample rate/channels'))
(C/'th20-sounds.lua').write_text('Zuu4R.th20Sounds={'+','.join('[%d]=%s'%(i,json.dumps(n))for i,n in soundrows.items())+'}\n',encoding='utf-8')
subprocess.run(['G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci/thanm.exe','-x','20',str(native/'associated-raw/effect.anm'),'effect/eff_maple.png'],cwd=W,check=True,capture_output=True)
save((W/'effect/eff_maple.png').read_bytes(),C/'art/fx/th20-maple.png',native/'associated-raw/effect.anm','effect/eff_maple.png sprite30')
for n in ('effect.anm.numeric.txt','effect.anm.named.utf8.txt'):
 p=native/'associated-animation'/n;save(p.read_bytes(),C/'source/audio-fx07'/n,p,'')
delays=[]
ref=json.loads((C/'source-reference.json').read_text('utf-8-sig'))
for a in ref['shots']:
 fields=a['source']['authored_fields'];r=fields.get('delay_rect')
 if r:
  rect=[float(v.strip())for v in r.strip('()').split(',')]
  delays.append(' [%d]={rect={%s},texture=%s,add=%s},'%(a['id'],','.join(format(v,'g')for v in rect),json.dumps(a['texture']),str(fields.get('delay_render','ADD_ARGB')=='ADD_ARGB').lower()))
(C/'delay-art.lua').write_text('Zuu4DelayArt={\n'+'\n'.join(delays)+'\n}\n',encoding='utf-8')
for name in ('lib/lib_Sound','lib/lib_File','system/ControlSound','system/ControlItem','title/lib/MusicData','lib/effect/lib_Con','lib/effect/lib_EffectLib','lib/bosslib/lib_SpellEffect','lib/bosslib/lib_Character','stg/stage6/boss/06b_Background','stg/stage6/lib_World06_BackGround01a'):
 p=S/(name+'.dnh.utf8.txt');save(p.read_bytes(),C/'source/audio-fx07'/p.name,p,'')
(C/'audio-fx07-reference.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('Installed',len(required),'PCM source sounds, original looped boss theme,',len(images),'original FX images; provenance saved.')
