DSExtraPool={};local P=DSExtraPool
P.specs={
 [2]={id=2,group='ds2',name='星符「奥尔特云」',boss='Marisa Kirisame',entry='Boss',hp=10000,frames=12000,x=-224,y=224,maxPhotos=4},
 [7]={id=7,group='ds7',name='梦符「梦想亚空穴」',boss='Reimu Hakurei',entry='Boss',hp=10000,frames=12000,x=-224,y=224,maxPhotos=4},
 [8]={id=8,group='ds8',name='彗星「Blazing Star」',boss='Marisa Kirisame',entry='Boss',hp=10000,frames=3600,x=0,y=-64,maxPhotos=1}}
function P.photoIndex(t,spec)if spec.id==8 then return t<1800 and 0 or 1 end;return math.min(spec.maxPhotos,math.floor(math.max(0,t-60)/120))end
function P.rng(seed)local s=math.floor(seed or 1)%2147483647;if s<=0 then s=1 end;return function()s=(s*16807)%2147483647;return(s-1)/2147483646 end end
