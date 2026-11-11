from pathlib import Path
import hashlib, json, sys
sys.path.insert(0, 'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime

ROOT = Path('G:/MySTG')
MOD = ROOT / 'aex-0.8.22/game/mod/SixStageCampaign'
LOG = ROOT / 'work/logs/six-stages'
lua = LuaRuntime()
for file in MOD.glob('*.lua'):
    lua.execute('assert(loadstring(...))', file.read_text(encoding='utf-8-sig'))
print('PASS Lua51 syntax')
lua.execute(r'''
setting={six_stage=1};keys={};KEY={F5=5,F6=6,F7=7,Z=90,UP=38,DOWN=40,ESCAPE=27}
clock=0;os.clock=function()return clock end
calls=0;frames=0;contacts=0;texts=0
function GetKeyState(k)return keys[k]or false end
function FrameFunc()frames=frames+1 end
function RenderFunc()end
function DoFrame()calls=calls+1 end
function AfterFrame()end
function SetViewMode()end;function RenderClear()end;function Color(...)return{}end
function RenderText()texts=texts+1 end;function RenderTTF()texts=texts+1 end
function SetImageState()end;function RenderRect()end;function Render()end
function IsValid(p)return p~=nil end
item={};ui={menu={}};player_lib={system={},debug_data={}}
reimu_player={is_class=true,colli=function()contacts=contacts+1 end}
ext={pausemenu={},pause_menu={IsKilled=function()return true end}}
lstg={included={},var={},lstg_ui={},FileManager={FileExist=function()return true end},
 RegisterAllGameObjectClass=function()end,BeginScene=function()end,EndScene=function()end}
stage={stages={},group={},current_stage={stage_name='init',is_menu=true}}
stage_init={frame=function()end};player_list={{'', 'reimu_player','Reimu'}}
function stage.New(n)local s={stage_name=n,name=n};stage.stages[n]=s;return s end
function stage.Set(n)stage.next_stage=assert(stage.stages[n],n)end
function stage.group.New()stage.testgroup={name='Normal',difficulty=2,stages={}}end
function stage.group.Find()return stage.testgroup end
function stage.group.AddStage(_,n,items)
 local s=stage.New(n);s.number=#stage.testgroup.stages+1;s.group=stage.testgroup;s.item_init=items
 table.insert(stage.testgroup.stages,s);return s
end
function stage.group.DefStageFunc(n,k,f)stage.stages[n][k]=f end
function stage.group.Start()end;function stage.group.PracticeStart()end
function stage.group.FinishStage()end;function stage.group.FinishReplay()end
function _init_item()lstg.var.score=0;lstg.var.graze=0 end
local names={'Misty Lake@Normal','Stage Two@Normal','Yuyuko Stage3@Normal',
 'Marisa Mixed@Normal','HSoB Stage5 Road@Normal','Nina Six@Normal'}
local function fakePlayer(homing)
 if homing then Y3Player={shoot=function()return 'homing'end};reimu_player.shoot=Y3Player.shoot
 else Stage12Player={};reimu_player.shoot=function()return 'piercing'end end
end
function Include(p)
 local module=p:match('mod/([^/]+)/')
 local function reg(i)
  stage.group.AddStage('Normal',names[i])
  stage.group.DefStageFunc(names[i],'init',function(s)_init_item(s);player={class=reimu_player}end)
 end
 if p:match('/root.lua$')then
  item.patch=(item.patch or 0)+1;lstg.lstg_ui.patch=(lstg.lstg_ui.patch or 0)+1
  if module=='Stage12Normal'then fakePlayer(false);reg(1);reg(2)
  elseif module=='YuyukoStage3'then fakePlayer(true);reg(3)
  elseif module=='MarisaMixed'then fakePlayer(true);reg(4)
  elseif module=='HSoBStage5Normal'then fakePlayer(true);reg(5)
  elseif module=='NinaStage6Normal'then fakePlayer(true);reg(6)end
 elseif p:match('/th08_stage4/stage.lua$')then reg(4)
 elseif p:match('/MarisaMixed/player.lua$')then fakePlayer(true)end
end
''')
lua.execute((MOD/'campaign.lua').read_text(encoding='utf-8'))
lua.execute(r'''
local C=SixStageCampaign
stage_init.frame({timer=30});assert(C.baseline)
local function enter(i,entry)
 C.entry=entry or'full';stage.next_stage=nil;stage.current_stage=stage.stages[C.names[i]]
 stage.current_stage:init()
end
enter(1);assert(reimu_player.shoot()=='piercing')
assert(lstg.var.lifeleft==2 and lstg.var.bomb==3)
reimu_player.colli(player,{});assert(contacts==1)
keys[KEY.F6]=true;FrameFunc();assert(C.god)
reimu_player.colli(player,{});assert(contacts==1,'god leaked collision')
FrameFunc();assert(C.god,'held key toggled twice')
keys[KEY.F6]=false;FrameFunc();keys[KEY.F6]=true;FrameFunc();assert(not C.god)
reimu_player.colli(player,{});assert(contacts==2,'immunity did not turn off immediately')
keys={}
for _,speed in ipairs({4,8,1})do keys[KEY.F7]=true;FrameFunc();assert(C.speed==speed);keys[KEY.F7]=false;FrameFunc()end
C.speed=8;calls=0;DoFrame();assert(calls==8)
stage.current_stage=stage.stages.SixStageGap;calls=0;DoFrame();assert(calls==1,'gap accelerated')
stage.current_stage=stage.stages[C.names[1]]
keys[KEY.F5]=true;local f=frames;FrameFunc();assert(C.select and frames==f)
keys[KEY.F5]=false;keys[KEY.DOWN]=true;FrameFunc();assert(C.choice==2)
keys[KEY.DOWN]=false;keys[KEY.Z]=true;FrameFunc();assert(not C.select and C.target==2)
keys={};stage.next_stage=nil
local gap=stage.stages.SixStageGap;stage.current_stage=gap;gap:init()
for i=1,60 do gap:frame()end;assert(not stage.next_stage,'gap skipped wall clock')
clock=1.01;gap:frame();assert(stage.next_stage==stage.stages[C.names[2]])
texts=0;gap:render();RenderFunc();assert(texts==0,'text during black transition')
enter(2);assert(item.patch==1 and lstg.lstg_ui.patch==1,'old module hooks accumulated')
assert(reimu_player.shoot()=='piercing')
keys[KEY.Z]=true;stage.next_stage=nil;C.go(3)
assert(C.reward and not stage.next_stage)
for i=1,300 do FrameFunc()end;assert(C.reward and not C.reward.exit,'held shoot skipped notice')
keys[KEY.Z]=false;FrameFunc();keys[KEY.Z]=true;FrameFunc();assert(C.reward.exit)
for i=1,29 do FrameFunc()end
assert(not C.reward and stage.next_stage==gap,'notice exit did not finish in30f')
keys={}
enter(3,'road-7300');assert(setting.y3_entry=='road-7300'and setting.y3_practice=='all')
assert(item.patch==1 and reimu_player.shoot==Y3Player.shoot)
enter(4,'non1');assert(not setting.marisa_road and setting.marisa_phase=='non1'and reimu_player.shoot==Y3Player.shoot)
enter(5,'final');assert(setting.hsob5_boss_only and setting.hsob5_boss_mode=='final')
enter(6,'kanako');assert(setting.nina_phase=='kanako')
assert(lstg.var.lifeleft==2 and lstg.var.bomb==3,'resource reset during handoff')
print('PASS actual control wrappers, source-hook isolation, six registrations, direct phase routing, resource carry, mandatory notice confirmation, 1s silent gap')
''')

source_dirs=['Stage12Normal','YuyukoStage3','Le03Stage4Normal','HSoBStage5Normal','MarisaMixed','NinaStage6Normal']
source_root=MOD.parent
hashes={str(p.relative_to(source_root)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest()
        for name in source_dirs for p in (source_root/name).rglob('*.lua')}
manifest=LOG/'revision/source-lua-sha256.json'
if manifest.exists():
    assert json.loads(manifest.read_text(encoding='utf-8'))==hashes,'Live source changed during final verification'
else:
    manifest.write_text(json.dumps(hashes,indent=2),encoding='utf-8')
print(f'PASS {len(hashes)} live source Lua hashes')
supplied=Path('C:/Users/Renko/AppData/Local/Temp/codex-clipboard-38cdf4ba-8b52-409b-9f94-8e2a5219592c.png')
assert (MOD/'art/yinyang.png').read_bytes()==supplied.read_bytes()
assert (MOD/'art/notice_bk.png').read_bytes()==(LOG/'th185-reference/notice/help/notice/notice_bk.png').read_bytes()
print('PASS supplied card and original TH185 notice texture exact bytes')
