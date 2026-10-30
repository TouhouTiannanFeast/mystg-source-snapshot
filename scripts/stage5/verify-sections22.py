from pathlib import Path
from lupa.lua51 import LuaRuntime
base=Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages')
l=LuaRuntime(unpack_returned_tuples=True)
for path in [base/'th18_stage5/sections.lua',base/'suwako5/stage.lua']:
 l.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'))
for name in ['suwako5/pool','th18_stage5/runtime','th18_stage5/projectiles','th18_stage5/programs','th18_stage5/route','th18_stage5/sections']:
 l.execute((base/(name+'.lua')).read_text(encoding='utf-8-sig'))
l.execute('''local C,R=Th18Stage5Sections,Th18Stage5Runtime
local originalFront=Th18Stage5Programs.th18.MainFront.ops
local originalLatter=Th18Stage5Programs.th18.MainLatter.ops
local expected={'Cir00','Cir01','GirlC01','Cir02','Phantom01','GirlD01','Cir03','GirlD02'}
for i=0,7 do
 local e=C.entry('road-'..i);R.startRoute(123)
 local first;R.onActor=function(a)first=first or a.name end
 C.run(R,e,e.program)
 for t=1,200 do R.stepRoute(0,400);if first then break end end
 assert(first==expected[i+1],'wrong first spawn road-'..i..' '..tostring(first))
 assert(Th18Stage5Programs.th18.MainFront.ops==originalFront)
 assert(Th18Stage5Programs.th18.MainLatter.ops==originalLatter)
end
local all=Suwako5Pool.draw(123,4)
for n=1,8 do local p=C.phases(all,C.entry('boss-'..n));assert(#p==9-n);for i=1,#p do assert(p[i]==all[n+i-1])end end
assert(C.entry('full').front and C.entry('full').mid)
assert(C.entry('mid').mid and not C.entry('mid').front)
assert(not pcall(C.entry,'boss-9'))
print('PASS eight real source road entries first spawns, source tables unchanged, eight seeded boss suffixes, invalid entry guard')
''')
# Execute the actual modified init task with a bounded host mock: only flow/protection, no combat simulation.
s=(base/'suwako5/stage.lua').read_text(encoding='utf-8-sig')
start=s.index('local immunePlayer,immuneCollision');end=s.index("if setting.suwako5_autostart then")
flow=s[start:end]
for entry in ['full','mid']+['road-'+str(i) for i in range(8)]+['boss-'+str(i) for i in range(1,9)]:
 for god in [False,True]:
  t=LuaRuntime(unpack_returned_tuples=True)
  t.execute((base/'suwako5/pool.lua').read_text(encoding='utf-8-sig'));t.execute((base/'th18_stage5/sections.lua').read_text(encoding='utf-8-sig'))
  t.globals().chosen=entry;t.globals().god=god
  t.execute('''setting={suwako5_entry=chosen,suwako5_invincible=god,suwako5_seed=123};player={colli=true}
 R={clearHazards=function()end};P=Suwako5Pool;S={owned={}};Suwako={};ran={Int=function()return 123 end}
 events={};waits=0;bossWaits=0
 function IsValid(o)if o==player then return true end;if o and o.isBoss then bossWaits=bossWaits+1;return bossWaits<=2 end;return o~=nil end
 function New(class,phases)if class==Suwako then selected=phases;return {isBoss=true}end;return {state={}}end
 function Del()end;function clean()end;print=function()end
 task={Wait=function()waits=waits+1;if god and selected and bossWaits<=2 then assert(player.colli==false)end end}
 local T={controller={},run=function(name)events[#events+1]=name end,idle=function()return true end,
 command=function(a,e,k)if k=='enmCreateA' then events[#events+1]='mid' end end}
 Th18Stage5Runtime=T
 Th18Stage5Host={begin=function()end,step=function()if god then routeProtected=true end end,
 finishRoute=function()events[#events+1]='finish'end,cleanup=function()end}
 Th18Stage5Background={Object={},armMidboss=function()end,beginValley=function()end,step=function()end,interrupt=function()end}
 -- Record routing without simulating authored attack programs in the flow mock.
 Th18Stage5Sections.run=function(r,e,name)events[#events+1]=e.program==name and e.program..':'..e.first or name end
 stage={group={AddStage=function()end,DefStageFunc=function(n,k,f)if k=='init'then init=f else teardown=f end end,
 initTask=function(s,f)f()end}}
 ''')
  t.execute(flow)
  t.execute('''init({});assert(S.finished);assert(player.colli==true);teardown();assert(player.colli==true)
local e=Th18Stage5Sections.entry(chosen);assert(#selected==(e.boss and 9-e.boss or 8))
local mid=0;local front=0;local latter=0
for _,x in ipairs(events)do if x=='mid'then mid=mid+1 end;if x:match('^MainFront')then front=front+1 end;if x:match('^MainLatter')then latter=latter+1 end end
assert(mid==(e.mid and 1 or 0));assert(front==(e.front and 1 or 0));assert(latter==(e.boss and 0 or 1))
''')
print('PASS actual stage init flow: 18 entries x invincibility on/off, continuation, eight-stage suffixes and restored collision; no native/full-stage run')
