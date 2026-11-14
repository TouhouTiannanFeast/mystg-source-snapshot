-- st06enm script10/11 ->12..19. Source fade60f, UV speeds, tint,
-- and128 paired ring samples; host blend/screen-coordinate adaptation.
local function rect(tex,blend,u,v,c)
 RenderTexture(tex,blend,{-192,224,0,u,v,c},{192,224,0,u+384,v,c},{192,-224,0,u+384,v+448,c},{-192,-224,0,u,v+448,c})
end
function SixBoss5Spell(t,grey)
 SetViewMode('world');local f=math.min(1,t/60)
 local tex='six.bg5.card.'..(grey and'c'or'a')
 local c=grey and Color(255*f,128,128,128)or Color(255*f,255,0,0)
 rect(tex,'',64+t*.0003125*512,-t*.00045454546*512,c)
 rect(tex,'mul+add',128,-t*.000625*512,Color(255*f,255,255,255))
 for layer=1,2 do
  local blend=layer==1 and'mul+rev'or'mul+add'
  local col=layer==1 and Color(255*f,255,255,255)or(grey and Color(96*f,128,128,128)or Color(96*f,255,0,0))
  local u=t*(layer==1 and(grey and .01 or .005)or-.005)*512
  local v=t*(layer==1 and .005 or-.005)*512
  -- TH20's paired ring strip uses128 samples including the closing pair.
  -- ins402(380,190): width380, center radius190 => outer380, inner0.
  -- i1=4 repeats the texture four times along the circumference (V),
  -- while U runs from the outer to inner edge; not Cartesian ellipse UVs.
  for i=0,126 do
   local a=i*2*math.pi/127;local b=(i+1)*2*math.pi/127
   local va=v+i/127*4*512;local vb=v+(i+1)/127*4*512
   RenderTexture('six.bg5.card.b',blend,
    {380*math.cos(a),80-380*math.sin(a),0,u,va,col},
    {0,80,0,u+512,va,col},
    {0,80,0,u+512,vb,col},
    {380*math.cos(b),80-380*math.sin(b),0,u,vb,col})
  end
 end
end
