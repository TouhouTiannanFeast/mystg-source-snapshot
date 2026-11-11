from pathlib import Path
import sys,json,hashlib,os
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';os.chdir(G)
read=lambda p:p.read_text(encoding='utf-8-sig')
data=LuaRuntime().execute(read(M/'dialogue46/data.lua'));text=json.loads(read(M/'dialogue46/text.json'));src=json.loads(read(M/'dialogue46/source.json'))
assert sum(map(len,text.values()))==91 and len(text)==11
assert text['s6kanako'][2][0]=='kanako'
assert data.voiceOnly.s6battle
assert data.scenes.s4pre[3].portrait=='marisano'
assert 'face_pl01no.png' in data.art.marisano.layers[2].file
assert data.art.fakesanaeno.layers[1].file=='art/watari-nina-bs.png'
assert data.art.fakesanaeno.layers[2].file=='art/watari-nina-no.png'
assert (data.art.fakesanaeno.layers[2].x,data.art.fakesanaeno.layers[2].y,data.art.fakesanaeno.layers[2].cw,data.art.fakesanaeno.layers[2].ch)==(310,83,304,213)
assert '/st07enm/face/enemy7/' in src['assets']['watari-nina-bs.png']['source'].replace('\\','/')

assert 'face05' in data.art.sanaedp.layers[2].file
for key,a in data.art.items():
 if key.startswith('suwako'):
  assert len(a.layers)==1 and a.layers[1].file=='art/frog-user.png'
  assert (a.layers[1].x,a.layers[1].y,a.layers[1].cw,a.layers[1].ch)==(260,122,446,960)
for a in data.art.values():
 for v in a.layers.values():
  assert (v.x or 0)+(v.cw or v.w)<=v.w and (v.y or 0)+(v.ch or v.h)<=v.h
assert hashlib.sha256((M/'dialogue46/art/frog-user.png').read_bytes()).hexdigest()==hashlib.sha256(Path('C:/Users/Renko/AppData/Local/Temp/codex-clipboard-c12c3dda-0eb1-42e3-aee8-36d6cc00ee17.png').read_bytes()).hexdigest()

for key,a in data.art.items():
 if key.startswith(('ringo','rabbit')):
  h=a.layers[2];assert h.x==26 and h.y==0 and h.cw==262 and h.ch==186
 if key.startswith('seiran'):
  h=a.layers[2];assert h.x==180 and h.y==112 and h.cw==222 and h.ch==212
for name,a in src['assets'].items():assert hashlib.sha256((M/'dialogue46/art'/name).read_bytes()).hexdigest()==a['sha256']
for key,rows in text.items():
 pages=list(data.scenes[key].values())
 for n,(_,_,t)in enumerate(rows,1):assert ''.join(line for p in pages if p.line==n for line in p.rows.values())==t
 for p in pages:
  assert len(p.rows)<=2
  for line in p.rows.values():assert sum(.5 if ord(c)<128 else 1 for c in line)<=20
for f in ['dialogue3.lua','dialogue46.lua','root.lua']:
 LuaRuntime().execute('assert(loadstring(...))',read(M/f))
l=LuaRuntime();l.execute('''SixStageCampaign={install=function()end};SixStageDialogue3={data={art={},fallback={}}};function LoadTexture()end;function LoadImage()end;function SetImageCenter()end''')
l.execute(read(M/'dialogue46.lua'))
for path in ['mod/MarisaMixed/stage14.lua','mod/MarisaMixed/root.lua','mod/NinaStage6Normal/road17/load.lua','mod/NinaStage6Normal/intro12.lua','mod/NinaStage6Normal/root.lua']:
 code=l.globals().SixStageCampaign.sourceText(path);l.execute('assert(loadstring(...))',code)
print('PASS exact91 lines/11 scenes, confirmed Kanako speaker, pagination, original PNG hashes, Lua51 and all5 patched source chunks')

l.execute("""
SixStageDialogue3.active=false
local n=0;SixStageStory46.randomLaugh=function()n=n+1 end
SixStageStory46.play('s6battle');SixStageStory46.play('s6battle')
assert(n==1 and not SixStageDialogue3.active and not SixStageStory46.active)
print('PASS voice-only battle laugh once without a dialogue overlay; target portraits/crops/source bytes')
""")
l.execute("""
setting={};stage={current_stage={timer=0}};MOVE_ACCEL=1;MOVE_DECEL=2
TH11S6Milk={Boss={init=function()end},card={del=function()end}}
local count=0
TH11S6Runtime={step=function()count=count+1 end}
TH11S6Voice={step=function()end};NinaRoad17={}
SixStageCampaign.install(6,{})
TH11S6Runtime.step();assert(count==1)
TH11S6Milk.card.del({});TH11S6Runtime.step();assert(count==1,'road advanced between midboss defeat and story')
task={MoveTo=function()assert(SixStageStory46.holdRoad)end}
SixStageStory46.play=function(key)assert(key=='s6midpost' and SixStageStory46.holdRoad)end
TH11S6Milk.card.after({});TH11S6Runtime.step();assert(count==2 and not SixStageStory46.holdRoad)
print('PASS midboss defeat holds road through departure/post-story, then resumes')
""")
