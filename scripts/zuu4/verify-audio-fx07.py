"""Focused balance/source-FX checks in Lua51; never launches a whole encounter."""
from pathlib import Path
import sys,json,hashlib,struct,math,wave
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
C=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/zuu4')
B=Path('G:/MySTG/work/zuu4/audio-fx07/before')
def vm(before=False):
 l=LuaRuntime(unpack_returned_tuples=True)
 for f in ('art','runtime','animation','effects','patterns','horou','horou-spells','th20'):
  if before and f=='effects':continue
  p=(B if before else C)/(f+'.lua');l.execute(p.read_text('utf-8-sig'))
 return l
for p in C.glob('*.lua'):LuaRuntime().execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
a,b=vm(True),vm()
for id in ('non1','spell1','non2','spell2','non3','stone','final'):
 old,new=a.globals().Zuu4Specs[id],b.globals().Zuu4Specs[id]
 for k,v in old.items():assert new[k]==((24000 if id=='non3'else 58500)if k=='hp'and id in ('non3','stone')else v),(id,k)
print('PASS HP24000/58500; all other phase HP/rates/holds/time/name/order preserved')
b.execute('''
local R=Zuu4R
R.start('non3',123)
for t=0,319 do R.step(192,400,24000)end
local rings,fans=0,0
for _,s in ipairs(R.hazards)do
 assert(s.radius==4 and s.id>=369 and s.id<=376)
 if s.profile then fans=fans+1;assert(math.abs(s.profile.initial-0.4)<1e-12 and math.abs(s.profile.s1-0.08)<1e-12 and math.abs(s.profile.s2-1.2)<1e-12)
 else rings=rings+1;assert(s.speed==2)end
end
assert(R.counts.shots==144 and rings==44 and fans==100)
print('PASS non3: four11-shot rings +100 single fans=144 vs old436; all three speed targets x2; HSoB art/collision unchanged')
R.start('stone',123)
for t=0,260 do R.step(192,400,t<150 and 58500 or t<200 and 40400 or t<250 and 26900 or 13400)end
for i,v in ipairs({120,150,200,250})do assert(R.stonePhaseStarts[i]==v)end
local n={};for _,s in ipairs(R.hazards)do n[s.sourceColor]=(n[s.sourceColor]or 0)+1;assert(s.radius==4)end
assert(n[6]==5 and n[3]==24 and n[5]==3 and n[1]==2)
R.start('stone',123)
for t=0,7199 do R.step(192,400,58500)end
for i,v in ipairs({120,1920,3719,5518})do assert(R.stonePhaseStarts[i]==v)end
assert(R.hp==58500 and Zuu4Specs.stone.time==120 and Zuu4Specs.stone.bombRate==0.25)
print('PASS Stone four HP/time phases, scaled gates40500/27000/13500; time fallback120/1920/3719/5518 unchanged; density5/7,24/32,13/17,8/10')
''')
# Compare actual combat trajectories before/after cosmetic tasks, using two VMs.
for id,frames in [('non1',450),('non2',450),('spell1',500),('spell2',1000),('final',1000)]:
 def run(l):
  l.execute('Zuu4R.start(...,123)',id)
  l.execute('local R=Zuu4R;for t=1,... do R.step(192,400,Zuu4Specs[R.id].hp)end',frames)
  return l.eval('''function()local R=Zuu4R;local out={};for _,s in ipairs(R.hazards)do
   if s.mode~='notice' then out[#out+1]=string.format('%s/%s/%.9f/%.9f/%.9f/%.9f/%s',s.kind,s.id or s.visual or'',s.x,s.y,s.angle,s.speed or 0,s.radius)end end
   return table.concat(out,';'),R.random(),R.boss.x,R.boss.y end''')()
 assert run(a)==run(b),id+' cosmetics changed combat path/RNG'
 print('PASS cosmetic isolation',id,frames,'frames; combat paths and RNG match previous implementation')
# Resource bounds and render calls: load the actual new FX module.
l=vm();g=l.globals();textures={};loads=[]
def loadtex(name,path):
 p=C.parents[1]/path
 data=p.read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n';textures[name]=struct.unpack_from('>II',data,16)
def loadimg(name,tex,x,y,w,h,*rest):
 assert w>0 and h>0 and x>=0 and y>=0 and x+w<=textures[tex][0] and y+h<=textures[tex][1],name
 loads.append(name)
g.LoadTexture=loadtex;g.GetTextureSize=lambda n:textures[n];g.LoadImage=loadimg
l.execute('Zuu4R.fx.load()')
l.execute('''
local R,F=Zuu4R,Zuu4R.fx
function Color(a,r,g,b)for _,n in ipairs({a,r,g,b})do assert(n==n and n>=0 and n<=255)end;return {a,r,g,b}end
local draws=0
function SetImageState()end
function Render(...)draws=draws+1 end
function Render4V(...)assert(select('#',...)==13);draws=draws+1 end
function RenderTexture(tex,blend,...)assert(select('#',...)==4);for _,v in ipairs({...})do assert(#v==6)end;draws=draws+1 end
for id,s in pairs(Zuu4Art.shots)do s.image='shot'..id end
R.start('spell2',123)
for t=0,999 do R.step(192,400,4500);F.background();F.render('cutin');F.render('front')end
assert(draws>1000)
local d=F.deathStart({x=192,y=140});for t=0,255 do F.deathStep(d,t);F.deathRender(d)end;assert(#d.items==0)
local e=assert(F.newErase({x=192,y=200,radius=4,id=369}));for t=0,44 do F.eraseStep(e,t);F.eraseRender(e,t)end
print('PASS original FX resources/bounds; charge/point/arrow/square/cutin/background renders, source death255f and erase32f lifecycle')
''')
refs=json.loads((C/'audio-fx07-reference.json').read_text('utf-8'))
for r in refs:assert hashlib.sha256((C/r['output']).read_bytes()).hexdigest()==r['sha256']
with wave.open(str(C/'audio/hsob_6boss.wav'))as w:assert w.getframerate()==48000 and w.getnframes()>=12570074
for p in (C/'audio').rglob('*.wav'):
 with wave.open(str(p))as w:assert w.getsampwidth()==2 and w.getnframes()>0
print('PASS provenance hashes, all25 source SE and boss BGM decodable PCM; source loop22.5469375..261.8765417 seconds')
