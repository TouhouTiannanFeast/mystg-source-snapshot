-- Lookup only.  The Nina host owns LoadTexture/LoadImage and maps frog:30 to
-- Nina's copy of TH11Stage6Normal/milk/art/stg7enm2.png sprite 30.
Nina08Art={
 actor={frog={visual='frog',source='TH11Stage6Normal/milk/art/stg7enm2.png',sprite=30,w=254,h=254,scale=0.26}},
 -- Retail bank is the hash-pinned TH08 etama ANM extraction.  type-to-ANM-script
 -- decoding is not present in the local corpus, so sprite ids remain deliberately
 -- unresolved rather than guessed; root must load the records after native lookup.
 lookup={
  [2]={image='nina.th08.type2',path='G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites/etama.entry0.sprite?.png',w=16,h=16,radius=5,source='etama.anm/native type table pending'},
  [3]={image='nina.th08.type3',path='G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites/etama.entry0.sprite?.png',w=16,h=16,radius=5,source='etama.anm/native type table pending'}
 },
 bullet={ [2]={name='th08.type2',radius=5},[3]={name='th08.type3',radius=5} },
 colors={[2]='red',[4]='blue',[6]='green',[8]='cyan',[10]='purple',[13]='yellow',[14]='white'}
}
-- Concrete TH08 local-original etama color strips.  Old TH08 has no later
-- 0x114 descriptor table; this explicit ANM-strip mapping is the documented
-- adaptation, not a fallback to a default bullet.
local bank='G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites/'
local function rec(sprite,w,h,r)return {image='nina.th08.etama.'..sprite,path=bank..'etama.entry0.sprite'..sprite..'.png',w=w,h=h,radius=r,source='th08 etama.anm archive 9d7edf43b8'}end
function Nina08Art.lookup(typ,color)
 local c=math.max(0,math.min(15,color or 0))
 if typ==2 then return rec(16+c,16,16,4)end
 if typ==3 then return rec(32+c,14,16,4)end
 if typ==17 then return rec(136+c,16,16,4)end
 return nil
end
Nina08Art.actor.familiar={visual='familiar',image='nina.th08.etama.54',path=bank..'etama.entry0.sprite54.png',w=16,h=16,radius=12,source='Sub19/Sub62 anmSet(54)'}
