"""Create isolated host adapters. Existing mods are read-only inputs."""
from pathlib import Path
R=Path('G:/MySTG');B=R/'aex-0.8.22/game/mod/TH10Stage6Normal';O=R/'aex-0.8.22/game/mod/TH11Stage6Normal'
def read(n):return (B/n).read_text(encoding='utf-8').replace('TH10S6','TH11S6').replace('th10','th11')
def save(n,s):(O/n).write_text(s,encoding='utf-8')
s=read('runtime.lua')
s=s.replace("'MainSub1'","'main'")
s=s.replace('function R.start(seed)', '''function R.roadRemaining()
 local n=0
 for _,a in ipairs(R.actors or {})do if not a.controller and not a.dead then n=n+1 end end
 return n
end
function R.start(seed)
 R.midbossRequested=nil;R.midbossPending=false
 R.resumeTick=nil''')
s=s.replace('R.invuln=0','R.invuln=0;R.bossPresent=false;R.roadEnd=false;R.midbossBorn=nil;R.skipped=0')
s=s.replace("elseif k=='moveVel' then", "elseif k=='moveVelRel' then a.relativeAngle,a.relativeSpeed=v[1],v[2]\n elseif k=='moveVel' then")
s=s.replace("elseif k=='moveEllipse' then a.orbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],x=a.x,y=a.y,ellipse=v[5],tilt=v[6]}","""elseif k=='moveEllipse' then
  -- Retail 0x414455 / 0x459670: arg5 is axis rotation; arg6
  -- scales the perpendicular radius. Linear relative motion is independent.
  a.orbit={angle=v[1],omega=v[2],radius=v[3],dr=v[4],x=a.x,y=a.y,tilt=v[5],ratio=v[6]}
""")
s=s.replace("elseif k=='enmCreate' or k=='enmCreateA' or k=='enmCreateM' or k=='enmCreateAM' then", "elseif k:match('^enmCreate') then\n  if v[1]=='MapleEnemy' then return end\n  if v[1]=='Boss' then R.roadEnd=true;return end\n  if v[1]=='MBoss' then\n   -- Suspend only the road controller; surviving minors keep their own clocks.\n   R.midbossRequested=R.tick;R.midbossPending=true\n   while R.roadRemaining()>0 do coroutine.yield(1)end\n   R.midbossPending=false;R.bossPresent=true;R.midbossBorn=R.tick\n   if R.onMidboss then R.onMidboss()end;return\n  end\n  if k:sub(-1)=='F' and R.bossPresent then R.skipped=R.skipped+1;return end")
s=s.replace("elseif ignore[k] then return", """elseif k=='dialogRead' then if v[1]==0 then R.roadEnd=true;a.dead=true end
 elseif k=='dialogWait' then return -- dialogue UI omitted; source attack waits remain intact
 elseif k=='waitMidboss' then
  while R.bossPresent do coroutine.yield(1)end
  R.resumeTick=R.tick
 elseif k=='anmPlayAbs' then return -- source MapleEnemy effects handled by the local scene
 elseif ignore[k] then return""")
s=s.replace("if a.orbit then local o=a.orbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr;a.x=o.x+math.cos(o.angle)*o.radius;a.y=o.y+math.sin(o.angle)*(o.ellipse and o.radius*o.ellipse or o.radius)", """if a.orbit then
   local o=a.orbit;o.angle=o.angle+o.omega;o.radius=o.radius+o.dr
   local u=(o.angle-o.tilt);local x,y=math.cos(u)*o.radius,math.sin(u)*o.radius*o.ratio
   a.x=o.x+x*math.cos(o.tilt)-y*math.sin(o.tilt)
   a.y=o.y+x*math.sin(o.tilt)+y*math.cos(o.tilt)""")
s=s.replace("a.x,a.y=a.x+(a.offsetX or 0),a.y+(a.offsetY or 0)","""if a.relativeSpeed then
  a.offsetX=(a.offsetX or 0)+math.cos(a.relativeAngle)*a.relativeSpeed
  a.offsetY=(a.offsetY or 0)+math.sin(a.relativeAngle)*a.relativeSpeed
 end
 a.x,a.y=a.x+(a.offsetX or 0),a.y+(a.offsetY or 0)""")
s=s.replace('child.hp=v[4];','child.hp=v[4]*2;',1)
s=s.replace("local function pat(a,id)return assert(a.patterns[id],'missing etNew '..id) end", "local function pat(a,id)return assert(a.patterns[id],'missing etNew '..id) end\n-- Only the two pre-midboss crow batches use Hard attack parameters.\nlocal function attackDifficulty(a)return (a.name=='Crow00' or a.name=='Crow01')and 2 or 1 end")
s=s.replace("coroutine.yield(math.max(1,v[2]))", "coroutine.yield(math.max(1,v[attackDifficulty(a)+1]))")
s=s.replace("local p=pat(a,v[1]);p.n,p.layers=v[3],v[7]", "local p=pat(a,v[1]);local d=attackDifficulty(a);p.n,p.layers=v[d+2],v[d+6]")
s=s.replace("local p=pat(a,v[1]);p.speed,p.speed2=v[3],v[7]", "local p=pat(a,v[1]);local d=attackDifficulty(a);p.speed,p.speed2=v[d+2],v[d+6]")
s=s.replace("child.born=R.tick;R.spawn(child,v[1],{},-2)", "child.born=R.tick;R.spawn(child,v[1],{},-2)\n  if child.name=='BPhantom00' then child.hp=child.hp*2 end")
save('runtime.lua',s)
save('road-runtime.lua',read('road-runtime.lua').replace('a.entered=a.entered or inside','a.entered=a.entered or (a.x>=-208 and a.x<=208 and a.y>=-16 and a.y<=464)'))
s=read('projectiles.lua')
# TH11 uses the modern indexed transform flags; its birth variants are1/2.
s=s.replace("local map=b.group=='th11' and th11", "local map=b.group=='th11' and modern")
s=s.replace("b.birth=b.group=='th11' and (r.kind==4 and 15 or 8) or (r.i==1 and 15 or r.i==2 and 25 or 8)","b.birth=r.i==1 and 15 or r.i==2 and 25 or 8")
s=s.replace('  velocity(b);R.hazards[#R.hazards+1]=b', "  if a.name=='RPhantom01'and p.typ==3 then\n   a.needleIndex=(a.needleIndex or 0)+1;b.color=a.needleIndex%2==1 and 13 or 9\n  end\n  velocity(b);R.hazards[#R.hazards+1]=b")
save('projectiles.lua',s)
s=read('host.lua')
s=s.replace('self.rect=false;self.colli=false','self.rect=true;self.colli=false')
s=s.replace('self.rot=-b.angle*180/pi+90','self.heading=-b.angle*180/pi+90;self.rot=0')
s=s.replace('Render(img,self.x,self.y,self.rot,scale,scale)','Render(img,self.x,self.y,self.heading,scale,scale)')
s=s.replace('local DamageBase=Class(enemy)', '''local Contact=Class(object)
function Contact:init(owner)
 self.owner=owner;self.group=GROUP_ENEMY_BULLET;self.layer=LAYER_ENEMY;self.bound=false;self.colli=false;self.rect=true;self.rot=0
 self.x,self.y=owner.x,owner.y;own(self)
end
function Contact:frame()
 local o=self.owner
 if not IsValid(o)or o.data.dead then Del(self);return end
 local a=o.data;self.x,self.y=o.x,o.y;self.a,self.b=(a.hitW or 16)/2,(a.hitH or 16)/2
 self.colli=R.bitAnd(a.flags or 0,2)==0
end
function Contact:del()H.owned[self]=nil end
Contact.kill=Contact.del
local Trail=Class(object)
local visualSeed=1106
local function visualRandom(a,b)visualSeed=visualSeed*16807%2147483647;return a+(b-a)*visualSeed/2147483647 end
function Trail:init(a)
 local sid=a.anm and a.anm[0]or 98;local base=({[94]=155,[96]=163,[98]=171,[100]=179})[sid]or 171
 self.img=TH11S6Sprites.enemy[base+math.floor(visualRandom(0,8))]
 self.group=GROUP_GHOST;self.layer=LAYER_ENEMY-.01;self.colli=false;self.bound=false
 self.ox,self.oy=a.x,224-a.y;self.sx,self.sy=visualRandom(-8,8),visualRandom(-4,4)
 self.tx,self.ty=visualRandom(-8,8),visualRandom(16,32);own(self)
end
function Trail:frame()if self.timer>=10 then Del(self)end end
function Trail:render()
 local u=math.min(1,self.timer/10);local scale=.5*(1-u*u)
 SetImageState(self.img,'',Color(255,255,255,255));Render(self.img,self.ox+self.sx+(self.tx-self.sx)*u,self.oy+self.sy+(self.ty-self.sy)*u,0,scale,scale)
end
function Trail:del()H.owned[self]=nil end
local DamageBase=Class(enemy)''')
s=s.replace('self.x,self.y=a.x,224-a.y;self.a,self.b=12,12;', 'self.x,self.y=a.x,224-a.y;self.a,self.b=12,12;self.rect=true;self.group=GROUP_NONTJT;self.contact=New(Contact,self);')
s=s.replace("self.protect=(a.invuln or 0)>0","self.protect=(a.invuln or 0)>0 or R.bitAnd(a.flags or 0,9)~=0")
s=s.replace('self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2','self.a,self.b=(a.hurtW or 24)/2,(a.hurtH or 24)/2;self.colli=R.bitAnd(a.flags or 0,1)==0')
s=s.replace('self.protect=(a.invuln or 0)>0','self.protect=a.age<20 or (a.invuln or 0)>0')
s=s.replace('self.vx,self.vy=0,0\n self.x,self.y=a.x','self.vx,self.vy=0,0;self.protect=true\n self.x,self.y=a.x')
s=s.replace('if not self.protect and not self.data.dead then','if self.data.age>=20 and not self.protect and not self.data.dead then')
s=s.replace('self.a,self.b=a.width/2,a.width/2;self.heading=-b.angle*180/pi+90;self.rot=0','self.a,self.b=a.width/2,a.width/2;self.heading=-b.angle*180/pi+90;self.rot=0\n if b.typ==4 then self.heading=self.heading+180 end')
s=s.replace("Render(self.image,self.x,self.y,self.rotation,self.flip,1)","Render(self.image,self.x,self.y,self.rotation,self.flip*(self.visualScale or 1),self.visualScale or 1)")
s=s.replace('self.image,self.rotation,self.flip=P.enemy(a)', '''self.image,self.rotation,self.flip=P.enemy(a)
 self.visualScale=1
 if not a.name:find('Crow')then
  local t=a.age-(a.poseStart or 0)
  if t<6 then self.visualScale=2*(1-(1-t/6)^2)elseif t<12 then self.visualScale=2-((t-6)/6)^2 end
  if t>=12 then New(Trail,a)end
 end''')
s=s.replace("TH11S6Sound.play('tan00',.22,b.x)","TH11S6Sound.play('tan00',.22,b.x)")
# Local item conversion includes base bullet.kill callers in the Boss module.
s=s.replace('local Minor=Class(item_faith_minor)','local NativeMinor=item_faith_minor\nlocal Minor=Class(NativeMinor)')
s=s.replace('item_faith_minor.init(self,x,y);own(self)',"NativeMinor.init(self,x,y);self.img='item2';self.imgup='item_up2';own(self)")
s=s.replace('item_faith_minor.frame(self)','NativeMinor.frame(self)')
s=s.replace('function Minor:del()H.owned[self]=nil end','function Minor:del()H.owned[self]=nil end\nMinor.collect=item_point.collect\nitem_faith_minor=Minor')
s=s.replace('({[1]=1,[2]=2,[3]=5,[4]=6})[kind] or 5','2')
start=s.index('function Drop:collect()');end=s.index('function Drop:del()',start)
s=s[:start]+'function Drop:collect()item_point.collect(self)end\n'+s[end:]
s=s.replace(" self.img=TH11S6Sprites.enemy[base+math.floor(visualRandom(0,8))]", " if a.name=='RPhantom01' then base=179 end\n self.img=TH11S6Sprites.enemy[base+math.floor(visualRandom(0,8))]")
s=s.replace(" H.enemies[self]=true;own(self);H.spawns=H.spawns+1", " if a.name=='RPhantom01'then self.death_ef=4 end\n H.enemies[self]=true;own(self);H.spawns=H.spawns+1")
s=s.replace("local H=TH11S6Host;local R=TH11S6Runtime;local P=TH11S6Presentation", "local H=TH11S6Host;local R=TH11S6Runtime;local P=TH11S6Presentation\nfunction H.finalFrogLife(x,y)\n if H.frogLife then return end\n H.frogLife=true;New(item_extend,x,y)\nend")
s=s.replace(" -- Animated native enemy_death_ef owns", " if a.name=='RPhantom01'and a.f[0]<0 then H.finalFrogLife(self.x,self.y)end\n -- Animated native enemy_death_ef owns")
save('host.lua',s)
s=read('sound.lua').replace("'s6.'","'th11s6.'")
s=s[:s.index('-- Original v1.00a')]+"-- Native config0x4a34f0+53*8 selects wav43 at pointer-table0x4a36b0.\nTH11S6Runtime.onSound=function(id,x)assert(id==53,'unresolved TH11 sound '..id)end -- source cat call muted\n"
s=s.replace("'bonus3'","'bonus'")
save('sound.lua',s)
print('Isolated runtime/projectiles/host/sound adapters written')
