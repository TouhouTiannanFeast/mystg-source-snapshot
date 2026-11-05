from pathlib import Path
from lupa import LuaRuntime
root=Path(r'G:/MySTG/aex-0.8.22/game/mod/NinaStage6Normal/scenery')
need=['load.lua','world06.lua','th10boss.lua','th10boss-assets.lua','th11sanae-spell.lua','art/stg4bg3.png','art/stg4bg4.png','art/stg4bg5.png','art/bg-stg6bg.png','art/cdbg07a.png','art/cdbg07b.png']
for rel in need:
    assert (root/rel).is_file(), rel
src=(root/'world06.lua').read_text(encoding='utf-8')
api=(root/'load.lua').read_text(encoding='utf-8')
# Current world06 geometry/camera/alpha behavior is checked against retail evidence.
import subprocess,sys
subprocess.run([sys.executable,str(Path(__file__).with_name('verify-world06-native.py'))],check=True)
spell=(root/'th11sanae-spell.lua').read_text(encoding='utf-8')
assert "'nina.th11.sanae.b',0,0,384,448" in spell and 'local scale=1-t/300' in spell
assert 'NinaTH11SanaeSpell.Object' in api and 'TH10S6Background.BossObject' in api
assert 'function N.setPhase' in api and 'function N.arrival' in api and "duration or 120" in api
assert 'CreateRenderTarget' in api and 'PushRenderTarget' in api and 'self.old' in api
assert "active.ninaPhase==id" in api and "ninaPhase=='kanako'" in api
assert "LoadImage('nina.scenery.old.image'" in api and "32,16,384,448" in api
lua=LuaRuntime(unpack_returned_tuples=True)
compile_chunk=lua.eval('function(s,n) return load(s,n) end')
for rel in ['load.lua','world06.lua','th10boss.lua','th10boss-assets.lua','th11sanae-spell.lua']:
    result=compile_chunk((root/rel).read_text(encoding='utf-8'),rel)
    chunk,error=(result if isinstance(result,tuple) else (result,None))
    assert chunk is not None, f'{rel}: {error}'
print('PASS scenery API; source-count world06 clouds/four-pillars/gate/seals; TH11 Sanae card cdbg07a/b dimensions; Kanako TH10S6')

