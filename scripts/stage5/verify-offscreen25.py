from pathlib import Path
from lupa.lua51 import LuaRuntime
import hashlib,json
BASE=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages');WORK=Path('G:/MySTG/work/stage5/offscreen25')
results=[]
for folder in ['th18_stage5','suwako5']:
 def setup(old):
  l=LuaRuntime(unpack_returned_tuples=True)
  l.execute((BASE/folder/'runtime.lua').read_text('utf-8-sig'))
  text=((WORK if old else BASE)/folder/'projectiles.lua').read_text('utf-8-sig');l.execute(text)
  l.execute('''R='''+('Th18Stage5Runtime'if folder=='th18_stage5'else'Suwako5Runtime')+''';R.hazards={};R.stats={bullets=0,lasers=0};R.playerX=0;R.playerY=400
math.atan2=math.atan2 or function(y,x)return math.atan(y,x)end
function make(x,y,vx,vy,cull,active,group)
 return {group=group or 'th10',x=x,y=y,vx=vx,vy=vy,angle=math.atan2(vy,vx),speed=2,typ=0,color=0,ex={},pc=0,active=active or {},age=10,cull=cull or 0}
end
''');return l
 for label,expr in [('right','make(207,100,2,0)'),('left','make(-207,100,-2,0)'),('bottom','make(0,463,0,2)'),('top','make(0,-79,0,-2)'),('inside','make(0,100,2,0)'),('delay','make(210,100,2,0,10)'),('th10bounce',"make(195,100,2,0,0,{{kind='bounce',age=0,count=1}},'th10')"),('dsbounce',"make(195,100,2,0,0,{{kind='bounce',age=0,count=1,mask=15}},'dsc')"),('wrap',"make(195,100,2,0,0,{{kind='wrap',age=0,count=1}},'isc0902')")]:
  old,new=setup(True),setup(False)
  for l in [old,new]:l.execute('b='+expr+';R.projectileStep(b)')
  for key in ['x','y','vx','vy','angle','speed','age','cull','dead','collidable']:
   assert old.globals().b[key]==new.globals().b[key],(folder,label,key)
  if label in ['right','left','bottom','top']:assert new.globals().b.offscreenRemoval
  else:assert not new.globals().b.offscreenRemoval,(folder,label)
  results.append(folder+'/'+label)
 # Execute actual framework callbacks and the host's real dead-object frame branch.
 l=setup(False)
 framework=Path('G:/MySTG/aex-0.8.22/game/packages/thlib-scripts/THlib/bullet/bullet.lua').read_text('utf-8-sig')
 l.execute('''bullet={};BulletBreak={};item_faith_minor={};lstg={world={boundl=-224,boundr=224,boundb=-256,boundt=256}}
fx=0;items=0;function New(c)if c==BulletBreak then fx=fx+1 elseif c==item_faith_minor then items=items+1 end end
function BoxCheck()return true end
H={owned={}};S={owned={}};Shot={};NativeShot={}
''')
 l.execute(framework[framework.index('function bullet:kill()'):framework.index('function bullet:render()')])
 file=BASE/folder/('host.lua'if folder=='th18_stage5'else'stage.lua');host=file.read_text('utf-8-sig');cls='Shot'if folder=='th18_stage5'else'NativeShot'
 for method in ['del','kill']:
  line=next(x for x in host.splitlines()if x.startswith('function '+cls+':'+method+'()'));l.execute(line)
 start=host.index('function '+cls+':frame()');end=host.index('function '+cls+':render()',start);l.execute(host[start:end])
 l.execute('C='+cls+''';function Del(o)C.del(o)end
local function object(b)return {data=b,_index=1,imgclass={size=1},x=205,y=100}end
b=make(207,100,2,0);R.projectileStep(b);assert(b.dead and b.offscreenRemoval)
local o=object(b);H.owned[o]=true;S.owned[o]=true;C.frame(o);assert(fx==0 and items==0)
assert(not H.owned[o] or C==NativeShot);assert(not S.owned[o] or C==Shot)
-- Scripted deletion remains visible.
C.frame(object({dead=true}));assert(fx==1 and items==0)
-- Active Kill retains both break effect and framework item callback.
C.kill(object({}));assert(fx==2 and items==1)
''')
 print('PASS',folder,'actual natural-cull -> host frame -> framework callbacks: silent exit; scripted Del/active Kill retained')
for folder,file in [('th18_stage5','host.lua'),('suwako5','stage.lua')]:
 LuaRuntime().execute('assert(loadstring(...))',(BASE/folder/file).read_text('utf-8-sig'))
protected=json.loads((WORK/'protected.json').read_text())
for rel,h in protected.items():assert hashlib.sha256((BASE/rel).read_bytes()).hexdigest()==h,rel
print('PASS',len(results),'prior/new boundary/delay/bounce/wrap comparisons; gameplay fields identical;',len(protected),'protected files unchanged; Lua51 syntax; no native/full-stage launch')
