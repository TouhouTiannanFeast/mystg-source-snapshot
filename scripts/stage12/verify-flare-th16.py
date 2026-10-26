from pathlib import Path
import importlib,json,hashlib
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';ref=json.loads((M/'source/player/flare-th16-reference.json').read_text(encoding='utf-8'));old=Path(ref['backup_attack']).read_text(encoding='utf-8');new=(M/'flare/attack.lua').read_text(encoding='utf-8');results=[]
assert hashlib.sha256((M/'flare/th16-flame-local.png').read_bytes()).hexdigest()==ref['texture_sha256']
# The entire emitter/Boss/card program remains byte identical to the saved version.
assert old[old.index('-- Royal Flare Sub23:'):]==new[new.index('-- Royal Flare Sub23:'):]
for backend in ('luajit21','lua51','lua54'):
 signatures=[]
 for source,changed in ((old,False),(new,True)):
  l=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
  l.globals().Stage2FileExists=lambda p:(M/p).is_file()
  l.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
  l.execute(source)
  l.globals().Changed=changed
  proof=l.execute('''
  local api=Stage2Flare;api.reset();local births={};local serial=0;local tick=0
  local create=New
  New=function(c,...)
   local args={...};local o=create(c,...)
   if c==api.Shot then
    serial=serial+1;o.testID=serial
    births[serial]={tick,args[1],args[2],args[3],args[4],args[5],args[6]}
   end
   return o
  end
  local b=New(api.Boss);local frames={}
  for t=0,2939 do
   tick=t;b.class.frame(b)
   local sx,sy,svx,svy,n=0,0,0,0,0
   for o in pairs(api.state.owned)do
    o.class.frame(o)
    if IsValid(o)then
     o.x=o.x+o.vx;o.y=o.y+o.vy;o.class.render(o)
     if Changed then
      assert(o.a==6 and o.b==6 and not o.rect and o.hscale==1 and o.vscale==1)
      assert(o.img=='flare.fire'..(math.floor((o.age-1)/3)%4+1))
     end
     sx=sx+math.floor(o.x*100000)*o.testID;sy=sy+math.floor(o.y*100000)*o.testID
     svx=svx+math.floor(o.vx*100000)*o.testID;svy=svy+math.floor(o.vy*100000)*o.testID;n=n+1
    end
   end
   frames[t+1]={sx,sy,svx,svy,n,b.x,b.y}
  end
  assert(next(api.state.owned)==nil,'cleanup leak')
  return {births=births,frames=frames,shots=api.state.shots}
  ''')
  def array(table):return [[v[i] for i in range(1,len(v)+1)]for v in table.values()]
  signatures.append({'births':array(proof.births),'frames':array(proof.frames),'shots':proof.shots})
 assert signatures[0]==signatures[1],'nonvisual behavior changed: '+backend
 results.append({'backend':backend,'shots':signatures[1]['shots'],'spawn_arguments_exact':True,'2940_frame_trajectory_velocity_and_boss_position_exact':True,'source_texture_hash':True,'radius':6,'frames':4,'frame_period':3,'cleanup':True})
 print(backend+': old/new fullcard spawn/trajectory/velocity/Boss equality; source radius6/animation3; cleanup PASS')
(R/'work/logs/stage12/flare-th16/unit.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
