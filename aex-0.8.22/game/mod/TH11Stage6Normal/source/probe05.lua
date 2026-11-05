-- Opt-in bounded verification only; public play never enables this fixture.
local R,H,M,A=TH11S6Runtime,TH11S6Host,TH11S6Milk,TH11S6Suwako
local s={}
local after=AfterFrame
AfterFrame=function()
 after();if not R.tick then return end
 if R.tick==3161 then
  assert(R.midbossPending and R.roadRemaining()>0 and H.midbossStarts==0,'preboss survivors were deleted')
  s.initial=R.roadRemaining();s.shots=R.stats.bullets
 end
 if R.tick==3201 then
  assert(s.initial and R.midbossPending and R.roadRemaining()>0 and H.midbossStarts==0,'boss did not wait')
  assert(R.stats.bullets>s.shots,'waiting minor attacks stopped')
  local targets={};for o in pairs(H.enemies)do if IsValid(o)and not o.data.dead then targets[#targets+1]=o end end
  s.defeats=#targets;assert(s.defeats>0)
  for _,o in ipairs(targets)do assert(not o.protect,'source minor must be damageable');Damage(o,o.hp+1);Kill(o)end
  assert(R.roadRemaining()==0,'actual host defeat did not clear remaining count');s.lastKill=R.tick
 end
 if H.midbossStarts>0 and not s.released then
  assert(s.lastKill and R.midbossBorn>=s.lastKill and R.midbossBorn<=s.lastKill+1 and H.midbossStarts==1,'early/double/delayed boss')
  s.released=true;print('TH11S6 GATE05 PASS remaining='..s.initial..' killed='..s.defeats..' request='..R.midbossRequested..' born='..R.midbossBorn)
 end
 if H.midbossPhase=='nonspell' and M.nonspellState.tick>=100 and not s.non then s.non=true;H.midboss.hp=0 end
 if H.midbossPhase=='spell' and M.state.tick>=230 and not s.spell then
  s.spell=true;assert(A.frog and IsValid(A.frog)and not A.frog.colli,'new frog not active');H.midboss.hp=0
 end
 if s.spell and H.midbossEnds==1 and not s.pass then
  s.pass=true;assert(not A.frog,'frog cleanup');print('TH11S6 FROG05 PASS new user art spell render and cleanup')
 end
end
local render=RenderFunc
RenderFunc=function()
 render();if not R.tick then return end
 if H.midbossPhase=='spell'and M.state.tick>=100 and not s.capture then
  s.capture=true;lstg.Snapshot('userdata/snapshot/th11s6-change05-frog.jpg')
 end
end
