from pathlib import Path
import sys,os,hashlib,json,wave
sys.path.insert(0,'G:/MySTG/work/six-stages-tools');from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';O=R/'work/logs/six-stages/momiji-audio-20261113';os.chdir(G)
l=LuaRuntime();l.execute('''
SixStageCampaign={};function LoadSound()end
''');l.execute((M/'momiji-audio.lua').read_text('utf-8-sig'))
code=l.globals().SixStageCampaign.sourceText('mod/Stage12Normal/stage1/momiji.lua')
original=(G/'mod/Stage12Normal/stage1/momiji.lua').read_text('utf-8-sig')
cue="                    PlaySound('six.momiji.medium',1,math.max(-1,math.min(1,o.x/224)),true)\n"
intro="PlaySound('six.momiji.entrance',1,0,true);"
assert code.count(cue)==1 and code.count(intro)==1 and code.replace(cue,'').replace(intro,'')==original
l.execute('''
function Include()end;function LoadTexture()end;function LoadImage()end
bullet={};laser_bent={};laser_bent_renderFunc={};laser_bent_renderFuncDeath={};laser_bent.size=1
function Class(base)local c={};return setmetatable(c,{__index=base})end
boss={card={New=function(...)theCard={};return theCard end},init=function()end}
COLOR_BLUE=1;COLOR_RED=2;COLOR_DEEP_RED=3;COLOR_GRAY=4
function cos(a)return math.cos(a*math.pi/180)end;function sin(a)return math.sin(a*math.pi/180)end
function Angle(a,b)return math.atan2(b.y-a.y,b.x-a.x)*180/math.pi end
ran={Float=function(self,a,b)return(a+b)/2 end};player={x=0,y=-160}
setting={};th14={clean_bullets=function()end,clean_actors=function()end,stats={phases=0},stage_frames=0}
task={New=function(o,f)o.work=coroutine.create(f)end,Wait=function()coroutine.yield()end}
shots={};sounds={};entrances=0
function Stage12BossEntrance(cards,...)return cards end
function New(c,...)local a={...};shots[#shots+1]={kind=a[4],tick=Stage1Momiji.state.tick};return{}end
function PlaySound(n,v,p,f)if n=='six.momiji.medium'then sounds[#sounds+1]={tick=Stage1Momiji.state.tick,volume=v};assert(v==1 and f==true)elseif n=='six.momiji.entrance'then entrances=entrances+1;assert(v==1 and f==true)end end
''')
l.execute((G/'mod/Stage12Normal/stage1/momiji-pattern.lua').read_text('utf-8-sig'))
l.execute((G/'mod/Stage12Normal/stage1/momiji-config.lua').read_text('utf-8-sig'))
l.execute(code)
l.execute('''
local b={x=0,y=72,hp=900};theCard.init(b)
assert(entrances==0,'entrance played during card init')
while coroutine.status(b.work)~='dead'do local ok,e=coroutine.resume(b.work);assert(ok,e)end
local expected={};for t=0,MomijiPattern.duration-1 do for _,e in ipairs(MomijiPattern.events(t))do if e.kind=='scale'then expected[#expected+1]=t end end end
assert(#sounds==#expected)
for i,t in ipairs(expected)do assert(sounds[i].tick==t)end
assert(sounds[1].tick==60 and sounds[2].tick==90 and sounds[3].tick==120)
local medium=0;for _,s in ipairs(shots)do if s.kind=='scale'then medium=medium+1 end end
assert(medium==#expected*48)
print('PASS actual Momiji card task: '..#sounds..'wave cues; first60/90/120; all48-medium waves retain quantity; no rice/laser cue')
Stage1Momiji.Boss.init({});assert(entrances==1,'Boss appearance did not play exactly once')
print('PASS actual Boss init entrance sound once; separate from all medium waves')
''')
with wave.open(str(M/'se/momiji-medium.wav'),'rb')as w:assert(w.getnchannels(),w.getframerate(),w.getnframes(),w.getsampwidth())==(2,48000,144000,2)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(O/'source.json').write_text(json.dumps({'source':'C:/Users/Renko/Downloads/未命名 1.wav','source_sha256':sha(Path('C:/Users/Renko/Downloads/未命名 1.wav')),'runtime_asset':'mod/SixStageCampaign/se/momiji-medium.wav','runtime_sha256':sha(M/'se/momiji-medium.wav'),'format':'sourcePCMfloat32->PCM16;48000Hz/stereo/3s retained, no normalization/resampling','trigger':'each48-medium volley, everywave1/2/3; original time/other audio retained','volume':1,'calls_full35s':len(l.globals().sounds)},ensure_ascii=False,indent=2),'utf-8')
print('PASS Lua51 source delta and engine-compatible PCM16 clip; original input retained; no package')
