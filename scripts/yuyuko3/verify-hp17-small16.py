from pathlib import Path
import re,sys,json,hashlib,collections
sys.path.insert(0,'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime
m=Path('G:/MySTG/aex-0.8.22/game/mod');r=m/'Le03Stage4Normal';b=m/'YuyukoStage3';l=LuaRuntime(unpack_returned_tuples=True)
for p in list(r.glob('*.lua'))+list(b.glob('*.lua')):l.execute('assert(loadstring(...))',p.read_text('utf-8-sig'))
for n in ['constants','movement','bullet-style','firing','enemy-health','runtime','schedule']:l.execute((r/(n+'.lua')).read_text('utf-8-sig'))
l.execute('Le03.start(42)');counts=collections.Counter()
for i,e in l.globals().Le03.enemies.items():
 orig=e['sourceHP'];kind=e['kind'];hp=e['hp'];expected=(1500 if orig>=20000 else 600)if kind==0 else(120 if orig>=5000 else 100 if orig>=2000 else 80)
 assert hp==expected and orig==l.globals().Le03Schedule[i][6];counts[(kind,hp)]+=1
print('PASS122 source HP preserved and differentiated TH10 HP:',dict(counts))
l.execute((b/'player-config.lua').read_text('utf-8-sig'));assert l.globals().Y3PlayerConfig.damage_scale==1 and l.globals().Y3PlayerConfig.road_damage_scale==1
host=(r/'host.lua').read_text('utf-8-sig');fn=re.search(r'function EnemyDamage:take_damage\(d\).*?\nend',host,re.S)[0]
l.execute('EnemyDamage={};enemy={take_damage=function(o,d)o.hp=o.hp-d end};R={damageEnemy=function(e,d)e.hp=e.hp-d end}')
l.execute(fn);l.execute('local o={hp=100,data={hp=100}};EnemyDamage.take_damage(o,10);assert(o.hp==90 and o.data.hp==90 and o.hostHp==90)')
assert 'local E=Class(EnemyDamage)' in host
print('PASS road/Boss damage scale1; actual base damage dispatch synchronizes HP once')
root=(b/'root.lua').read_text('utf-8-sig');assert "if not b.le04 and b.typ==3 then self.img='y3.small.'..(b.col%16)end" in root;assert "local image='y3.b3.'..(b.col%16)" in root
from PIL import Image
for row in json.loads((b/'art/th10-small/manifest.json').read_text()):
 p=b/'art/th10-small'/f"{row['color']}.png";assert p.read_bytes()==Path(row['source']).read_bytes();assert Image.open(p).size==(16,16)
print('PASS16 original TH10 small-ball sprites, dimensions and laser/LE04 exclusion')
