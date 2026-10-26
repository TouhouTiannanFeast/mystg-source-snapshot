from pathlib import Path
import json,re,importlib,math
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';logs=R/'work/logs/stage12/balance'
shots=json.loads((M/'source/balance/shots.json').read_text());s=next(x for x in shots if x['game']==14 and x['path'].endswith('pl00a.sht'));assert s['sets'][1]['main_nominal_dps']==560
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True);lua.globals().dofile=lambda p:lua.execute((R/'aex-0.8.22/game'/p).read_text(encoding='utf-8'));lua.execute('math.atan2=math.atan2 or function(y,x)return math.atan(y,x)end')
 lua.execute((M/'character-animation.lua').read_text(encoding='utf-8'))
 lua.execute('''
 local angleSeen;Render=function(_,x,y,rot)angleSeen=rot end
 local c={render=function()error('old callback used')end};Stage12Art.installBulletRender(c)
 for _,family in ipairs({'arrow','scale','rice','grain'})do
  for a=-180,180,15 do
   local b={img='test',x=0,y=0,rot=123,stage12BulletFamily=family,vx=math.cos(a*math.pi/180),vy=math.sin(a*math.pi/180)}
   setting={};c.render(b)
   assert(math.abs(((angleSeen+90-a+180)%360)-180)<1e-6,'sprite not tangent')
  end
 end
 ''');print(backend+':100 tangent angles + pre-registered rendering callback PASS')
fixed=(logs/'fixed-native.log').read_text(encoding='utf-8');before=(logs/'baseline-native.log').read_text(encoding='utf-8')
for name in ('GirlRedA01','GirlB01','GirlC01','GirlD01','Phantom02'):
 pattern=r'BALANCE CASE '+name+r' hp=(\d+) remaining=([-.\d]+) frames=(\d+) killed=true'
 old=re.search(pattern,before);new=re.search(pattern,fixed);assert old and new and int(new[3])<int(old[3])
 assert float(new[2])<=0
print('Native five enemy classes take real-shot damage and die faster PASS')
