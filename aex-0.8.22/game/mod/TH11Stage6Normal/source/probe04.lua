local R,H,M,A=TH11S6Runtime,TH11S6Host,TH11S6Milk,TH11S6Suwako
local N=M.nonspellState
local s={start=tonumber(setting.th11s6_checkpoint)or 0,chains=0}
local hook=R.onActor
R.onActor=function(a)
 hook(a)
 if not s.enemy and a.name=='Crow01'then
  for o in pairs(H.enemies)do if o.data==a then s.enemy=o;break end end
  local hp=s.enemy.hp;Damage(s.enemy,10);assert(s.enemy.hp==hp and hp==400 and s.enemy.protect,'native constructor immunity/HP')
 end
end
local after=AfterFrame
AfterFrame=function()
 after();if not R.tick then return end
 if s.enemy and IsValid(s.enemy)then
  local a=s.enemy.data
  if a.age==19 and not s.age19 then s.age19=true;local hp=s.enemy.hp;Damage(s.enemy,10);assert(s.enemy.hp==hp,'native19f damage')end
  if a.age==20 and not s.age20 then s.age20=true;local hp=s.enemy.hp;Damage(s.enemy,10);assert(s.enemy.hp==hp-10,'native20f release')end
 end
 for o in pairs(H.owned)do if IsValid(o)and o.data and o.data.typ==4 and o.data.age>=20 then
  local angle=o.data.angle;local heading=o.heading*math.pi/180
  assert(-math.sin(heading)*math.cos(angle)-math.cos(heading)*math.sin(angle)>.99999 and o.rot==0,'native chain direction/collision')
  s.chains=s.chains+1
 end end
 if H.midbossPhase=='nonspell' and N.tick>=230 and not s.non then
  s.non=true;assert(H.midboss.maxhp==12000 and M.nonspell.t3==2400 and not A.frog,'native nonspell40s/no-frog');H.midboss.hp=0
 end
 if H.midbossPhase=='spell' and M.state.tick>=230 and not s.spell then
  s.spell=true;assert(H.midboss.maxhp==24000 and M.card.t3==3000 and A.frog and IsValid(A.frog),'native spell24000/frog')
  assert(A.frog.colli==false and A.frog.group==GROUP_GHOST,'frog collision');H.midboss.hp=0
 end
 if setting.th11s6_checkpoint==590 and R.tick>=s.start+300 and not s.pass then
  s.pass=true;assert(s.age19 and s.age20 and s.chains>0,'native chain/immunity coverage')
  print('TH11S6 CHAINS04 PASS nativeHP400 protect0/19 release20 chainChecks='..s.chains)
 end
 if s.spell and H.midbossEnds==1 and not s.pass then
  s.pass=true;assert(not A.frog,'frog cleanup');print('TH11S6 BOSS04 PASS Suwako nonspell12000/40s spell24000/50s frog/cleanup')
 end
end
local render=RenderFunc;local captured={}
RenderFunc=function()
 render()
 if not R.tick then return end
 local key
 if setting.th11s6_checkpoint==590 and R.tick>=s.start+280 then key='chains'
 elseif H.midbossPhase=='nonspell' and N.tick>=210 then key='suwako'
 elseif H.midbossPhase=='spell' and M.state.tick>=220 then key='frog'end
 if key and not captured[key]then captured[key]=true;lstg.Snapshot('userdata/snapshot/th11s6-change04-'..key..'.jpg')end
end
