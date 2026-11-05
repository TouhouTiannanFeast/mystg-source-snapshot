NinaHaniwa05={}
function NinaHaniwa05.frame(a)
 local slot=math.floor(math.max(0,(a.age or 0)-15)/5)
 if a.artSlot~=slot then
  a.artSeed=((a.artSeed or(3719+(a.id or 1)*7919))*16807)%2147483647
  a.artFrame=({'28','29','30','red'})[math.floor((a.artSeed-1)/2147483646*4)+1]
  a.artSlot=slot
 end
 return 'haniwa:'..a.artFrame
end
function NinaHaniwa05.isNote(b)return b.group=='th17'and b.typ==31 and b.color==6 end
