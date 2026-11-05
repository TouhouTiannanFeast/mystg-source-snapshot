-- Scoped changes requested for Nina6-03; no global engine modifications.
NinaFix03={}
local N=NinaFix03
function N.art(b,original)
 if not original then return nil end
 -- NINA6-06: TH10 Normal Moses light orbs (type25) become TH20 large diamonds,
 -- red/blue alternating along the single red column; radius 6 is retained.
 if b.group=='th10moses'and b.typ==25 then
  if not b.ninaDiamond then
   N.orbCount=(N.orbCount or 0)+1
   b.ninaDiamond=N.orbCount%2==0 and 579 or 577
  end
  local d=Nina03Art[b.ninaDiamond]
  return{image=d.image,w=d.w,h=d.h,radius=original.radius or original.width or 6}
 end
 local swap
 if b.group=='th08'and b.rice then return Nina08Art.lookup(3,b.color) end
 if b.group=='th08'and b.diamond then
  local d=Nina03Art[b.diamondSprite]or Nina03Art[576]
  return{image=d.image,w=d.w,h=d.h,radius=5}
 end
 if b.group=='th13'and b.typ==9 and b.color==13 then swap=Nina06Art.scale06
 elseif b.group=='th17'and b.typ==31 and b.color==6 then swap={image='nina.note.yellow',w=48,h=32}
 elseif b.group=='th13L'and b.typ==21 and b.color==3 then swap=Nina03Art[579]
 elseif b.group=='th08'and NinaState and NinaState.current=='non4'and(b.typ==2 or b.typ==3)then
  local colors={[0]=576,[1]=577,[2]=577,[3]=578,[4]=578,[5]=579,[6]=579,[7]=580,[8]=580,[9]=581,[10]=581,[11]=582,[12]=582,[13]=582,[14]=582,[15]=583}
  swap=Nina03Art[colors[b.color]or 583]
 elseif b.group=='th11rice'and not(b.typ==3 and b.color==2)then swap=Nina10Art.lookup(0,b.color,b.group)end
 if swap then return{image=swap.image,w=swap.w,h=swap.h,radius=original.radius or original.width or 4}end
 return original
end
do
 local R=Nina10Runtime;local command=R.command;local start=R.start;local step=R.projectileStep
 function R.start(spec,seed)start(spec,seed);NinaFix03.orbCount=0;R.riceColored=0;R.riceExtras=0;R.riceRedBirths=0;R.continuousEntry=false end
 function R.command(a,e,k,v)
  -- MBoss's retail offscreen entrance must not overwrite Nina's previous pose.
  if R.spec.id=='non2'and R.continuousEntry and a==R.boss and R.tick==0 and k=='movePos'then return end
  if a.group=='th10moses'and k=='laserStOn'then
   local p=a.patterns[v[1]]
   local b={group=a.group,typ=v[2],color=v[3],x=a.x+(p.ox or 0),y=a.y+(p.oy or 0),angle=v[4],speed=0,age=0,
    laser={straight=true,length=v[5],endLength=v[6],delay=v[7],grow=v[8],hold=v[9],shrink=v[10],width=v[11],flags=v[12]},collidable=false}
   R.hazards[#R.hazards+1]=b;R.stats.lasers=R.stats.lasers+1;if R.onShot then R.onShot(b)end;return
  end
  return command(a,e,k,v)
 end
 function R.projectileStep(b)
  if b.laser and b.laser.straight then
   if b.dead then return end
   local l=b.laser;local t=b.age-l.delay
   if t<0 then l.scale=.03
   elseif t<l.grow then l.scale=math.max(.03,t/math.max(1,l.grow))
   elseif t<l.grow+l.hold then l.scale=1
   else l.scale=math.max(0,1-(t-l.grow-l.hold)/math.max(1,l.shrink))end
   b.collidable=t>=l.grow and t<l.grow+l.hold;b.age=b.age+1
   if t>=l.grow+l.hold+l.shrink then b.dead=true end
   return
  end
  local red=b.group=='th11rice'and b.typ==3 and b.color==2
  step(b)
  if red and not b.dead and b.color~=2 and not b.ninaExtra then
   R.riceColored=R.riceColored+1
   if R.riceColored%5==0 then
    local extra=R.copy(b);extra.ninaExtra=true;extra.angle=extra.angle+math.pi/18
    extra.vx,extra.vy=R.polar(extra.angle,extra.speed)
    R.hazards[#R.hazards+1]=extra;R.stats.bullets=R.stats.bullets+1;R.riceExtras=R.riceExtras+1
    if R.onShot then R.onShot(extra)end
   end
  end
 end
end
