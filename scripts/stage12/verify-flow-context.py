from pathlib import Path
import importlib,math
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal'
for backend in ('luajit21','lua51','lua54'):
 L=importlib.import_module('lupa.'+backend).LuaRuntime
 l=L(unpack_returned_tuples=True);l.globals().Stage2FileExists=lambda p:(M/p).is_file();l.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'));l.execute((M/'flare/attack.lua').read_text(encoding='utf-8'))
 l.execute('''
 Stage2Flare.reset();setting.flare_test=false
 local source={x=0,y=112,valid=true}
 for _,angle in ipairs({0,90,180,-90,37})do
  local b=New(Stage2Flare.Shot,0,0,.3,angle,.015,COLOR_RED,source)
  for t=1,8 do
   local oldx,oldy=b.x,b.y;source.x=source.x+2;source.y=source.y-3
   b.class.frame(b);b.x=b.x+b.vx;b.y=b.y+b.vy;b.class.render(b)
   local dx,dy=b.x-oldx,b.y-oldy;local len=math.sqrt(dx*dx+dy*dy)
   assert((cos(b.rot+90)*dx+sin(b.rot+90)*dy)/len>.999999,'sprite +Y head not tangent')
  end
  Del(b)
 end
 ''')
 # Real route coroutine with early and timeout bosses, using original schedule.
 for life in (10,300,2940):
  f=L(unpack_returned_tuples=True)
  f.execute('''unpack=unpack or table.unpack;wall=0;objects={};setting={stage12_entry='s2-flare'};ran={Float=function(s,a,b)return(a+b)/2 end};Class=function(b)return{}end;object={};Include=function()end;GROUP_GHOST=0;LAYER_TOP=0;EnumRes=function()return{},{}end;StopMusic=function()end;task={Wait=function(n)coroutine.yield(n)end};
  Stage2Route={enemies={},clean=function()end,spawn=function(e)table.insert(objects,{wall=wall,t=e.t,name=e.name})end};Stage2Route.hina=function()return{expires=wall+10}end;
  Stage12Music={stop=function()end,play=function()end};Stage12Background={start=function()end};Stage2Flare={Boss='flare',reset=function()end,clean=function()end};Stage2Magic={Entry='entry'};Stage2Mystia={Boss='mystia',reset=function()end,clean=function()end};Stage2Mamizou={Boss='mamizou',reset=function()end,clean=function()end};Stage12Tail={run=function(b,s,a,w,r)while a(b)do w(1)end;r.finalTail=6;r.finalTailCleared=true end};
  IsValid=function(o)return o and o.expires and wall<o.expires end;New=function(c,...)if c=='flare'then return{expires=wall+bosslife}elseif c=='mystia'or c=='mamizou'then return{expires=wall+10}else return{}end end''')
  f.globals().bosslife=life;f.execute((M/'schedule.lua').read_text(encoding='utf-8'));f.execute((M/'stage2-run.lua').read_text(encoding='utf-8'));f.execute('''local co=coroutine.create(function()Stage2FullRun({})end);while coroutine.status(co)~='dead'do local ok,n=coroutine.resume(co);assert(ok,n);if n then wall=wall+n end;assert(wall<20000)end''')
  rows=[e for e in f.globals().objects.values() if e.t>=2974 and e.t<4964];base=60+life+60
  assert rows[0].wall==base,(backend,life,rows[0].wall,base)
  assert all(e.wall-base==e.t-2974 for e in rows)
 print(backend+': flame actual +Y head follows moving flight tangent; early/300/timeout boss relative wave intervals PASS')
 # Seeded stratification and emitter-follow tests.
 signatures=[]
 for seed in (123,123,456):
  c=L(unpack_returned_tuples=True);c.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'));c.globals().dofile=lambda p:c.execute((R/'aex-0.8.22/game'/p).read_text(encoding='utf-8-sig'));c.globals().seed=seed
  c.execute("CopyImage=function()end;COLOR_CYAN=6;COLOR_PURPLE=5;arrow_small={init=function(o,col)o.img='arrow_small'..col end};th14={stats={phases=0,ended=0},stage_frames=0,clean_bullets=function()end,clean_actors=function()end};setting={};ran.Float=function(s,a,b)seed=(seed*48271)%2147483647;return a+(b-a)*seed/2147483647 end")
  c.execute((M/'character-animation.lua').read_text(encoding='utf-8'));c.execute((M/'stage1/context.lua').read_text(encoding='utf-8'))
  vals=c.execute('''
  local card=Stage1Context.card();local o={x=0,y=96};card.init(o);local out={};local release
  for t=0,400 do
   task.Do(o);local st=Stage1Context.state
   assert(o.x==st.emitterX and o.y==st.emitterY,'boss not standing on emitter')
   if t==40 then for b in pairs(st.owned)do assert(b.x==o.x and b.y==o.y,'spawn not on boss')end end
   if t==320 then
    assert(st.stats.release_count==175);local r=dofile('mod/Stage12Normal/stage1/context-geometry.lua').translate(dofile('mod/Stage12Normal/stage1/context-geometry.lua').echo_rect(t),st.carrier.x,st.carrier.y)
    local bins={};for b in pairs(st.owned)do
     local index=math.floor((b.x-r.l-8)/(r.r-r.l-16)*175)+1;assert(index>=1 and index<=175 and not bins[index],'uneven release cell');bins[index]=true;out[b.serial]=b.x
    end
   end
   local objects={};for b in pairs(st.owned)do objects[#objects+1]=b end
   for _,b in ipairs(objects)do if IsValid(b)then b.class.frame(b);b.x=b.x+(b.vx or 0);b.y=b.y+(b.vy or 0)end end
  end
  card.del(o);assert(next(Stage1Context.state.owned)==nil);return out
  ''');signatures.append([vals[i] for i in range(1,176)])
 assert signatures[0]==signatures[1] and signatures[0]!=signatures[2]
 print(backend+': Boss/emitter exact following,175 unique release bins, seeded randomness and cleanup PASS')


