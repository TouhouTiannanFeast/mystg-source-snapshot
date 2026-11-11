from pathlib import Path
import sys,json,hashlib,os
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';os.chdir(G)
read=lambda p:p.read_text(encoding='utf-8-sig')
l=LuaRuntime();d=l.execute(read(M/'dialogue2/data.lua'));t=json.loads(read(M/'dialogue2/text.json'));s=json.loads(read(M/'dialogue2/source.json'))
assert {k:len(v)for k,v in t.items()}=={'s2hinapre':12,'s2mystiapre':7,'s2mamizoupre':14,'s2mamizoupost':10}
for key,rows in t.items():
 pages=list(d.scenes[key].values())
 for n,(_,_,text)in enumerate(rows,1):assert ''.join(line for p in pages if p.line==n for line in p.rows.values())==text
 for p in pages:
  assert len(p.rows)<=2
  for line in p.rows.values():assert sum(.5 if ord(c)<128 else 1 for c in line)<=20
for name,a in s['assets'].items():assert hashlib.sha256((M/'dialogue2/art'/name).read_bytes()).hexdigest()==a['sha256']
for file in ['dialogue2.lua','root.lua']:l.execute('assert(loadstring(...))',read(M/file))
l.execute('''
SixStageCampaign={install=function()end};SixStageDialogue3={data={art={},fallback={}}}
SixStageStory46={data={scenes={},names={}},active=false};function LoadTexture()end;function LoadImage()end;function SetImageCenter()end
function IsValid(o)return o~=nil end;function Kill(o)o.ended=true end
player={dialog=false};MOVE_DECEL=4
boss={move={New=function(x,y,t,m)return{is_combat=false,x=x,y=y,t=t,m=m}end},init=function(o,x,y,name,cards)o.cards=cards end}
task={Wait=function(n)for i=1,n do coroutine.yield()end end,New=function(o,f)o.work=coroutine.create(f)end}
local function cls()
 return{init=function(o,start)boss.init(o,0,288,'actor',{{is_combat=false,t=60},{is_combat=true,id=start or 1}},nil)end}
end
Stage2Mystia={Boss=cls()};Stage2Mamizou={Boss=cls()};Stage2Flare={Boss=cls()}
tailTicks=0;Stage12Tail={run=function(b,s,a,wait,stats)for i=1,3 do wait(1)end end}
SixStageStory46.play=function(key)
 SixStageStory46.active=true;player.dialog=true;task.Wait(5)
 SixStageStory46.active=false;player.dialog=false
end
''')
l.execute(read(M/'dialogue2.lua'))
code=l.globals().SixStageCampaign.sourceText('mod/Stage12Normal/stage2-run.lua');l.execute('assert(loadstring(...))',code)
assert 'SixStageDialogue2.hina()' not in code
assert code.index("SixStageStory46.play('s2mamizoupost')")<code.index("phase('Complete')")
l.execute('''
SixStageCampaign.install(2,{})
local A=SixStageDialogue2
local p={};Stage2Flare.Boss.init(p);assert(#p.cards==3 and p.cards[1].t==60 and not p.cards[2].is_combat and p.cards[3].is_combat,'Patchouli story must follow visible Boss entry')
local b={};Stage2Mystia.Boss.init(b);assert(#b.cards==3 and b.cards[1].t==60 and b.cards[3].is_combat)
b.cards[2].init(b);assert(A.holdMystia)
local tail=coroutine.create(function()Stage12Tail.run(b,nil,nil,function()tailTicks=tailTicks+1;task.Wait(1)end,{})end)
assert(coroutine.resume(tail));assert(tailTicks==0)
assert(coroutine.resume(b.work));assert(player.dialog)
for i=1,94 do assert(coroutine.resume(b.work));assert(coroutine.resume(tail));assert(tailTicks==0 and A.holdMystia and player.dialog)end
assert(coroutine.resume(b.work));assert(b.ended and not A.holdMystia and not player.dialog)
while coroutine.status(tail)~='dead'do assert(coroutine.resume(tail))end
assert(tailTicks==3,'tail scheduler skipped or duplicated steps')
local m={};Stage2Mamizou.Boss.init(m,1);assert(#m.cards==3)
local later={};Stage2Mamizou.Boss.init(later,3);assert(#later.cards==2 and later.cards[2].id==3)
print('PASS original60f entries retained; Mystia tail paused during dialogue+90f then resumes exact steps; later Mamizou practice skips pre-story')
''')
print('PASS exact43 user lines/four scenes, pagination/glyph assets/original PNG hashes, Lua51 and Stage2 source adapter')
