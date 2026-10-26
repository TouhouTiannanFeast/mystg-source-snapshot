from pathlib import Path
import importlib
m=Path('G:/MySTG/aex-0.8.22/game/mod/Stage12Normal')
for name in ('luajit21','lua51','lua54'):
 l=importlib.import_module('lupa.'+name).LuaRuntime(unpack_returned_tuples=True);l.execute((m/'background-source-state.lua').read_text(encoding='utf-8'));S=l.globals().Stage12BackgroundSource
 assert abs(S.alpha(2,'bg2.th16.st02b',290,0)-64)<1e-8
 for t,a in ((80,128),(160,160),(240,128)):assert abs(S.alpha(2,'bg2.th16.st02b',290,t)-a)<1e-8
 assert S.alpha(1,'bg1.world02',0,449)==0 and S.alpha(1,'bg1.world02',0,510)==144
 assert S.blend(1,'bg1.world02',-10)=='mul+add' and S.blend(1,'bg1.world02',-20)=='mul+sub'
 assert S.overlay_alpha(4438,255)==0 and S.overlay_alpha(4588,255)==255
 f=S.fog(2,1640);assert [f[i] for i in range(1,6)]==[80,208,208,1000,1700]
 l.execute('''unpack=unpack or table.unpack;Class=function(b)return {}end;background={};Include=function()end;setting={};function Color(...)return {...}end;function Set3D(...)end;function SetViewMode(...)end;function RenderClearViewMode(...)end;draws={};function RenderTexture(n,b,...)table.insert(draws,{n,b,...})end''')
 l.execute((m/'background-data.lua').read_text(encoding='utf-8'));l.execute((m/'background.lua').read_text(encoding='utf-8'));l.execute("local bg=debug.getupvalue(Stage12Background.start,2); captured=nil;New=function(c,n)captured=c;return {}end;Stage12Background.start(2)")
 c=l.globals().captured;l.globals().scene=l.globals().Stage12BackgroundData[2];l.globals().c=c;l.execute('c.render({stageIndex=2,age=4600,scene=scene});assert(#draws==39)')
 print(name+': source fog/alpha/blend/overlay timing and actual39draws render PASS')

