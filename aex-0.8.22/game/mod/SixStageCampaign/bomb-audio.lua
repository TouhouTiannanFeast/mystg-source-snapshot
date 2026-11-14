-- Reimu Bomb only: bypass THlib's per-alias override with 2.5x effective gains.
local previous=PlaySound
local gain={power1=.6,cat00=.55,nep00=.5,slash=.75,explode=.4}
PlaySound=function(name,volume,pan,flag)
 if gain[name]then
  for level=2,8 do
   local info=debug.getinfo(level,'S')
   if not info then break end
   if info.source:gsub('\\','/'):find('THlib/player/reimu/reimu.lua',1,true)then
    return previous(name,gain[name]*2.5,pan,true)
   end
  end
 end
 return previous(name,volume,pan,flag)
end
