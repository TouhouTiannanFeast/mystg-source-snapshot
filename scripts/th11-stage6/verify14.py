from pathlib import Path
import hashlib,json
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change14'
for n,h in json.loads((L/'before-hashes.json').read_text()).items():
 if n not in ['milk/boss.lua','milk/nonspell.lua','README.md']:assert hashlib.sha256((M/n).read_bytes()).hexdigest()==h,n
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
classes={};Class=function(base)local c={};for k,v in pairs(base or{})do c[k]=v end;c.base=base;classes[#classes+1]=c;return c end
img_class={};bullet={init=function(o,img)o.imgclass=img end,skip_fade_in=function()end,del=function()breaks=breaks+1 end,kill=function()kills=kills+1 end}
breaks=0;kills=0;setting={};COLOR_BLUE=1;COLOR_RED=2;COLOR_YELLOW=3;COLOR_GRAY=4
cos=function(a)return math.cos(a*math.pi/180)end;sin=function(a)return math.sin(a*math.pi/180)end
LoadTexture=function()end;GetTextureSize=function()return 16,16 end;LoadImage=function()end
IsValid=function(o)return not o.invalid end
Del=function(o)o.class.del(o);o.invalid=true end
New=function(c,...)local o={class=c};c.init(o,...);return o end
task={New=function(o,fn)o.co=coroutine.create(fn)end,Wait=function()coroutine.yield()end}
boss={init=function(o,x,y)o.x,o.y=x,y end,card={New=function(n,t1,t2,t3,hp)return {hp=hp,t3=t3*60}end}}
TH11S6Suwako={clean=function()end};ran={Float=function(_,a,b)return (a+b)/2 end};player={x=0,y=-180}
''')
for n in ['milk/pattern.lua','milk/nonspell.lua']:l.execute((M/n).read_text(encoding='utf-8'))
l.execute('nonShot=classes[#classes]')
l.execute((M/'milk/boss.lua').read_text(encoding='utf-8'))
l.execute('''
local M=TH11S6Milk;local spellShot=classes[#classes-1]
for _,c in ipairs({nonShot,spellShot})do
 local o=New(c,0,0,2,0,'main');o.x=100000;o.age=300
 local old=breaks;c.frame(o)
 assert(o.invalid and o.offscreenRemoval and breaks==old,'offscreen must not generate break effect')
 local o=New(c,0,0,2,0,'main');c.del(o);assert(breaks==old+1,'phase/manual clear must retain effect')
 local o=New(c,0,0,2,0,'main');local oldKill=kills;c.kill(o);assert(kills==oldKill+1,'Bomb kill changed')
end
local o={};M.Boss.init(o);assert(o.x==-224 and o.y==256,'leftupper outside start')
M.nonspell.init(o);local oldx,oldy=o.x,o.y
for frame=1,60 do
 local ok,err=coroutine.resume(o.co);assert(ok,err)
 assert(o.x>=oldx and o.y<=oldy and MilkHoneyNonspell.shots==0,'entry must move smoothly without early fire')
 oldx,oldy=o.x,o.y
end
assert(math.abs(o.x)<1e-9 and o.y==96,'existing60f entry endpoint')
assert(M.nonspell.hp==12000 and M.nonspell.t3==2400 and M.card.hp==24000 and M.card.t3==3000)
assert(MilkHoneyNonspell.events(120)and not MilkHoneyNonspell.events(119))
''')
print('PASS actual both Shot.frame offscreen->del no BulletBreak;normaldel/Bombkill retained;actual Boss upperleft(-224,256) and existing60f smooth entry->(0,96),no earlyfire;120f firstnonspellshot and HP/time unchanged;other mod files byte-identical.')
