from pathlib import Path
import shutil,json,uuid,datetime
r=Path('G:/MySTG');src=r/'aex-0.8.22/game';dest=r/'builds'/('Stage12-Playtest-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'));game=dest/'game';game.mkdir(parents=True)
for name in ['LuaSTGSub.exe','d3dcompiler_47.dll','xaudio2_9redist.dll','launch','config.json']:shutil.copy2(src/name,game/name)
for name in ['packages','plugins']:shutil.copytree(src/name,game/name)
mod=game/'mod/Stage12Normal';mod.parent.mkdir();mod.mkdir()
source=src/'mod/Stage12Normal'
for path in source.rglob('*'):
 if not path.is_file():continue
 rel=path.relative_to(source)
 if rel.parts[0]=='source' or path.suffix=='.json' or path.name=='README.md':continue
 out=mod/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,out)
(game/'userdata').mkdir()
config=json.loads((game/'config.json').read_text(encoding='utf-8'));config['application_instance_id']=str(uuid.uuid4());(game/'config.json').write_text(json.dumps(config,indent=2),encoding='utf-8')
# Keep root UI to one obvious action and a short guide.
(dest/'开始游戏.cmd').write_bytes(b'@echo off\r\ncd /d "%~dp0game"\r\nLuaSTGSub.exe "setting.mod=\'Stage12Normal\'; setting.windowed=true; start_game=true"\r\nif errorlevel 1 pause\r\n')
(dest/'试玩说明.txt').write_text('解压整个文件夹后，双击「开始游戏.cmd」。无需安装LuaSTG。\n\n方向键移动，Shift低速，Z射击，X使用符卡，Esc暂停或重新开始。\n一面通关后自动进入二面。请勿把启动文件单独移出文件夹。\n需要Windows；建议解压到可写目录。录像与设置会保存在game/userdata。\n\n这是当前一、二面试玩版。长上下文结界：50秒、1000血、每批25发，首框固定向上，后续背向自机，旧弹保留。\n图片和音乐含用户本地提供的东方Project素材，原作著作权归上海爱丽丝幻乐团；本包供试玩。引擎版权与许可见game/licenses。\n',encoding='utf-8-sig')
licenses=game/'licenses';licenses.mkdir();shutil.copy2(r/'aex-0.8.22/doc/LICENSE',licenses/'LuaSTG-AEX-LICENSE.txt');shutil.copy2(r/'aex-0.8.22/doc/README.md',licenses/'LuaSTG-AEX-README.md')
(r/'work/logs/stage12/package').mkdir(exist_ok=True)
(r/'work/logs/stage12/package/path.txt').write_text(str(dest),encoding='utf-8')
print(dest)
