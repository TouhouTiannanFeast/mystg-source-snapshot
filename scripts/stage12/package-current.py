from pathlib import Path
import shutil,json,uuid,datetime,hashlib,zipfile
r=Path('G:/MySTG');src=r/'aex-0.8.22/game';stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S');name='Stage12-Playtest-'+stamp;dest=r/'builds'/name;game=dest/'game';game.mkdir(parents=True)
log=r/'work/logs/stage12/package-current'/stamp;log.mkdir(parents=True)
# Preserve every production byte, including JSON, source provenance, and collision/audio plugins.
source_rows={};files=[]
for n in ('LuaSTGSub.exe','d3dcompiler_47.dll','xaudio2_9redist.dll','launch','config.json'):files.append(src/n)
for n in ('packages','plugins','mod/Stage12Normal'):files.extend(p for p in (src/n).rglob('*')if p.is_file())
for p in files:
 rel=p.relative_to(src);data=p.read_bytes();sha=hashlib.sha256(data).hexdigest();out=game/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(data);source_rows[str(rel).replace('\\','/')]=sha
# Isolate the application instance; production scripts/resources remain byte-identical.
config=json.loads((game/'config.json').read_text(encoding='utf-8'));config['application_instance_id']=str(uuid.uuid4());(game/'config.json').write_text(json.dumps(config,indent=2),encoding='utf-8')
settings=json.loads((src/'userdata/setting.json').read_text(encoding='utf-8'));allowed=('keys','keys2','keysys','resx','resy','vsync','timezone','sevolume','bgmvolume','locale')
fresh={k:settings[k]for k in allowed if k in settings};fresh.update(username='User',mod='Stage12Normal',last_mod='Stage12Normal',windowed=True,sevolume=100)
(game/'userdata').mkdir();(game/'userdata/setting.json').write_text(json.dumps(fresh,ensure_ascii=False,indent=2),encoding='utf-8')
launcher=(r/'start-stage12-practice.ps1').read_text(encoding='utf-8-sig');old="$practiceRoot=Join-Path $PSScriptRoot 'aex-0.8.22\\game'";assert old in launcher;launcher=launcher.replace(old,'$practiceRoot=$PSScriptRoot').replace('当前 LuaSTG 游戏窗口','当前游戏窗口')
first,body=launcher.split('\n',1);launcher=first+'\ntry {\n'+body+'''\n} catch {\n Add-Type -AssemblyName System.Windows.Forms\n [void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'启动失败')\n}\n''';(game/'start-playtest.ps1').write_text(launcher,encoding='utf-8-sig')
(dest/'开始试玩.cmd').write_bytes(b'@echo off\r\nstart "" powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0game\\start-playtest.ps1" %*\r\n')
(dest/'试玩说明.txt').write_text('当前一、二面试玩包\n\n先解压整个文件夹，再双击「开始试玩.cmd」。无需另外安装LuaSTG、Python或开发工具。适用于Windows。\n\n选择「一面·开头」可玩完整前二面；也可以选任意道中、非符或符卡作为起点，打完后会继续后面的内容。\n无敌默认开启：撞弹不扣残机、不触发全屏消弹。要检查中弹判定，请取消勾选「无敌」。\n\n方向键移动；Shift低速；Z射击；X符卡；Esc暂停。调整起点或无敌设置前，请关闭游戏后重新启动。\n\n请不要单独移动启动文件或删除game目录里的文件。存档、录像和设置保存在game/userdata；包中不含开发者的存档。\n游戏数据为打包时的当前版本，本次打包没有调整血量、时限、弹幕或判定。\n\n东方Project素材著作权归上海爱丽丝幻乐团。本包供私人试玩。引擎版权与许可证见game/licenses。\n',encoding='utf-8-sig')
lic=game/'licenses';lic.mkdir();shutil.copy2(r/'aex-0.8.22/doc/LICENSE',lic/'LuaSTG-AEX-LICENSE.txt');shutil.copy2(r/'aex-0.8.22/doc/README.md',lic/'LuaSTG-AEX-README.md')
# Ensure no file changed under us while taking the snapshot, or silently vanished.
for rel,sha in source_rows.items():
 assert hashlib.sha256((src/rel).read_bytes()).hexdigest()==sha,'Source changed during packaging: '+rel
 if rel!='config.json':assert hashlib.sha256((game/rel).read_bytes()).hexdigest()==sha,'Copy mismatch: '+rel
entries=json.loads((game/'mod/Stage12Normal/practice-entries.json').read_text(encoding='utf-8'));assert len(entries)==15
for n in ('se_enep00.wav','se_enep01.wav','se_enep02.wav'):assert (game/'packages/thlib-resources/THlib/se'/n).is_file()
manifest={str(p.relative_to(dest)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest()for p in dest.rglob('*')if p.is_file()}
(game/'package-manifest.json').write_text(json.dumps({'built':stamp,'files':manifest,'source_files':source_rows,'notes':'All production scripts/resources are byte-identical; config instance ID and fresh settings are deployment-only.'},ensure_ascii=False,indent=2),encoding='utf-8')
archive=dest.with_suffix('.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6)as z:
 for p in sorted(dest.rglob('*')):
  if p.is_file():z.write(p,str(p.relative_to(dest.parent)))
with zipfile.ZipFile(archive)as z:
 assert z.testzip() is None
 for rel,sha in manifest.items():assert hashlib.sha256(z.read(name+'/'+rel)).hexdigest()==sha,'Archive mismatch: '+rel
qa=r/'work/package-check'/stamp/'试玩包 解压核对';qa.mkdir(parents=True)
with zipfile.ZipFile(archive)as z:z.extractall(qa)
for rel,sha in manifest.items():assert hashlib.sha256((qa/name/rel).read_bytes()).hexdigest()==sha,'Extraction mismatch: '+rel
report={'archive':str(archive),'folder':str(dest),'extracted':str(qa/name),'source_files':len(source_rows),'files':len(manifest)+1,'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'copied_all_source_files':True,'archive_readback':True,'extraction_readback':True,'entries':15,'death_sounds':['enep00','enep01','enep02'],'gameplay_unchanged':True}
(log/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');(r/'work/logs/stage12/package-current/latest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
