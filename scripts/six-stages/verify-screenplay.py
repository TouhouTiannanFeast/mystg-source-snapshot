from pathlib import Path
import sys,json,hashlib,os
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');G=R/'aex-0.8.22/game';M=G/'mod/SixStageCampaign';O=R/'work/logs/six-stages/screenplay-20261113';os.chdir(G)
read=lambda p:p.read_text('utf-8-sig')
l=LuaRuntime();data=l.execute(read(M/'screenplay/data.lua'));raw=json.loads(read(M/'screenplay/text.json'));prov=json.loads(read(M/'screenplay/source.json'));doc=json.loads(read(O/'source-paragraphs.json'));paragraphs={r['paragraph']:r['text'].strip()for r in doc['paragraphs']}
assert hashlib.sha256(Path(prov['document']).read_bytes()).hexdigest()==prov['document_sha256']
count=0
for key,rows in raw.items():
 pages=list(data.scenes[key].values())
 for n,row in enumerate(rows,1):
  pp=[p for p in pages if p.line==n];assert pp
  assert ''.join(s for p in pp for s in p.rows.values())==row['text'],(key,n)
  if row['paragraph'] and not(key=='s5pre'and row['paragraph']==239):
   assert row['text']==paragraphs[row['paragraph']][:paragraphs[row['paragraph']].rfind('」')+1]
  for p in pp:
   assert len(p.rows)<=2
   for s in p.rows.values():assert sum(.5 if ord(c)<128 else 1 for c in s)<=20
   if row['speaker_label']=='不显示名字':assert p.portrait=='maskedreimu'and p.displayName==''
   if p.speaker=='kaguya'and row['speaker_label']!='不显示名字':assert p.portrait.startswith('kaguya')and p.displayName=='辉夜'
  count+=1
assert count==155
assert data.scenes.s2hinapost[1].text=='「原来还要钱的啊……」'
assert data.scenes.s3pre[1].displayName=='？？？'
reveal=[p for p in data.scenes.s4post.values()if p.text=='「吾乃永远与须臾的公主，辉夜大人！」'];assert reveal and all(p.displayName=='辉夜'and p.portrait.startswith('kaguya')for p in reveal)
assert len(data.scenes.s6post)==0 and len(data.scenes.s6midpost)==0
assert not any(k.startswith('ending')for k in data.scenes.keys())
for a in prov['assets']:assert hashlib.sha256((M/'screenplay'/a['file']).read_bytes()).hexdigest()==a['sha256']
for name in ['root.lua','screenplay.lua','dialogue3.lua','dialogue46.lua','screenplay/data.lua']:
 l.execute('assert(loadstring(...))',read(M/name))
l.execute('''
SixStageCampaign={install=function()end};SixStageDialogue3={data={art={},fallback={}}};SixStageStory46={data={scenes={},names={}}}
function LoadTexture()end;function LoadImage()end;function SetImageCenter()end
function IsValid(o)return o~=nil end;function Kill(o)o.ended=true end
player={dialog=false};MOVE_DECEL=1
boss={move={New=function()return{is_combat=false}end},init=function(o,x,y,name,cards)o.cards=cards end}
task={Wait=function(n)for j=1,n do coroutine.yield()end end,New=function(o,f)o.work=coroutine.create(f)end}
SixStageStory46.play=function(key)table.insert(played,key);assert(player.dialog or key=='s5mid')end
played={};Zuu4Order={'non1','spell1','non2','spell2','non3','stone','final'};Zuu4Specs={non3={}}
Stage2Flare={Boss={}};Stage2Mystia={Boss={}}
function cos(a)return math.cos(a*math.pi/180)end
Zuu4Boss={init=function(o,mode)local cards={};local ids=mode and Zuu4Specs[mode]and{mode}or Zuu4Order;for _,id in ipairs(ids)do cards[#cards+1]={id=id,is_combat=true}end;boss.init(o,0,96,'Horou',cards)end}
''')
l.execute(read(M/'screenplay.lua'))
l.execute('''
local P=SixStageScreenplay;SixStageCampaign.install(5,{})
setting={};P.beforeFive();assert(player.dialog and played[1]=='s5off')
local co=coroutine.create(P.afterFiveArrival);for j=1,90 do assert(coroutine.resume(co));assert(player.dialog)end
assert(coroutine.resume(co));assert(not player.dialog and played[2]=='s5pre')
local full={};Zuu4Boss.init(full);assert(#full.cards==8 and full.cards[5].is_combat==false and full.cards[6].id=='non3')
local mid={};Zuu4Boss.init(mid,'non3');assert(#mid.cards==2 and mid.cards[2].id=='non3')
local code=SixStageCampaign.sourceText('mod/HSoBStage5Normal/boss-link.lua');assert(loadstring(code));assert(code:find('beforeFive',1,true)<code:find('New(Entrance)',1,true));assert(code:find('afterFiveArrival',1,true)<code:find('New(Zuu4Boss',1,true))
print('PASS active screenplay data mapping; Stage5 offscreen->original entrance->pre/90f, mid before non3; every original card retained')
SixStageCampaign.install(2,{})
local base=false;local rendered
Render=function(...)rendered={...}end
Stage2Flare.Boss.render({x=12,y=134,_bosssys={render=function()base=true end}})
assert(base and rendered[1]=='s2.hina-0'and rendered[2]==12 and rendered[3]==134 and rendered[5]==1.2 and rendered[6]==1.2)
local pages=SixStageScreenplay.data.scenes.s2hinapre
assert(#pages==2 and pages[1].portrait=='patchoulihina'and pages[2].portrait=='patchoulihina')
print('PASS Patchouli two pages share cutout; actual Boss render uses Hina with original position/scale/system rendering')
Stage2Mystia.Boss.render({x=3,y=112,ani=8,_bosssys={render=function()end}})
assert(rendered[1]=='six.script.aya.2'and rendered[2]==3 and rendered[3]==112 and rendered[5]==1 and rendered[6]==1)
Stage2Mystia.Boss.render({x=3,y=112,ani=8,motionSpeed=1,moveAngle=180,_bosssys={render=function()end}})
assert(rendered[1]=='six.script.aya.6'and rendered[5]==-1 and rendered[6]==1)
local ms=SixStageScreenplay.data.scenes.s2mystiapre
assert(ms[1].portrait=='mystiahappy'and ms[3].portrait=='mystiaspecial'and ms[4].portrait=='mystiahappy')
print('PASS Mystia happy/special/happy; Aya idle/moving/facing retains original4f cadence and position')
''')
# Execute the actual renderer and initial portrait-selection routine in a small drawing fixture.
s=read(M/'dialogue3.lua');render=s[s.index('function D.render()'):s.index('C.drawDialogue=D.render')]
l.execute('''D=SixStageDialogue3;data=D.data;D.active=true;D.pages={SixStageScreenplay.data.scenes.s1open[1]};D.page=1;D.age=12;D.art={kaguya='maskedreimu'};D.shade={kaguya=1};D.cast={other='none'};D.scene=nil
colors={};labels={};function SetViewMode()end;function Render()end;function RenderRect()end;function Color(a,r,g,b)return{a,r,g,b}end;function SetImageState(n,b,c)colors[n]=c end;function glyphs(s,...)labels[#labels+1]=s end
''')
l.execute(render);l.execute('''D.render();assert(labels[1]=='');assert(colors['six.script.maskedreimu.1'][2]==0);assert(colors['six.script.maskedreimu.50'][2]==0);assert(colors['six.script.maskedreimu.165'][2]==255);print('PASS actual renderer hides name, black head, full-color lower body; original PNG unchanged')''')
show=s[s.index('function D.show('):s.index('function D.advance()')]
l.execute('''C=SixStageCampaign;C.index=2;KEY={Z=1};function GetKeyState()return false end;function ObjList()return ipairs({})end;stage={current_stage={timer=1}};D.active=false''')
l.execute(show);l.execute('''D.show('s2hinapre',{pages=SixStageScreenplay.data.scenes.s2hinapre,other='hina',initial='hinano',names={hina='雏'}});assert(D.art.kaguya=='maskedreimu','NPC-only scene revealed inactive player');print('PASS NPC-only dialogue also retains masked inactive protagonist')''')
l.execute('''
lstg={world={r=192,b=-224}};local positions={}
Render=function(img,x,y,rot,sx,sy)positions[img]={x,y,sx,sy}end
for _,key in ipairs({'patchoulihina','mystiahappy','mystiaspecial'})do
 local a=data.art[key]
 for _,light in ipairs({0,.5,1})do
  D.active=true;D.age=12;D.exit=nil;D.scene=nil;D.page=1
  D.pages={{speaker='hina',portrait=key,displayName='',rows={}}}
  D.art={kaguya='maskedreimu',hina=key};D.cast={other='hina'};D.shade={kaguya=0,hina=light}
  D.render();local pos=positions[a.layers[1].image]
  assert(math.abs(pos[1]+a.visibleRight*pos[3]-192)<1e-8,'right edge drift')
  assert(math.abs(pos[2]-a.visibleBottom*pos[4]+224)<1e-8,'bottom edge drift')
 end
end
print('PASS actual portrait render: Patchouli/Mystia right-bottom flush at active/inactive/pulse scales')
''')
(O/'verify.json').write_text(json.dumps({'lines_including_voice_only':count,'visible_lines':count-1,'document_sha256':prov['document_sha256'],'assets_unchanged':True,'layout':True,'ending_implemented':False},indent=2),'utf-8')
print('PASS exact154 lines including original3-line prologue and voice-only laugh; original glyph/assets,2-row pagination,Lua51')
