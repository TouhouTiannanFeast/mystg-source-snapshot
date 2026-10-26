"""Trace the legacy card2 corner-return beam without changing gameplay files."""
from pathlib import Path
import json,math
from lupa.lua51 import LuaRuntime
ROOT=Path('G:/MySTG');C=ROOT/'aex-0.8.22/game/mod/MySTG/stages/suwako5';OUT=ROOT/'work/logs/suwako5'
def trace(legacy):
 l=LuaRuntime(unpack_returned_tuples=True)
 for f in ['pool.lua','runtime.lua','projectiles.lua','programs.lua']:
  p=ROOT/'work/suwako5/fix06'/f.replace('.lua','.before.lua') if legacy and f in ['runtime.lua','projectiles.lua'] else C/f
  l.execute(p.read_text(encoding='utf-8'))
 l.globals().LEGACY=legacy
 l.execute('''
 local R=Suwako5Runtime;local n=0
 traceCorners={};traceFrames={}
 R.start(Suwako5Pool.find('th10-card2'),20261026)
 R.onShot=function(b)if b.laser then n=n+1;b.traceId=n;b.traceBorn=R.tick end end
 for tick=0,340 do
  R.step(0,400,R.spec.hp)
  if LEGACY then
   for _,b in ipairs(R.hazards)do
    if b.laser and #b.active>0 and math.abs(b.x)>=192 and b.y>=448 and b.vy>0 then
     b.traceCorner=true
     traceCorners[#traceCorners+1]={id=b.traceId,born=b.traceBorn,tick=R.tick,x=b.x,y=b.y,angle=b.angle,color=b.color}
    end
   end
  end
  R.stepHazards()
  if R.tick==260 or R.tick==280 or R.tick==300 then
   local frame={}
   for _,b in ipairs(R.hazards)do if b.laser then frame[#frame+1]={id=b.traceId,x=b.x,y=b.y,angle=b.angle,length=b.laser.length,color=b.color,corner=b.traceCorner or false}end end
   traceFrames[R.tick]=frame
  end
 end
 ''')
 def rows(t):return [{k:v for k,v in row.items()} for _,row in t.items()]
 return {'corners':rows(l.globals().traceCorners),'frames':{str(k):rows(v) for k,v in l.globals().traceFrames.items()}}
a,b=trace(True),trace(False)
assert len(a['corners'])==2 and all(x['born']==159 and x['tick']==223 for x in a['corners'])
(OUT/'fix07-lineage.json').write_text(json.dumps({'legacy':a,'current':b},ensure_ascii=False,indent=2),encoding='utf-8')
# Vector diagram from simulation telemetry, not an edited game screenshot.
frames=a['frames']['280'];svg=['<svg xmlns="http://www.w3.org/2000/svg" width="640" height="740" viewBox="0 0 640 740"><rect width="640" height="740" fill="#15202d"/><text x="34" y="32" fill="white" font-size="20">Legacy card2: isolated upward return at frame 280</text><text x="34" y="58" fill="#c4d1e2" font-size="15">Source-coordinate trace; orange = simultaneous corner reflection</text><g transform="translate(100 90)"><rect width="384" height="448" fill="#090f18" stroke="#b2c5db"/>']
for row in sorted(frames,key=lambda x:x['corner']):
 x=row['x']+192;y=row['y'];ex=x+math.cos(row['angle'])*row['length'];ey=y+math.sin(row['angle'])*row['length'];color='#ffb347' if row['corner'] else '#668397';opacity='1' if row['corner'] else '.35'
 svg.append(f'<line x1="{x}" y1="{y}" x2="{ex}" y2="{ey}" stroke="{color}" opacity="{opacity}" stroke-width="{6 if row["corner"] else 2}"/>')
 if row['corner']:
  svg.append(f'<circle cx="{x}" cy="{y}" r="7" fill="#ffb347"/><text x="{x+10}" y="{y+5}" fill="#ffdca6" font-size="16">#{row["id"]}</text>')
svg+=['<circle cx="192" cy="128" r="6" fill="#f5f7fa"/></g><text x="34" y="590" fill="#ffb347" font-size="18">First pair: fired frame159, reflected frame223 (3.72s).</text><text x="34" y="620" fill="#d7e0ed" font-size="17">Both axes flip, sending the beam diagonally back across center.</text><text x="34" y="650" fill="#d7e0ed" font-size="17">At frame280 (4.67s), it separates clearly from the fan.</text><text x="34" y="695" fill="#b0c4d9" font-size="16">Diagnostic only. No extra gameplay change in this investigation.</text></svg>']
(OUT/'fix07-corner-return.svg').write_text(''.join(svg),encoding='utf-8')
for x in a['corners']:print('LEGACY CORNER',x)
for x in frames:
 if x['corner']:print('FRAME280 isolated beam',x)
print('Saved legacy/current lineage and vector trajectory diagram; later current-model geometry is saved for comparison.')
