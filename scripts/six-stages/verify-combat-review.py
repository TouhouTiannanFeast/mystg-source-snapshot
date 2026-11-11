from pathlib import Path
import sys, hashlib, json, re
sys.path.insert(0, 'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG'); GAME=ROOT/'aex-0.8.22/game'; MOD=GAME/'mod/SixStageCampaign'
LOG=ROOT/'work/logs/six-stages/combat-20261111'; LOG.mkdir(parents=True,exist_ok=True)
def read(p): return p.read_text(encoding='utf-8-sig')
for p in [MOD/'campaign.lua',MOD/'combat-review.lua',MOD/'road-audio.lua',MOD/'root.lua']:
    LuaRuntime().execute('assert(loadstring(...))',read(p))
# Use the existing controller fixtures, with the real updated controller.
fixture=read(ROOT/'scripts/six-stages/verify.py').split("lua.execute((MOD/'campaign.lua')")[0]
ns={};exec(fixture,ns);controller=ns['lua'];controller.execute(read(MOD/'campaign.lua'))
controller.execute('''
local C=SixStageCampaign
for i=1,6 do
 C.index=i;C.leaving=false;C.clearWait=nil;stage.next_stage=nil;C.reward=nil
 stage.current_stage.timer=100
 stage.group.FinishStage();assert(C.clearWait==240 and not stage.next_stage)
 stage.group.FinishStage();assert(C.clearWait==240)
 C.updateClearWindow();assert(C.clearWait==240)
 for f=1,239 do stage.current_stage.timer=100+f;C.updateClearWindow();assert(not stage.next_stage)end
 stage.current_stage.timer=340
 C.updateClearWindow()
 if i==2 then assert(C.reward and not stage.next_stage)
 else assert(stage.next_stage)end
end
print('PASS all six clear routes: extra240 live ticks, duplicate finish does not reset; card notice preserved')
C.clearWait=120;C.prepareMenu();assert(not C.clearWait,'menu inherited a pending stage finish')
''')
l=LuaRuntime()
l.execute('''
setting={marisa_phase='stardust',marisa_ssg_mode='full'}
SixStageCampaign={install=function()end};function Include()end
GROUP_ENEMY_BULLET=1;GROUP_INDES=2;LAYER_ENEMY_BULLET=100
function LoadSound()end;function PlaySound()end;function SetViewMode()end
function IsValid(o)return o and not o.removed end
function Del(o)o.removed=true end;function Kill(o)o.removed=true end
function Dist(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
owned={};function ObjList()return ipairs(owned)end
bullet_deleter={frame=function(o)o.original=true end}
boss={card={New=function(name,t1,t2,t3,hp)return{name=name,hp=hp,t3=t3*60}end},
 move={New=function()return{name='move'}end},take_damage=function()end,
 frame=function()end,init=function(o,x,y,name,cards)o.cards=cards;o.x=x;o.y=y end}
classes={};function Class(base)
 local c={base=base};setmetatable(c,{__index=base});classes[#classes+1]=c;return c
end
task={New=function()end}; MOVE_DECEL=1
th08s4={phase_specs={milky={hp=2300}},clear=function()end,Beam={frame=function(o)o.checked=true end},
 card=function(id)return{name=id,hp=id=='milky'and th08s4.phase_specs.milky.hp or({stardust=16000,non1=15700,non3=15500,master=2000})[id],init=function()end}end}
SSG={};SSGSelected05={frames=function()return 3780 end,accept=function()return true end}
SSGInspect04={};MarisaVisual={clear=function()end}
MarisaDS={clean=function()end,card=function()return{name='comet',hp=10000,init=function()end}end}
DSExtraPool={specs={[8]={}}}
''')
source=read(GAME/'mod/MarisaMixed/root.lua')
l.execute(source.split('function Boss:render()')[0],name='@mod/MarisaMixed/root.lua')
l.execute(read(MOD/'combat-review.lua'))
l.execute('''
SixStageCampaign.install(4,classes)
local b={};classes[#classes].init(b)
assert(#b.cards==7 and b.cards[1].name=='move'and b.cards[2].name=='stardust'and b.cards[7].name=='master')
assert(b.cards[7].hp==2500 and setting.marisa_phase=='stardust')
assert(b.cards[4].name=='milky'and b.cards[4].hp==12000)
local beam={spark=true};th08s4.Beam.frame(beam);assert(beam.layer==99 and beam.checked)
local other={};th08s4.Beam.frame(other);assert(other.layer==nil)
print('PASS actual private Marisa init: stardust->non1->milky->non3->comet->final suffix; terminal2500 and Spark under bullets')
Zuu4R={id='final',shot=function(x,y,s,a,id)return{id=id}end,projectileStep=function()end,
 erase=function(b)b.dead=true end};Zuu4Stage={current='final'}
SixStageCampaign.installRoadAudio=function()end
SixStageCampaign.install(5,{})
local tail=Zuu4R.shot(0,0,1,0,636);tail.life=60;tail.fadeStart=30;Zuu4R.projectileStep(tail);assert(tail.life==30 and tail.fadeStart==nil)
local note=Zuu4R.shot(0,0,1,0,356);Zuu4R.projectileStep(note);assert(not note.life)
owned={}
for _,id in ipairs({548,356,36,636,353})do owned[#owned+1]={data={id=id},x=0,y=0,colli=true}end
local d={timer=30,x=0,y=0};bullet_deleter.frame(d)
assert(owned[1].removed and owned[1].data.dead and not owned[1].colli)
for i=2,#owned do assert(not owned[i].removed and not owned[i].data.dead)end
Zuu4R.id='non1';bullet_deleter.frame(d);assert(d.original)
print('PASS respawn clear: only feather548; notes/penalty/tail survive; ordinary cards retain native clearer')
''')
# Original boss result functions: true survival timeout captures; normal timeout fails.
system=read(GAME/'packages/thlib-scripts/THlib/enemy/boss_system.lua')
def function(text,name):
    a=text.index('function '+name);return text[a:text.index('\nend',a)+4]
r=LuaRuntime();r.execute('''system={};time_rate=60;lstg={var={score=0}};sounds={};fx={}
function PlaySound(n)table.insert(sounds,n)end
function New(kind,...)table.insert(fx,{kind,...})end
hinter_bonus='bonus';hinter='hint';kill_timer='timer';kill_timer2='real'
''')
for name in ['system:popSpellResult()','system:resultSpell(info)']:
    r.execute(function(system,name))
r.execute('''
function test(survival,clean)
 sounds={};fx={}
 local b={hp=0,timeout=true,time_sc=survival,chip_bonus=clean,bombchip_bonus=clean,sc_bonus=clean and 1000 or nil,
 timer=2100,is_sc=true,__getspellbonus=true,__card_timer=2100,spell_damage=0}
 local s=setmetatable({boss=b,clock={GetElapsed=function()return 35 end},finishSpellHist=function()end},{__index=system})
 if not survival then b.chip_bonus=false;b.bombchip_bonus=false;b.sc_bonus=nil end
 s:popSpellResult();return b,sounds,fx
end
local b,s,f=test(true,true);assert(b._getcard and s[1]=='cardget'and f[1][1]=='bonus')
b,s,f=test(false,true);assert(not b._getcard and s[1]=='fault'and f[1][2]=='hint.bonusfail')
b,s,f=test(true,false);assert(not b._getcard and #s==0 and f[1][2]=='hint.bonusfail')
print('PASS actual boss result: NMNB survival timeout success/cardget/bonus; ordinary timeout fault/bonusfail; failed survival no success')
''')
# Every original road event has an official bank mapping; no fallback to HSoB.
a=LuaRuntime();a.execute('''SixStageCampaign={};setting={};stage={current_stage={timer=1}};events={};original={}
function LoadSound()end
function PlaySound(n)table.insert(original,n)end
lstg={PlaySound=function(n,v,p)table.insert(events,{n,v,p})end}
HSoB5={env={},finished=false,playSource=function(n)table.insert(original,n)end,resetSound=function()end}
''');a.execute(read(GAME/'mod/HSoBStage5Normal/sound-data.lua'));a.execute(read(MOD/'road-audio.lua'))
a.execute('''SixStageCampaign.installRoadAudio()
for _,file in pairs(HSoB5.soundFiles)do assert(SixStageCampaign.roadAudioFiles[file]);HSoB5.playSource(file)end
assert(#original==0)
local n=#events;HSoB5.playSource('shot2.wav');assert(#events==n)
HSoB5.finished=true;HSoB5.playSource('shot2.wav');assert(original[1]=='shot2.wav')
print('PASS all45 HSoB road source events map to TH10; same-event dedup and source boss audio retained')
''')
bank={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (MOD/'se/th10').glob('*.wav')}
assert len(bank)==28
for _,name in a.globals().SixStageCampaign.roadAudioFiles.items():assert 'se_'+name+'.wav' in bank
provenance={'archive':'G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/th10.dat',
 'method':'thdat12 -x10, original WAV bytes; event correspondence chosen for the port, not original HSoB audio',
 'sha256':bank,'mapping':dict(a.globals().SixStageCampaign.roadAudioFiles.items())}
(MOD/'se/th10/source.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2),encoding='utf8')
print('PASS syntax and all28 original TH10 WAV resources exist; provenance/hashes recorded')
