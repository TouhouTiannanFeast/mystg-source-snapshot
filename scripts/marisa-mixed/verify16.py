from pathlib import Path
import hashlib,json
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed')
def read(p):return p.read_text(encoding='utf-8-sig')
meta=json.loads(read(M/'source/road16-bgm.json'))
for path,key in [(meta['target'],'sha256'),(meta['playback'],'playback_sha256')]:assert hashlib.sha256((M/path).read_bytes()).hexdigest()==meta[key]
assert hashlib.sha256(Path(meta['source']).read_bytes()).hexdigest()==meta['sha256']
assert 'stardust={sub=41,time=65,hp=16000,inv=690' in read(M/'th08/boss.lua')
for road in [True,False]:
 lua=LuaRuntime(unpack_returned_tuples=True)
 for name in ['audio14.lua','stage14.lua','th08/boss.lua']:lua.execute('assert(loadstring(...))',read(M/name))
 lua.execute('''setting={marisa_road=...};ext={pausemenu={PauseSound=function()end,ResumeSound=function()end}}
 music={};plays={};function LoadMusic(n,path,a,b)assert(a>0 and a==b);music[n]='stopped'end
 function PlayMusic(n)assert(music[n]);music[n]='playing';plays[n]=(plays[n]or 0)+1 end
 function StopMusic(n)music[n]='stopped'end;function GetMusicState(n)return music[n]end
 function PauseMusic(n)assert(music[n]=='playing');music[n]='paused'end
 function ResumeMusic(n)assert(music[n]=='paused');music[n]='playing'end
 function EnumRes()local keys={};for n in pairs(music)do keys[#keys+1]=n end;return keys,{}end''',road)
 lua.execute(read(M/'audio14.lua'))
 lua.execute('''local A=MarisaMusic14
 A.startRoad();A.startRoad()
 if setting.marisa_road then
  assert(GetMusicState(A.roadName)=='playing' and plays[A.roadName]==1)
  ext.pausemenu:PauseSound();assert(GetMusicState(A.roadName)=='paused');ext.pausemenu:ResumeSound();assert(GetMusicState(A.roadName)=='playing')
  A.stopRoad();assert(GetMusicState(A.roadName)=='stopped');A.startRoad()
 else assert(A.roadName==nil)end
 A.start();A.start();assert(GetMusicState(A.name)=='playing' and plays[A.name]==1)
 if A.roadName then assert(GetMusicState(A.roadName)=='stopped' and not A.roadActive)end
 ext.pausemenu:PauseSound();assert(GetMusicState(A.name)=='paused');ext.pausemenu:ResumeSound();assert(GetMusicState(A.name)=='playing')
 A.stop();A.stopRoad();assert(GetMusicState(A.name)=='stopped')''')
s=read(M/'stage14.lua');assert 'function C.run()\n MarisaMusic14.startRoad()' in s and 'function C.cleanup()MarisaMusic14.stopRoad()' in s
print('PASS Stardust16000HP/65s readback; source/copy OGG hashes; syntax; fullstage/boss-only audio lifecycle, idempotent play, pause/resume, road cleanup, boss switch')
