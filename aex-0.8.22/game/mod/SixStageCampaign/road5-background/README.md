# Five-road source-derived full 3D scenery

Campaign only, loaded by background5.lua. Original HSoBStage5Normal Lite code/assets retained. Uses original World05 archive textures/MQO faces and camera/scene formulas; source.json lists provenance and remaining shader/material differences. Native practice/full road routing and source Warp timing retained. No gameplay/audio changes.

Rebuild meshes: python G:/MySTG/scripts/six-stages/build-road5-background.py
Verify: python G:/MySTG/scripts/six-stages/verify-road5-background.py
Bounded normal campaign preview: powershell -File G:/MySTG/work/logs/six-stages/road5-background-20261114/native-campaign.ps1 -Stage5
Normal launcher: G:/MySTG/start-six-stages.cmd ->Stage5 full or road sections.

Remaining: original Monochrome/heat/bubble shaders and MQO bump/material lighting; original camera formulas ported but no retail frame-by-frame comparison.
