-- Stage-five selection only. Pattern RNG is separate from the draw RNG.
Suwako5Pool={spells={},nonspells={}}
local P=Suwako5Pool
local names={
 [1]='开宴「二拜二拍一拜」',[2]='土著神「手长足长大人」',[3]='神具「洩矢的铁轮」',
 [4]='源符「厌川的翡翠」',[5]='蛙狩「蛙以口鸣，方致蛇祸」',[6]='土著神「七石七木」',
 [8]='土著神「宝永四年的赤蛙」',[9]='「诹访大战 ～ 土著神话 vs 中央神话」',[10]='祟符「御社宫司大人」'}
local hp={[1]=2800,[2]=3600,[3]=2800,[4]=3600,[5]=3500,[6]=3500,[8]=10000,[9]=10000,[10]=10000}
for _,id in ipairs({1,2,3,4,5,6,8,9,10}) do
 P.spells[#P.spells+1]={id='th10-card'..id,name=names[id],group='th10',entry='BossCard'..id,hp=hp[id],frames=id==8 and 2400 or id==9 and 5040 or id==10 and 9600 or 6300,sourceIndex=id}
end
local ds={'神樱「湛樱花吹雪」','姬川「Princess Jade Green」','铁轮「Mythical Ring」','土著神「御射军神大人」'}
for i,c in ipairs({'a','b','c','d'}) do
 P.spells[#P.spells+1]={id='th125-'..c,name=ds[i],group='ds'..c,entry='Boss',hp=10000,frames=12000}
end
P.spells[#P.spells+1]={id='th143-0902',name='绿石「Jade Break」',group='isc0902',entry='AttackFunc',hp=3200,frames=5400}
P.spells[#P.spells+1]={id='th143-0906',name='蛙符「涂有鲜血的赤蛙塚」',group='isc0906',entry='AttackFunc',hp=1900,frames=5400}
for _,id in ipairs({1,2,3,4,5,6,8}) do
 P.nonspells[#P.nonspells+1]={id='th10-non'..id,name='',group='th10',entry='Boss'..id,hp=8000,frames=3600,sourceIndex=id}
end
function P.rng(seed)
 local state=math.floor(tonumber(seed) or 1)%2147483647
 if state<=0 then state=1 end
 return function() state=(state*16807)%2147483647;return (state-1)/2147483646 end
end
local function sample(pool,n,rng)
 assert(n>=1 and n<=#pool,'invalid stage-five draw size')
 local t={};for i,v in ipairs(pool) do t[i]=v end
 for i=1,n do local j=i+math.floor(rng()*(#t-i+1));t[i],t[j]=t[j],t[i] end
 local out={};for i=1,n do out[i]=t[i] end;return out
end
function P.draw(seed,count)
 local rng=P.rng(seed);count=count or 4
 local spells=sample(P.spells,count,rng)
 local nons=sample(P.nonspells,count,rng)
 table.sort(nons,function(a,b)return a.sourceIndex<b.sourceIndex end)
 local phases={}
 for i=1,count do phases[#phases+1]=nons[i];phases[#phases+1]=spells[i] end
 return phases
end
function P.find(id)
 for _,pool in ipairs({P.spells,P.nonspells}) do for _,spec in ipairs(pool) do if spec.id==id then return spec end end end
 error('unknown Suwako phase: '..tostring(id))
end
-- Six shooting-progress stages replace successful photos0..5.
-- Counter5 is the last source-safe stage: DS-d's wait is260-50*counter.
function P.photoIndex(hp,maxHp)
 assert(maxHp>0,'invalid DS maximum HP')
 local lost=1-math.max(0,math.min(1,hp/maxHp))
 return math.min(5,math.floor(lost*6+0.000000001))
end
