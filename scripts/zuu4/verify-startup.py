"""Check only the encounter timer lifecycle used by the startup callback."""
from pathlib import Path
import sys

sys.path.insert(0, 'G:/MySTG/work/resource-test-deps')
from lupa.lua51 import LuaRuntime

root = Path('G:/MySTG/aex-0.8.22/game/mod/MySTG/stages/zuu4')
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute((root / 'runtime.lua').read_text(encoding='utf-8-sig'))
lua.execute('boss={card={New=function() return {} end}}; Zuu4Specs={non1={hold=300,time=70,hp=5777}}')
host = (root / 'host.lua').read_text(encoding='utf-8-sig')
card_factory = host[host.index('local function card(id,index)'):host.index('local ZuuDamage=Class(boss)')]
lua.execute('local R,S=Zuu4R,{}\n' + card_factory + '\nStartupCard=card("non1",1)')
lua.execute('''
assert(Zuu4R.tick == 0)
local o={timer=1}
StartupCard.frame(o)
assert(o.timer==0, 'pre-init timer hold')
Zuu4R.tick=300; o.timer=1
StartupCard.frame(o)
assert(o.timer==1, 'normal timer release')
''')
print('PASS actual card.frame before card.init; timer hold and release unchanged')
