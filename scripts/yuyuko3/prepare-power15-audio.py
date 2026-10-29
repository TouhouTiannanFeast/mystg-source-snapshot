from pathlib import Path
import subprocess,json,wave,hashlib
m=Path('aex-0.8.22/game/mod/YuyukoStage3/music');p=m/'manifest.json';rows=json.loads(p.read_text('utf-8'));road=next(r for r in rows if r['key']=='road')
out=m/'road-louder.wav'
subprocess.run(['G:/Tools/NapCat/py/QQbot/tools/ffmpeg/ffmpeg-9.0.1-essentials_build/bin/ffmpeg.exe','-hide_banner','-loglevel','error','-nostdin','-y','-i',road['source'],'-vn','-af','volume=2,alimiter=limit=0.98:level=false:latency=true','-ar','44100','-ac','2','-c:a','pcm_s16le',str(out)],check=True)
with wave.open(str(out)) as w:duration=w.getnframes()/w.getframerate()
assert abs(duration-road['duration'])<1e-9
out.replace(m/'road.wav');road['gain_db']=6.0206;road['limiter_peak']=0.98;road['sha256']=hashlib.sha256((m/'road.wav').read_bytes()).hexdigest();p.write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS road +6.02dB with limiter, unchanged duration; boss file untouched')
