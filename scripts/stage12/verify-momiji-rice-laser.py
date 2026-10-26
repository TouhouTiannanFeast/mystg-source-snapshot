from pathlib import Path
import json,importlib,math
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';results=[]
for backend in ('luajit21','lua51','lua54'):
 for life in (3600,900):
  l=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
  l.globals().Stage2FileExists=lambda p:(M/p).is_file()
  l.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
  l.globals().Include=lambda p:l.execute((M/p).read_text(encoding='utf-8'))
  l.execute('''
  soundCalls=0;LoadSound=function(n,p)assert(Stage2FileExists(p))end;PlaySound=function(n,v,pan)assert(n=='momiji.th143.kira00');soundCalls=soundCalls+1 end
  COLOR_DEEP_RED=1;COLOR_RED=2;COLOR_BLUE=6;COLOR_GRAY=16
  ball_mid={init=function(o)o.img='medium';o.a=4;o.b=4 end}
  grain_a={init=function(o)o.img='rice';o.a=2.5;o.b=2.5 end};arrow_big={init=function(o)o.img='scale';o.a=2.5;o.b=2.5 end}
  Stage12Art={bullet=function(o,f,c)o.img=f;o.stage12BulletFamily=f end}
  th14={stats={phases=0,ended=0},clean_bullets=function()end,clean_actors=function()end,stage_frames=0}
  laser_bent_renderFunc={};laser_bent_renderFuncDeath={}
  laser_bent={init=function(o,c,x,y,len,width,sample,node)o.x=x;o.y=y;o.l=len;o.w=width;o._bound=false end,frame=function()end,del=function()end,kill=function()end}
  -- With all aim switches disabled, even a call to the aim helper is an error.
  Angle=function()error('hidden aim still called')end
  ''')
  l.execute((M/'stage1/momiji-pattern.lua').read_text(encoding='utf-8'))
  l.execute((M/'stage1/momiji.lua').read_text(encoding='utf-8'))
  l.globals().Life=life
  data=l.execute('''
  local api=Stage1Momiji;local b=New(api.Boss)
  assert(b.hp==900,'HP');local medium,small=0,0;local pulses={}
  local speeds={};local births=0;local create=New
  New=function(c,...)
   local o=create(c,...)
   if c==api.Shot then
    assert(o.kind~='gun');assert(MomijiPattern.inside(o.x,o.y,o.fanX,o.fanY,o.fanCenter,o.fanHalf))
    if o.kind=='scale' then
     assert(o.fanHalf==155)
     if o.medium then medium=medium+1;assert(o.img=='momiji.th10.medium' and o.a==8 and o.b==8)else small=small+1;assert(o.img=='medium' and o.a==4)end
    end
    if o.kind=='rice' then local v=math.sqrt(o.vx*o.vx+o.vy*o.vy);assert(v>=1 and v<=1.7);speeds[#speeds+1]=v end
    births=births+1
   elseif c==api.Laser then
    assert(o.l==60 and o.w==28);local tick=api.state.tick;pulses[tick]=(pulses[tick] or 0)+1
    local pulse=api.state.tick-o.window.start;assert(pulse>=15 and pulse<=115 and (pulse-15)%20==0,'laser birth offset')
    assert(math.abs(MomijiPattern.wrap(o.angle-90))<155)
   end
   return o
  end
  for t=0,Life-1 do
   player.x=100*math.sin(t/12);player.y=-160
   b.class.frame(b)
   assert(b.x>=-140 and b.x<=140 and b.y>=28 and b.y<=128,'movement bounds')
   if t==239 then assert(math.abs(b.x)>0.01,'Boss never moved')end
   local objects={};for o in pairs(api.state.owned)do objects[#objects+1]=o end
   for _,o in ipairs(objects)do if IsValid(o)then
    o.class.frame(o)
    if IsValid(o)then
     o.x=o.x+(o.vx or 0);o.y=o.y+(o.vy or 0)
     if o.class==api.Shot then assert(MomijiPattern.inside(o.x,o.y,o.fanX,o.fanY,o.fanCenter,o.fanHalf)) end
    end
   end end
  end
  if IsValid(b) then b.hp=0;b.class.frame(b) end
  assert(next(api.state.owned)==nil,'owned laser/rice leak')
  local low,high=10,0;for _,v in ipairs(speeds)do low=math.min(low,v);high=math.max(high,v)end
  assert(low<1.1 and high>1.6,'source randomness lost')
  assert(small==0 and medium>0,'all medium waves');local d=api.state;assert(soundCalls==d.rounds*6,'sound once per volley');for tick,count in pairs(pulses)do local pulse=(tick-MomijiPattern.start)%MomijiPattern.echoInterval;assert(count==((pulse==15 or pulse==75) and 8 or 5),'per pulse count')end
  return {rice=d.rice,scale=d.scale,lasers=d.lasers,rounds=d.rounds,gun=d.gun,bounces=d.bounces,randomLow=low,randomHigh=high}
  ''')
  expected=(2400,1872,13)if life==3600 else(600,432,3)
  assert (data.rice,data.scale,data.rounds)==expected and data.lasers==data.rounds*36 and data.gun==0 and data.bounces==0
  # Reversible fan aim and individual laser branches remain callable.
  l.execute('''
  MomijiAimConfig.aimFans=true;Angle=function()return 12 end
  assert(MomijiPattern.front({}, {})==12)
  MomijiAimConfig.directLaser=true
  assert(#MomijiPattern.laserAngles(90,90,function(a,b)return(a+b)/2 end)==12)
  MomijiAimConfig.directLaser=false
  assert(#MomijiPattern.laserAngles(90,90,function(a,b)return(a+b)/2 end)==11)
  ''')
  results.append({'backend':backend,'life':life,**dict(data.items()),'cone_bounds':True,'all_aim_off':True,'restoration_flags':True,'cleanup':True})
  print(backend+':'+str(life)+'frames rice='+str(data.rice)+' scale='+str(data.scale)+' lasers='+str(data.lasers)+' cone/randomness/aimflags/cleanup PASS')
(R/'work/logs/stage12/momiji-rice-laser/unit.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
