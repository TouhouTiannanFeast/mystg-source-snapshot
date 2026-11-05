-- Focused native validation only, never enabled by a normal launcher.
local R,H,M=TH11S6Runtime,TH11S6Host,TH11S6Milk
local N=M.nonspellState
local state={phase='none',nonChecked=false,spellChecked=false,crows=0,blue=0}
local actor=R.onActor
R.onActor=function(a)
 actor(a)
 if a.name=='Crow02'then
  state.crows=state.crows+1
  if not state.firstCrow then state.firstCrow=R.tick end
 end
end
local frame=AfterFrame
AfterFrame=function()
 frame()
 if not R.tick or not player or not IsValid(player)then return end
 if H.midbossPhase=='nonspell' and N.tick>=245 and not state.nonChecked then
  state.nonChecked=true;assert(H.midboss.hp==12000 and H.midboss.maxhp==12000,'nonspell HP')
  assert(N.shots>=640 and N.speeds[1]==3.75 and N.speeds[2]==3.10 and N.colorFrames==20,'manual nonspell data')
  local count=0;for o in pairs(N.owned)do if IsValid(o)and count<6 then Kill(o);count=count+1 end end
  H.midboss.hp=0
  print('TH11S6 NONSPELL03 PASS shots='..N.shots)
 end
 if H.midbossPhase=='spell' and M.state.tick>=245 and not state.spellChecked then
  state.spellChecked=true;assert(state.nonChecked and next(N.owned)==nil,'nonspell -> spell cleanup')
  assert(H.midboss.hp==24000 and H.midboss.maxhp==24000 and M.card.t3==3000,'spell HP/time')
  assert(M.state.main>0 and M.state.secondary>0,'spell layers')
  state.killedAt=R.tick;H.midboss.hp=0
 end
 if state.firstCrow and R.tick>=state.firstCrow+110 and not state.pass then
  state.pass=true
  assert(state.spellChecked and H.midbossEnds==1 and not R.bossPresent,'encounter completion')
  assert(state.firstCrow-state.killedAt<10 and state.crows>=6,'early-defeat crow restart')
  for o in pairs(H.enemies)do if IsValid(o)and not o.protect then Kill(o);break end end
  print('TH11S6 CROW03 PASS delay='..(state.firstCrow-state.killedAt)..' crows='..state.crows)
 end
 for o in pairs(H.owned)do if IsValid(o)and o.group==GROUP_ITEM then
  assert(o.img=='item2' and o.imgup=='item_up2','non-blue road/Bomb item');state.blue=state.blue+1
 end end
 if state.pass and state.blue>0 and not state.reported then
  state.reported=true;print('TH11S6 CHANGE03 PASS nonspell12000/spell24000 blue='..state.blue..' crows='..state.crows)
 end
end
local render=RenderFunc;local captures={}
RenderFunc=function()
 render()
 local key=H.midbossPhase
 if key=='nonspell' and N.tick>=220 or key=='spell' and M.state.tick>=220 or state.firstCrow and R.tick>=state.firstCrow+70 then
  key=state.firstCrow and 'crows'or key
  if not captures[key]then captures[key]=true;lstg.Snapshot('userdata/snapshot/th11s6-change03-'..key..'.jpg')end
 end
end
