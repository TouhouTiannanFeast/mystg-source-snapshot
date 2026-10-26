from pathlib import Path
import importlib
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal'
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 p=lua.execute((m/'mamizou/pattern.lua').read_text(encoding='utf-8'))
 assert p.health[4]==787.5 and p.durations[4]==1800
 assert [p.health[i] for i in (1,2,3,5)]==[800,1500,900,1575]
 lua.execute('stops={};played=0;resumed=0;EnumRes=function()return {"global"},{"stage"}end;StopMusic=function(n)stops[n]=true end;PlayMusic=function()played=played+1 end;ResumeMusic=function()resumed=resumed+1 end')
 lua.execute((m/'music.lua').read_text(encoding='utf-8-sig'))
 lua.execute('PlayMusic("menu");ResumeMusic("menu");Stage12Music.play("s2.boss");assert(played==0 and resumed==0 and stops.global and stops.stage)')
 lua.execute((r/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 lua.globals().dofile=lambda p:lua.execute((r/'aex-0.8.22/game'/p).read_text(encoding='utf-8'))
 lua.execute("CopyImage=function()end;COLOR_CYAN=6;COLOR_PURPLE=5;arrow_small={init=function(o,col)o.img='arrow_small'..col end};th14={stats={phases=0,ended=0},stage_frames=0,clean_bullets=function()end,clean_actors=function()end};setting={}")
 lua.execute((m/'character-animation.lua').read_text(encoding='utf-8'))
 lua.execute((m/'stage1/context.lua').read_text(encoding='utf-8'))
 lua.execute('''
 local c=Stage1Context.card();assert(c.hp==1000 and c.duration==3000)
 local o={x=0,y=96};c.init(o);local first
 for t=0,321 do
  task.Do(o)
  if t==40 then for b in pairs(Stage1Context.state.owned) do first=b;break end
   assert(math.abs(first.echo_speed-0.8)<1e-9,'spawn speed') end
  if t==0 then assert(Stage1Context.state.carrier.vy==0.65,'carrier speed changed') end
  local objects={};for b in pairs(Stage1Context.state.owned)do objects[#objects+1]=b end
  for _,b in ipairs(objects)do if IsValid(b)then
   b.class.frame(b);b.x=b.x+(b.vx or 0);b.y=b.y+(b.vy or 0)
  end end
  if t==159 then assert(math.abs(first.echo_speed-(1.2+120/60)*2/3)<1e-8,'acceleration ratio') end
 end
 assert(first.mode=='linear' and IsValid(first),'release/survival')
 assert(math.abs(math.sqrt(first.vx^2+first.vy^2)-(1.2+120/60)*2/3)<1e-8,'release velocity')
 assert(Stage1Context.state.stats.spawned==175,'density changed');c.del(o)
 ''')
 print(backend+': silent BGM / HP787.5 / spawn, acceleration, release speed2/3 PASS')
