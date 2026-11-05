local root='aex-0.8.22/game/mod/NinaStage6Normal/import10/'
dofile(root..'specs.lua');dofile(root..'art.lua');dofile(root..'runtime.lua')
assert(#Nina10Specs==4)
local expected={non2=2400,spell2=4200,spell3=3600,kanako=9000}
for _,s in ipairs(Nina10Specs) do
 assert(s.frames==expected[s.id] and s.x>=-192 and s.x<=192 and s.y>=0 and s.y<=448)
 Nina10Runtime.start(s,37);assert(Nina10Runtime.boss and #Nina10Runtime.actors==1)
 for i=1,180 do Nina10Runtime.step(0,400,s.hp);Nina10Runtime.stepHazards() end
 assert(#Nina10Runtime.hazards>0,s.id..' did not schedule bullets')
 Nina10Runtime.clearHazards();assert(#Nina10Runtime.hazards==0)
end
print('PASS import10 specs, schedules, cleanup')
