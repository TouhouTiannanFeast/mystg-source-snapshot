from pathlib import Path
import json,hashlib,importlib,sys,site
sys.path.append(site.getusersitepackages());from PIL import Image
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/Stage12Normal';meta=json.loads((M/'source/unified-art/reference.json').read_text());names=set()
for row in meta['sprites']:
 p=M/row['output'];assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'],row['name'];assert hashlib.sha256(Path(row['source']).read_bytes()).hexdigest()==row['source_sha256']
 assert Image.open(p).getbbox();names.add(row['name'])
for c,v in meta['characters'].items():assert hashlib.sha256(Path(v['source']).read_bytes()).hexdigest()==v['source_sha256']
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 lua.globals().dofile=lambda p:lua.execute((R/'aex-0.8.22/game'/p).read_text(encoding='utf-8'))
 lua.globals().ImageExists=lambda p:p in names
 lua.execute("IsValid=function(o)return true end;Render=function(name,x,y,rot,sx,sy)assert(ImageExists(name),'missing frame '..name)end")
 lua.execute((M/'character-animation.lua').read_text(encoding='utf-8'))
 lua.execute('''
 for _,id in ipairs({'momiji','wakasagi','mystia','patchouli','mamizou'}) do
  local o={x=0,y=0,hp=123,a=16,b=12,vx=0,vy=0,_bosssys={render=function()end}}
  local cls={frame=function()end};Stage12Art.attach(cls,id)
  for t=1,240 do
   local delta=t>=20 and t<60 and -1 or t>=90 and t<130 and 1 or 0
   o.x=o.x+delta;local x,y=o.x,o.y
   cls.frame(o);cls.render(o)
   assert(o.x==x and o.y==y and o.hp==123 and o.a==16 and o.b==12 and o.vx==0 and o.vy==0,'visual callback modified gameplay')
   if t==45 then assert(o.stage12Anim.state=='left')end
   if t==110 then assert(o.stage12Anim.state=='right')end
   if t==60 and id~='wakasagi' then assert(o.stage12Anim.state=='stop_left')end
  end
 end
 local o={class={},a=7,b=3,rect=true,rot=20};Stage12Art.bullet(o,'arrow',6);assert(o.a==7 and o.b==3 and o.rect and o.rot==20)
 ''')
 print(backend+':5character idle/left/right/stop + gameplay immutability + bullet hitbox PASS')
print(str(len(names))+' source/output sprite hashes and5 ANM hashes PASS')
