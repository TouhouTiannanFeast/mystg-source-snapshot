-- Fixed-mode inspection uses a private routing table. Attack helper instructions,
-- random motion, projectile data, HP and clocks remain the current live version.
SSGInspect04={original=SSGCode};local I=SSGInspect04
I.order={'A1','A2','A3','A4','B1','B2','B3','B4','B5','B6'}
I.modes={
 A1={id='A1',name='本体：往返扫射弹源',short='Sweeping emitters',kind='body',helper=0x5c4,route=0x19d},
 A2={id='A2',name='本体：移动瞄准弹源',short='Moving aimed emitters',kind='body',helper=0x60b,route=0x1ac},
 A3={id='A3',name='本体：五向瞄准弹组',short='Five-way aimed groups',kind='body',helper=0x629,route=0x1bc},
 A4={id='A4',name='本体：旋转四向弹源',short='Rotating four-way emitters',kind='body',helper=0x675,route=0x1cb},
 B1={id='B1',name='僚机：变速旋转扇形弹',short='Orbiting fans',kind='bit',helper=0x6e4,route=0x270},
 B2={id='B2',name='僚机：瞄准环形弹',short='Aimed rings',kind='bit',helper=0x735,route=0x266},
 B3={id='B3',name='僚机：单向激光＋交替点弹',short='Single lasers and bursts',kind='bit',helper=0x73e,route=0x27a},
 B4={id='B4',name='僚机：双向激光＋扩展扇形弹',short='Double lasers and fans',kind='bit',helper=0x819,route=0x284},
 B5={id='B5',name='僚机：星形连接激光',short='Star-linked lasers',kind='bit',helper=0x89d,route=0x28e},
 B6={id='B6',name='僚机：回旋阵形＋追踪激光',short='Homing lasers',kind='bit',helper=0x8b9,route=0x298}
}
function I.select(mode)
 mode=mode or'full'
 SSGCode=I.original;I.current=nil
 if mode=='full'then return end
 local spec=assert(I.modes[mode],'unknown SSG inspection mode '..tostring(mode));local code={}
 for addr,ins in pairs(I.original)do code[addr]=ins end
 local function jump(addr,to)code[addr]={'JMP',{to},I.original[addr][3]}end
 if spec.kind=='body'then
  jump(0x17c,spec.route) -- use the original animation/prelude and CALL.
  jump(0x1f2,0x157) -- return to body cycle instead of summoning bits.
 else
  jump(0x14f,0x1f2) -- summon the same five bits without two unrelated body attacks.
  jump(0x22f,spec.route) -- repeat only this original combined bit helper.
 end
 SSGCode=code;I.current=spec
end
function I.start(seed,mode)
 I.select(mode);SSG.start(seed)
 if I.current then print('SSG INSPECT START '..I.current.id..' helper='..I.current.helper)end
end
