from pathlib import Path
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/MarisaMixed'
l=LuaRuntime();l.execute('''function LoadTexture()end;function LoadImage()end;function LoadSound()end
sounds={};function PlaySound(id,...)sounds[#sounds+1]={id,SSG.tick}end
shots={};function cos(d)return math.cos(d*math.pi/180)end;function sin(d)return math.sin(d*math.pi/180)end
function Render(...)lastDraw={...}end;function SetImageState()end;function Color(...)end''')
for p in ['ssg-code.lua','ssg.lua','ssg-inspect04.lua','th08-art02.lua','selected05-art.lua']:
 l.execute((M/p).read_text(encoding='utf8'))
l.execute('SSG.onBullet=function(b)shots[#shots+1]={stage=b.selected05Stage,c=b.c,color=b.selected05Color,skin=b.selected05Skin,owner=owner,at=SSG.tick}end')
l.execute((M/'ssg-selected05.lua').read_text(encoding='utf8'))
l.execute('''local fire=SSG.fire;SSG.fire=function(a,...)owner=a.bit and a.reg[0]or nil;return fire(a,...)end
SSGSelected05.start(20261106,'full')
for i=1,3600 do
 SSGSelected05.step(319,400,30000)
 assert(SSGSelected05.stage==(i<=1200 and'A2'or i<=2400 and'B1'or'B3'))
 if i<285 then assert(SSGSelected05.entryProtected)else assert(not SSGSelected05.entryProtected)end
 if i<3600 then assert(not SSG.done)end
end
assert(SSG.done and SSGSelected05.duration==3600)
assert(SSGSelected05.stats.stages[2].at==1201 and SSGSelected05.stats.stages[3].at==2401)
local colors={};local ticks={}
for _,s in ipairs(shots)do
 if s.stage=='B1'then
  assert(s.skin=='smallstar'and s.color==({2,4,6,8,12})[s.owner+1])
  colors[s.owner]=s.color;ticks[s.at]=true
 end
end
for i=0,4 do assert(colors[i])end
local n=0;for _ in pairs(ticks)do n=n+1 end
local soundCount=0;for _,s in ipairs(sounds)do if s[1]=='mm.selected09.shot'then assert(ticks[s[2]]);soundCount=soundCount+1 end end
assert(soundCount==n and n>0)
for k,r in pairs(TH08Art02)do r.image=k end
for _,c in ipairs({2,4,6,8,12})do SSGSelected05.drawBullet({selected05Skin='smallstar',selected05Color=c,x=319,y=224,age=10});assert(lastDraw[1]==tostring(246+c))end
''')
root=(M/'root.lua').read_text(encoding='utf8');l.execute('assert(loadstring(...))',root)
host=(R/'aex-0.8.22/game/packages/thlib-scripts/THlib/enemy/boss.lua').read_text(encoding='utf8')
def fn(s,name):
 a=s.index('function '+name);return s[a:s.index('\nend',a)+4]
l.execute('boss={};MarisaBase={};S={phase="ssg"};R=SSG;lstg={var={score=0}}')
l.execute(fn(host,'boss:take_damage'));l.execute(fn(root,'MarisaBase:take_damage'))
l.execute('''local o={hp=30000,mmEntryMove=true,dmg_factor=1,DMG_factor=1,spell_damage=0}
MarisaBase.take_damage(o,1000000);assert(o.hp==30000)
o.mmEntryMove=false;SSGSelected05.start(20261106,'A2')
for i=1,284 do SSGSelected05.step(319,400,30000);MarisaBase.take_damage(o,1000000);assert(o.hp==30000)end
SSGSelected05.step(319,400,30000);assert(not SSGSelected05.entryProtected)
MarisaBase.take_damage(o,10);assert(o.hp==29990)
assert(SSGSelected05.frames('A2')==1200 and SSGSelected05.frames('B1')==1200 and SSGSelected05.frames('B3')==1200)
''')
msg='PASS actual1200/1200/1200f windows,total3600f; five fixed emitter starcolors and exactsoundticks; native star sprite mappings; actual private damage callback plus host boss.take_damage blocks initialmove/prelude damage and releases on firstattack; HP30000 and syntax.'
p=R/'work/logs/marisa-mixed/change10';p.mkdir(parents=True,exist_ok=True);(p/'verify.log').write_text(msg+'\n',encoding='utf8');print(msg)
