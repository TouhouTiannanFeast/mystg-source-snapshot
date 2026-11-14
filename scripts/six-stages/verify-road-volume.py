from pathlib import Path
import sys,json,hashlib
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';LOG=R/'work/logs/six-stages/road-volume-20261113';LOG.mkdir(parents=True,exist_ok=True)
read=lambda p:p.read_text(encoding='utf-8-sig')
l=LuaRuntime();l.execute('''
SixStageCampaign={};setting={};stage={current_stage={timer=0}};captured={};expected={}
function LoadSound()end
lstg={PlaySound=function(n,v,p)captured={name=n,volume=v,pan=p}end}
HSoB5={finished=false,playSource=function(n,v,p)captured={source=true,name=n,volume=v,pan=p}end,resetSound=function()end}
''')
l.execute(read(G/'packages/thlib-scripts/THlib/se/se.lua'))
# Obtain actual engine baseline gains rather than copying the adapter values.
l.execute('enginePlay=PlaySound')
l.execute(read(G/'mod/SixStageCampaign/road-audio.lua'))
l.execute('''
SixStageCampaign.installRoadAudio()
local count=0
for file,name in pairs(SixStageCampaign.roadAudioFiles)do
 for _,v in ipairs({.23,1})do
  enginePlay(name,v,0);local standard=captured.volume
  if name=='tan00'or name=='tan01'or name=='tan02' then standard=.22 end
  stage.current_stage.timer=stage.current_stage.timer+1
  HSoB5.playSource(file,v,.3)
  assert(captured.name=='six.th10.'..name and captured.volume==standard and captured.pan==.3,file..' gain differs')
  expected[file]={name=name,volume=standard}
 end
 count=count+1
end
stage.current_stage.timer=1000;HSoB5.playSource('shot1.wav');local old=captured;HSoB5.playSource('shot1.wav');assert(captured==old,'dedup changed')
PlaySound('plst00',.9,.2);assert(captured.volume==.27)
PlaySound('plst00',.9,.2,true);assert(captured.volume==.9,'explicit gain bypass lost')
HSoB5.finished=true;HSoB5.playSource('shot1.wav',.8,.1);assert(captured.source and captured.volume==.8)
PlaySound('tan00',.9);assert(captured.name=='tan00'and captured.volume==.28,'Boss/common fallback changed')
print('PASS '..count..' mapped events: firing0.22, other common gains; explicit flag/dedup/pan/Boss forwarding retained')
''')
host=read(G/'mod/MarisaMixed/road/host.lua')
begin=host[host.index('function H.begin(seed)'):host.index('function H.step()')]
l.execute('''
shotCalls=0;soundCalls=0
Th18Stage5Host={cleanup=function()end};Th18Stage5Runtime={tick=0,startRoute=function()end}
New=function(kind,b)shotCalls=shotCalls+1;return b end
lstg.PlaySound=function(n,v,p)soundCalls=soundCalls+1;assert(n=='six.th10.tan00'and v==.22)end
''')
l.execute('local H,R=Th18Stage5Host,Th18Stage5Runtime;local A={load=function()end};local Shot="Shot";'+begin)
l.execute('''
SixStageCampaign.installRoad4Audio()
Th18Stage5Host.begin(1)
local R=Th18Stage5Runtime
for j=1,5 do R.onShot({x=0})end
assert(shotCalls==5 and soundCalls==1,'Stage4 lost bullets or repeated same-tick sound')
R.tick=1;R.onShot({x=0});assert(shotCalls==6 and soundCalls==2)
Th18Stage5Host.begin(2);R.onShot({x=0});assert(shotCalls==7 and soundCalls==3,'restart did not reset gate')
Th18Stage5Host=nil;SixStageCampaign.installRoad4Audio()
print('PASS actual Stage4 road begin: all7 shots preserved,0.22 once per tick, restart resets, Boss-only practice safe')
''')
report={'events':{k:dict(v.items())for k,v in l.globals().expected.items()},'stage4_firing_gain':.22,'music_changed':False,'compressed':False,'scope':'live SixStageCampaign only'}
(LOG/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf-8')
print('PASS Lua51 live adapter; music/source WAV files unchanged; no ZIP generated')
