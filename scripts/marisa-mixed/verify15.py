from pathlib import Path
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed')
def read(p):return p.read_text(encoding='utf-8-sig')
lua=LuaRuntime(unpack_returned_tuples=True)
for f in ['root.lua','ds/pool.lua','th08/host.lua','th08/boss.lua']:
 lua.execute('assert(loadstring(...))',read(M/f))
lua.execute(read(M/'ds/pool.lua'))
lua.execute('''local P=DSExtraPool;assert(P.specs[8].hp==10000 and P.specs[8].frames==1800)
for t=0,1799 do assert(P.photoIndex(t,P.specs[8])==(t<900 and 0 or 1))end''')
print('PASS Comet 1800f total, both900f phases, HP10000 retained')
lua.execute('''int=math.floor;max=math.max;min=math.min;object={};boss={card={},move={}};function Class(b)return setmetatable({},{__index=b})end
function boss.card.New(name,a,b,t,hp,drop,extra)return{name=name,t1=a*60,t2=b*60,t3=t*60,hp=hp}end
th08s4={phase_objects={},stats={phases=0,ended=0},frame=0,Beam={}}
local T=th08s4
function T.rad(a)return -a*180/math.pi end
function T.move()end;function T.drift()end;function T.clear()end;function T.rand(a,b)return(a+b)/2 end
function T.aim()return -60 end
beams={};volleys={}
function New(c,owner,x,y,a,l,w,color,warn,active,off,turn)local b={rot=a,width=w,timer=180};beams[#beams+1]=b;return b end
function T.volley(o,mode,typ,color,n)volleys[#volleys+1]={n=n,color=color}end
function IsValid(o)return o~=nil end
setting={};S={};names={final='恋符「Master Spark」'}
function clean()end
MarisaDS={};DSExtraPool=DSExtraPool
''')
lua.execute(read(Path('G:/MySTG/aex-0.8.22/game/packages/thlib-scripts/lib/Ltask.lua')))
lua.execute(read(M/'th08/boss.lua'))
root=read(M/'root.lua');section=root[root.index('local function card(id)'):root.index('-- Original stardust')]
# Read the complete local factory, including existing Stardust after-hook.
section=root[root.index('local function card(id)'):root.index('-- AEX Damage')]
lua.execute('local T=th08s4;'+section+'\nmakeCard=card')
lua.execute('''local c=makeCard('final');assert(c.hp==2500 and c.t3==3900 and c.name=='Love Sign / Master Spark')
assert(th08s4.phase_specs.stardust.hp==2400)
local o={x=0,y=0,hp=c.hp};c.init(o);assert(o.th08_phase=='master' and S.phase=='final')
for i=1,600 do task.Do(o)end
assert(#beams==2 and beams[1].rot==-90 and beams[2].rot==-60)
for _,b in ipairs(beams)do assert(b.width==180 and b.spark and not b.track_player)end
assert(#volleys>0);for _,v in ipairs(volleys)do assert(v.n==11)end''')
# Rendering must be independent of tracking, so fixed-direction Master beams retain full Spark artwork.
lua.execute('''laser={};bullet={};enemy={};function laser.render()error('Spark fell back to thin laser')end''')
lua.execute(read(M/'th08/host.lua'))
lua.execute('''TH08Visual02={renderSpark=function(o)assert(o.spark and not o.track_player);rendered=true end}
th08s4.Beam.render(beams[1]);assert(rendered)''')
print('PASS actual root terminal factory selects Master Spark, retains2500HP/65s; real task emits fixed first beam, locked subsequent aim, width180, Master eleven-star rings; four-layer render path active without tracking')
print('PASS Lua51 syntax; Stardust2400HP unchanged')



