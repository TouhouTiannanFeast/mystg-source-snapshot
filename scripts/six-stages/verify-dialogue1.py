from pathlib import Path
import sys,json,hashlib,os
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';os.chdir(G)
read=lambda p:p.read_text(encoding='utf-8-sig')
l=LuaRuntime();d=l.execute(read(M/'dialogue1/data.lua'));t=json.loads(read(M/'dialogue1/text.json'));s=json.loads(read(M/'dialogue1/source.json'))
assert {k:len(v)for k,v in t.items()}=={'s1open':3,'s1momijipre':2,'s1momijipost':1,'s1wakapre':10,'s1wakapost':6}
assert t['s1wakapre'][8][0]=='kaguya' and d.scenes.s1wakapre[9].portrait=='kaguya21'
for key in ['s1open','s1momijipre','s1momijipost']:assert all(p.speaker=='kaguya'for p in d.scenes[key].values())
assert all(key.startswith('wakasa')for key in d.art.keys())
for key,rows in t.items():
 pages=list(d.scenes[key].values())
 for n,(_,_,text)in enumerate(rows,1):assert ''.join(line for p in pages if p.line==n for line in p.rows.values())==text
 for p in pages:
  assert len(p.rows)<=2
  for line in p.rows.values():assert sum(.5 if ord(c)<128 else 1 for c in line)<=20
for name,a in s['assets'].items():assert hashlib.sha256((M/'dialogue1/art'/name).read_bytes()).hexdigest()==a['sha256']
for a in d.art.values():assert (a.layers[2].x,a.layers[2].y,a.layers[2].cw,a.layers[2].ch)==(168,18,228,148)
l.execute('''
setting={};SixStageCollectLine={frame=function(o)o.called=true end}
clearCount=0;drawCount=0;function SetViewMode()end;function RenderClear()clearCount=clearCount+1 end;function Color()end
SixStageCampaign={install=function()end,drawDialogue=function()drawCount=drawCount+1 end};SixStageDialogue3={data={art={},fallback={}}}
SixStageStory46={data={scenes={},names={}},play=function(key)assert(key=='s1wakapre')end}
function LoadTexture()end;function LoadImage()end;function SetImageCenter()end
function IsValid(o)return o~=nil end;function Kill(o)o.ended=true end
player={dialog=false};MOVE_DECEL=4
boss={move={New=function(x,y,t,m)return{is_combat=false,x=x,y=y,t=t,m=m}end},init=function(o,x,y,name,cards)o.cards=cards end}
task={Wait=function(n)for i=1,n do coroutine.yield()end end,New=function(o,f)o.work=coroutine.create(f)end}
th14={Wakasagi={init=function(o,mid,practice)boss.init(o,0,288,'Wakasagi',{{x=0,y=96,t=60},{is_combat=true}},nil)end,frame=function(o)o.called=true end}}
''')
l.execute(read(M/'dialogue1.lua'))
code=l.globals().SixStageCampaign.sourceText('mod/Stage12Normal/stage1/stage.lua');l.execute('assert(loadstring(...))',code)
assert code.index("SixStageStory46.play('s1open')")<code.index('Stage12Background.start(1)')
assert code.index("SixStageStory46.play('s1momijipre')")<code.index('local mb=New(Stage1Momiji.Boss)')
assert code.index("SixStageStory46.play('s1momijipost')")<code.index("print('TH14 POST-MOMIJI WAVES START")
assert code.index("SixStageStory46.play('s1wakapost')")<code.index('T.finished=true;',code.index("SixStageStory46.play('s1wakapost')"))
l.execute('''
SixStageCampaign.install(1,{})
SixStageDialogue3.active=true;SixStageDialogue3.which='s1open'
local line={timer=7};SixStageCollectLine.frame(line);assert(line.timer==6 and not line.called)
SixStageCampaign.drawDialogue();assert(clearCount==1 and drawCount==1)
SixStageDialogue3.active=false;SixStageCollectLine.frame(line);assert(line.called)
SixStageCampaign.drawDialogue();assert(clearCount==1 and drawCount==2)
local b={} ;th14.Wakasagi.init(b,false,'non1');assert(#b.cards==3 and b.cards[1].t==60 and b.cards[3].is_combat)
b.cards[2].init(b);assert(coroutine.resume(b.work));assert(player.dialog)
for i=1,89 do assert(coroutine.resume(b.work));assert(player.dialog)end
assert(coroutine.resume(b.work));assert(b.ended and not player.dialog)
local later={};th14.Wakasagi.init(later,false,'context');assert(#later.cards==2)
b.th14_phase='scale';th14.Wakasagi.frame(b);assert(b.called and SixStageDialogue1.finalSeen)
print('PASS unchanged60f entry/90f gated wait, non1 pre versus later practice, terminal detection and original frame callback')
''')
print('PASS exact22 user lines/five scenes; pre-stage prologue/guide clock and corrected Kaguya threat, Momiji monologues Kaguya-only/no Momiji assets, original TH14 PNG hashes/crops, Lua51/source order')
