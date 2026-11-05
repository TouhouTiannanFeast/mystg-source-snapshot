from pathlib import Path
import importlib

ROOT=Path(__file__).resolve().parents[3]
MOD=ROOT/'aex-0.8.22/game/mod/NinaStage6Normal/import10'
for backend in ('lua51','luajit21','lua54'):
    lua=importlib.import_module('lupa.'+backend).LuaRuntime(unpack_returned_tuples=True)
    lua.execute('math.atan2=math.atan2 or function(y,x)return math.atan(y,x)end')
    for name in ('pool.lua','runtime.lua','projectiles.lua','programs.lua','specs.lua','art.lua'):
        text=(MOD/name).read_text(encoding='utf-8')
        lua.execute('local f,e=(loadstring or load)(...);assert(f,e)',text)
        lua.execute(text)
    lua.execute('''
      assert(#Nina10Specs==4)
      local expected={non2=2400,spell2=4200,spell3=3600,kanako=9000}
      for _,s in ipairs(Nina10Specs) do
        assert(s.frames==expected[s.id] and s.x>=-192 and s.x<=192 and s.y>=0 and s.y<=448)
        localShots=0;Nina10Runtime.onShot=function() localShots=localShots+1 end
        Nina10Runtime.start(s,37);assert(Nina10Runtime.boss and #Nina10Runtime.actors==1,s.id..' start')
        for i=1,s.frames do Nina10Runtime.step(0,400,s.hp);Nina10Runtime.stepHazards() end
        assert(localShots>0,s.id..' did not schedule bullets')
        Nina10Runtime.clearHazards();Nina10Runtime.stepHazards();assert(#Nina10Runtime.hazards==0,s.id..' cleanup')
      end
    ''')
    print('PASS',backend,'import10 specs, schedules, cleanup')
