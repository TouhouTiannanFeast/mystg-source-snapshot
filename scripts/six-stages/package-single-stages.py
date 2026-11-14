from pathlib import Path
import datetime,hashlib,json,shutil,uuid,zipfile,re,subprocess,time,sys
R=Path('G:/MySTG');SRC=R/'aex-0.8.22/game';STAMP=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
LOG=R/('work/logs/six-stages/package-stage5-20261113' if '--stage5' in sys.argv else 'work/logs/six-stages/package-single-20261113');LOG.mkdir(parents=True,exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def replace(s,a,b):
 assert s.count(a)==1,(a,s.count(a));return s.replace(a,b)
reports=[]
targets=[(5,['HSoBStage5Normal'])] if '--stage5' in sys.argv else [(3,['YuyukoStage3','Le03Stage4Normal']),(6,['NinaStage6Normal'])]
for n,mods in targets:
 name=f'Stage{n}-NoStory-{STAMP}';dest=R/'builds'/name;game=dest/'game';game.mkdir(parents=True)
 files=[SRC/p for p in ['LuaSTGSub.exe','d3dcompiler_47.dll','xaudio2_9redist.dll','launch','config.json']]
 for root in ['packages','plugins']+['mod/'+m for m in mods]:files += [p for p in (SRC/root).rglob('*') if p.is_file()]
 if n in (5,6):files.append(SRC/'mod/YuyukoStage3/art/player/th13-pl00.png')
 camp=SRC/'mod/SixStageCampaign'
 for p in camp.rglob('*'):
  rel=p.relative_to(camp)
  if not p.is_file():continue
  if rel.parts[0].startswith(('dialogue','screenplay')) or rel.name.startswith('probe-'):continue
  if rel.parts[0]=='art' and rel.name in ['yinyang.png','notice_bk.png']:continue
  if p.suffix in ['.md','.json']:continue
  files.append(p)
 sources={}
 for p in files:
  rel=p.relative_to(SRC);out=game/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,out);sources[rel.as_posix()]=sha(p)
 M=game/'mod/SixStageCampaign'
 root=(M/'root.lua').read_text('utf-8-sig')
 root="Include('THlib.lua')\n"+root[root.index("LoadTexture('six.items'"):]
 root='\n'.join(s for s in root.splitlines() if 'dialogue' not in s and 'screenplay' not in s and 'six_story' not in s and 'six_combat_probe' not in s and 'six_resource_probe' not in s)+'\n'
 (M/'root.lua').write_text(root,'utf-8')
 c=(M/'campaign.lua').read_text('utf-8-sig')
 c=replace(c,"if C.index<6 then C.go(C.index+1)else C.complete=true;stage.Set('SixStageGap','none')end","C.complete=true;stage.Set('SixStageGap','none')")
 c=replace(c,"for i,name in ipairs(C.names)do",f"for i,name in pairs({{[{n}]=C.names[{n}]}})do")
 c=replace(c,"C.target=math.max(1,math.min(6,i));C.entry=entry or'full'",f"C.target={n};C.entry=entry or'full'")
 c=replace(c,"C.target=math.max(1,math.min(6,tonumber(index)or 1))",f"C.target={n}")
 c=replace(c,"C.choice=(C.choice+4)%6+1",f"C.choice={n}")
 c=replace(c,"C.choice=C.choice%6+1",f"C.choice={n}")
 c=replace(c,"for i=1,6 do RenderText",f"for i={n},{n} do RenderText")
 (M/'campaign.lua').write_text(c,'utf-8')
 menu=(M/'frontend/menu.lua').read_text('utf-8-sig')
 point='\nfunction M.switch(page,action)'
 filtering=f"\nlocal only={{}};for _,e in ipairs(M.entries)do if e.stage=={n} then e.label=e.label:gsub(' → 六面','');only[#only+1]=e end end;M.entries=only\n"
 menu=replace(menu,point,filtering+point)
 (M/'frontend/menu.lua').write_text(menu,'utf-8')
 config=json.loads((game/'config.json').read_text('utf-8'));config['application_instance_id']=str(uuid.uuid4());(game/'config.json').write_text(json.dumps(config,indent=2),'utf-8')
 settings=json.loads((SRC/'userdata/setting.json').read_text('utf-8'))
 fresh={k:settings[k] for k in ['keys','keys2','keysys','resx','resy','vsync','timezone','sevolume','bgmvolume','locale'] if k in settings}
 fresh.update(username='User',mod='SixStageCampaign',last_mod='SixStageCampaign',windowed=True)
 (game/'userdata').mkdir();(game/'userdata/setting.json').write_text(json.dumps(fresh,ensure_ascii=False,indent=2),'utf-8')
 for title,direct in [('开始游戏',True),('选择阶段',False)]:
  args=f"setting.mod='SixStageCampaign';setting.six_stage={n};setting.six_entry='full';setting.six_direct={'true' if direct else 'false'};setting.six_invincible=false;setting.six_speed=1;setting.windowed=true;start_game=true"
  (dest/(title+'.cmd')).write_bytes(('@echo off\r\ncd /d "%~dp0game"\r\nLuaSTGSub.exe "'+args+'"\r\nif errorlevel 1 pause\r\n').encode('ascii'))
 (dest/'试玩说明.txt').write_text(f'''第{n}面独立便携版（无剧情）\n\n完整解压，双击「开始游戏.cmd」。双击「选择阶段.cmd」进入标题菜单，选 Practice 可练本关各阶段。\n方向键移动，Shift低速，Z射击，X雷，Esc暂停。F5重开本关，F6切换无敌，F7切换1/4/8倍速度。\n本包取自2026-11-13当前六面连战的战斗、音效、资源及机体规则。移除剧情脚本、对话及立绘。关底结束保留240帧拾取，随后返回标题，不进入其他面。\n不含开发者存档、录像。你的设置与录像保存在game/userdata。需要Windows，无需安装开发工具。\n本包已做启动与局部入口检查，未整关手动通关。东方原素材版权归原作者，引擎许可证见game/licenses。\n''','utf-8-sig')
 lic=game/'licenses';lic.mkdir()
 for f in ['LICENSE','README.md']:shutil.copy2(R/'aex-0.8.22/doc'/f,lic/('LuaSTG-AEX-'+f))
 modified={}
 for rel,h in sources.items():
  assert sha(SRC/rel)==h,'live source changed '+rel
  if sha(game/rel)!=h:modified[rel]=sha(game/rel)
 assert set(modified)=={'config.json','mod/SixStageCampaign/root.lua','mod/SixStageCampaign/campaign.lua','mod/SixStageCampaign/frontend/menu.lua'}
 assert not list(M.glob('dialogue*'))
 manifest={p.relative_to(dest).as_posix():sha(p) for p in dest.rglob('*') if p.is_file()}
 (dest/'package-manifest.json').write_text(json.dumps(dict(stage=n,no_story=True,source_files=sources,package_files=manifest,package_only_changes=modified),ensure_ascii=False,indent=2),'utf-8')
 archive=dest.with_suffix('.zip')
 with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6)as z:
  for p in sorted(dest.rglob('*')):
   if p.is_file():z.write(p,name+'/'+p.relative_to(dest).as_posix())
 qa=R/'work/package-check/single-stages'/STAMP
 with zipfile.ZipFile(archive)as z:
  assert z.testzip() is None;z.extractall(qa)
 extract=qa/name
 for rel,h in manifest.items():assert sha(extract/rel)==h,rel
 assert sha(extract/'package-manifest.json')==sha(dest/'package-manifest.json')
 report=dict(stage=n,folder=str(dest),archive=str(archive),extracted=str(extract),bytes=archive.stat().st_size,sha256=sha(archive),source_files=len(sources),files=len(manifest),archive_readback=True,extraction_readback=True,changed_files=modified)
 reports.append(report);print(json.dumps(report,ensure_ascii=False),flush=True)
 (LOG/'packages.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2),'utf-8')
