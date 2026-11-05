from pathlib import Path
import shutil,re,json,hashlib
r=Path(r'G:/MySTG');src=r/'aex-0.8.22/game/mod/TH11Stage6Normal';mod=r/'aex-0.8.22/game/mod/NinaStage6Normal';dst=mod/'road17';dst.mkdir(exist_ok=True)
skip={'root.lua','player.lua','player-config.lua','player-data.lua','power-lock.lua','README.md','reference.json'}
manifest={}
def prefix(s):
 s=re.sub(r"([\"'])(art|milk|music|voice|se)/",r'\1road17/\2/',s)
 return s
for p in src.rglob('*'):
 if not p.is_file():continue
 rel=p.relative_to(src)
 if rel.parts[0]=='source' or str(rel) in skip:continue
 q=dst/rel;q.parent.mkdir(parents=True,exist_ok=True)
 manifest[rel.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
 if p.suffix=='.lua':q.write_text(prefix(p.read_text(encoding='utf-8-sig')),encoding='utf-8')
 else:shutil.copy2(p,q)
# Voice miss trigger remains restricted to road, even in the combined stage.
p=dst/'voice.lua';s=p.read_text(encoding='utf-8');s=s.replace("if stage.current_stage and stage.current_stage.stage_name=='Subterranean Animism 6@Normal'", "if NinaRoad17.active and stage.current_stage and stage.current_stage.stage_name=='Nina Six@Normal'")
s=s.replace('function V.play(id,gain)','function V.play(id,gain)\n print(\'NINA ROAD VOICE \'..id..\' stageframe=\'..tostring(stage.current_stage and stage.current_stage.timer))');p.write_text(s,encoding='utf-8')
s=src.joinpath('root.lua').read_text(encoding='utf-8-sig');s=s[:s.index("stage.group.New('Normal'")]
s=s.replace("Include('THlib.lua')\nInclude('player.lua');Include('power-lock.lua')\n",'')
s=re.sub(r"if setting.th11s6_change\d+ then Include\([^\n]+\n",'',s)
s=re.sub(r"Include\('([^']+)'\)",lambda m:"Include('road17/"+m[1]+"')",s)
s=s.replace('R.start();New(TH11S6Background.Object);New(Hud)','R.start();New(TH11S6Background.Object)')
a=s.index(' if R.roadEnd then\n  TH11S6Voice.play(4)');b=s.index('\nend',a)
s=s[:a]+" H.finished=true\n"+s[b:]
s='NinaRoad17={active=false,pendingLaugh=false}\nlocal road=NinaRoad17\nlocal defaultMinor=item_faith_minor\n'+s
s+='''
-- Host's blue road cancel drops must not replace Boss cancel drops.
item_faith_minor=defaultMinor
function road.run(s)
 setting.th11s6_test=false
 setting.th11s6_invincible=setting.nina_invincible or setting.nina_test
 setting.th11s6_checkpoint=setting.nina_test and(tonumber(setting.nina_road_checkpoint)or 0)or 0
 setting.th11s6_test_earlyclear=false;setting.th11s6_test_killboss=false
 road.active=true;road.pendingLaugh=false;item_faith_minor=H.Minor
 print('NINA ROAD START checkpoint='..setting.th11s6_checkpoint)
 H.run(s)
 assert(R.roadEnd,'road must finish naturally before Boss')
 road.active=false;item_faith_minor=defaultMinor;road.pendingLaugh=true;road.endFrame=s.timer
 print('NINA ROAD END tick='..R.tick..' stageframe='..s.timer)
end
function road.arrived()
 if not road.pendingLaugh then return end
 road.pendingLaugh=false;TH11S6Voice.play(4)
 print('NINA LAUGH4 AFTER APPEAR stageframe='..stage.current_stage.timer)
end
function road.clean()
 clean();road.active=false;road.pendingLaugh=false;item_faith_minor=defaultMinor
end
'''
# Resource literals in the controller, e.g. optional resource paths.
s=prefix(s)
# prefix() must not prefix Include('road17/...') twice (it only matches listed paths).
(dst/'load.lua').write_text(s,encoding='utf-8')
(mod/'source/road17.json').write_text(json.dumps({'source':str(src),'files_sha256':manifest,'changes':['private resource prefix','single-stage controller','4th laugh deferred','road-only global hooks']},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
# Root integration: load all classes at startup, execute route only when selected.
p=mod/'root.lua';s=p.read_text(encoding='utf-8')
s=s.replace("Include('music06/load.lua')","Include('music06/load.lua');Include('road17/load.lua')")
s=s.replace(' musicStart();S.lastPos=nil;', ' NinaRoad17.clean();S.lastPos=nil;')
a=s.index("  NinaScenery.phase='normal';New(NinaScenery.Object);task.Wait(60)")
b=s.index('  for _,spec in ipairs(specs)',a)
s=s[:a]+'''  local list={};local selection=setting.nina_phase or'all'
  local withRoad=selection=='all'or selection=='road'or(setting.nina_test and setting.nina_road_probe)
  if withRoad then
   S.current='road';NinaRoad17.run(s)
   if selection=='road'then
    S.current=nil;S.finished=true;print('NINA COMPLETE');stage.group.FinishStage();return
   end
   S.current='road-wait';task.Wait(120)
   assert(s.timer-NinaRoad17.endFrame==120,'road-to-intro wait must be120 frames')
   print('NINA ROAD WAIT120 stageframe='..s.timer)
  end
  musicStart();NinaScenery.phase='normal';New(NinaScenery.Object)
  if not withRoad then task.Wait(60)end
  if selection=='boss'then selection='all'end
  S.onNinaArrival=NinaRoad17.arrived
''' +s[b:]
s=s.replace("stage.group.DefStageFunc('Nina Six@Normal','del',function(s)clean();musicStop()end)","stage.group.DefStageFunc('Nina Six@Normal','del',function(s)clean();musicStop();NinaRoad17.clean()end)")
p.write_text(s,encoding='utf-8')
p=mod/'intro12.lua';s=p.read_text(encoding='utf-8');s=s.replace('  NinaSuwako11.step(a)',"  NinaSuwako11.step(a)\n  if t==N.revealStart+41 and self.state.onNinaArrival then self.state.onNinaArrival()end")
p.write_text(s,encoding='utf-8')
# Launcher: only route choice, invincibility and the standard action buttons.
p=r/'start-nina-stage6.ps1';s=p.read_text(encoding='utf-8-sig')
s=s.replace("'all','non1'","'all','road','boss','non1'")
s=s.replace("'完整 Boss 战','一非", "'完整六面 · 道中 → Boss','仅道中','仅完整 Boss 战','一非")
s=s.replace("渡里妮娜 · 六面 Boss 练习","六面 · 道中与 Boss")
s=s.replace('Drawing.Size(490,235)','Drawing.Size(490,195)')
a=s.index(' $ninaHelp=');b=s.index(' $ninaStart=',a);s=s[:a]+s[b:]
a=s.index(' $ninaGallery=');b=s.index(' $ninaForm.Controls.AddRange',a);s=s[:a]+s[b:]
s=s.replace(',$ninaHelp','').replace(',$ninaGallery','').replace('Drawing.Point(264,181)','Drawing.Point(264,145)').replace('Drawing.Point(369,181)','Drawing.Point(369,145)')
p.write_text(s,encoding='utf-8-sig')
print('Built private road copy; merged controller; deferred cue;13-entry selector')
