from pathlib import Path
import hashlib,json
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change11'
for n,h in json.loads((L/'before-hashes.json').read_text()).items():
 if n not in ['root.lua','sound.lua','README.md']:assert hashlib.sha256((M/n).read_bytes()).hexdigest()==h,n
old=(L/'before-sound.lua').read_text(encoding='utf-8');sound=(M/'sound.lua').read_text(encoding='utf-8')
assert sound==old.replace(";S.play('cat01',.55,x)end","end -- source cat call muted",1)
oldroot=(L/'before-root.lua').read_text(encoding='utf-8');root=(M/'root.lua').read_text(encoding='utf-8')
assert root==oldroot.replace('R.onMidboss=function()\n R.clearHazards()','R.onMidboss=function()\n R.clearHazards()\n if H.midbossStarts==0 then New(item_extend,0,128)end',1)
l=LuaRuntime(unpack_returned_tuples=True)
for s in [root,sound]:l.execute('assert(loadstring(...))',s)
l.execute('TH11S6Runtime={tick=0};played=0;PlaySound=function()played=played+1 end')
l.execute(sound)
l.execute('''
TH11S6Runtime.onSound(53,0);TH11S6Runtime.onSound(53,100);assert(played==0,'cat must stay silent')
TH11S6Sound.play('tan00',.22,0);assert(played==1,'other sound must still play')
R={tick=3160,clearHazards=function()end};H={midbossStarts=0};M={Boss={}};item_extend={};drops=0;bosses=0
TH11S6Voice={play=function(id)assert(id==2)end}
New=function(c,x,y)if c==item_extend then drops=drops+1;assert(x==0 and y==128)else assert(c==M.Boss);bosses=bosses+1 end end
''')
hook=root.split('R.onMidboss=function()\n',1)[1].split('\nend\nlocal Hud',1)[0]
l.execute('function intro()\n'+hook+'\nend')
l.execute('intro();assert(drops==1 and bosses==1);intro();assert(drops==1,"duplicate intro must not duplicate life");H.midbossStarts=0;intro();assert(drops==2,"new run reward")')
print('PASS Lua51 source53 muted/other shotsound intact;actual intro hook1life at0,128/duplicateguard/newrun reset;existing3rewardblocks and all other gameplay/audio assets byte-identical;root/sound syntax. No native/fullstage.')
