"""Source-focused Stone timing/health, Horou animation, and scoped damage checks."""
from pathlib import Path
import sys,json,hashlib,struct
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
MOD=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG'); C=MOD/'stages/zuu4'
phase_hash=hashlib.sha256((C/'patterns.lua').read_bytes()).hexdigest()
l=LuaRuntime(unpack_returned_tuples=True)
for p in list(C.glob('*.lua'))+[MOD/'systems/th18-fire/core.lua',MOD/'systems/th18-fire/bomb.lua']:
 l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
for f in ('art','runtime','animation','patterns','horou','horou-spells','th20'):
 l.execute((C/f'{f}.lua').read_text(encoding='utf-8-sig'))
l.execute('''
local R,A=Zuu4R,Zuu4R.animation
R.start('stone',123);local seen={}
for t=0,7199 do
 R.step(192,400,12000)
 if not seen[R.subphase]then seen[R.subphase]=t;print('TIME phase'..R.subphase..' sourceTick='..t)end
end
assert(R.stonePhaseStarts[1]==120 and R.stonePhaseStarts[2]==1920)
assert(R.stonePhaseStarts[3]==3719 and R.stonePhaseStarts[4]==5518)
assert(Zuu4Specs.stone.time==120)
R.start('stone',123)
for t=0,260 do
 local hp=t<150 and 12000 or t<200 and 7900 or t<250 and 4900 or 1900
 R.step(192,400,hp)
end
for i,v in ipairs({120,150,200,250})do assert(R.stonePhaseStarts[i]==v)end
assert(R.subphase==3)
local counts={};for _,b in ipairs(R.hazards)do
 assert(b.radius==4 and b.id>=369 and b.id<=376)
 counts[b.sourceColor]=(counts[b.sourceColor]or 0)+1
 assert(b.drawLayer==((b.sourceColor==5 or b.sourceColor==1)and 3 or 0))
end
assert(counts[6]==7 and counts[3]==32 and counts[5]==3 and counts[1]==2)
local b={kind='shot',id=374,x=192,y=-1,angle=-90,speed=0,accel=0,age=128,radius=4,delay=8,wraps=1,wrapPadding=32,noCull=true}
R.projectileStep(b);assert(b.y==-1 and b.wraps==1,'partial sprite must not wrap')
b.y=-16;R.projectileStep(b);assert(b.y==464 and b.wraps==0,'full sprite wrap includes32px')
R.projectileStep(b);assert(b.wraps==0,'single wrap only')
print('PASS Stone original four phases, HP early transitions, exact time checks, four layer emissions, HSoB diamonds and wrap bounds')
local o={x=192,y=140,book=true}
local function frame(kind,age,max,book,clock)
 o.pose={kind=kind,start=0,duration=max or 90};o.book=book~=false
 return A.bodyFrame(o,age,clock or 0)
end
assert(frame('stand',12)==1 and frame('stand',12,90,false)==31)
assert(frame('left',0)==12 and frame('left',8)==13 and frame('left',85)==12)
assert(frame('right',8,90,false)==41)
for i,v in ipairs({4,5,6,7,14,15})do assert(frame('shot1',(i-1)*6)==v)end
assert(frame('shot1',85)==16 and frame('shot1',30,90,false)==45)
assert(frame('shot2',0)==20 and frame('shot2',18)==23 and frame('shot2',85)==27)
assert(frame('shot3',0)==27 and frame('shot3',24)==23 and frame('shot3',85)==20)
assert(frame('shot2',0,90,false,171)==80)
R.start('non2',123)
for t=0,331 do R.step(192,400,5777)end
assert(#R.actors==2 and R.actors[1].hitRadius==48 and R.actors[2].hitRadius==48)
local parts=A.wingParts(R.boss,20);assert(#parts==28)
local strips,bases,machines,flyers,eyes=0,0,0,0,0
for _,p in ipairs(parts)do
 if p.image:find('normalStrip')then strips=strips+1;assert(p.vertices)end
 if p.image=='zuu4.wingBase'then bases=bases+1 end
 if p.image=='zuu4.wingMachine'then machines=machines+1 end
 if p.image=='zuu4.wingFlyer'then flyers=flyers+1 end
 if p.image=='zuu4.wingEye'or p.image=='zuu4.wingPupil'then eyes=eyes+1 end
end
assert(strips==8 and bases==3 and machines==6 and flyers==4 and eyes==2)
function SetImageState()end;function Color(...)return {...}end
local draw=0;function Render4V(...)assert(select('#',...)==13);draw=draw+1 end
function Render()end
A.render(R.boss);assert(draw==28)
local detached=A.detach(R.boss)
for t=0,150 do A.fadeStep(detached,t)end
for _,p in ipairs(detached)do assert(not p.active)end
local tail=R.random();for i=1,90 do R.animateStep(R.boss)end
local following=R.random();R.start('non2',123)
assert(R.random()==tail and R.random()==following,'cosmetic RNG altered attack RNG')
print('PASS source body pose tables/book/blink/movement;28 wing quads, eye/pupil, three bases, eight mesh strips; radius48 retained; cosmetic RNG isolation')
''')
host=(C/'host.lua').read_text(encoding='utf-8-sig')
damage=host[host.index('function ZuuDamage:take_damage'):host.index('function Zuu4Boss:render')]
l.execute('''
ZuuDamage={};stage={current_stage={timer=1}};Th18FireData={}
function IsValid(e)return e~=nil end
boss={take_damage=function(o,d)o.hp=o.hp-d end}
local R=Zuu4R;local S={current='stone',damage=0};R.boss={visible=true};R.tick=200
'''+damage+'''
TestBoss={hp=1000};TestDamageState=S
function Damage(o,d)ZuuDamage.take_damage(o,d)end
''')
l.execute((MOD/'systems/th18-fire/data.lua').read_text(encoding='utf-8-sig'))
l.execute((MOD/'systems/th18-fire/core.lua').read_text(encoding='utf-8-sig'))
l.execute('''
Th18Fire.damage(TestBoss,40,'bomb');assert(TestBoss.hp==990 and Th18Fire.damageKind==nil)
Th18Fire.damage(TestBoss,20);assert(TestBoss.hp==970,'ordinary shot changed')
TestDamageState.current='non1';stage.current_stage.timer=2
Th18Fire.damage(TestBoss,10,'bomb');assert(TestBoss.hp==970-10*Zuu4Specs.non1.rate,'non-Stone damage changed')
print('PASS Stone Bomb0.25, ordinary damage1 and current non-Stone multiplier preserved; source tag restored')
''')
base=(1+1.2)*0.4
hsob_dps=2*(base*2)*(60/6)+4*(base*2*2)*(60/12)
assert abs(hsob_dps-105.6)<1e-8
current={}
for name,slow in (('fast',False),('slow',True)):
 current[name]=l.execute('''local slow=...;lstg={var={power=400}};local F=Th18Fire
 local p={fireShort=-1,fireLong=-1};local dmg=0
 for t=1,120 do F.start(p);F.rows(p,slow,function(r)dmg=dmg+r.damage end);F.advance(p,true)end
 return dmg/2''',slow)
report={'hsobReimuBaselineDPS':hsob_dps,'currentReimuDPS':current,'phaseDataSHA256':phase_hash,'th20SHT':{}}
for name in ('pl00','pl01'):
 p=Path('G:/TouHou/MLforDanmu/data/local/touhou/th20-20261027/auxiliary-raw')/(name+'.sht')
 b=p.read_bytes();count=struct.unpack_from('<H',b,2)[0];assert count==160
 offsets=struct.unpack_from('<160I',b,0x5d4);groups=[]
 for i,a in enumerate(offsets):
  rows=[]
  while b[a:a+4]!=b'\xff'*4:
   rate,delay,dmg=struct.unpack_from('<BBh',b,a);rate2,delay2=b[a+50:a+52]
   rows.append({'rate':rate,'delay':delay,'damage':dmg,'rate2':rate2,'delay2':delay2,'option':b[a+40],'callbacks':list(struct.unpack_from('<4h',b,a+52))})
   a+=120
  assert a+4==(offsets[i+1]if i<159 else len(b))
  groups.append(rows)
 dps=lambda rs:sum(r['damage']*sum(1 for t in range(120)if (t%120 if r['rate2']else t%15)%(r['rate2']or r['rate'])==(r['delay2']if r['rate2']else r['delay']))/2 for r in rs if r['rate2']or r['rate'])
 report['th20SHT'][name]={'sha256':hashlib.sha256(b).hexdigest(),'groups':groups,'fullPowerEmissionOnlyByWeaponIndex':[
  {'index':i,'base':dps(groups[20*i+4]),'fast':dps(groups[20*i+4]+groups[20*i+9]),'slow':dps(groups[20*i+4]+groups[20*i+14])}for i in range(8)]}
 if name=='pl00':print('TH20 REIMU full-power emission-only',report['th20SHT'][name]['fullPowerEmissionOnlyByWeaponIndex'])
report['phaseRatios']=[]
spec=l.globals().Zuu4Specs
for key in ('non1','spell1','non2','spell2','non3','stone','final'):
 s=spec[key];row={'phase':key,'hp':s.hp,'rate':s.rate,'effectiveHP':s.hp/s.rate}
 row.update({'hsobBaselineSeconds':s.hp/s.rate/hsob_dps,'currentFastSeconds':s.hp/s.rate/current['fast'],'currentSlowSeconds':s.hp/s.rate/current['slow']})
 report['phaseRatios'].append(row)
out=Path('G:/MySTG/work/zuu4/audit06/firepower-report.json');out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('REPORT',out)
assert hashlib.sha256((C/'patterns.lua').read_bytes()).hexdigest()==phase_hash,'Concurrent phase-data edit: refresh report before publishing'
