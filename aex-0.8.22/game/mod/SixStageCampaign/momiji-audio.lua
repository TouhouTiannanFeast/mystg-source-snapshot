-- User clip once at each medium-ball volley; original stage source stays intact.
local C=SixStageCampaign
LoadSound('six.momiji.medium','mod/SixStageCampaign/se/momiji-medium.wav')
LoadSound('six.momiji.entrance','mod/SixStageCampaign/se/momiji-entrance.wav')
local source=C.sourceText
C.sourceText=function(path)
 if path=='mod/Stage12Normal/stage1/stage.lua'then
  local code=assert(source(path))
  local old="SixStageStory46.play('s1momijipre');"
  local at=assert(code:find(old,1,true),'Momiji pre-dialogue source changed')
  return code:sub(1,at+#old-1).."PlaySound('six.momiji.entrance',2,0,true);"..code:sub(at+#old)
 end
 if path~='mod/Stage12Normal/stage1/momiji.lua'then return source and source(path)end
 local f=assert(io.open(path,'rb'));local code=f:read('*a'):gsub('\r\n','\n');f:close()
 local old="                    local angles,center=P.angles('scale',front,0)"
 local at=assert(code:find(old,1,true),'Momiji medium volley source changed')
 local cue="                    PlaySound('six.momiji.medium',2,math.max(-1,math.min(1,o.x/224)),true)\n"
 code=code:sub(1,at-1)..cue..code:sub(at)
 return code
end
