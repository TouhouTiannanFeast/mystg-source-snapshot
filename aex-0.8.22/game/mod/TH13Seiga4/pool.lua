SeigaPool={}
local P=SeigaPool
P.specs={
 {id='non1',entry='Boss1',name='',hp=9000,frames=3300,x=0,y=128,yx=80,yy=112,yentry='BossMiyako1'},
 {id='spell1',entry='BossCard1',name='入魔「走火入魔」',hp=1700,frames=3300,x=0,y=96,yx=80,yy=112,yentry='BossMiyako1'},
 {id='non2',entry='Boss2',name='',hp=12000,frames=2700,x=0,y=96,yx=0,yy=260,yentry='BossMiyako1'},
 {id='spell2',entry='BossCard2',name='降灵「死人童乩」',hp=1700,frames=3000,x=0,y=96,yx=0,yy=260,yentry='BossMiyako2'},
}
for _,s in ipairs(P.specs)do s.group='th13';s.boss='Seiga Kaku' end
function P.rng(seed)local s=math.floor(seed or 1)%2147483647;if s<=0 then s=1 end;return function()s=s*16807%2147483647;return(s-1)/2147483646 end end
