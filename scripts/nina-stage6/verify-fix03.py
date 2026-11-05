from pathlib import Path
from lupa.lua51 import LuaRuntime
import json,hashlib
M=Path('G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
l=LuaRuntime(unpack_returned_tuples=True)
names=['runtime','projectiles','programs','encounter','encounter-nina','assets','import10/pool','import10/runtime','import10/projectiles','import10/programs','import10/specs','import10/art','import08/specs','import08/art','import08/runtime','art08-local','fix02','programs-fix03','art03','art06','fix03','suwako03']
for n in names:l.execute((M/(n+'.lua')).read_text(encoding='utf-8-sig'))
l.execute('assert(loadstring(...))',(M/'root.lua').read_text(encoding='utf-8-sig'))
l.execute('''
local specs={};for _,s in ipairs(NinaCoreSpecs)do specs[s.id]=s end;for _,s in ipairs(Nina10Specs)do specs[s.id]=s end;for _,s in pairs(Nina08Specs)do specs[s.id]=s end
local hp={non1=10700,spell1=18400,non2=10000,spell2=12000,non3=18000,spell3=11000,non4=11400,spell4=15800,final=30000,kanako=48800}
for k,v in pairs(hp)do assert(specs[k].hp==v,k)end
assert(specs.spell1.group=='th13L');assert(specs.spell2.entry=='BossCard2'and specs.spell2.diff==1)
local R=NinaCoreRuntime;R.onActor=function()end;R.onShot=function()end;R.start(specs.spell1,123)
assert(R.yoshika.group=='th13L','Suwako must select Lunatic companion closure too')
for i=1,1000 do R.step(0,400,specs.spell1.hp);R.stepHazards()end
assert(R.boss.patterns[0].speed==3.5,'Lunatic speed branch')
print('PASS HP10 readback; spell1 Lunatic source execution speed3.5 / minimum wait10')
local T=Nina10Runtime;T.onActor=function()end;local lasers=0;T.onShot=function(b)if b.laser and b.laser.straight then lasers=lasers+1;assert(b.x==-224 or b.x==224);assert(b.laser.width==32)end end
T.start(specs.spell2,123);for i=1,750 do T.step(0,400,specs.spell2.hp);T.stepHazards()end
assert(lasers>0,'Moses source stationary lasers missing');print('PASS actual Normal Moses source laser births '..lasers)
local orbs,orbitDiamond,orbitRadius=0,{},{};local hardOnly=0
T.onShot=function(b)
 if b.typ==18 or(b.typ==5 and b.color==6)then hardOnly=hardOnly+1 end
 if b.typ==25 then
  local a=NinaFix03.art(b,Nina10Art.lookup(b.typ,b.color,b.group))
  orbs=orbs+1;orbitDiamond[orbs]=a.image;orbitRadius[orbs]=a.radius
 end
end
T.start(specs.spell2,123);for i=1,900 do T.step(0,400,specs.spell2.hp);T.stepHazards()end
assert(orbs>0,'Moses Normal light orb missing')
assert(hardOnly==0,'Normal Moses kept Hard-only blue orb/flame')
for i=1,orbs do
 assert(orbitRadius[i]==6,'Moses diamond radius changed')
 assert(orbitDiamond[i]==Nina03Art[i%2==1 and 577 or 579].image,'Moses diamond not red/blue alternating at '..i)
end
print('PASS Moses Normal: '..orbs..' light orbs -> alternating TH20 diamonds 577/579, radius6, no Hard-only bullets')
local chain={image='old',radius=2.4}
local scale=NinaFix03.art({group='th13',typ=9,color=13},chain)
assert(scale.image==Nina06Art.scale06.image and scale.radius==2.4,'non1 yellow chain must become yellow scale at radius2.4')
assert(NinaFix03.art({group='th13',typ=9,color=6},chain)==chain,'blue chain must stay unchanged')
print('PASS non1 yellow chain -> TH13 scale sprite236; other chain colors untouched')
T.onShot=function()end;T.start(specs.non2,123);T.boss.x,T.boss.y=71,113;T.continuousEntry=true;T.step(0,400,specs.non2.hp)
assert(math.abs(T.boss.x-71)<4 and math.abs(T.boss.y-113)<4,'Boss transition teleport');print('PASS non2 entry uses preceding Boss position')
local function rice()
 local red=0;T.onShot=function(b)if b.color==2 then red=red+1 end end
 T.start(specs.spell3,123)
 for i=1,600 do T.step(0,400,specs.spell3.hp);T.stepHazards()end
 assert(T.riceColored>0 and T.riceExtras==math.floor(T.riceColored/5));assert(red>0)
 return red,T.riceColored,T.riceExtras
end
local red,colored,extra=rice();print('PASS rice red births '..red..'; nonred '..colored..' + '..extra..' extras only (one per five)')
NinaState={current='non4'}
local original={image='old',radius=4};assert(NinaFix03.art({group='th08',typ=2,color=2},original).image==Nina03Art[577].image)
assert(NinaFix03.art({group='th08',typ=2,color=4},original).image==Nina03Art[578].image)
assert(NinaFix03.art({group='th08',typ=3,color=6},original).radius==4)
NinaState.current='final';assert(NinaFix03.art({group='th08',typ=2,color=2},original)==original)
assert(NinaFix03.art({group='th13L',typ=21,color=3},original).image==Nina03Art[579].image)
assert(NinaFix03.art({group='th11rice',typ=3,color=2},original)==original)
assert(NinaFix03.art({group='th11rice',typ=3,color=6},original).image==Nina10Art.lookup(0,6).image)
print('PASS visual-only source colors/diamonds/dots; original collision radius retained')
local S=NinaSuwako03;local a=S.new({x=0,y=112,hp=4000},7);local oldx,oldy=a.x,a.y
for i=1,180 do local x,y=a.x,a.y;S.step(a);assert((a.x-x)^2+(a.y-y)^2<=.45^2+.00001)end
assert(a.x~=oldx or a.y~=oldy);local calls=0;S.onRevive=function()calls=calls+1 end;a.hp=0
for i=1,239 do S.step(a);assert(a.down and a.hp==0)end
S.step(a);assert(not a.down and a.hp==4000 and a.glow and calls==1)
assert(S.downSprite(16)==26);print('PASS silent Suwako slow wander<=.45; down239 / revive240; accelerated palette and glow')
''')
for r in json.loads((M/'source/art03.json').read_text(encoding='utf-8')):
 assert hashlib.sha256(Path(r['source']).read_bytes()).hexdigest()==r['sha256']
 assert hashlib.sha256((M/r['target']).read_bytes()).hexdigest()==r['sha256']
print('PASS TH20 diamond source byte hashes and root Lua51 syntax')
for p in ['art/yellow-scale06.png','se/se_tan00.wav','se/se_lazer00.wav','music06/th20-12-stone-goddess.wav']:
 assert (M/p).is_file(),p
se=json.loads((M/'source/se06.json').read_text(encoding='utf-8'))
for f in se['files'].values():
 assert hashlib.sha256((M/f['target']).read_bytes()).hexdigest()==f['sha256'],f['target']
ref=json.loads((M/'music06/reference.json').read_text(encoding='utf-8'))
assert (ref['loop_start_bytes'],ref['size_bytes'])==(2210240,34336192)
assert hashlib.sha256((M/'music06'/ref['output']).read_bytes()).hexdigest()==ref['output_sha256']
load=(M/'music06/load.lua').read_text(encoding='utf-8')
assert "LoadMusic(NinaStage6Music.name,'music06/th20-12-stone-goddess.wav'" in load
print('PASS original SE pair hashes + TH20 No.13 music file/loop/reference')
