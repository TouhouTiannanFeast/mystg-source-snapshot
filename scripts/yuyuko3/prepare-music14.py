from pathlib import Path
import subprocess,wave,json,hashlib
m=Path('G:/MySTG/aex-0.8.22/game/mod/YuyukoStage3');a=m/'music';a.mkdir(exist_ok=True)
ff='G:/Tools/NapCat/py/QQbot/tools/ffmpeg/ffmpeg-9.0.1-essentials_build/bin/ffmpeg.exe'
if (m/'music.lua').exists():raise SystemExit('Music already prepared; do not replace current integration.')
rows=[]
for key,source in [('road','E:/Tencent/Tencent Files/それぞれの思惑と足跡 - トリック・ノスタルジー.mp3'),('boss','E:/Tencent/Tencent Files/幽雅に咲かせ、墨染の桜 ～ Border of Life - 黄昏フロンティア, 上海アリス幻樂団.mp3')]:
 out=a/(key+'.wav')
 subprocess.run([ff,'-hide_banner','-loglevel','error','-nostdin','-y','-i',source,'-vn','-ar','44100','-ac','2','-c:a','pcm_s16le',str(out)],check=True)
 with wave.open(str(out),'rb') as w:duration=w.getnframes()/w.getframerate();assert w.getnchannels()==2 and w.getsampwidth()==2
 rows.append(dict(key=key,source=source,source_sha256=hashlib.sha256(Path(source).read_bytes()).hexdigest(),output='music/'+out.name,duration=duration,sha256=hashlib.sha256(out.read_bytes()).hexdigest()))
 print(key,round(duration,3),'seconds')
(a/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
s='-- User-selected music, converted to PCM for the engine; whole-track loops.\nY3Music={names={road="y3.music.road",boss="y3.music.boss"}}\nlocal M=Y3Music\n'
for row in rows:s+=f"LoadMusic(M.names.{row['key']},'{row['output']}',{row['duration']:.15g},{row['duration']:.15g})\n"
s+='''function M.stop()
 for _,name in pairs(M.names)do StopMusic(name)end
 M.current=nil
end
function M.play(key)
 local name=assert(M.names[key],'Unknown Yuyuko music')
 if M.current==key and GetMusicState(name)=='playing' then return end
 local global,staged=EnumRes('bgm')
 for _,pool in ipairs({global,staged})do for _,n in pairs(pool)do StopMusic(n)end end
 PlayMusic(name,1);M.current=key
 print('Y3 MUSIC '..key)
end
'''
(m/'music.lua').write_text(s,encoding='utf-8')
p=m/'root.lua';s=p.read_text('utf-8-sig').replace("Include('THlib.lua')","Include('THlib.lua')\nInclude('music.lua')",1)
s=s.replace('  New(Y3Background.stage);',"  local entry=setting.y3_entry or 'full'\n  local roadEntry=setting.y3_full and(entry=='full' or entry:match('^road%-%d+$'))\n  Y3Music.play(roadEntry and 'road' or 'boss')\n  New(Y3Background.stage);")
s=s.replace('  local b=New(Yuyuko,',"  Y3Music.play('boss')\n  local b=New(Yuyuko,")
s=s.replace('clean();S.current=nil;S.finished=true;', 'clean();Y3Music.stop();S.current=nil;S.finished=true;')
s=s.replace("'del',function()if Y3Road", "'del',function()Y3Music.stop();if Y3Road")
p.write_text(s,encoding='utf-8')
