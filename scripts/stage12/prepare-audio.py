from pathlib import Path
import struct,wave,json,hashlib
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal';rows=[]
for game,track,out,key,source in [(14,'th14_02.wav','mist-lake.wav','s1.route',Path('G:/TouHou/th14东方辉针城汉化版+1.00b日文版/thbgm.dat')),(14,'th14_03.wav','mermaid.wav','s1.boss',Path('G:/TouHou/th14东方辉针城汉化版+1.00b日文版/thbgm.dat')),(10,'th10_04.wav','dark-side.wav','s2.boss',Path('G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/thbgm.dat'))]:
 fmt=m/('source/audio/thbgm.fmt' if game==14 else 'source/thbgm.fmt');b=fmt.read_bytes();row=next(b[i:i+52] for i in range(0,len(b),52) if b[i:i+16].split(b'\0')[0].decode()==track)
 off,total,start,end=struct.unpack_from('<4I',row,16);encoding,ch,rate,byte_rate,align,bits=struct.unpack_from('<HHIIHH',row,32);assert encoding==1 and bits==16 and align==4
 with source.open('rb') as f:f.seek(off);pcm=f.read(end)
 assert len(pcm)==end and 0<start<end
 target=m/'music'/out
 with wave.open(str(target),'wb') as w:w.setnchannels(ch);w.setsampwidth(bits//8);w.setframerate(rate);w.writeframes(pcm)
 rows.append(dict(key=key,source=str(source),track=track,offset=off,loop_start_bytes=start,pcm_bytes=end,loop_end=end/byte_rate,loop_length=(end-start)/byte_rate,output='music/'+out,output_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),fmt_sha256=hashlib.sha256(b).hexdigest()))
old=json.loads((m/'source/music-reference.json').read_text(encoding='utf-8'));old['key']='s2.route';rows.append(old)
(m/'source/audio/tracks.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
lua='Stage12Music={names={}}\nlocal M=Stage12Music\n'
for row in rows:
 lua+=f"M.names['{row['key']}']='stage12.{row['key']}'\nLoadMusic(M.names['{row['key']}'],'{row['output']}',{row['loop_end']:.15g},{row['loop_length']:.15g})\n"
lua+='''function M.stop()
 for _,name in pairs(M.names) do StopMusic(name) end
end
function M.play(key)
 M.stop();PlayMusic(assert(M.names[key]),1)
 print('STAGE12 MUSIC '..key)
end
local pause,resume=ext.pausemenu.PauseSound,ext.pausemenu.ResumeSound
function ext.pausemenu:PauseSound()
 pause(self);self.stage12Paused={}
 for _,name in pairs(M.names) do
  if GetMusicState(name)=='playing' then self.stage12Paused[#self.stage12Paused+1]=name;PauseMusic(name) end
 end
end
function ext.pausemenu:ResumeSound()
 resume(self)
 for _,name in ipairs(self.stage12Paused or {}) do if GetMusicState(name)=='paused' then ResumeMusic(name) end end
 self.stage12Paused={}
end
'''
(m/'music.lua').write_text(lua,encoding='utf-8')
p=m/'root.lua';s=p.read_text(encoding='utf-8').replace("Include('THlib.lua')","Include('THlib.lua')\nInclude('music.lua')",1);p.write_text(s,encoding='utf-8')
p=m/'stage2-run.lua';s=p.read_text(encoding='utf-8');a=s.index("local musicName=");b=s.index('local R=Stage2Route',a);s=s[:a]+s[b:];s=s.replace('StopMusic(musicName)','Stage12Music.stop()').replace('PlayMusic(musicName,1)',"Stage12Music.play('s2.route')").replace("R.clean();phase('Mamizou');Stage2Mamizou.reset()","R.clean();phase('Mamizou');Stage2Mamizou.reset();Stage12Music.play('s2.boss')");p.write_text(s,encoding='utf-8')
p=m/'stage1/stage.lua';s=p.read_text(encoding='utf-8').replace('if setting.th14_practice then',"if setting.th14_practice then\n            Stage12Music.play('s1.boss')").replace('task.Wait(60); front(s)',"Stage12Music.play('s1.route');task.Wait(60); front(s)").replace('local b=New(T.Wakasagi,false) ',"local b=New(T.Wakasagi,false) ")
s=s.replace('local b=New(T.Wakasagi,false)\n',"Stage12Music.play('s1.boss')\n            local b=New(T.Wakasagi,false)\n").replace("function() T.clean();Stage1Momiji.clean();Stage1Context.clean() end)","function() T.clean();Stage1Momiji.clean();Stage1Context.clean();Stage12Music.stop() end)");p.write_text(s,encoding='utf-8')
p=r/'scripts/stage12/verify.py';s=p.read_text(encoding='utf-8').replace("  route.execute((m/'stage1/stage.lua')","  route.execute(\"Stage12Music={play=function()end,stop=function()end}\")\n  route.execute((m/'stage1/stage.lua')");p.write_text(s,encoding='utf-8')
print('Extracted3 tracks, integrated4 BGM states')
