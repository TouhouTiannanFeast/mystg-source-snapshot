local names={}
LoadSound("dsx.sound51","se/se_nep00.wav");names[51]="dsx.sound51"
LoadSound("dsx.sound67","se/se_ch02.wav");names[67]="dsx.sound67"
DSExtraSound=function(id,x)if names[id]then PlaySound(names[id],0.5,(x or 0)/192)end end
