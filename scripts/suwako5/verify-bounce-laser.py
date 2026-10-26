"""Targeted wall-reflection geometry and source-laser rendering regression."""
from pathlib import Path
import json,hashlib
from lupa.lua51 import LuaRuntime
r=Path('G:/MySTG');c=r/'aex-0.8.22/game/mod/MySTG/stages/suwako5';l=LuaRuntime(unpack_returned_tuples=True)
for name in ['projectiles.lua','stage.lua','laser-art.lua']:l.execute('assert(loadstring(...))',(c/name).read_text(encoding='utf-8'))
for name in ['pool.lua','runtime.lua','projectiles.lua','laser-art.lua']:l.execute((c/name).read_text(encoding='utf-8'))
l.execute('''
local R=Suwako5Runtime
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' != '..tostring(b))end
local function shot(group,x,y,vx,vy,k,mask,count)
 return {group=group,x=x,y=y,vx=vx,vy=vy,angle=math.atan2(vy,vx),speed=math.sqrt(vx*vx+vy*vy),ex={},pc=0,active={{kind=k or 'bounce',age=0,count=count or 1,mask=mask or 15,r=-999999}},age=100,cull=1000,typ=8,color=2}
end
-- Reflect the same 48-needle circumference in each wall and a corner.
-- Independent oracle: rigid mirror of the complete circle preserves radii.
for _,group in ipairs({'th10','dsc'}) do
 for _,wall in ipairs({'left','right','top','bottom','corner'}) do
  for i=0,47 do
   local a=i*2*math.pi/48;local dx,dy=math.cos(a)*.75,math.sin(a)*.75
   local x,y,vx,vy,ex,ey
   if wall=='left' then x,y,vx,vy=-194+dx,150+dy,-2,0;ex,ey=-384-x+2,y
   elseif wall=='right' then x,y,vx,vy=194+dx,150+dy,2,0;ex,ey=384-x-2,y
   elseif wall=='top' then x,y,vx,vy=dx,-2+dy,0,-2;ex,ey=x,-y+2
   elseif wall=='bottom' then x,y,vx,vy=dx,450+dy,0,2;ex,ey=x,896-y-2
   else x,y,vx,vy=194+dx,-2+dy,2,-2;ex,ey=384-x-2,-y+2 end
   local b=shot(group,x,y,vx,vy);R.projectileStep(b);near(b.x,ex);near(b.y,ey);assert(#b.active==0)
  end
 end
end
-- Boundary mask, disabled bottom, wrap and bounce count remain intact.
local b=shot('dsc',194,150,2,0,'bounce',4);R.projectileStep(b);near(b.x,196);assert(#b.active==1)
b=shot('th10',0,450,0,2,'bounceNoBottom');R.projectileStep(b);near(b.y,452)
b=shot('dsc',194,150,2,0,'bounce',15,2);R.projectileStep(b);assert(b.active[1].count==1)
b=shot('dsc',194,150,2,0,'wrap');R.projectileStep(b);near(b.x,-192)
-- Laser bridge and ISC geometry are outside the ring correction.
b=shot('th10',194,150,2,0);b.laser={length=128,width=14};R.projectileStep(b);near(b.x,192)
b=shot('isc0902',194,150,2,0);R.projectileStep(b);near(b.x,192)
-- Every catalog phase still uses the user's latest HP and time.
local P=Suwako5Pool;assert(#P.spells==15 and #P.nonspells==7)
for _,pool in ipairs({P.spells,P.nonspells}) do for _,s in ipairs(pool) do assert(s.frames==1800)end end
''')
# Run the actual NativeLaser renderer against a recording drawing API.
stage=(c/'stage.lua').read_text(encoding='utf-8');body=stage.split('function NativeLaser:render()',1)[1].split('function NativeLaser:del()',1)[0]
l.execute('''NativeLaser={};function SetImageState(...)end;function Color(...)return {}end
 function Render(image,x,y,rot,sx,sy)draw={image,x,y,rot,sx,sy}end
''')
l.execute('function NativeLaser:render()'+body)
l.execute('''
for _,row in ipairs({{'th10',3,2,14,128},{'dsd',21,1,48,192},{'dsd',21,5,32,128}})do
 local o={data={group=row[1],typ=row[2],color=row[3]},x=10,y=20,rot=0,w=row[4],l1=0,l2=row[5],l3=0,_a=255,alpha=1}
 NativeLaser.render(o);assert(draw[1]:find('suwako5.laser-',1,true)==1);assert(math.abs(draw[2]-(10+row[5]/2))<1e-7);assert(draw[3]==20 and draw[4]==-90)
 local art=Suwako5LaserArt[row[1]=='th10' and 'th10' or 'ds'][row[2]][row[3]];assert(draw[5]==row[4]/art.w and draw[6]==row[5]/art.h)
end
''')
refs=json.loads((c/'laser-art-reference.json').read_text(encoding='utf-8'))
for x in refs['records']:
 assert hashlib.sha256((c/x['target']).read_bytes()).hexdigest()==x['sha256']==hashlib.sha256(Path(x['source']).read_bytes()).hexdigest()
assert len(refs['records'])==24
print('PASS: 480 mirrored-circle points, masks/count/wrap guards; source sprite hashes24; actual laser renderer mapping/axis/extent; Lua syntax and30s preserved.')
