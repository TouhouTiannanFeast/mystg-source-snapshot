local R=NinaCoreRuntime
local command=R.command
local presentation={boss_set_life_count=true,ex_ins_repeat=true,player_protect_range=true,enemy_lifebar_color=true,anm_create_front=true,lifeMarker=true}
function R.command(a,e,k,v)
 if (k=='enmCreate'or k=='enmCreateA')and v[1]=='BossCard4_AtEt'then v=R.copy(v);v[4]=1300 end
 if presentation[k]then return end
 if a.name=='Yoshika' and k=='lifeSet'and v[1]==4000 then a.colorDownStart=nil end
 return command(a,e,k,v)
end
local switch=R.switch
function R.switch(a,name)
 if a.name=='Yoshika'and name:find('Dead')then a.colorDownStart=R.tick;print('NINA SUWAKO COLOR '..R.tick)end
 return switch(a,name)
end
NinaCorePool={}
function NinaCorePool.rng(seed)
 local s=math.max(1,(seed or 1)%2147483647)
 return function()s=s*16807%2147483647;return(s-1)/2147483646 end
end
NinaCoreSpecs={
 {id='non1',entry='BossCard1',name='',hp=10700,frames=3300,x=0,y=96,group='th13',yx=80,yy=112,yentry='BossMiyako1'},
 {id='spell1',entry='BossCard2',name='蛙灾「操纵奶蟆」',hp=18400,frames=3000,x=0,y=96,group='th13L',yx=0,yy=260,yentry='BossMiyako2',yoshikaBox={0,160,384,320}},
 {id='non3',entry='Boss3',name='',hp=18000,frames=3960,x=0,y=128,group='th20'},
 {id='spell4',entry='BossCard4',name='偶像「奶蛙重赐诫命」',hp=15800,frames=3600,x=0,y=128,group='th17'},
}
