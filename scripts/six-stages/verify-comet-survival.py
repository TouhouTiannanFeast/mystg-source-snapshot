from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');GAME=R/'aex-0.8.22/game'
read=lambda p:p.read_text(encoding='utf-8-sig')
for p in ['combat-review.lua','dialogue2.lua','dialogue46.lua','dialogue2/probe.lua','probe-combat.lua']:
 LuaRuntime().execute('assert(loadstring(...))',read(GAME/'mod/SixStageCampaign'/p))
code=read(R/'scripts/six-stages/verify-combat-review.py')
exec(code[code.index('# Original boss result functions:'):code.index('# Every original road event')])
print('PASS changed Lua51 syntax and actual engine success/failure result functions')
