from pathlib import Path
import importlib,json,math
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';out=[]
for backend in ('luajit21','lua51','lua54'):
 l=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 l.globals().Stage2FileExists=lambda p:(M/p).is_file()
 l.execute((R/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
 l.globals().Include=lambda p:l.execute((M/p).read_text(encoding='utf-8'))
 l.execute('LoadAnimation=function()end;SetAnimationCenter=function()end;COLOR_PURPLE=6;COLOR_CYAN=8;player={x=0};setting.mystia_note_test=true;lstg={Snapshot=function()end}')
 l.execute((M/'mystia/attack.lua').read_text(encoding='utf-8'))
 l.execute('''
 local api=Stage2Mystia
 for _,color in ipairs({'red','purple','blue','cyan'}) do
  api.reset();api.emitRing(0,0,color=='red' and 1.5 or 0.75,-90,color=='red' and 'red' or 'blue',color)
  local n,cx,cy=0,0,0
  for b in pairs(api.state.owned) do
   n=n+1;cx=cx+b.x;cy=cy+b.y
   assert(b.img=='mystia.note.'..color and b.a==3.6 and b.b==3.6 and not b.rect and b.rot==-90 and b.hscale==0.9 and b.vscale==0.9)
   assert(math.abs(math.sqrt(b.x*b.x+b.y*b.y)-10)<1e-7)
  end
  assert(n==5 and math.abs(cx)<1e-7 and math.abs(cy)<1e-7)
  for t=0,70 do
   for b in pairs(api.state.owned)do b.class.frame(b);b.x=b.x+b.vx;b.y=b.y+b.vy end
  end
  local count=0;for b in pairs(api.state.owned)do count=count+1 end;assert(count==5,'premature fade')
  local one;for b in pairs(api.state.owned)do one=b;break end
  Kill(one);count=0;for b in pairs(api.state.owned)do count=count+1 end;assert(count==4,'one note clears entire ring')
  api.clean();assert(next(api.state.owned)==nil,'Bomb/card cleanup')
 end
 api.reset()
 local boss=New(api.Boss)
 for t=0,3599 do
  boss.class.frame(boss)
  for b in pairs(api.state.owned) do b.class.frame(b);b.x=b.x+b.vx;b.y=b.y+b.vy end
 end
 assert(api.state.shots==2192 and api.state.notes==2192*5 and api.state.red==1096 and api.state.blue==1096)
 assert(api.state.moves==17 and api.state.moveChecks==680 and api.state.movingShots==544)
 assert(next(api.state.owned)==nil,'timeout cleanup')
 ''')
 # Independent union-of-circles sampling: central safe disk and24pxouter envelope.
 centers=[(10*math.cos(k*math.tau/5),10*math.sin(k*math.tau/5)) for k in range(5)]
 hit=lambda x,y:any((x-a)**2+(y-b)**2<=3.6**2+1e-9 for a,b in centers)
 assert not hit(0,0) and hit(10,0) and hit(13.6,0) and not hit(13.7,0)
 assert all(not hit(r*math.cos(a),r*math.sin(a)) for r in (0,2,4,5.5) for a in (k*math.tau/100 for k in range(100)))
 events=l.globals().MystiaAyaPattern.events
 assert len(events(180))==4 and len(events(181))==0 and len(events(335))==4 and len(events(340))==0
 for e in events(180).values():
  assert e['speed']==(1.5 if e['color']=='red' else 0.75)
 assert all(e['xOffset'] is None for e in events(180).values())
 # Compare each emitted angle/quantity against source Boss2_at2/at3 formulas.
 sequence=[]
 for t in range(3600):
  now=list(events(t).values());r=t-180
  active=r>=0 and r%200<=155 and r%200%5==0
  assert len(now)==(4 if active else 0)
  if active:
   n=(r%200)/5
   for i,e in enumerate(now):
    red=i<2;j=i if red else i-2
    expected=-(0.628319+n*0.314159-j*3.1415927 if red else 2.356194-n*0.314159-j*3.1415927)*180/math.pi
    assert abs(e['angle']-expected)<1e-9
    assert e['speed']==(1.5 if red else 0.75)
    if not red:sequence.append(e['noteColor'])
 assert sequence==(['purple','blue','cyan','blue']*274)

 out.append({'backend':backend,'rings':2192,'notes':10960,'center_hollow':True,'outer_diameter':27.2,'individual_kill':True,'center_trajectory':True,'unchanged_emission_and_motion':True,'timeout_cleanup':True})
 print(backend+':2192rings/10960notes; 27.2px hollow/individual collision; Boss2 trajectories/palette/movement/cleanup PASS')
(R/'work/logs/stage12/notes/unit.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
