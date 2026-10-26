from pathlib import Path
import importlib
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal'
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.execute((r/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 lua.globals().dofile=lambda p:lua.execute((r/'aex-0.8.22/game'/p).read_text(encoding='utf-8'))
 lua.execute("CopyImage=function()end;COLOR_CYAN=6;COLOR_PURPLE=5;arrow_small={init=function(o,col)o.img='arrow_small'..col end};th14={stats={phases=0,ended=0},stage_frames=0,clean_bullets=function()end,clean_actors=function()end};setting={}")
 lua.execute((m/'character-animation.lua').read_text(encoding='utf-8'))
 lua.execute((m/'stage1/context.lua').read_text(encoding='utf-8'))
 lua.execute('''
 local c=Stage1Context.card();assert(c.hp==1000 and c.duration==3000)
 local o={x=0,y=96};c.init(o)
 player.x=180
 local saved
 for t=0,400 do
  task.Do(o)
  local carrier=Stage1Context.state.carrier
  if t==0 then assert(carrier.x==0 and carrier.vx==0 and carrier.vy==0.65 and math.abs(carrier.y-28.65)<1e-6,'first rectangle must start centred and go up') end
  if t==200 then player.x=-180;assert(carrier.vx==0 and carrier.vy==0.65,'first heading followed player') end
  if t==400 then assert(carrier.vx>0,'later rectangle must aim away from current player') end
  local objects={};for b in pairs(Stage1Context.state.owned)do objects[#objects+1]=b end
  for _,b in ipairs(objects)do
   if IsValid(b)then b.class.frame(b);b.x=b.x+(b.vx or 0);b.y=b.y+(b.vy or 0) end
  end
  if t==399 then
   for b in pairs(Stage1Context.state.owned)do if b.mode=='linear' then saved=b;break end end
   assert(saved,'no released arrows');saved.x,saved.y=0,0;saved.travel_x,saved.travel_y=0,0;saved.age=500
  end
 end
 assert(IsValid(saved) and Stage1Context.state.owned[saved],'old cycle arrow deleted')
 assert(saved.mode=='linear' and saved.x==0 and saved.y==0,'old arrow recaptured/carried')
 assert(Stage1Context.state.stats.spawned==175,'seven arcs must contain25arrows each')
 c.del(o);assert(next(Stage1Context.state.owned)==nil and not IsValid(saved),'final cleanup failed')
 ''')
 print(backend+': prior-cycle survival/no recapture/25 per arc/HP1000/end cleanup PASS')
