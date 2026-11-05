from pathlib import Path
from lupa.lua51 import LuaRuntime
m=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal')
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
function Include()end;function Class()return{}end
GROUP_GHOST=1;LAYER_ENEMY=10
objects={};function IsValid(o)return o and not o.deleted end
function Del(o)o.deleted=true end
function New(cls,...)local o={class=cls,timer=0};cls.init(o,...);table.insert(objects,o);return o end
function Color(...)return{...}end;function LoadTexture()end;function LoadImage()end;function CreateRenderTarget()end
function PushRenderTarget()end;function PopRenderTarget()end;function RenderClear()end;function SetViewMode()end
alphas={};function SetImageState(name,blend,c)alphas[name]=c[1]end;function Render()end
lstg={tmpvar={}}
background={init=function(self)if IsValid(lstg.tmpvar.bg)then Del(lstg.tmpvar.bg)end;lstg.tmpvar.bg=self end}
local function view()return{init=function()end,render=function()end}end
NinaTH11SanaeSpell={Object=view()};TH10S6Background={BossObject=view()};NinaWorld06={Object=view()}
''')
l.execute((m/'scenery/load.lua').read_text(encoding='utf-8'))
l.execute('''
local N=NinaScenery
local old={class={render=function()end}};lstg.tmpvar.bg=old
local h=New(N.Object,old)
assert(IsValid(old)and h.old==old and h.fade==120 and old.ninaHidden)
for i=1,60 do N.Object.frame(h)end;N.Object.render(h)
assert(alphas['nina.scenery.new.image']==127.5 and alphas['nina.scenery.old.image']==255)
for i=1,60 do N.Object.frame(h)end;assert(old.deleted and h.old==nil)
N.Object.render(h);assert(alphas['nina.scenery.new.image']==255)
for _,phase in ipairs({'spell','normal','kanako'})do
 local before=h.active
 if phase=='kanako'then N.arrival(120)else N.setPhase(phase)end
 assert(h.old==before and IsValid(before)and h.fade==120)
 for i=1,119 do N.Object.frame(h)end;assert(IsValid(before))
 N.Object.frame(h);assert(before.deleted and h.old==nil)
end
print('PASS120f road/normal/spell/Kanako crossfades;half alpha at60;old view alive until120;adopted road survives background init')
''')
l.execute('''
TH11S6Host={enemies={}};TH11S6Runtime={copy=function(a)return a end}
TH11S6Presentation={enemy=function(a)return'frog'..(math.floor(a.age/3)%3),0,1 end,ring=function()return'halo',0,1,128 end}
''')
l.execute((m/'road17/departure18.lua').read_text(encoding='utf-8'))
l.execute('''
objects={}
local living={x=40,y=0,data={name='RPhantom01',age=810,poseStart=0,anm={}}}
local killed={x=40,y=0,data={name='RPhantom01',age=810,defeated=true}}
local exited={x=40,y=300,data={name='RPhantom01',age=810,offscreenRemoval=true}}
TH11S6Host.enemies={[living]=true,[killed]=true,[exited]=true}
TH11S6Host.finishFrogs();assert(#objects==1)
local o=objects[1];assert(o.x==40 and o.y==0 and o.group==GROUP_GHOST and not o.colli)
local cls=TH11S6Host.FrogExit18
for i=1,89 do o.timer=i;cls.frame(o);assert(IsValid(o))end
assert(o.y>224);o.timer=90;cls.frame(o);assert(o.deleted and o.y==296)
print('PASS surviving frog starts at actual visible pose, remains animated until offscreen90f; defeated/offscreen frogs excluded; no combat/drop callbacks')
''')
for p in [m/'root.lua',m/'road17/load.lua',m/'road17/background.lua']:
 result=l.eval('function(s)return loadstring(s)end')(p.read_text(encoding='utf-8'));assert not isinstance(result,tuple),(p,result)
