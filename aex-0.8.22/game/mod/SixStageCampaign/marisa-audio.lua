-- Campaign-only TH08 cues. Original Sub55: 13 at90, 19 at150/610/...
local C=SixStageCampaign
local dir='mod/SixStageCampaign/marisa-audio/'
for _,name in ipairs({'tan00','gun00','nep00'})do
 LoadSound('six.marisa08.'..name,dir..'se_'..name..'.wav')
end
local install=C.install
function C.install(i,classes)
 install(i,classes);if i~=4 then return end
 local T=th08s4
 if T.six_audio13 then return end;T.six_audio13=true
 local function cue(name,gain,x)
  lstg.PlaySound('six.marisa08.'..name,gain,math.max(-1,math.min(1,(x or 0)/192)))
 end
 local last
 local emit=T.emit
 T.emit=function(o,...)
  local result=emit(o,...)
  local p=MarisaMixed.phase
  if p=='stardust'or p=='non1'or p=='milky'or p=='non3'then
   local now=stage.current_stage.timer
   if last~=now then last=now;cue('tan00',10^(-1900/2000),o.x)end
  end
  return result
 end
 local move=T.move
 T.move=function(o,x,y,n,mode)
  local result=move(o,x,y,n,mode)
  if MarisaMixed.phase=='final'and x==192 and y==160 and n==90 then
   cue('gun00',10^(-1500/2000),o.x)
  end
  return result
 end
 local beam=T.Beam.init
 T.Beam.init=function(o,owner,x,y,angle,length,width,color,warning,active,off,turn)
  beam(o,owner,x,y,angle,length,width,color,warning,active,off,turn)
  if MarisaMixed.phase=='final'and length==650 and warning==120 then
   cue('nep00',10^(-400/2000),x)
  end
 end
end
