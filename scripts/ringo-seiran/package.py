from pathlib import Path
import datetime, hashlib, json, shutil, uuid, zipfile

r=Path('G:/MySTG'); src=r/'aex-0.8.22/game'
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
name='RingoSeiran-Portable-'+stamp; dest=r/'builds'/name; game=dest/'game'
game.mkdir(parents=True)
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
files=[src/n for n in ('LuaSTGSub.exe','d3dcompiler_47.dll','xaudio2_9redist.dll','launch','config.json')]
for n in ('packages','plugins','mod/RingoSeiran'):
    files.extend(p for p in (src/n).rglob('*') if p.is_file())
rows={}
for p in files:
    rel=p.relative_to(src); out=game/rel; out.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(p,out); rows[rel.as_posix()]=digest(p)
config=json.loads((game/'config.json').read_text(encoding='utf-8'))
config['application_instance_id']=str(uuid.uuid4())
(game/'config.json').write_text(json.dumps(config,indent=2),encoding='utf-8')
settings=json.loads((src/'userdata/setting.json').read_text(encoding='utf-8'))
allowed=('keys','keys2','keysys','resx','resy','vsync','timezone','sevolume','bgmvolume','locale')
fresh={k:settings[k] for k in allowed if k in settings}
fresh.update(username='User',mod='RingoSeiran',last_mod='RingoSeiran',windowed=True)
(game/'userdata').mkdir()
(game/'userdata/setting.json').write_text(json.dumps(fresh,ensure_ascii=False,indent=2),encoding='utf-8')
for filename,phase in [('开始游戏.cmd','all'),('非符练习.cmd','nonspell'),('符卡练习.cmd','spell')]:
    launcher='@echo off\r\ncd /d "%~dp0game"\r\nLuaSTGSub.exe "setting.mod=\'RingoSeiran\'; setting.rs_practice=\''+phase+'\'; setting.rs_seed=20261102; setting.windowed=true; start_game=true"\r\nif errorlevel 1 pause\r\n'
    (dest/filename).write_bytes(launcher.encode('ascii'))
(dest/'试玩说明.txt').write_text('铃瑚＋清兰 独立Boss便携版\n\n请先完整解压ZIP，再双击「开始游戏.cmd」。适用于Windows，无需安装LuaSTG、Python或开发工具。\n「非符练习.cmd」「符卡练习.cmd」分别进入对应阶段。\n\n方向键移动；Z射击；Shift低速；X使用Bomb；Esc暂停。\n非符13000血、30秒，实际击破掉落1个完整B。符卡15000血、45秒，清兰仅在符卡登场；开幕为铃瑚对白180帧→清兰飞入60帧→清兰对白180帧→蓄力120帧，随后同时发弹与追击。45秒包含开幕。落锤发出六组三角形铳弹（每组6颗）和6颗红边白芯原版环玉，环玉从铳弹组之间飞出，靠近自机24像素后渐隐；每次落锤交替显示“씨”“발”点弹排字特效。\n保留当前全部弹幕、音效、伤害与判定；Bomb仍为当前原数值。蓄力画面为120帧本地适配，并非原动画逐帧移植。\n\n请保留整个文件夹结构，解压到可写目录；设置和录像保存在game/userdata。本包不含开发者存档、录像。\n东方Project素材版权归上海爱丽丝幻乐团；供私人试玩。引擎许可证见game/licenses。\n',encoding='utf-8-sig')
lic=game/'licenses';lic.mkdir()
for n in ('LICENSE','README.md'): shutil.copy2(r/'aex-0.8.22/doc'/n,lic/('LuaSTG-AEX-'+n))
for rel,sha in rows.items():
    assert digest(src/rel)==sha, 'Source changed: '+rel
    if rel!='config.json': assert digest(game/rel)==sha, 'Copy mismatch: '+rel
manifest={p.relative_to(dest).as_posix():digest(p) for p in dest.rglob('*') if p.is_file()}
(game/'package-manifest.json').write_text(json.dumps({'built':stamp,'files':manifest,'source_files':rows,'gameplay_unchanged':True},ensure_ascii=False,indent=2),encoding='utf-8')
archive=dest.with_suffix('.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in sorted(dest.rglob('*')):
        if p.is_file(): z.write(p,name+'/'+p.relative_to(dest).as_posix())
qa=r/'work/package-check/ringo-seiran'/stamp/'便携版 解压检查'
qa.mkdir(parents=True)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for rel,sha in manifest.items(): assert hashlib.sha256(z.read(name+'/'+rel)).hexdigest()==sha
    z.extractall(qa)
for rel,sha in manifest.items(): assert digest(qa/name/rel)==sha
report={'archive':str(archive),'folder':str(dest),'extracted':str(qa/name),'bytes':archive.stat().st_size,'sha256':digest(archive),'source_files':len(rows),'files':len(manifest)+1,'archive_readback':True,'extraction_readback':True,'gameplay_unchanged':True}
log=r/'work/logs/ringo-seiran';log.mkdir(parents=True,exist_ok=True)
(log/'package-latest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
