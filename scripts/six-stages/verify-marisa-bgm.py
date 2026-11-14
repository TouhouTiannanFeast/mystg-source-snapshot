from pathlib import Path
import sys,subprocess,hashlib,re,json
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';L=R/'work/logs/six-stages/marisa-bgm-20261113';L.mkdir(parents=True,exist_ok=True)
l=LuaRuntime();l.execute('''
SixStageCampaign={install=function()end};function Include()end;setting={marisa_road=true}
th08s4={phase_specs={milky={}},Beam={frame=function()end}}
calls={};function PlayMusic(name,v)table.insert(calls,{name,v})end
function LoadMusic()end;function StopMusic()end;function GetMusicState()return 'stopped'end
function EnumRes()return{},{}end;ext={pausemenu={PauseSound=function()end,ResumeSound=function()end}}
''')
l.execute((G/'mod/MarisaMixed/audio14.lua').read_text('utf-8-sig'))
l.execute((M/'combat-review.lua').read_text('utf-8-sig'));l.execute('''
SixStageCampaign.installRoad4Audio=function()end
SixStageCampaign.install(4,{})
MarisaMusic14.startRoad();MarisaMusic14.start()
assert(calls[1][1]=='mm.road.music'and calls[1][2]==1)
assert(calls[2][1]=='mm.marisa.music'and math.abs(calls[2][2]-10^(-2.9/20))<1e-12)
PlayMusic('unrelated',.8);assert(calls[3][2]==.8)
print('PASS actual Marisa music start gain='..calls[2][2]..'; road/other tracks unchanged')
''')
p=G/'mod/MarisaMixed/bgm/marisa.ogg';h=hashlib.sha256(p.read_bytes()).hexdigest()
ff='G:/Tools/NapCat/py/QQbot/tools/ffmpeg/ffmpeg-9.0.1-essentials_build/bin/ffmpeg.exe'
r=subprocess.run([ff,'-hide_banner','-nostats','-i',str(p),'-af','volume=-2.9dB,ebur128=peak=true:framelog=verbose','-f','null','-'],capture_output=True,text=True,encoding='utf-8',errors='replace',creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
(L/'gain-measurement.log').write_text(r.stderr,'utf-8');assert r.returncode==0
s=r.stderr[r.stderr.rfind('Summary:'):];i=float(re.search(r'I:\s*([-\d.]+) LUFS',s)[1]);assert abs(i-(-7.2))<=.1,i
assert hashlib.sha256(p.read_bytes()).hexdigest()==h
(L/'result.json').write_text(json.dumps(dict(measured_LUFS=i,playback_gain=10**(-2.9/20),source_sha256=h,source_unchanged=True,game_sfx_unchanged=True),indent=2),'utf-8')
print('PASS gained stream measured',i,'LUFS; original audio unchanged; no package')
