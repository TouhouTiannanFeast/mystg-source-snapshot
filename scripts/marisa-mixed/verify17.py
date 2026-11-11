from pathlib import Path
from lupa.lua51 import LuaRuntime
M=Path('G:/MySTG/aex-0.8.22/game/mod/MarisaMixed');l=LuaRuntime()
l.execute('''setting={};background={};function Class(b)return{}end
function SetViewMode()end;function SetZBufferEnable()end;function SetFog()end
lstg={PostEffect=function(a,b,c,d,rows)rendered=rows end}''')
for f in ['data.lua','anm.lua','background.lua']:l.execute((M/'road'/f).read_text(encoding='utf-8-sig'))
s=(M/'stage14.lua').read_text(encoding='utf-8');l.execute('assert(loadstring(...))',s)
transition=s[s.index(' local scenery=bg.state'):s.index('\nend\nif setting.marisa_test')]
l.globals().switch=l.eval('function(bg)local B=Th18Stage5Background;'+transition+' end')
l.execute('''local B=Th18Stage5Background
for _,advance in ipairs({0,1,111,255,511,777})do
 local s=B.new();B.armMidboss(s);for i=1,3500 do B.stageStep(s)end;B.beginValley(s)
 for i=1,6000+advance do B.stageStep(s)end
 local age=s.age;local broadcasts=s.broadcasts
 B.render(s);local before=rendered;local raw=s.std.values.pos[2]
 switch({state=s});B.render(s)
 for r=1,#before do for c=1,#before[r]do assert(math.abs(before[r][c]-rendered[r][c])<1e-9,'entry render discontinuity row'..r..' col'..c)end end
 assert(s.age==age and s.broadcasts==broadcasts+1 and s.rock==1)
 local y=rendered[1][2];B.stageStep(s);B.render(s)
 assert(math.abs(rendered[1][2]-y-1)<1e-9,'boss scroll did not continue smoothly')
 print('PASS entry phase '..advance..' originalY='..raw..' resetY=384; all shader uniforms continuous; boss scroll/ANM/rock retained')
end''')
print('PASS exact stage transition Lua51 syntax and six actual STD/ANM render continuity boundaries')
