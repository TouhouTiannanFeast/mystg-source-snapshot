"""Execute full and defeated-card routes; independently check source and assets."""
from pathlib import Path
import json,hashlib,importlib,sys,site,re,math,wave
sys.path.append(site.getusersitepackages())
from PIL import Image,ImageDraw
ROOT=Path('G:/MySTG');MOD=ROOT/'aex-0.8.22/game/mod/Stage2Full';LOG=ROOT/'work/logs/stage2-full'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ref=json.loads((MOD/'reference.json').read_text(encoding='utf-8'))
assert sha(Path(ref['th10_source']))==ref['th10_sha256']
for a in ref['assets']:
 assert sha(Path(a['path']))==a['sha256']
 assert sha(MOD/a['out'])==a['output_sha256']
for c in ref['components']:
 assert sha(Path(c['source']))==c['source_sha256']
magic=json.loads((MOD/'source/magic-reference.json').read_text(encoding='utf-8'))
assert sha(Path(magic['source']))==magic['source_sha256']
for row in magic['assets']:
 assert sha(Path(row['source']))==row['sha256']
 assert sha(MOD/row['out'])==row['output_sha256']
music=json.loads((MOD/'source/music-reference.json').read_text())
assert music['track']=='th10_03.wav'
assert sha(MOD/music['output'])==music['output_sha256']
with wave.open(str(MOD/music['output'])) as w:
 assert (w.getnchannels(),w.getsampwidth(),w.getframerate())==(2,2,44100)
 assert w.getnframes()*4==music['pcm_bytes']
 assert abs(w.getnframes()/44100-music['loop_end'])<1e-9
assert 0<music['loop_length']<music['loop_end']
matches=[];results=[];frames=[]
for backend in ('luajit21','lua51','lua54'):
 Lua=importlib.import_module('lupa.'+backend).LuaRuntime
 lua=Lua(unpack_returned_tuples=True)
 for p in MOD.rglob('*.lua'):
  loader=lua.eval('loadstring or load');out=loader(p.read_text(encoding='utf-8'),'@'+str(p));assert not isinstance(out,tuple) or out[0],out
 for mode in ('timeout','kill') if backend=='luajit21' else ('kill',):
  lua=Lua(unpack_returned_tuples=True)
  lua.globals().Stage2FileExists=lambda path:(MOD/path).is_file()
  lua.execute((ROOT/'scripts/stage2-full/harness.lua').read_text())
  def include(path):
   if path=='THlib.lua':return
   lua.execute((MOD/path).read_text(encoding='utf-8'))
  lua.globals().Include=include
  if backend=='luajit21' and mode=='timeout':
   def sink(phase,t,objects,images):
    rows=[]
    for o in objects.keys():
     name=o.img
     if name and -270<o.x<270 and -300<o.y<360:
      im=images[name];rect=[im.rect[i] for i in range(1,5)]
      rows.append(dict(x=o.x,y=o.y,rot=(o.angle+90 if o.kind=='water-laser' else o.age*1.5 if o.img=='s2.magic.circle' and o.age is not None else o.rot or 0),sx=(6/16 if o.kind=='water-laser' else 0.65 if o.img=='s2.magic.circle' else 1),sy=(o.length/14 if o.kind=='water-laser' else 0.65 if o.img=='s2.magic.circle' else 1),path=im.path,rect=rect))
    frames.append(dict(phase=phase,t=t,objects=rows))
   lua.globals().Stage2FrameSink=sink
  include('root.lua')
  lua.execute('''
   local menu=setmetatable({},{__index=ext.pausemenu})
   PlayMusic('s2.dark-road',1);menu:PauseSound();assert(GetMusicState('s2.dark-road')=='paused')
   menu:ResumeSound();assert(GetMusicState('s2.dark-road')=='playing')
   menu:PauseSound();StopMusic('s2.dark-road');menu:ResumeSound();assert(GetMusicState('s2.dark-road')=='stopped')
   assert(Stage2Mamizou.cards[4].hp==1050,'second spell HP')
   assert(not pcall(function()Angle({x=0,y=0},player)end),'Angle accepts non-engine table')
     local o=Stage2Route.spawn({name='BGirl00B',t=200,x=0,y=-16,hp=30,mirror=false})
   assert(o.emit==nil,'mock incorrectly exposes class helpers');assert(not pcall(function()o:emit()end),'native crash regression absent');o.class.frame(o)
     assert(o.hp==8,'basic HP scaling');for i=1,4 do o.class.colli(o,{dmg=2})end;assert(o.hp==0,'ordinary enemy is invulnerable');o.class.frame(o);assert(not IsValid(o),'ordinary enemy did not die')
   local seed=New(Stage2Route.Seed,0,112,'GSpCir00')
   assert(not pcall(function()enemy.render(seed)end),'native animation precondition missing');seed.class.render(seed)
     Damage(seed,50);assert(seed.hp==13,'seed opening protection missing')
   for i=0,76 do seed.class.frame(seed) end
   for i=1,7 do seed.class.colli(seed,{dmg=2})end;assert(seed.hp<=0,'seed damage hook missing');seed.class.frame(seed);assert(not IsValid(seed))
   local sun=Stage2Route.spawn({name='Girl01',t=4114,x=0,y=100,hp=400,mirror=false})
   for i=1,31 do sun.class.frame(sun)end
   assert(sun.hp==100,'sunflower HP scaling');for i=1,50 do sun.class.colli(sun,{dmg=2})end
   sun.class.frame(sun);assert(not IsValid(sun),'sunflower cannot be shot down')
   local source={x=0,y=112,valid=true}
   local fire=New(Stage2Flare.Shot,0,0,0.3,0,0.015,COLOR_RED,source)
   assert(math.abs(fire.speed-0.2)<1e-9 and math.abs(fire.acc-0.01)<1e-9,'Flare initial speed scale')
   for i=1,100 do fire.class.frame(fire)end
   assert(math.abs(fire.speed-1.2)<1e-9,'Flare accelerated speed scale');Del(fire);Stage2Flare.reset()
   Stage2Route.clean()
   local anchor=New(Stage2Route.Hina)
   for i=0,92 do anchor.class.frame(anchor)end
   local mirrored
   for o in pairs(Stage2HarnessObjects)do if o.class==Stage2Route.Seed then mirrored=o end end
   assert(mirrored and math.abs(mirrored.x+anchor.x)<1e-9,'seed birth is not mirrored')
   assert(not anchor.img,'hidden passage anchor exposes Patchouli sprite')
   assert(mirrored.img=='s2.magic.circle','first wave circle sprite')
   Stage2Route.clean()
   local turning=New(Stage2Route.Shot,0,200,3,-90,'s2.bullet-67',{turn=30})
   for i=1,90 do turning.class.frame(turning)end
   assert(math.abs(turning.y-63.5)<1e-7,'pre-turn travel must decelerate')
   assert(turning.img=='s2.bullet-67','yellow turn too early')
   turning.class.frame(turning)
   assert(turning.img=='s2.bullet-77' and turning.a==2 and turning.b==2 and turning.speed==1.8,'yellow turn state')
   assert(math.abs(turning.angle+60)<1e-9,'source turn offset')
   Del(turning)
   local emitter=New(Stage2Route.Hina)
   Stage2Route.lasers=0
   local savedX=player.x;local headings={};local spawnTimes={}
   for age=0,1761 do
    if age==1089 then player.x=-90 elseif age==1094 then player.x=0 elseif age==1099 then player.x=90 end
    for o in pairs(Stage2HarnessObjects)do if o.class==Stage2Route.Seed then o.class.frame(o)end end
    emitter.class.frame(emitter)
    for beam in pairs(Stage2HarnessObjects)do
     if beam.class==Stage2Magic.Laser and not beam.probed then
      beam.probed=true;spawnTimes[#spawnTimes+1]=age
      local found=false
      for o in pairs(Stage2HarnessObjects)do if o.class==Stage2Route.Seed and o.book and o.x==beam.originX and o.y==beam.originY then found=true end end
      assert(found,'laser must originate from a living book')
      assert(math.abs(beam.speed-8/3)<1e-9,'laser speed scale')
      if #headings<3 then headings[#headings+1]=beam.angle end
      local original=beam.angle;beam.class.frame(beam);assert(beam.angle==original,'laser homes after firing')
     end
    end
   end
   assert(Stage2Route.circleSeeds==20,'circle count must increase by4')
   assert(Stage2Route.laserRounds==15 and Stage2Route.lasers==45,'laser round count changed')
   assert(spawnTimes[2]-spawnTimes[1]==5 and spawnTimes[4]-spawnTimes[1]==30,'laser cadence')
   assert(headings[1]~=headings[2] and headings[2]~=headings[3],'per-shot aiming lost')
   player.x=savedX;Stage2Route.clean()
   local book=New(Stage2Route.Seed,0,112,'BSpCir01')
   for i=0,96 do book.class.frame(book)end
   assert(book.img:find('s2.magic.book',1,true),'book sprite')
   local papers=0
   for o in pairs(Stage2HarnessObjects)do if o.class==Stage2Route.Shot and o.img=='s2.magic.paper6' then papers=papers+1;assert(math.abs(o.speed-4/3)<1e-9,'paper speed scale') end end
   assert(papers==5,'paper fan must preserve five shots')
   Stage2Route.clean()
   local beam=New(Stage2Magic.Laser,0,0,0)
   for i=1,36 do beam.class.frame(beam)end
   assert(beam.x==48 and beam.length==96 and beam.a==48 and beam.b==1.5 and beam.rect,'laser geometry/hitbox')
   beam.class.frame(beam);assert(math.abs(beam.x-(48+8/3))<1e-9 and beam.length==96,'moving96px laser tail')
   beam.class.render(beam);Del(beam);assert(not Stage2Route.owned[beam],'laser cleanup')
   local entry=New(Stage2Magic.Entry,0,134)
   for i=1,60 do entry.class.frame(entry)end
   entry.class.render(entry)
   for i=61,120 do entry.class.frame(entry)end
   assert(not IsValid(entry),'entry effect leaked')
   for _,cls in ipairs({Stage2Mamizou.Boss,Stage2Flare.Boss,Stage2Mystia.Boss})do
    local b=New(cls);b.class.frame(b);assert(b.a>0 and b.b>0,'boss hitbox lost')
    local hp=b.hp;b.class.colli(b,{dmg=10});assert(b.hp<hp,'boss collision cannot damage');Del(b)
   end
  ''')
  if backend=='luajit21' and mode=='timeout':
   entry_rows=[]
   def render_sink(name,x,y,rot,sx,sy):
    im=lua.globals().Stage2HarnessImages[name]
    entry_rows.append(dict(x=x or 0,y=y or 0,rot=rot or 0,sx=sx or 1,sy=sy or 1,path=im.path,rect=[im.rect[i] for i in range(1,5)]))
   lua.globals().Stage2RenderSink=render_sink
   lua.execute("local fx=New(Stage2Magic.Entry,0,134);for i=1,60 do fx.class.frame(fx)end;fx.class.render(fx);Stage2Flare.Boss.render({_bosssys={render=function()end},x=0,y=134});Del(fx)")
   lua.globals().Stage2RenderSink=None
   frames.append(dict(phase='Patchouli entry (callback)',t=60,objects=entry_rows))
  # Shoot using the actual primary-shot damage/cadence, through collision callbacks.
  # One of two 2-damage bullets every4frames represents50% primary-shot hits.
  lua.execute("""
   for _,cards in ipairs({Stage2Mamizou.cards,{Stage2Flare.card},{Stage2Mystia.card}})do
    for _,c in ipairs(cards)do
     local o={class={base=boss},hp=c.hp,protect=false}
     local t=0;local effective=0
     while o.hp>0 and t<c.duration do
      if t>=120 and t%4==0 then
       local factor=math.min(1,(t-120)/120)
       enemybase.colli(o,{dmg=2*factor});effective=effective+2*factor
      end
      t=t+1
     end
     assert(o.hp<=0,'boss cannot be defeated at50% main-shot hits')
     assert(t<c.duration*0.8,'boss damage budget lacks timeout margin')
     print(string.format('BOSS DAMAGE BUDGET hp=%d kill_seconds=%.2f limit_seconds=%.2f',c.hp,t/60,c.duration/60))
    end
   end
  """)
  # Independently confirm the embedded route is the pinned spawn list.
  expected=json.loads((MOD/'source/route-events.json').read_text())
  schedule=lua.globals().Stage2Schedule
  assert len(schedule)==len(expected)==162
  for i,e in enumerate(expected,1):
   q=schedule[i];assert q.t==e['t'] and q.name==e['name'] and q.x==e['x'] and q.y==e['y'] and q.hp==e['hp']
  report,log=lua.globals().Stage2HarnessRun(mode)
  result=json.loads(report);result['backend']=backend;results.append(result)
  (LOG/f'{backend}-{mode}.log').write_text(log+'\n',encoding='utf-8')
  print(result,flush=True)
out=dict(status='passed',scope='actual integrated callbacks in a stub host; native parity and visual playtest pending',results=results)
(LOG/'result.json').write_text(json.dumps(out,indent=2)+'\n')
(LOG/'frames.json').write_text(json.dumps(frames,indent=2)+'\n')
sheet=Image.new('RGB',(384*len(frames),480),(18,20,29));d=ImageDraw.Draw(sheet)
for k,f in enumerate(frames):
 panel=Image.new('RGB',(384,448),(18,20,29))
 for o in f['objects']:
  im=Image.open(MOD/o['path']).convert('RGBA');x,y,w,h=o['rect'];im=im.crop((x,y,x+w,y+h))
  if o.get('sx',1)!=1 or o.get('sy',1)!=1:im=im.resize((max(1,round(im.width*o['sx'])),max(1,round(im.height*o['sy']))),Image.Resampling.BICUBIC)
  if o['rot']:im=im.rotate(o['rot'],expand=True,resample=Image.Resampling.BICUBIC)
  panel.paste(im,(round(192+o['x']-im.width/2),round(224-o['y']-im.height/2)),im)
 sheet.paste(panel,(384*k,0));d.text((384*k+8,456),f['phase'],fill='white')
d.text((8,470),'Headless callback preview; native scene and appearance still need playtest',fill=(170,180,195))
sheet.save(LOG/'preview.png')
