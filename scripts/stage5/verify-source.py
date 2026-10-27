from pathlib import Path
from lupa.lua51 import LuaRuntime
r=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages');l=LuaRuntime(unpack_returned_tuples=True)
l.execute('math.atan2=math.atan2 or function(y,x)return math.atan(y,x)end')
for p in list((r/'th18_stage5').glob('*.lua'))+[r/'suwako5/stage.lua']:
 try:l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8-sig'))
 except Exception as e:raise Exception(str(p)+' '+str(e))
for name in ['suwako5/pool','th18_stage5/data','th18_stage5/anm','th18_stage5/runtime','th18_stage5/projectiles','th18_stage5/programs','th18_stage5/route','th18_stage5/background']:
 # Remove only host background class registration for headless playback.
 s=r.joinpath(name+'.lua').read_text(encoding='utf-8-sig');s=s.split('B.Object=Class(background)')[0];l.execute(s)
l.execute('''local R=Th18Stage5Runtime;local A=Th18Stage5Animation
for _,bank in ipairs({'enemy','bullet','effect','ability','suwako','background'})do
 for id in pairs(Th18Stage5Data[bank].scripts)do local a=A.new(bank,id);for t=1,200 do A.step(a)end end
end
local b=Th18Stage5Background.new();for t=1,6000 do Th18Stage5Background.step(b)end
assert(b.loops>0);assert(Th18Stage5Background.interrupt(b,1));for t=1,1024 do Th18Stage5Background.step(b)end
for typ,row in pairs(Th18Stage5Data.bulletTypes)do for color,ids in pairs(row.spriteSets)do for i=1,3 do assert(Th18Stage5Data.bullet.sprites[ids[i]],'missing bullet sprite '..typ..'/'..color..'/'..i)end end end
R.startRoute(1234);R.onShot=function(b)assert(Th18Stage5Data.bulletTypes[b.typ].colors[b.color])end;R.run('MainFront');for t=1,10000 do R.stepRoute(0,400);for _,a in ipairs(R.actors)do if not a.controller then R.cullActor(a,32,32)end end;if R.idle()then break end end
assert(R.idle(),'front never completed');print('FRONT',R.tick,R.stats.actors,R.stats.bullets)
R.command(R.controller,{i={},f={}},'enmCreateA',{'MBoss',-192,-32,40,0,1});for t=1,160 do R.stepRoute(0,400)end;R.run('MainLatter')
for t=1,12000 do R.stepRoute(0,400);for _,a in ipairs(R.actors)do if not a.controller then R.cullActor(a,32,32)end end;if R.idle()then break end end
assert(R.idle(),'latter never completed');print('LATTER',R.tick,R.stats.actors,R.stats.bullets)
''')
print('Lua51 syntax / all used ANM programs / full STD loops+interrupt / route timeout PASS')


import json,hashlib
folder=r/'th18_stage5'
refs=json.loads((folder/'assets-source.json').read_text(encoding='utf-8'))['records']
for row in refs:
 assert hashlib.sha256(Path(row['source']).read_bytes()).hexdigest()==row['sha256']
 assert hashlib.sha256((folder/row['target']).read_bytes()).hexdigest()==row['sha256']
for row in json.loads((folder/'route-source.json').read_text(encoding='utf-8'))['sources']:
 assert hashlib.sha256(Path(row['path']).read_bytes()).hexdigest()==row['sha256']
l.execute("for _,pool in ipairs({Suwako5Pool.nonspells,Suwako5Pool.spells})do for _,s in ipairs(pool)do assert(s.frames==1800)end end;assert(#Suwako5Pool.spells==15 and #Suwako5Pool.nonspells==7);assert(Suwako5Pool.find('th10-card2').hp==3600 and Suwako5Pool.find('th125-a').hp==1000 and Suwako5Pool.find('th143-0906').hp==190)")
print('PASS',len(refs),'source texture hashes / ECL hashes / existing Suwako pool15+7, HP and30s')
