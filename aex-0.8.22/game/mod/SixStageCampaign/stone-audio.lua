-- Stone-only corrected TH20 event IDs, not WAV table indices.
local C=SixStageCampaign
local cues={[21]={'se_tan00.wav',-2400},[27]={'se_tan00.wav',-1100},[54]={'se_ch02.wav',-300},[6]={'se_enep02.wav',-1400}}
for id,c in pairs(cues)do LoadSound('six.stone.'..id,'mod/SixStageCampaign/stone-audio/'..c[1])end
local install=C.install
function C.install(i,classes)
 install(i,classes);if i~=5 then return end
 local R=Zuu4R;local source=R.onSound;local ticks={}
 local function emit(id)
  if ticks[id]==R.tick then return end;ticks[id]=R.tick
  PlaySound('six.stone.'..id,10^(cues[id][2]/2000))
 end
 R.onSound=function(name,...)
  if R.id=='stone'then
   local id=({shot2=21,['th20.27']=27,['th20.54']=54,['th20.6']=6})[name]
   if id then return emit(id)end
  end
  return source(name,...)
 end
 local clear=R.clearBullets
 R.clearBullets=function(...)
  -- Only the three explicit clear calls inside P.stone's transition loop;
  -- Bomb/Miss and generic cleanups have different caller source files.
  local caller=debug.getinfo(2,'S')
  if R.id=='stone'and caller and caller.source:find('stages/zuu4/th20.lua',1,true)then emit(27)end
  return clear(...)
 end
end

