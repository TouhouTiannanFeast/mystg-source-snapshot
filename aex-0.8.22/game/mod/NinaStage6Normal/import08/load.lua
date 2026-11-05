Include('import08/specs.lua')
Include('import08/art.lua')
Include('import08/runtime.lua')
NinaImports=NinaImports or {}
NinaImports.th08={specs=Nina08Specs,art=Nina08Art,create=function(spec,seed,callbacks)
 local R=Nina08Runtime;R.start(spec,seed)
 callbacks=callbacks or {};if callbacks.onActor then R.onActor=callbacks.onActor end;if callbacks.onShot then R.onShot=callbacks.onShot end
 return {step=function(px,py,hp)return R.step(px,py,hp)end,hazards=R.hazards,actors=R.actors,boss=R.boss,cleanup=R.clearHazards,onActor=R.onActor,onShot=R.onShot}
end}
