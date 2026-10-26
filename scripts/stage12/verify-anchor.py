from pathlib import Path
import importlib,json,math
r=Path('G:/MySTG');m=r/'aex-0.8.22/game/mod/Stage12Normal';oracle=json.loads((r/'work/research/stage12-anchor/original-oracle.json').read_text())
for backend in ('luajit21','lua51','lua54'):
 for original in (True,False):
  lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
  lua.globals().Stage2FileExists=lambda p:(m/p).exists()
  lua.execute((r/'scripts/stage2-full/harness.lua').read_text(encoding='utf-8'))
  lua.globals().dofile=lambda p:lua.execute((r/'aex-0.8.22/game'/p).read_text(encoding='utf-8-sig'))
  lua.execute("ball_mid={init=function(o)end};PlaySound=function()end;th14={owned={},stats={phases=0,ended=0},track=function(o)th14.owned[o]=true;return o end,rand=function(a,b)return (a+b)/2 end}")
  lua.globals().setting.stage12_anchor_original=original
  lua.execute((m/'stage1/anchor.lua').read_text(encoding='utf-8-sig'))
  P=lua.globals().Stage1Anchor.pattern;profile=lua.globals().Stage1Anchor.state.profile
  for v in oracle['spawn']:
   if v['count']==2:
    rows=P.trail(.7*180/math.pi-180, int(.4/.19635)*4,profile)
    assert abs(rows[1+v['layer']*2+v['side']].speed-v['speed']*profile.trail_speed_scale)<1e-6
  for t,v in enumerate(oracle['traces']['vector']):assert abs(P.medium_speed(.8*profile.trail_speed_scale,.05*profile.trail_speed_scale,60+t)-v*profile.trail_speed_scale)<1e-5
  for t,v in enumerate(oracle['traces']['lerp']):
   expected=v+(.06*profile.speed_scale-.06)*(t+1)/60
   assert abs(P.impact_speed(1.5,t,profile)-expected)<1e-5
  for age in (0,40,80,160):assert abs(P.speed(age,profile)-7*min(age/80,1)**4*profile.speed_scale)<1e-9
  original_rows=P.trail(23,48,P.profile(True));tuned_rows=P.trail(23,48,P.profile(False))
  for i in range(1,9):
   assert abs(tuned_rows[i].speed/original_rows[i].speed-1/2)<1e-9
   assert abs(tuned_rows[i].accel/original_rows[i].accel-1/2)<1e-9
  assert sum(bool(P.keep(i,P.profile(False))) for i in range(300))==100
  for v in oracle['bounds']:assert P.outside(v['x'],224-v['y'],v['w'],v['h'])==v['outside'],v
  for v in oracle['move_angles']:
   a=P.move_angle(v['x'],v['y'],v['player_x'],v['random_rad'],v['random_mod3'])
   assert abs(a+v['angle']*180/math.pi)<.001,(v,a)
  lua.execute('''
 local S=Stage1Anchor;local st=S.state;local original=setting.stage12_anchor_original
 st.tick=0;st.stats={anchors=0,impacts=0,faded=0,completed=0,medium=0,burst=0,candidates=0,launch_ticks={}}
 local owner={x=0,y=80,valid=true};local a=New(S.Anchor,owner,-90)
 local flight=0;local hit_tick;local lastx,lasty
 while IsValid(a) do
  st.tick=st.tick+1;a.class.frame(a);a.x=a.x+a.vx;a.y=a.y+a.vy
  if a.state~='outbound' and not hit_tick then hit_tick=st.tick;lastx,lasty=a.x,a.y end
  if hit_tick and not original then assert(a.x==lastx and a.y==lasty,'visible return');if st.tick-hit_tick>=30 then assert(a.hide,'fade visibility')end end
  assert(a.rot==0 and a.rect==true and a.a==48 and a.b==48,'ANM rotation changed source hitbox')
  assert(st.tick<1000,'lifecycle stalled')
 end
 assert(st.tick-hit_tick>100,'original return clock removed')
 assert(st.stats.burst==(original and 10 or 3),'impact count tuning')
 for b in pairs(st.owned)do if b.burst then
  local spawn_y=b.y+4*b.initial*sin(b.angle)
  assert(math.abs(spawn_y-(original and st.lastHit.y+16 or math.max(-184,st.lastHit.y+16-40)))<1e-6,'bottom distribution tuning')
 end end
 assert(st.stats.medium==(original and st.stats.candidates or math.floor((st.stats.candidates+2)/3)))
 if original then assert(st.stats.faded==0) else assert(st.stats.faded==1)end
 local b=New(S.Medium,0,0,0,1.5,0,true)
 assert(b.rect and b.a==2 and b.b==2,'source droplet square collision')
 for t=0,74 do b.class.frame(b);b.x=b.x+b.vx;b.y=b.y+b.vy;assert(b.vy==0,'invented gravity')end
 assert(math.abs(b.speed-(original and .06 or .04))<1e-8)
 b.class.frame(b);assert(b.a==3 and b.b==3,'type4 conversion')
 S.clean();assert(next(st.owned)==nil and next(th14.owned)==nil)
 ''')
  print(backend+': '+('original' if original else 'tuned')+' executable-oracle speeds/movement; full return clock; actual sprite transform; no tuned visible return PASS')

from PIL import Image
for name,texture,box in [('drop','etama8.png',(128,192,144,208)),('small','etama.png',(128,48,144,64)),('birth','etama2.png',(129,209,159,239))]:
 actual=Image.open(m/f'art/anchor/impact-{name}.png').convert('RGBA');expected=Image.open(r/f'work/research/stage12-anchor/bullet/{texture}').crop(box).convert('RGBA')
 assert actual.size==expected.size and actual.tobytes()==expected.tobytes()
s=(m/'stage1/anchor.lua').read_text(encoding='utf-8');assert 'stage12.anchor.streak' not in s and '256,16' not in s
print('TH12 palette sprite callback drop468/small72/birth263 pixels and no laser binding PASS')
