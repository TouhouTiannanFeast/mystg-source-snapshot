from pathlib import Path
import sys, wave
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG/aex-0.8.22/game')
M=ROOT/'mod/SixStageCampaign'
l=LuaRuntime()
l.execute(r'''
setting={};SixStageCampaign={};object={is_class=true,render=function()end}
function Class(base)
 local c={base=base,is_class=true}
 if base then for _,k in ipairs({'init','del','frame','render','colli','kill'})do c[k]=base[k]end end
 return c
end
lstg={var={score=0,faith=0,pointrate=10000,lifeleft=2,bomb=3,chip=0,bombchip=0,power=400},
 world={l=-192,r=192,b=-224,t=224,boundl=-224,boundr=224,boundb=-256,boundt=256}}
min,max,int,sqrt=math.min,math.max,math.floor,math.sqrt
function LoadTexture()end;function LoadImageGroup()end;function SetImageState()end
function SetV()end;function Color()return{}end;function New()return{}end
sounds={};function PlaySound(n,v,p)sounds[#sounds+1]={n,v,p}end
function StopSound(n)stopped=n end
function SetViewMode(m)lastView=m end
function RenderText(f,t)lastText=t;textCount=(textCount or 0)+1 end
GROUP_ITEM=6;LAYER_ITEM=-300;ran={Float=function(_,a,b)return(a+b)/2 end}
function BoxCheck()return true end
function RawDel(o)o.deleted=true end;function Del(o)o.deleted=true end
function SetAttr(o,k,v)o[k]=v end
function PreserveObject(o)o.preserved=true end
function IsValid(o)return o~=nil end
function Include()end
''')
l.execute((ROOT/'packages/thlib-scripts/THlib/item/item.lua').read_text(encoding='utf-8-sig'))
l.execute((M/'adapters.lua').read_text(encoding='utf8'))
l.execute(r'''
SixStageCampaign.install(1,{})
local function spawn(c)local o=setmetatable({class=c},{__index=c});c.init(o,0,0);return o end
for _,c in ipairs({item_point,item_faith,item_faith_minor,item_power,item_power_large,item_power_full})do
 local p=spawn(c);assert(p.img=='six.item.point');p.attract=8
 local score,faith=lstg.var.score,lstg.var.faith;c.collect(p)
 assert(lstg.var.score==score+10000 and lstg.var.faith==faith,'nonresource item is not a score point')
end
local life,bomb=lstg.var.lifeleft,lstg.var.bomb
for i=1,2 do item_chip.collect(spawn(item_chip));item_bombchip.collect(spawn(item_bombchip))end
assert(lstg.var.lifeleft==life and lstg.var.bomb==bomb and lstg.var.chip==2 and lstg.var.bombchip==2)
item_chip.collect(spawn(item_chip));item_bombchip.collect(spawn(item_bombchip))
assert(lstg.var.lifeleft==life+1 and lstg.var.bomb==bomb+1 and lstg.var.chip==0 and lstg.var.bombchip==0)
assert(spawn(item_extend).img=='six.item.life'and spawn(item_bomb).img=='six.item.bomb')
assert(spawn(item_chip).hscale==.75 and spawn(item_bombchip).hscale==.75)
for _,c in ipairs({item_chip,item_bombchip})do
 local p=spawn(c);p.timer=25;p.dy=0;c.frame(p);c.frame(p)
 assert(p.hscale==.75 and p.vscale==.75,'fragment scaling accumulated after entry')
end
SetViewMode('world');textCount=0;RenderText('menu','debug',0,-200,.22);assert(textCount==0)
RenderText('menu','boss title',0,120,.5);assert(textCount==1)
SetViewMode('ui');RenderText('score3','2/5',500,361,.35);assert(lastText=='2/3')
print('PASS actual native item classes: blue scorepoints, no faith gain, full icons, exact3chip thresholds, hidden lower helper text, HUD /3')
''')
le=ROOT/'mod/Le03Stage4Normal'
for f in ['constants.lua','movement.lua','runtime.lua','schedule.lua']:
    l.execute((le/f).read_text(encoding='utf-8-sig'))
l.execute(r'''
enemybase={};enemy=Class(object)
enemy.init=function(o,_,hp)o.hp=hp;o._colli=true end
enemy.take_damage=function(o,d)o.hp=o.hp-d end
enemy.kill=function(o)o.killed=true end
''')
host=(le/'host.lua').read_text(encoding='utf8')
start=host.index('local EnemyDamage=Class(enemy)')
end=host.index(chr(10)+'R.onEnemy=',start)
chunk=chr(10).join(['local R=Le03;local owned={};local function own(o)return o end',host[start:end],'CampaignTestEnemy=E'])
l.execute('assert(loadstring(...,"mod/Le03Stage4Normal/host.lua"))()',chunk)
l.execute(r'''
SixStageCampaign.install(3,{CampaignTestEnemy})
Le03.start(1);local count,central=0,0
for _,e in ipairs(Le03.enemies)do
 if e.appear==9500 then
  count=count+1;central=central+(e.survival and 1 or 0)
  assert(e.invincible==1);e.active=true;local hp=e.hp
  Le03.damageEnemy(e,1e9);assert(e.active and e.hp==hp)
  local o=setmetatable({class=CampaignTestEnemy},{__index=CampaignTestEnemy});CampaignTestEnemy.init(o,e)
  assert(o.protect);CampaignTestEnemy.base.take_damage(o,1e9);assert(o.hp==hp)
  CampaignTestEnemy.kill(o);assert(o.preserved and e.active and not o.killed)
  CampaignTestEnemy.frame(o);assert(o.protect and o.hp==hp)
 end
end
assert(count==3 and central==1,'survival change altered one-life reward ownership')
print('PASS actual Le03 final3: source/native damage, forcedKill, frame protection; central-only reward unchanged')
NinaSpecs={{id='kanako',hp=48800,frames=9000},{id='final',hp=123,frames=3600}}
SixStageCampaign.install(6,{})
assert(NinaSpecs[1].frames==5400 and NinaSpecs[1].hp==48800 and NinaSpecs[2].frames==3600)
print('PASS Kanako9000->5400frames; HP and other phase retained')
Th18Stage5Host={items={}};SSG={tick=0};SSGSelected05={step=function()
 SSG.tick=SSG.tick+1;if SSG.tick==10 then PlaySound('mm.selected12.charge',.4,0)end
end}
SixStageCampaign.install(4,{})
local score=lstg.var.score;Th18Stage5Host.onCollect({x=1,y=2});assert(lstg.var.score==score+10000)
sounds={};stopped=nil
for i=1,69 do SSGSelected05.step()end
assert(#sounds==1 and sounds[1][1]=='six.marisa.charge'and sounds[1][2]==1 and not stopped)
SSGSelected05.step();assert(stopped=='six.marisa.charge'and not SixStageCampaign.chargeStopTick)
print('PASS private TH18 pickup score hook; louder one-shot charge exact60f stop')
''')
with wave.open(str(M/'se/marisa-charge.wav'),'rb')as w:
    assert w.getnframes()/w.getframerate()==1
for n in ['campaign.lua','root.lua','adapters.lua']:
    l.execute('assert(loadstring(...))',(M/n).read_text(encoding='utf8'))
sheet=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/etama/data/etama/etama2.png')
assert (M/'art/th08-items.png').read_bytes()==sheet.read_bytes()
launcher=Path('G:/MySTG/start-six-stages.ps1').read_text(encoding='utf-8-sig')
assert '道中第 $sixWaveIndex 波'not in launcher and 'Add-SixEntry 3 road-front' in launcher and 'Add-SixEntry 3 road-back'in launcher
assert '珠乌' in launcher and 'zuu-' not in launcher
print('PASS exact TH08 sheet, 1.000s WAV, syntax, corrected selector entries')
