from pathlib import Path
import concurrent.futures,subprocess,re,json,hashlib,csv,math,time
R=Path('G:/MySTG');G=R/'aex-0.8.22/game/mod';O=R/'work/logs/six-stages/loudness-20261113';O.mkdir(parents=True,exist_ok=True)
FF=Path('G:/Tools/NapCat/py/QQbot/tools/ffmpeg/ffmpeg-9.0.1-essentials_build/bin/ffmpeg.exe')
rows=[]
def add(stage,kind,path,gain=1):rows.append(dict(stage=stage,kind=kind,path=str(G/path),gain=gain))
for n in [1,2]:
 for k in ['route','boss']:add(n,'road'if k=='route'else'boss',f'Stage12Normal/music/user-s{n}-{k}.wav')
for k in ['road','boss']:add(3,k,f'YuyukoStage3/music/{k}.wav')
add(4,'road','MarisaMixed/bgm/road.ogg');add(4,'boss','MarisaMixed/bgm/marisa.ogg')
add(5,'road','HSoBStage5Normal/art/hsob_5road.ogg');add(5,'boss','HSoBStage5Normal/stages/zuu4/audio/hsob_6boss.wav')
add(6,'road','NinaStage6Normal/road17/music/hellfire-mantle.wav');add(6,'boss','NinaStage6Normal/music06/th20-12-stone-goddess.wav')
for name,gain in [('tan00',.22),('tan01',.22),('tan02',.22),('lazer00',.35),('enep00',.35),('plst00',.27)]:add('common',name,f'SixStageCampaign/se/th10/se_{name}.wav',gain)
for name in ['shot1','shot2','shot3','shot4','shot5','Laser01','enemy_vanish_B','bulletbreak']:
 add(5,name,f'HSoBStage5Normal/stages/zuu4/audio/se/{name}.wav')
for name,gain in [('se_tan00.wav',10**(-2400/2000)),('se_ch02.wav',10**(-300/2000)),('se_enep02.wav',10**(-1400/2000))]:add('5stone',name,'SixStageCampaign/stone-audio/'+name,gain)
def measure(row):
 p=Path(row['path']);assert p.is_file(),p
 h=hashlib.sha256(p.read_bytes()).hexdigest();bgm=row['kind']in ['road','boss']
 filt='ebur128=peak=true:framelog=verbose'if bgm else'astats=metadata=0:reset=0'
 cmd=[str(FF),'-hide_banner','-nostats','-i',str(p),'-vn','-af',filt,'-f','null','-']
 r=subprocess.run(cmd,capture_output=True,text=True,encoding='utf-8',errors='replace',creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
 (O/f"{row['stage']}-{row['kind']}.log").write_text(r.stderr,'utf-8')
 assert r.returncode==0,r.stderr[-2000:]
 assert hashlib.sha256(p.read_bytes()).hexdigest()==h
 row.update(sha256=h)
 dur=re.search(r'Duration: (\d+):(\d+):([\d.]+)',r.stderr)
 if dur:row['duration_s']=int(dur[1])*3600+int(dur[2])*60+float(dur[3])
 if bgm:
  summary=r.stderr[r.stderr.rfind('Summary:'):]
  row['LUFS']=float(re.search(r'I:\s*([-\d.]+) LUFS',summary)[1]);row['LRA_LU']=float(re.search(r'LRA:\s*([-\d.]+) LU',summary)[1]);row['true_peak_dBTP']=float(re.search(r'Peak:\s*([-\d.]+) dBFS',summary)[1])
 else:
  summary=r.stderr[r.stderr.rfind('Overall'):]
  row['RMS_dBFS']=float(re.search(r'RMS level dB:\s*([-\d.]+)',summary)[1]);row['peak_dBFS']=float(re.search(r'Peak level dB:\s*([-\d.]+)',summary)[1])
  row['gain_dB']=20*math.log10(row['gain']);row['estimated_RMS_after_gain']=row['RMS_dBFS']+row['gain_dB']
 print(json.dumps(row,ensure_ascii=False),flush=True)
 return row
with concurrent.futures.ThreadPoolExecutor(max_workers=3)as pool:results=list(pool.map(measure,rows))
(O/'measurements.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),'utf-8')
keys=list(dict.fromkeys(k for row in results for k in row))
with (O/'measurements.csv').open('w',encoding='utf-8-sig',newline='')as f:
 w=csv.DictWriter(f,fieldnames=keys);w.writeheader();w.writerows(results)
text=['# 六面音频响度测量','', '游戏素材只读测量，未修改音量、音频或压缩包。音乐采用EBU R128整曲积分响度；LUFS数值越接近0越响。短音效采用RMS/峰值，不能将它的RMS直接当成音乐LUFS比较。','', '| 面数 | 道中 LUFS | Boss LUFS |','|---|---:|---:|']
for n in range(1,7):
 a=next(r for r in results if r['stage']==n and r['kind']=='road');b=next(r for r in results if r['stage']==n and r['kind']=='boss');text.append(f"|{n}|{a['LUFS']:.1f}|{b['LUFS']:.1f}|")
text+=['','完整源文件、哈希、动态范围、峰值与音效数据见 measurements.csv/json。','测量未包含自机/敌弹事件叠加、游戏混音、Windows音量与扬声器听感；短音效应用播放倍率后的RMS仅按线性增益估算。']
(O/'report.md').write_text('\n'.join(text)+'\n','utf-8')
