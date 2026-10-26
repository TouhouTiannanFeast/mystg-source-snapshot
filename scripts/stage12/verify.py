from pathlib import Path
import importlib,hashlib,json
root=Path('G:/MySTG');mods=root/'aex-0.8.22/game/mod';m=mods/'Stage12Normal'
results=[]
for backend in ('luajit21','lua51','lua54'):
 lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
 compile=lua.eval('function(s,n) local f,e=(loadstring or load)(s,n);assert(f,e) end')
 for p in m.rglob('*.lua'):compile(p.read_text(encoding='utf-8'),'@'+str(p))
 g=lua.execute((m/'stage1/context-geometry.lua').read_text(encoding='utf-8'));g.echo_test()
 new=(m/'stage1/momiji-pattern.lua').read_text();assert 'echoCount=48,echoSpacing=310/47' in new and 'MomijiPattern.rearHalf=155' in new
 # Run both early kill and full timeout; inspect actual emitted event frames.
 for midlife in (300,3600):
  route=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
  route.execute((root/'scripts/th14-stage1/schedule-harness.lua').read_text(encoding='utf-8'))
  route.execute("Stage1Momiji={Boss='momiji',clean=function()end};Stage1Context={clean=function()end};local n=New;New=function(c,...) if c=='momiji' then return n('boss',true) end return n(c,...) end")
  harness=(root/'scripts/th14-stage1/schedule-harness.lua').read_text(encoding='utf-8').replace('mid and 1500',f'mid and {midlife}')
  route.execute(harness)
  route.execute("Stage1Momiji={Boss='momiji',clean=function()end};Stage1Context={clean=function()end};local n=New;New=function(c,...) if c=='momiji' then return n('boss',true) end return n(c,...) end")
  route.execute("Stage12Music={play=function()end,stop=function()end};Stage12Background={start=function()end}")
  route.execute((m/'stage1/stage.lua').read_text(encoding='utf-8'))
  events,bosses=route.globals().th14.run()
  assert len(events)==186 and bosses[1]['frame']==2420
  frames=[e['frame'] for e in events.values()]
  assert not any(2420<=f<2420+midlife for f in frames),'fairy spawned during Momiji'
  assert min(f for f in frames if f>2420)==2420+max(midlife,160)
  results.append(dict(backend=backend,syntax=True,context_geometry=True,waves=len(events),mid_frame=2420,mid_life=midlife,no_overlap=True))
for p in (mods/'Stage2Full').rglob('*'):
 if p.is_file() and p.name not in ('root.lua','README.md'):
  target=m/p.relative_to(mods/'Stage2Full')
  if str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='mamizou/pattern.lua':
   assert target.read_text(encoding='utf-8')==p.read_text(encoding='utf-8').replace('durations={3600,4200,3600,7800,7200}','durations={3600,4200,3600,1800,7200}').replace('health={800,1500,900,1050,1575}','health={800,1500,900,787.5,1575}')
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='mamizou/attack.lua':
   original=p.read_text(encoding='utf-8').replace('function Mamizou:init()','function Mamizou:init(start_card)').replace('if setting.mamizou_phase then selected={cards[setting.mamizou_phase]} end', 'if start_card then selected={};for i=start_card,#cards do selected[#selected+1]=cards[i] end\n    elseif setting.mamizou_phase then selected={cards[setting.mamizou_phase]} end')
   assert original==target.read_text(encoding='utf-8')
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='mystia/attack.lua':
   old=p.read_text(encoding='utf-8');new=target.read_text(encoding='utf-8')
   oldmove=old[old.index('local function start_move(o)'):old.index('local card=')]
   assert oldmove==new[new.index('local function start_move(o)'):new.index('local card=')]
   assert "local card=boss.card.New('',0,2,60,800,{0,0,0},false)" in new
   assert old[old.index('local Mystia=Class(boss)'):old.index('Stage2Mystia=')].replace("{card},nil,'Easy'","{card},nil,'Normal'")==new[new.index('local Mystia=Class(boss)'):new.index('Stage2Mystia=')]
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='mystia/pattern.lua':
   old=p.read_text(encoding='utf-8');new=target.read_text(encoding='utf-8');assert old[old.index('function P.move_age'):]==new[new.index('function P.move_age'):]
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='stage2-run.lua':
   assert 'Stage12Tail.run' in target.read_text() and 'Stage12Background.start(2)' in target.read_text()
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='flare/attack.lua':
   text=target.read_text(encoding='utf-8');assert "LoadTexture('flare.fire','flare/th16-flame-local.png')" in text and 'self.a,self.b,self.rect=6,6,false' in text
  elif str(p.relative_to(mods/'Stage2Full')).replace('\\','/')=='route.lua':
   old=p.read_text(encoding='utf-8');new=target.read_text(encoding='utf-8');assert old.replace('enemybase.init(self,math.max(1,math.ceil(e.hp/4)),false)',"local healthScale=e.name=='Girl01' and Stage12PlayerConfig.damage_scale or 0.25\n    enemybase.init(self,math.max(1,math.ceil(e.hp*healthScale)),false)")==new
  else:assert p.read_bytes()==target.read_bytes(),str(p)
context=(m/'stage1/context.lua').read_text(encoding='utf-8')
for forbidden in ['local function whale','local function sonar','local function query','local function boxes','local Mark=','start_whale']:assert forbidden not in context
assert "T.card('tail')" not in (m/'stage1/boss.lua').read_text(encoding='utf-8')
result={'checks':results,'stage2_preserved_except_named_tuning_and_mystia_notes':True,'other_deepseek_cards_absent':True}
(root/'work/logs/stage12/static.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,indent=2))




