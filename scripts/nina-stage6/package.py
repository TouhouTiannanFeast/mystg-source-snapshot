"""Build the NinaStage6Normal portable package (bundled LuaSTG runtime)."""
from pathlib import Path
import datetime, hashlib, json, os, shutil, subprocess, time, uuid, zipfile

R = Path('G:/MySTG')
src = R / 'aex-0.8.22/game'
stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
name = 'NinaStage6Normal-Portable-' + stamp
dest = R / 'builds' / name
game = dest / 'game'
game.mkdir(parents=True)


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


files = [src / n for n in ['LuaSTGSub.exe', 'd3dcompiler_47.dll', 'xaudio2_9redist.dll', 'launch', 'config.json']]
for n in ['packages', 'plugins', 'mod/NinaStage6Normal']:
    files.extend(p for p in (src / n).rglob('*') if p.is_file())
rows = {}
for p in files:
    rel = p.relative_to(src)
    out = game / rel
    out.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, out)
    rows[rel.as_posix()] = sha(p)

config = json.loads((game / 'config.json').read_text(encoding='utf-8'))
config['application_instance_id'] = str(uuid.uuid4())
(game / 'config.json').write_text(json.dumps(config, indent=2), encoding='utf-8')

settings = json.loads((src / 'userdata/setting.json').read_text(encoding='utf-8'))
fresh = {k: settings[k] for k in ['keys', 'keys2', 'keysys', 'resx', 'resy', 'vsync', 'timezone', 'sevolume', 'bgmvolume', 'locale'] if k in settings}
fresh.update(username='User', mod='NinaStage6Normal', last_mod='NinaStage6Normal', windowed=True)
(game / 'userdata').mkdir()
(game / 'userdata/setting.json').write_text(json.dumps(fresh, ensure_ascii=False, indent=2), encoding='utf-8')

launcher = ('@echo off\r\ncd /d "%~dp0game"\r\n'
            'LuaSTGSub.exe "setting.mod=\'NinaStage6Normal\'; setting.nina_phase=\'all\'; setting.nina_seed=20261104; '
            'setting.nina_test=false; setting.nina_invincible=false; setting.windowed=true; start_game=true"\r\n'
            'if errorlevel 1 pause\r\n')
(dest / '开始游戏.cmd').write_bytes(launcher.encode('ascii'))

portable_ps1 = (R / 'start-nina-stage6.ps1').read_text(encoding='utf-8-sig')
portable_ps1 = portable_ps1.replace("Join-Path $PSScriptRoot 'aex-0.8.22\\game'", "Join-Path $PSScriptRoot 'game'")
assert "Join-Path $PSScriptRoot 'game'" in portable_ps1
(dest / 'start-nina-stage6.ps1').write_text(portable_ps1, encoding='utf-8-sig')
selector = ('@echo off\r\npowershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0start-nina-stage6.ps1" -Selector\r\n'
            'if errorlevel 1 pause\r\n')
(dest / '选择阶段.cmd').write_bytes(selector.encode('ascii'))

readme = '''渡里妮娜 六面 · Normal 便携版

完整解压 ZIP 到可写目录，再双击「开始游戏.cmd」。Windows 版，不需要安装 LuaSTG、Python 或任何开发工具；请保留整个文件夹结构。
想单独练某一段时双击「选择阶段.cmd」，可在窗口里选阶段并勾选「无敌观察」。

操作：方向键移动，Shift 低速，Z 射击，X Bomb，Esc 暂停。

内容：完整六面（道中 → 10 个 Boss 阶段 → 追加终符）。
当前血量：一非 10700 / 一符 18400 / 二非 10000 / 二符 12000 / 三非 18000 / 三符 11000 / 四非 11400 / 四符 15800 / 终符 30000 / 追加终符 48800。
召唤物：一符的人马埴轮 1300；一非/一符的芳香位（诹访子）4000；二非/二符的沉默诹访子 4000；四非使魔 300；终符使魔 4000/2100/1000/1000/1000/2100/4000（无敌）；神奈子六色球与发弹控制器 240。

只包含本关和所需运行文件，不含开发者存档或录像；设置与录像写在 game/userdata 里。本包为当前工作版本，建议重点试玩一符、四符（含埴轮血量）的手感。

东方 Project 原素材版权归上海爱丽丝幻乐团；本包按用户请求打包，供私人试玩。引擎许可证见 game/licenses。
'''
(dest / '试玩说明.txt').write_text(readme, encoding='utf-8-sig')

lic = game / 'licenses'
lic.mkdir()
for n in ['LICENSE', 'README.md']:
    shutil.copy2(R / 'aex-0.8.22/doc' / n, lic / ('LuaSTG-AEX-' + n))

for rel, h in rows.items():
    assert sha(src / rel) == h, 'Source changed: ' + rel
    if rel != 'config.json':
        assert sha(game / rel) == h, rel

manifest = {p.relative_to(dest).as_posix(): sha(p) for p in dest.rglob('*') if p.is_file()}
(game / 'package-manifest.json').write_text(json.dumps(dict(
    built=stamp, files=manifest, source_files=rows, gameplay_unchanged=True,
    portable_visual_change='none', launcher='开始游戏.cmd / 选择阶段.cmd'), ensure_ascii=False, indent=2), encoding='utf-8')

archive = dest.with_suffix('.zip')
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for p in sorted(dest.rglob('*')):
        if p.is_file():
            z.write(p, name + '/' + p.relative_to(dest).as_posix())

qa = R / 'work/package-check/nina-stage6' / stamp / '便携包 解压测试'
qa.mkdir(parents=True)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for rel, h in manifest.items():
        assert hashlib.sha256(z.read(name + '/' + rel)).hexdigest() == h, rel
    z.extractall(qa)
for rel, h in manifest.items():
    assert sha(qa / name / rel) == h, rel

# Smoke test the extracted copy: start one phase for a few seconds and check the log.
smoke = {'ran': False}
exe = qa / name / 'game' / 'LuaSTGSub.exe'
log = qa / name / 'game' / 'engine.log'
if os.environ.get('NINA_PKG_SKIP_SMOKE') == '1':
    smoke = {'skipped': True, 'reason': 'NINA_PKG_SKIP_SMOKE=1 (a game instance was running)'}
else:
  try:
    proc = subprocess.Popen([str(exe), "setting.mod='NinaStage6Normal'; setting.nina_phase='non1'; setting.nina_seed=20261104; "
                                        "setting.nina_test=false; setting.nina_invincible=true; setting.windowed=true; start_game=true"],
                            cwd=str(exe.parent))
    time.sleep(14)
    proc.terminate()
    try:
        proc.wait(timeout=10)
    except Exception:
        proc.kill()
    text = log.read_text(encoding='utf-8', errors='ignore') if log.exists() else ''
    smoke = {'ran': True, 'phase_seen': 'NINA PHASE non1' in text, 'log_bytes': len(text),
             'error_seen': any(s in text for s in ('[E]', 'Error', 'Lua Error'))}
    assert smoke['phase_seen'], 'portable smoke test: phase did not start'
  except Exception as e:
    smoke['error'] = str(e)

report = dict(archive=str(archive), folder=str(dest), extracted=str(qa / name),
              bytes=archive.stat().st_size, sha256=sha(archive),
              source_files=len(rows), files=len(manifest) + 1,
              archive_readback=True, extraction_readback=True, gameplay_unchanged=True, smoke=smoke)
logdir = R / 'work/logs/nina-stage6/package'
logdir.mkdir(parents=True, exist_ok=True)
(logdir / 'package-latest.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(report, ensure_ascii=False))
