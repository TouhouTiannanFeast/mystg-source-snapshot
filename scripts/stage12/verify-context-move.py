from pathlib import Path
import importlib,json
r=Path('G:/MySTG');p=r/'aex-0.8.22/game/mod/Stage12Normal/stage1/context-geometry.lua';rows=[]
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True);g=lua.execute(p.read_text(encoding='utf-8'))
 for px,py in [(0,-176),(180,100),(-180,100),(0,200),(0,-28)]:
  c=g.carrier(px,py);first=g.echo_rect(0)
  assert c.vx*(first.cx-px)+c.vy*(first.cy-py)>=0
  contact=None;resumed=False
  for t in range(400):
   oldx,oldy=c.x,c.y;dx,dy=g.advance(c,t)
   if contact is not None and t<320 and abs(dx)+abs(dy)>1e-9:resumed=True
   if c.stopped and contact is None:contact=t
   if t>=320:assert dx==0 and dy==0
   assert dx*c.vx+dy*c.vy>=-1e-9
   rect=g.translate(g.echo_rect(t),c.x,c.y)
   assert rect.l>=-192-1e-6 and rect.r<=192+1e-6 and rect.b>=-224-1e-6 and rect.t<=224+1e-6
   # Carry a test point exactly; its displacement relative to field stays fixed.
   bx,by=oldx+12,oldy-30
   assert abs((bx+dx-c.x)-12)<1e-9 and abs((by+dy-c.y)+30)<1e-9
  if contact is not None and contact<319:assert resumed,'motion latched after contact'
  if px==0 and py==-176:assert contact is not None and resumed and abs(g.translate(g.echo_rect(319),c.x,c.y).t-224)<1e-6,'shrinking top edge must stay flush'
  last=g.echo_rect(399);assert last.w*2==135 and last.h*2==192
  rows.append({'backend':backend,'player':[px,py],'offset':[c.x,c.y],'first_contact':contact,'resumed_after_contact':resumed,'final_size':[135,192]})
(r/'work/logs/stage12/context-move.json').write_text(json.dumps(rows,indent=2),encoding='utf-8');print('15 direction/dynamic-edge/resumed-motion/carry/final-size cases PASS')
