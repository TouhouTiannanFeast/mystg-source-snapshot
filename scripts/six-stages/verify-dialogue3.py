from pathlib import Path
import sys,json,hashlib,os
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');MOD=R/'aex-0.8.22/game/mod/SixStageCampaign';D=MOD/'dialogue3'
os.chdir(MOD.parent.parent)
def read(p):return p.read_text(encoding='utf-8-sig')
dataLua=read(D/'data.lua');data=LuaRuntime().execute(dataLua)
text=json.loads(read(D/'text.json'));source=json.loads(read(D/'source.json'))
assert len(text['pre'])==17 and len(text['post'])==15
assert all('talk_06_'in a['entry']for a in source['assets']if a['file'].startswith('art/shion'))
for a in source['assets']:assert hashlib.sha256((D/a['file']).read_bytes()).hexdigest()==a['sha256']
for which in ['pre','post']:
 pages=list(data[which].values())
 for i,(_,_,line)in enumerate(text[which],1):
  actual=''.join(row for p in pages if p['line']==i for row in p['rows'].values())
  assert actual==line,(which,i)
  for p in pages:
   if p['line']==i:
    assert len(p['rows'])<=2
    for row in p['rows'].values():assert sum(.5 if ord(c)<128 else 1 for c in row)<=20
print('PASS exact17+15 user lines, bounded2-line pagination, Shion group06 only, original PNG/font byte hashes')
for p in [MOD/'campaign.lua',MOD/'root.lua',MOD/'dialogue3.lua',MOD/'probe-dialogue3.lua',D/'data.lua']:
 LuaRuntime().execute('assert(loadstring(...))',read(p))
fixture=read(R/'scripts/six-stages/verify.py').split("lua.execute((MOD/'campaign.lua')")[0]
ns={};exec(fixture,ns);l=ns['lua'];l.execute(read(MOD/'campaign.lua'))
l.globals().dialogueData=l.execute(dataLua)
l.execute('''
function dofile()return dialogueData end
function LoadTexture()end;function LoadImage()end;function SetImageCenter()end;function LoadTTF()end
function Class()return{}end
GROUP_GHOST=0;function ObjList()return ipairs({})end
task={Wait=function(n)for i=1,n do coroutine.yield()end end};function Del(o)o.deleted=true end
created=0;function New(class,...)created=created+1;local o={};class.init(o,...);return o end
player={x=0,y=-176,dialog=false};SixStageCampaign.install=function()end
''')
l.execute('''TestDamage={};function TestDamage.take_damage()end
TestBoss={base=TestDamage};function TestBoss.init(o)o.name='Saigyouji Yuyuko'end
''',name='@mod/YuyukoStage3/root.lua')
l.execute(read(MOD/'dialogue3.lua'))
l.execute('''
local C,D=SixStageCampaign,SixStageDialogue3
C.index=3;C.speed=8;stage.current_stage={stage_name=C.names[3],timer=100}
setting.y3_practice='all';C.install(3,{TestBoss})
keys[KEY.Z]=true
local co=coroutine.create(function()made=New(TestBoss)end)
assert(coroutine.resume(co));assert(D.active and D.which=='pre'and created==0)
local n=frames
for i=1,50 do FrameFunc()end
assert(frames==n+50 and D.page==1 and D.age==50,'held shooting skipped dialogue or live simulation stopped')
local dc=calls;DoFrame();assert(calls==dc+1,'dialogue accelerated simulation')
keys[KEY.Z]=false;FrameFunc();keys[KEY.Z]=true;FrameFunc();assert(D.page==2)
for i=1,25 do FrameFunc()end;assert(D.page==2,'held confirm repeated')
keys[17]=true
while D.active do FrameFunc()end
keys={};assert(D.preDone and player.dialog)
assert(coroutine.resume(co));assert(player.dialog and created==0,'attack gate ended before90f')
for i=1,90 do assert(player.dialog);assert(coroutine.resume(co))end
assert(created==1 and made.name=='死宛'and D.spawned and not player.dialog)
stage.group.FinishStage();assert(D.active and D.which=='post'and not C.clearWait)
keys[17]=true;while D.active do FrameFunc()end;keys={}
stage.group.FinishStage();assert(C.clearWait==240 and D.postDone and not stage.next_stage)
print('PASS source-coroutine pre gate, held-Z protection/fresh confirmation, CTRL skip,live1x dialogue with8x combat, restored player input, post before240f pickup window')
C.cancelDialogue();setting.y3_practice='spell3'
assert(loadstring("function TestBoss.init(o)o.name='Saigyouji Yuyuko'end",'@mod/YuyukoStage3/root.lua'))()
C.install(3,{TestBoss});New(TestBoss)
assert(not D.active and D.enabled and not D.preEnabled,'mid-card practice replayed pre-story')
assert(C.beforeFinish() and D.which=='post','terminal completion omitted practice post-story')
D.cancel()
D.show('pre');C.go(4);assert(not D.active and not player.dialog,'stage selector left a frozen dialogue')
print('PASS mid-card practice skips pre-story and retains terminal post-story; manual stage cancellation restores input')
setting.y3_practice='all';C.index=3;C.leaving=false;C.clearWait=nil;stage.next_stage=nil
assert(loadstring("TestBoss2={base=TestDamage};function TestBoss2.init(o)o.name='Saigyouji Yuyuko'end",'@mod/YuyukoStage3/root.lua'))()
C.install(3,{TestBoss2});D.enabled=false;made=New(TestBoss2);D.enabled=true
stage.group.initTask=function(s,f)s.work=coroutine.create(f)end
local source={init=function(s)stage.group.initTask(s,function()sourceWaitComplete=true end)end}
C.wrapSource(3,source);local s={};source.init(s)
assert(coroutine.resume(s.work));assert(sourceWaitComplete and D.active and D.which=='post'and not D.resumeFinish)
D.page=#D.pages;D.exit=0;for i=1,12 do FrameFunc()end
assert(D.postDone and not C.clearWait,'natural post skipped source cleanup/wait')
assert(coroutine.resume(s.work));assert(coroutine.status(s.work)=='dead')
stage.group.FinishStage();assert(C.clearWait==240)
print('PASS post-story after source cleanup/wait but before automatic clear fade;240f pickup resumes afterward')
''')
print('PASS Lua51 syntax')
