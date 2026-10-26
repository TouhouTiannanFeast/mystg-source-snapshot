from pathlib import Path
import shutil
root=Path('G:/MySTG'); mods=root/'aex-0.8.22/game/mod'; target=mods/'Stage12Normal'

assert not target.exists(), 'Initial scaffold only; preserve the integrated playable mod.'
shutil.copytree(mods/'Stage2Full',target)
def put(p,s): p.write_text(s,encoding='utf-8')
s1=target/'stage1';s1.mkdir(exist_ok=True)
for name in ['host.lua','geometry.lua','enemies.lua','boss.lua','stage.lua','provenance.json']:
 shutil.copy2(mods/'TH14Stage1Normal'/name,s1/name)
# Avoid require('geometry') cache collisions across the three imported patterns.
h=(s1/'host.lua').read_text(encoding='utf-8');h=h.replace("T.g=require('geometry')","T.g=dofile('mod/Stage12Normal/stage1/geometry.lua')")
put(s1/'host.lua',h)
m=mods/'MomijiNon1'
shutil.copy2(m/'momiji.png',target/'momiji.png');shutil.copy2(m/'pattern.lua',s1/'momiji-pattern.lua')
s=(m/'root.lua').read_text(encoding='utf-8');s=s[s.index('local P=MomijiPattern'):s.index('local Hud=Class(object)')]
s += '\nStage1Momiji={Boss=Momiji,clean=clean,state=D}\n'
put(s1/'momiji.lua',s)
a=(mods/'DeepSeekAbyss'/'root.lua').read_text(encoding='utf-8')
# Include only context attack and rendering; omit every other attack and practice stage.
s="local G=dofile('mod/Stage12Normal/stage1/context-geometry.lua')\nCopyImage('abyss.context.line','white')\n"
s+=a[a.index('local A='):a.index('local Mark=')]
s=s.replace("local labels={'SONAR RINGS','QUERY TRACKING','CONTEXT / POWER RESONANCE','ABYSSAL MIGRATION'}\n",'')
s=s[:s.index("    elseif self.mode=='wall' then")]+s[s.index("    elseif self.mode=='echo' then"):]
s=s[:s.index("    elseif self.mode=='whale' then")]+s[s.index('    end\n    self.age=self.age+1'):]
s+=a[a.index('local function start_context()'):a.index('local function set_whale')]
s+='''
local function reset()
 clear();A.phase=3;A.local_tick=0;A.tick=0;A.impacts={}
 A.stats={spawned=0,deleted=0,killed=0,bounces=0,echo_cycles=0,echo_arcs=0,echo_releases=0}
end
Stage1Context={clean=function() clear();A.phase=0;A.impacts={} end,render=render_context,state=A}
function Stage1Context.card()
 local c=boss.card.New('长上下文结界',1,2,15,1500,{5,5,0},false)
 c.init=function(o)
  th14.clean_bullets();th14.clean_actors();reset();th14.stats.phases=th14.stats.phases+1
  th14.label='Long Context Barrier';o.th14_phase='context'
  print('TH14 PHASE START context frame='..th14.stage_frames)
  task.New(o,function()
   for t=0,899 do A.local_tick=t;A.tick=t;context(o,t);task.Wait(1) end
  end)
 end
 c.del=function(o)
  Stage1Context.clean();th14.stats.ended=th14.stats.ended+1
  print('TH14 PHASE END context frame='..th14.stage_frames..' arcs='..A.stats.echo_arcs..' releases='..A.stats.echo_releases)
 end
 return c
end
'''
put(s1/'context.lua',s)
g=(mods/'DeepSeekAbyss'/'geometry.lua').read_text(encoding='utf-8')
geom='local G={}\nlocal function clamp(v,a,b) return math.max(a,math.min(b,v)) end\n'
geom+=g[g.index('function G.bounce'):g.index('function G.edge')]
geom+=g[g.index('G.echo_period='):g.index('function G.pose')]
put(s1/'context-geometry.lua',geom+'\nreturn G\n')
b=(s1/'boss.lua').read_text(encoding='utf-8').replace("T.card('tail')","Stage1Context.card()")
put(s1/'boss.lua',b)
s=(s1/'stage.lua').read_text(encoding='utf-8').replace('local mb=New(T.Wakasagi,true)','local mb=New(Stage1Momiji.Boss)')
s=s.replace("T.clean(); T.finished=true", "T.clean();Stage1Momiji.clean();Stage1Context.clean(); T.finished=true")
s=s.replace("function() T.clean() end)","function() T.clean();Stage1Momiji.clean();Stage1Context.clean() end)")
put(s1/'stage.lua',s)
s=(target/'root.lua').read_text(encoding='utf-8'); runner=s[:s.index("stage.group.New('Normal'")]
runner=runner.replace("Include('THlib.lua')\n",'')
put(target/'stage2-run.lua',runner)
put(target/'root.lua','''Include('THlib.lua')
Include('stage1/host.lua')
Include('stage1/enemies.lua')
Include('stage1/momiji-pattern.lua')
Include('stage1/momiji.lua')
Include('stage1/context.lua')
Include('stage1/boss.lua')
Include('stage1/stage.lua')
Include('stage2-run.lua')
stage.group.AddStage('Normal','Stage Two@Normal',nil,true)
stage.group.DefStageFunc('Stage Two@Normal','init',function(s)
 Stage2Route.finished=false
 stage.group.initTask(s,function() Stage2FullRun(s) end)
end)
stage.group.DefStageFunc('Stage Two@Normal','del',Stage2FullAPI.clean)
local Field=Class(object)
function Field:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY_BULLET-1,false,false end
function Field:render() Stage1Context.render() end
local oldInit=stage.stages['Misty Lake@Normal'].init
stage.stages['Misty Lake@Normal'].init=function(s) oldInit(s);New(Field) end
stage_init.frame=function(s)
 if s.timer==30 then
  lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
  stage.group.Start('Normal')
 end
end
local previousAfter=AfterFrame
AfterFrame=function()
 previousAfter()
 local st=stage.current_stage
 if st and st.name=='Misty Lake@Normal' then th14.stage_frames=th14.stage_frames+1 end
 if setting.stage12_test and IsValid(player) then
  player.protect=1000
  if setting.stage12_kill and _boss and IsValid(_boss) and _boss.is_combat and _boss.__card_timer>300 then _boss.hp=0 end
 end
end
if setting.stage12_test then
 local previousFrame=DoFrame
 DoFrame=function(...) for i=1,8 do previousFrame(...) end end
 local previousMenu=stage_menu.frame
 stage_menu.frame=function(s)
  previousMenu(s)
  if th14.finished and Stage2Route.finished and s.timer>=30 then print('STAGE12 COMPLETE');stage.Set('stage.quit') end
 end
 local seen={}
 local previousRender=RenderFunc
 RenderFunc=function()
  previousRender()
  local st=stage.current_stage;local phase=st and st.name or 'menu'
  if _boss and IsValid(_boss) and _boss.__card_timer>240 then phase=phase..'/'..(_boss.th14_phase or Stage2Route.phase) end
  if not seen[phase] then
   seen[phase]=true
   local path='userdata/snapshot/stage12-'..tostring(#Stage12Captures+1)..'.jpg'
   Stage12Captures[#Stage12Captures+1]=path;lstg.Snapshot(path);print('STAGE12 SNAPSHOT '..path..' '..phase)
  end
 end
end
Stage12Captures={}
''')
put(root/'start-stage12.ps1', '''$ErrorActionPreference='Stop'
$stage12Game=Join-Path $PSScriptRoot 'aex-0.8.22\\game'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Close the running LuaSTG game first.'}
$stage12Args="setting.mod='Stage12Normal'; setting.windowed=true; start_game=true"
Start-Process -FilePath (Join-Path $stage12Game 'LuaSTGSub.exe') -WorkingDirectory $stage12Game -ArgumentList ('"'+$stage12Args+'"') -WindowStyle Normal
''')
put(root/'start-stage12.cmd','@echo off\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-stage12.ps1"\nif errorlevel 1 pause\n')
print('Prepared isolated Stage12Normal')


