"""Package the current mod byte-for-byte with isolated runtime and settings."""
from pathlib import Path
import datetime,hashlib,json,shutil,uuid,zipfile
R=Path('G:/MySTG');src=R/'aex-0.8.22/game'
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
name='TH11Stage6Normal-Portable-'+stamp;dest=R/'builds'/name;game=dest/'game'
game.mkdir(parents=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[src/n for n in ['LuaSTGSub.exe','d3dcompiler_47.dll','xaudio2_9redist.dll','launch','config.json']]
for n in ['packages','plugins','mod/TH11Stage6Normal']:files.extend(p for p in (src/n).rglob('*')if p.is_file())
rows={}
for p in files:
 rel=p.relative_to(src);out=game/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,out);rows[rel.as_posix()]=sha(p)
config=json.loads((game/'config.json').read_text(encoding='utf-8'));config['application_instance_id']=str(uuid.uuid4())
# Portable-only user request: hide the small bottom stage label.
root=game/'mod/TH11Stage6Normal/root.lua'
caption="function Hud:render()RenderText('menu',H.finished and 'ROAD COMPLETE' or 'TH11 STAGE 6 / NORMAL',0,-200,.22,'centerpoint')end"
source_root=root.read_text(encoding='utf-8');assert source_root.count(caption)==1
portable_root=source_root.replace(caption,'function Hud:render()end -- portable: stage caption hidden',1)
root.write_text(portable_root,encoding='utf-8')
(game/'config.json').write_text(json.dumps(config,indent=2),encoding='utf-8')
settings=json.loads((src/'userdata/setting.json').read_text(encoding='utf-8'))
fresh={k:settings[k]for k in ['keys','keys2','keysys','resx','resy','vsync','timezone','sevolume','bgmvolume','locale']if k in settings}
fresh.update(username='User',mod='TH11Stage6Normal',last_mod='TH11Stage6Normal',windowed=True)
(game/'userdata').mkdir();(game/'userdata/setting.json').write_text(json.dumps(fresh,ensure_ascii=False,indent=2),encoding='utf-8')
launcher='@echo off\r\ncd /d "%~dp0game"\r\nLuaSTGSub.exe "setting.mod=\'TH11Stage6Normal\'; setting.th11s6_checkpoint=0; setting.th11s6_invincible=false; setting.windowed=true; start_game=true"\r\nif errorlevel 1 pause\r\n'
(dest/'开始游戏.cmd').write_bytes(launcher.encode('ascii'))
(dest/'试玩说明.txt').write_text('地灵殿六面道中 Normal · 奶与蜜 便携版\n\n完整解压ZIP到可写目录，再双击「开始游戏.cmd」。Windows版，无需安装LuaSTG、Python或开发工具。请保留整个文件夹结构。\n\n方向键移动，Z射击，Shift低速，X使用Bomb，Esc暂停。默认非无敌，固定4P；道中Boss为诹访子非符12000HP/40秒→流淌着奶与蜜之地24000HP/50秒。\n\n包含当前版本：风神录EX背景、开幕两批乌鸦H发弹、蓝怨灵400/200HP、20帧出生保护、全蓝点、青蛙三帧动画与黄色特效/黄绿针弹、四段笑声和掉残笑声、四处残机奖励、原猫叫静音。首批乌鸦结束后笑声半音量，掉残笑声原音量，Boss登场/结束笑声双倍音量。具体说明见game/mod/TH11Stage6Normal/README.md。\n\n只包含本关及所需运行文件，不含开发者存档或录像；设置与录像存放在game/userdata。此包未做整关人工试玩，请重点检查四处残机收取、两阶段Boss衔接及音效听感。\n东方Project原素材版权归上海爱丽丝幻乐团；用户提供的青蛙及音效按本次便携打包请求一并收录，供私人试玩。引擎许可证见game/licenses。\n',encoding='utf-8-sig')
lic=game/'licenses';lic.mkdir()
for n in ['LICENSE','README.md']:shutil.copy2(R/'aex-0.8.22/doc'/n,lic/('LuaSTG-AEX-'+n))
for rel,h in rows.items():
 assert sha(src/rel)==h,'Source changed: '+rel
 if rel not in ['config.json','mod/TH11Stage6Normal/root.lua']:assert sha(game/rel)==h,rel
assert root.read_text(encoding='utf-8')==portable_root
manifest={p.relative_to(dest).as_posix():sha(p)for p in dest.rglob('*')if p.is_file()}
(game/'package-manifest.json').write_text(json.dumps(dict(built=stamp,files=manifest,source_files=rows,gameplay_unchanged=True,portable_visual_change='Hud.render no-op; bottom stage caption hidden; source mod unchanged'),ensure_ascii=False,indent=2),encoding='utf-8')
archive=dest.with_suffix('.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6)as z:
 for p in sorted(dest.rglob('*')):
  if p.is_file():z.write(p,name+'/'+p.relative_to(dest).as_posix())
qa=R/'work/package-check/th11-stage6'/stamp/'便携包 解压测试';qa.mkdir(parents=True)
with zipfile.ZipFile(archive)as z:
 assert z.testzip()is None
 for rel,h in manifest.items():assert hashlib.sha256(z.read(name+'/'+rel)).hexdigest()==h
 z.extractall(qa)
for rel,h in manifest.items():assert sha(qa/name/rel)==h
report=dict(archive=str(archive),folder=str(dest),extracted=str(qa/name),bytes=archive.stat().st_size,sha256=sha(archive),source_files=len(rows),files=len(manifest)+1,archive_readback=True,extraction_readback=True,gameplay_unchanged=True)
log=R/'work/logs/th11-stage6/package12';log.mkdir(parents=True,exist_ok=True)
(log/'package-latest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
