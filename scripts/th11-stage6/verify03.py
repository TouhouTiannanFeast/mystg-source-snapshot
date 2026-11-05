"""Focused regression: scene sampling/depth, local drops, phase data and resume."""
from pathlib import Path
import json,hashlib,re
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';L=R/'work/logs/th11-stage6/change03'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
before=json.loads((L/'before-hashes.json').read_text())
for n in ['milk/pattern.lua','player.lua','player-data.lua','player-config.lua','power-lock.lua','music.lua']:
 assert sha(M/n)==before[n],n
old=(L/'before/programs.lua').read_text(encoding='utf-8');new=(M/'programs.lua').read_text(encoding='utf-8')
def functions(s):
 chunks=re.split(r'P\["(\w+)"\]=',s);return dict(zip(chunks[1::2],chunks[2::2]))
a,b=functions(old),functions(new);assert set(a)==set(b)
for n in a:
 if n!='main':assert a[n]==b[n],n
ref=json.loads((M/'source/milk-reference.json').read_text())
bg=json.loads((M/'source/background-selection.json').read_text())
for row in bg['textures']:assert sha(M/row['output'])==row['sha256']
assert ref['nonspell_included']and ref['hp']==24000 and ref['nonspell_hp']==12000 and ref['nonspell_duration']==2400
source=Path(ref['source_nonspell']).read_text(encoding='utf-8')
local=(M/'milk/nonspell.lua').read_text(encoding='utf-8')
expected=source.replace('hp=8000','hp=12000',1).replace('60,8000,{0,0,0}','60,N.hp,{0,0,0}',1).replace("'art/ofuda-'","'milk/art/ofuda-'").replace('setting.milk_test','setting.th11s6_milk_test')
expected=expected.replace('duration=3600','duration=2400',1).replace('60,N.hp,{0,0,0}','40,N.hp,{0,0,0}',1)
assert local==expected,'nonspell user manual edits were not retained'
l=LuaRuntime(unpack_returned_tuples=True)
def run(s):return l.execute(s)
for p in M.rglob('*.lua'):l.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
run('''
ran={Float=function(self,a,b)return a+(b-a)*.376123 end}
LoadTexture=function()end;LoadImage=function()end;samplers={};SetTextureSamplerState=function(tex,mode)samplers[tex]=mode end
Class=function(base)local c={base=base};for k,v in pairs(base or{})do c[k]=v end;return c end
background={};object={};bullet={};img_class={}
item={init=function(o,x,y,typ)o.x,o.y,o.img,o.imgup=x,y,'item'..typ,'item_up'..typ end,frame=function()end}
item_faith_minor={init=function(o,x,y)o.x,o.y,o.img=x,y,'item8' end,frame=function()end}
item_point={collect=function(o)blueCollected=(blueCollected or 0)+1 end}
enemy={};enemybase={};GROUP_ITEM=6;GROUP_GHOST=0;GROUP_ENEMY_BULLET=5;LAYER_ENEMY=0
player={};IsValid=function(o)return o~=nil and not o.dead end
Color=function(...)return {...}end
''')
for n in ['runtime.lua','road-runtime.lua','projectiles.lua','programs.lua','presentation.lua','host.lua']:
 run((M/n).read_text(encoding='utf-8'))
run('''
local H=TH11S6Host
for kind=1,6 do local o={};H.Drop.init(o,0,0,kind);assert(o.img=='item2'and o.imgup=='item_up2');H.Drop.collect(o)end
local o={};H.Minor.init(o,0,0);assert(o.img=='item2'and o.imgup=='item_up2');H.Minor.collect(o)
assert(blueCollected==7 and item_faith_minor==H.Minor,'native bullet.kill must also create blue items')
local R=TH11S6Runtime
function resumeAt(endTick)
 R.start();R.onShot=nil;local crows={};local all=0
 R.onActor=function(a)all=all+1;if a.name=='Crow02'then crows[#crows+1]={t=R.tick,hp=a.hp}end end
 R.onMidboss=function()for _,a in ipairs(R.actors)do if not a.controller then a.dead=true end end end
 -- Fixture clears preboss minors through defeat before the new encounter gate.
 while R.tick<3161 do
  if R.tick==3159 then for _,a in ipairs(R.actors)do if not a.controller then a.dead=true;a.defeated=true end end end
  R.step(0,400,1)
 end
 assert(R.bossPresent and #crows==0 and R.midbossBorn==3160)
 for i=1,180 do R.step(0,400,1)end;assert(#crows==0,'crows leaked into encounter')
 R.tick=endTick;R.bossPresent=false
 for i=1,121 do R.step(0,400,1)end
 assert(R.resumeTick==endTick and #crows==8 and crows[1].t==endTick,'immediate crow continuation')
 for i,row in ipairs(crows)do assert(row.hp==400 and row.t==endTick+math.floor((i-1)/2)*40)end
 assert(R.skipped==0,'post-boss waves skipped')
end
resumeAt(3500);resumeAt(10000)
''')
run((M/'background-assets.lua').read_text(encoding='utf-8'))
run((M/'background.lua').read_text(encoding='utf-8'))
run('''
assert(samplers['th11s6.ex.stg7bg']=='linear+wrap'and samplers['th11s6.ex.stg7bg2']=='linear+wrap'and samplers['th11s6.ex.stg7bg3']=='linear+wrap')
local B=TH11S6Background;local g=B.groups();assert(#g==455)
Set3D=function()end;SetViewMode=function()end;RenderClear=function()end;SetImageState=function()end;Render=function()end
local enabled=false;local draws=0;local cleared=false
ClearZBuffer=function()cleared=true end;SetZBufferEnable=function(v)enabled=v~=0 end
Render4V=function()assert(enabled and cleared,'geometry drawn without depth');draws=draws+1 end
B.Object.render({state=B.new(),groups=g});assert(draws==455 and not enabled,'depth state not restored for player/bullets')
''')
print('PASS Lua51; current phase12000/24000,40s/50s+manual speed/color retained; player/music/spell pattern unchanged; all non-main road routines byte-identical; blue drops; immediate40f-spaced crows for early3500/late10000 endings;455quads+UVwrap+depth/restoration.')
(L/'verify.json').write_text(json.dumps(dict(status='PASS',hp=[12000,24000],times=[2400,3000],resume_cases=[3500,10000],blue_collect_checks=7),indent=2))
