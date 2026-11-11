from pathlib import Path
import sys,re,json,hashlib
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH125Extra';W=R/'work/logs/th125-extra/change05'
sys.path.insert(0,str(R/'scripts/suwako5'));import build as lower
src=(M/'source/ecl27_c.named.utf8.txt').read_text(encoding='utf-8')
funcs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3])for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',src,re.M|re.S)}
program=(M/'programs.lua').read_text(encoding='utf-8')
for n in ['Boss','Boss1','Boss1Spark','Boss1_anim','Boss1_at1','BossNice']:
 code,_=lower.lower(funcs[n]);assert 'P["ds8"]["'+n+'"]='+code in program
assert program.split('P["ds8"]={}')[0]==(W/'programs.lua').read_text(encoding='utf-8').split('P["ds8"]={}')[0]
l=LuaRuntime(unpack_returned_tuples=True)
for n in ['pool','runtime','projectiles','programs']:l.execute((M/(n+'.lua')).read_text(encoding='utf-8'))
l.execute('R=DSExtraRuntime;births={};sounds={};shakes={};shots={};R.onActor=function(a)births[#births+1]=R.tick end;R.onSound=function(id)sounds[id]=(sounds[id]or 0)+1 end;R.onShake=function(t,x,y)assert(t==90 and x==1 and y==1);shakes[#shakes+1]=R.tick end;R.onShot=function(b)shots[#shots+1]={t=R.tick}end;R.start(DSExtraPool.specs[8],123)')
for i in range(3600):
 l.execute('R.step(0,400,10000);R.stepHazards()')
 assert l.globals().R.photos==(0 if i<1800 else 1)
assert l.globals().DSExtraPool.specs[8].frames==3600
assert list(l.globals().shakes.values())==list(range(62,3600,150))
assert list(l.globals().births.values())[:45]==list(range(62,152,2))
assert l.globals().sounds[51]==24 and l.globals().sounds[67]==1
ref=json.loads((M/'source/reference.json').read_text(encoding='utf-8'))
for s in ref['sounds']:assert hashlib.sha256((M/s['target']).read_bytes()).hexdigest()==s['sha256']
anm=(M/'source/enm27.anm.txt').read_text(encoding='utf-8');a=re.search(r'script script19 \{(.*?)\n\}',anm,re.S)[1]
assert 'ins_50(0.0f, 0.0f)'in a and 'ins_60(8, 0, 2.5f, 2.5f)'in a
for p in M.glob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
print('PASS source-exact six Ex8 functions;150f cycle/45x2f sparks;3600f/0->1 at1800;24 source shake+sound51 and1 sound67;original sound hashes andANM19;othercards unchanged;Lua51 syntax.')
