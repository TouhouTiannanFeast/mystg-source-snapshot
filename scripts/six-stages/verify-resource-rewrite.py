from pathlib import Path
import sys,json,hashlib,struct,re
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign'
def read(p):return p.read_text(encoding='utf-8-sig')
for p in M.glob('*.lua'):LuaRuntime().execute('assert(loadstring(...))',read(p))
fixture=read(R/'scripts/six-stages/verify-revision.py').split("l.execute((M/'adapters.lua')")[0]
ns={};exec(fixture,ns);l=ns['l']
l.execute('''function Render()renders=(renders or 0)+1 end
function RenderScore()scores=(scores or 0)+1 end
GROUP_GHOST=0;player={x=0,y=-160,death=0,dx=0,dy=0};function Dist()return 100 end
function Angle()return -90 end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end
''')
l.execute(read(M/'adapters.lua'))
l.execute('''
SixStageCampaign.install(1,{})
local function spawn(c)local o=setmetatable({class=c,timer=0},{__index=c});c.init(o,0,0);return o end
local lives,bombs=lstg.var.lifeleft,lstg.var.bomb
for _,c in ipairs({item_chip,item_bombchip})do
 local o=spawn(c);assert(o.deleted and o.hide and not o.colli)
 for i=1,10 do c.collect(o)end
end
assert(lstg.var.lifeleft==lives and lstg.var.bomb==bombs and lstg.var.chip==0 and lstg.var.bombchip==0)
for _,c in ipairs({item_extend,item_bomb})do
 local o=spawn(c);o.timer=59;o.dy=0;c.frame(o);assert(o.attract==0)
 o.timer=60;c.frame(o);assert(o.attract==8 and o.target==player)
end
local o=spawn(item_point);o.attract=0;local s=lstg.var.score
item_point.collect(o);assert(lstg.var.score==s+10000)
lstg.var.graze=999999;lstg.var.faith=999999;assert(item.PointRateFunc(lstg.var)==10000)
lstg.var.power=1;GetPower(-200);assert(lstg.var.power==400)
SetViewMode('ui');renders=0;scores=0;textCount=0
Render('hint.power');Render('hint.point');Render('hint.Cnumber');Render('lifechip1');assert(renders==0)
RenderScore('score2',10000,600,239);assert(scores==0)
RenderText('score3','0/5',600,361,.35);RenderText('score1','4.0/4.0',600,262,.4);assert(textCount==0)
Render('hint.life');RenderScore('score3',123,600,414);assert(renders==1 and scores==1)
print('PASS actual item classes: no fragments/conversion; resources attract at60, not59; fixed points/firepower; HUD rows removed')
''')
# Real reward hook, including timeout reset between kill and payout.
q=LuaRuntime();q.execute('''
SixStageCampaign={index=1,install=function()end};setting={};lstg={world={l=-192,r=192,t=224}}
item_extend='life';item_bomb='bomb';drops={}
function New(c,x,y)table.insert(drops,{c,x,y})end;function AfterFrame()end
boss={system={kill=function(s)s.boss.timeout=nil end}}
th14={label='none'};Stage2Route={phase='none'};Y3Road={active=false}
Y3={specs={spell3={name='survival'}}};Stage2Mamizou={Boss={},state={phase=0}}
MarisaMixed={phase='none'};MarisaRabbit14={Boss={},state={phase='none'}}
Zuu4Stage={current='none'};NinaState={current='none'};MarisaRoad14={state={phase='none'}}
''');q.execute(read(M/'road-bonus.lua'))
q.execute('''
local C,B=SixStageCampaign,SixStageCampaignRoadBonus
function reward(i,p,timeout,survival)
 C.index=i;drops={};local b={hp=0,timeout=timeout,time_sc=survival,is_combat=true,current_card={name='x'}}
 if i==1 then b.th14_phase=p=='boss'and'scale'or'non1'
 elseif i==2 then b.class=Stage2Mamizou.Boss;Stage2Mamizou.state.phase=p=='spell1'and 2 or p=='boss'and 5 or 1
 elseif i==3 then b.current_card.name=p=='boss'and'survival'or'other'
 elseif i==4 then
  if p=='rabbit'then b.class=MarisaRabbit14.Boss;MarisaRabbit14.state.phase='spell'
  else MarisaMixed.boss=b;MarisaMixed.phase=p end
 elseif i==5 then Zuu4Stage.boss=b;Zuu4Stage.current=p
 elseif i==6 then NinaState.current=p end
 local s={boss=b};boss.system.kill(s);assert(b.timeout==nil)
 boss.system.endChipBonus(s,0,120);local count=#drops
 boss.system.endChipBonus(s,0,120);assert(#drops==count,'duplicate card reward')
 local life,bomb=0,0;for _,d in ipairs(drops)do if d[1]=='life'then life=life+1 else bomb=bomb+1 end end
 return life,bomb
end
for _,c in ipairs({{1,'boss',false,false,1,0},{1,'boss',true,false,1,0},
 {2,'spell1',true,false,0,1},{2,'boss',false,false,1,1},{2,'boss',true,false,0,0},
 {3,'boss',true,true,1,2},{4,'rabbit',false,false,1,0},{4,'rabbit',true,false,0,0},
 {4,'non3',true,false,1,0},{4,'final',true,false,1,0},
 {5,'final',false,false,0,3},{5,'final',true,false,0,0},
 {6,'non3',true,false,1,0},{6,'final',true,false,1,0},{6,'kanako',false,false,0,0},
 {1,'other',false,false,0,0},{2,'other',false,false,0,0}})do
 local life,bomb=reward(c[1],c[2],c[3],c[4]);assert(life==c[5]and bomb==c[6],c[1]..' '..c[2])
end
for i,expected in ipairs({2,2,3,3,0,0})do
 C.index=i;C.install(i,{});setting={y3_entry='full',marisa_road=true}
 th14.label='Wakasagihime';Stage2Route.phase='Mamizou';MarisaRoad14.state.phase='entry'
 drops={};if i==3 then Y3Road.active=true;AfterFrame();Y3Road.active=false end
 AfterFrame();assert(#drops==expected,'road reward '..i);AfterFrame();assert(#drops==expected)
end
print('PASS requested reward matrix: all phase/end/defeat/timeout conditions and dedup; roads1/1,1/1,1/2,0/3,none,none')
''')
# Original anchor frame, with the requested presentation adapter.
a=LuaRuntime();a.execute('''
setting={};SixStageCampaign={install=function()end};object={};bullet={init=function()end,skip_fade_in=function()end};classes={}
function Class(base)local c={base=base};setmetatable(c,{__index=base});return c end
function LoadTexture()end;function LoadImage()end;function LoadSound()end
function Stage12FireSound(n)table.insert(sounds,n)end
sounds={};function PlaySound(n)table.insert(sounds,n)end
function New()return{}end;function SetViewMode()end;function SetImageState()end
draws={};function Render(...)table.insert(draws,{...})end;function Color(...)return{}end
function Del(o)o.deleted=true end;function IsValid(o)return o~=nil end
function AfterFrame()end
function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end
function Angle()return 0 end;GROUP_ENEMY=2;GROUP_GHOST=0;LAYER_ENEMY_BULLET=100;LAYER_TOP=200
misc={ShakeScreen=function(t,s)shake={t,s}end}
th14={owned={},track=function()end,rand=function(a,b)return(a+b)/2 end}
player={collect_line=96};lstg={world={l=-192,r=192}}
boss={card={New=function(name,t1,t2,t3,hp)return{hp=hp}end}}
''')
a.globals().AnchorPattern=a.execute(read(G/'mod/Stage12Normal/stage1/anchor-pattern.lua'))
a.execute('function dofile()return AnchorPattern end')
anchor=read(G/'mod/Stage12Normal/stage1/anchor.lua');a.execute(anchor)
a.execute(read(M/'opening-anchor.lua'))
a.execute('''
SixStageCampaign.install(1,{})
assert(Stage1Anchor.card().hp==1080,'stage1 terminal HP was not doubled')
local A=Stage1Anchor;A.state.tick=10;A.state.stats={anchors=0,impacts=0,launch_ticks={}}
local o={};A.Anchor.init(o,{x=0,y=100},-90);assert(sounds[1]=='six.anchor.launch')
o.x=AnchorPattern.edges.r+20;o.y=0;A.Anchor.frame(o)
assert(o.state=='hold'and shake[1]==60 and shake[2]==2 and sounds[2]=='six.anchor.impact')
o.state='return';o.return_x,o.return_y=o.owner.x,o.owner.y;A.Anchor.frame(o)
assert(o.state=='finish'and sounds[3]=='six.anchor.launch')
local line={timer=68};SixStageCollectLine.render(line)
assert(draws[2][3]==player.collect_line and draws[3][3]==player.collect_line)
print('PASS actual anchor impact/return state machine: source sounds56/57 and shake60x2; original POC sprites at actual collect line')
''')
print('PASS campaign Lua51 syntax')
log=R/'work/logs/six-stages/resources-20261111';log.mkdir(parents=True,exist_ok=True)
source={'anchor_ecl':'mod/Stage12Normal/source/anchor/stage04.named.utf8.txt:26-27,70,787',
 'th12_exe':'G:/TouHou/[th12] 东方星莲船 (汉化版+日文版)/th12.exe',
 'sound_records':{'56':{'address':'0x4aea00','wav_index':46,'file':'se_boon00.wav','ds_volume':-500},
                  '57':{'address':'0x4aea14','wav_index':47,'file':'se_don00.wav','ds_volume':0}},
 'sound_pointer_table':'0x4aea50', 'poc':'TH10 front.anm scripts77..79, sprites48/50; original60..198f flash/fade, placed at live player.collect_line',
 'assets':{str(p.relative_to(M)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [M/'art/th10-front.png',*(M/'se/th12').glob('*.wav')]}}
(log/'source.json').write_text(json.dumps(source,ensure_ascii=False,indent=2),encoding='utf8')

