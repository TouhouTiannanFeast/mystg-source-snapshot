-- Live dependency: source road owns all gameplay, visual mappings and assets.
Le03ModuleRoot='mod/Le03Stage4Normal/'
Le03AssetRoot=Le03ModuleRoot..'art/'
for _,name in ipairs({'constants','movement','bullet-style','firing','runtime','schedule','host'})do
 Include(Le03ModuleRoot..name..'.lua')
end
Y3Road={clean=Le03Host.clean}
local waveFrames={}
local seen={}
for _,row in ipairs(Le03Schedule)do
 if not seen[row[1]]then waveFrames[#waveFrames+1]=row[1];seen[row[1]]=true end
end
table.sort(waveFrames)
function Y3Road.position()
 local frame=Le03.tick or 0
 local wave=0
 for i,t in ipairs(waveFrames)do if Le03.spawnTick(t)<=frame then wave=i else break end end
 return wave,#waveFrames,frame
end
function Y3Road.run(startFrame)
 Y3Road.active=true
 Le03Host.run(startFrame,{seed=tonumber(setting.y3_seed)or 20261029,
  invincible=setting.y3_invincible or setting.y3_test})
 Y3Road.active=false
end
