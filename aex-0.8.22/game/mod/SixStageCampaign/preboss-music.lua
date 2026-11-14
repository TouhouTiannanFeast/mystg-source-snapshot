-- Stage5's road BGM must survive the offscreen and arrival dialogues.
-- Zuu4R.musicStart already stops the road track when Boss combat begins.
local C=SixStageCampaign
local previous=C.sourceText
function C.sourceText(path)
 local code=previous and previous(path)
 if path~='mod/HSoBStage5Normal/boss-link.lua'then return code end
 if not code then local f=assert(io.open(path,'rb'));code=f:read('*a');f:close()end
 local old=" StopMusic('hs5.road')"
 local a,b=code:find(old,1,true);assert(a,'Stage5 pre-Boss BGM hook missing')
 assert(not code:find(old,b+1,true),'ambiguous Stage5 pre-Boss BGM hook')
 return code:sub(1,a-1)..' -- Keep road music until the Boss music actually starts.'..code:sub(b+1)
end
