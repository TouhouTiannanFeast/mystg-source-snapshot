from pathlib import Path
import json,wave,hashlib,importlib
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal'
rows=json.loads((m/'source/audio/tracks.json').read_text(encoding='utf-8'))
for row in rows:
 p=m/row['output'];assert hashlib.sha256(p.read_bytes()).hexdigest()==row['output_sha256']
 with wave.open(str(p)) as w:
  assert w.getframerate()==44100 and w.getnchannels()==2 and w.getsampwidth()==2
  assert abs(w.getnframes()/44100-row['loop_end'])<1e-8
 assert 0<row['loop_length']<row['loop_end']
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.globals().Stage2FileExists=lambda p:(m/p).exists()
 lua.execute((r/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 lua.execute((m/'music.lua').read_text(encoding='utf-8'))
 lua.execute('''
 local M=Stage12Music;local menu=setmetatable({},{__index=ext.pausemenu})
 for _,key in ipairs({'s1.route','s1.boss','s2.route','s2.boss'}) do
  M.play(key)
  for k,name in pairs(M.names)do assert(GetMusicState(name)==(k==key and 'playing' or 'stopped'))end
  menu:PauseSound();assert(GetMusicState(M.names[key])=='paused')
  menu:ResumeSound();assert(GetMusicState(M.names[key])=='playing')
  menu:PauseSound();M.stop();menu:ResumeSound()
  for _,name in pairs(M.names)do assert(GetMusicState(name)=='stopped')end
 end
 ''')
 print(backend+': four switches, pause/resume/exit PASS')
print('4 PCM hashes/WAV formats/original loop ranges PASS')
