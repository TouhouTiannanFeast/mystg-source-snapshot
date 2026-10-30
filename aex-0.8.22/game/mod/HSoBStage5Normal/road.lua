-- Generated from pinned HSoB1.12 stage5 scripts. Normal index1.
local E=HSoB5.env
setfenv(1,E)
local phase,phaseEx,R05_GainDamageRate,CreateShotWay_E01,CreateShotCircle_E01,CreateShotSquare_E01,CreateShotSquare_E02,CreateShotHalfSquare_E01,CreateShotStraight_E01,CreateShot_E01,_CreateShot_E01,SetEnemyF01,SetEnemyF02,SetEnemyF03,SetEnemyF04,SetEnemyF04b,SetEnemyF05,SetEnemyI01,I01_SetLaser,SetEnemyD01,SetEnemyF06,SetEnemyI02,SetEnemyF07,SetEnemyF08,SetEnemyMBoss,SetEnemyMB_1,SetEnemyMB_2,SetEnemyMB_3,DesertFairyMotion,DesertFairyMotion2,SinglePhase,PhaseTotal,E01_NORMAL,E01_ARROW,E01_SQUARE
phase=function(SplitNum)
 local w
 PhaseTotal=PhaseTotal + (SinglePhase * SplitNum)
 w=trunc(PhaseTotal)
 PhaseTotal=PhaseTotal - w
 do return w end
end
phaseEx=function(SplitNum)
 local old,w
 old=PhaseTotal
 old=old + (SinglePhase * SplitNum)
 w=trunc(old)
 do return w end
end
R05_GainDamageRate=asTask(function(objEnemy,delay,timer)
 timer=trunc(timer)
 ObjEnemy_SetDamageRate(objEnemy,10,10)
 waitObj(objEnemy,delay)
 for t=0,(timer)-1 do
  local tmp
  if truth(Obj_IsDeleted(objEnemy)) then
   do return  end
  end
  tmp=(100 / ((10 - ((((t + 1)) / timer) * 9))))
  ObjEnemy_SetDamageRate(objEnemy,tmp,tmp)
  waitObj(objEnemy,1)
 end
 ObjEnemy_SetDamageRate(objEnemy,100,100)
end)
CreateShotWay_E01=function(x,y,speed,angle,graphic,delay,way,way_angle,r,shot_type)
 local w_cen
 w_cen=0
 if truth((way > 1)) then
  w_cen=(((way - 1)) / 2)
 end
 for i=0,(way)-1 do
  local sa,sx,sy
  sa=(angle + (((i - w_cen)) * way_angle))
  sx=(x + (cos(sa) * r))
  sy=(y + (sin(sa) * r))
  CreateShot_E01(sx,sy,speed,sa,graphic,delay,shot_type)
 end
end
CreateShotCircle_E01=function(x,y,speed,angle,graphic,delay,way,r,shot_type)
 for i=0,(way)-1 do
  local sa,sx,sy
  sa=(angle + ((i * 360) / way))
  sx=(x + (cos(sa) * r))
  sy=(y + (sin(sa) * r))
  CreateShot_E01(sx,sy,speed,sa,graphic,delay,shot_type)
 end
end
CreateShotSquare_E01=function(x,y,speed,angle,graphic,delay,way,r,shot_type)
 for j=0,(4)-1 do
  local vpos
  vpos=arr(arr(cos((angle + (j * 90))),sin((angle + (j * 90)))),arr(cos((angle + (((j + 1)) * 90))),sin((angle + (((j + 1)) * 90)))))
  for i=0,(way)-1 do
   local tmp,vx,vy,sa,ss,sx,sy
   tmp=(i / way)
   vx=((at(at(vpos,0),0) * ((1 - tmp))) + (at(at(vpos,1),0) * tmp))
   vy=((at(at(vpos,0),1) * ((1 - tmp))) + (at(at(vpos,1),1) * tmp))
   sa=atan2(vy,vx)
   ss=(speed * ((((vx ^ 2) + (vy ^ 2))) ^ 0.5))
   sx=(x + (vx * r))
   sy=(y + (vy * r))
   CreateShot_E01(sx,sy,ss,sa,graphic,delay,shot_type)
  end
 end
end
CreateShotSquare_E02=function(x,y,speed,angle,graphic,delay,way,way2,r,shot_type)
 for j=0,(4)-1 do
  local vpos
  vpos=arr(arr(cos((angle + (j * 90))),sin((angle + (j * 90)))),arr(cos((angle + (((j + 1)) * 90))),sin((angle + (((j + 1)) * 90)))))
  for i=0,(way)-1 do
   local oway
   oway=(((((way2 - 1)) / 2) * 0.1) / way)
   for k=0,(way2)-1 do
    local tmp2,tmp,vx,vy,sa,ss,sx,sy
    tmp2=(((k - (((way2 - 1)) / 2))) * 0.1)
    tmp=(oway + ((((i + tmp2)) / ((way - 1))) * ((1 - (oway * 2)))))
    vx=((at(at(vpos,0),0) * ((1 - tmp))) + (at(at(vpos,1),0) * tmp))
    vy=((at(at(vpos,0),1) * ((1 - tmp))) + (at(at(vpos,1),1) * tmp))
    sa=atan2(vy,vx)
    ss=(speed * ((((vx ^ 2) + (vy ^ 2))) ^ 0.5))
    sx=(x + (vx * r))
    sy=(y + (vy * r))
    CreateShot_E01(sx,sy,ss,sa,graphic,delay,shot_type)
   end
  end
 end
end
CreateShotHalfSquare_E01=function(x,y,speed,angle,graphic,delay,way,r,shot_type)
 local vpos
 vpos=arr(arr(cos((angle + 90)),sin((angle + 90))),arr(cos((angle - 90)),sin((angle - 90))),arr(cos(angle),sin(angle)))
 for j=0,(2)-1 do
  for i=0,(way)-1 do
   local tmp,vx,vy,sa,ss,sx,sy
   tmp=(i / way)
   vx=((at(at(vpos,j),0) * ((1 - tmp))) + (at(at(vpos,2),0) * tmp))
   vy=((at(at(vpos,j),1) * ((1 - tmp))) + (at(at(vpos,2),1) * tmp))
   sa=atan2(vy,vx)
   ss=(speed * ((((vx ^ 2) + (vy ^ 2))) ^ 0.5))
   sx=(x + (vx * r))
   sy=(y + (vy * r))
   CreateShot_E01(sx,sy,ss,sa,graphic,delay,shot_type)
  end
 end
 do
  local vx,vy,sa,ss,sx,sy
  vx=at(at(vpos,2),0)
  vy=at(at(vpos,2),1)
  sa=atan2(vy,vx)
  ss=(speed * ((((vx ^ 2) + (vy ^ 2))) ^ 0.5))
  sx=(x + (vx * r))
  sy=(y + (vy * r))
  CreateShot_E01(sx,sy,ss,sa,graphic,delay,shot_type)
 end
end
CreateShotStraight_E01=function(x,y,speed,angle,graphic,delay,way,r,shot_type)
 for j=0,(1)-1 do
  local vpos
  vpos=arr(arr(cos(((angle + (j * 90)) - 45)),sin(((angle + (j * 90)) - 45))),arr(cos(((angle + (((j + 1)) * 90)) - 45)),sin(((angle + (((j + 1)) * 90)) - 45))))
  for i=0,(way)-1 do
   local tmp,vx,vy,sa,ss,sx,sy
   tmp=(i / way)
   vx=((at(at(vpos,0),0) * ((1 - tmp))) + (at(at(vpos,1),0) * tmp))
   vy=((at(at(vpos,0),1) * ((1 - tmp))) + (at(at(vpos,1),1) * tmp))
   sa=atan2(vy,vx)
   ss=(speed * ((((vx ^ 2) + (vy ^ 2))) ^ 0.5))
   sx=(x + (vx * r))
   sy=(y + (vy * r))
   CreateShot_E01(sx,sy,ss,sa,graphic,delay,shot_type)
  end
 end
end
CreateShot_E01=function(x,y,speed,angle,graphic,delay,shot_type)
 do local _switch=shot_type
 if _switch==E01_NORMAL then
  _CreateShot_E01(x,y,speed,angle,graphic,delay)
 elseif _switch==E01_ARROW then
  _CreateShot_E01(x,y,speed,(angle + 1),graphic,delay)
  _CreateShot_E01(x,y,speed,(angle - 1),graphic,delay)
  _CreateShot_E01(x,y,(speed * 1.02),angle,graphic,delay)
 elseif _switch==E01_SQUARE then
  _CreateShot_E01(x,y,(speed * 0.975),angle,graphic,delay)
  _CreateShot_E01(x,y,speed,(angle + 1),graphic,delay)
  _CreateShot_E01(x,y,speed,(angle - 1),graphic,delay)
  _CreateShot_E01(x,y,(speed * 1.025),angle,graphic,delay)
 end end
end
_CreateShot_E01=function(x,y,speed,angle,graphic,delay)
 local obj
 obj=My_CreateShotA2Ex(x,y,(speed * 1.5),angle,(((-speed) * 1.25) / 30),(speed / 4),graphic,delay,DELAY_DEFAULT)
 ObjMove_AddPatternA2(obj,30,NO_CHANGE,NO_CHANGE,(speed / 120),0,speed)
end
SetEnemyF01=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniToX,iniValue,iniValue2,iniWait)
 local TAct,TMove,TShot,timer,iniMuki,e_type,eSize,eColor,emnImage,objEnemy
 TAct=asTask(function()
  R05_GainDamageRate(objEnemy,0,(iniWait / 2))
  TShot()
  TMove()
 end)
 TMove=asTask(function()
  if truth((iniValue == 0)) then
   DesertFairyMotion(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
  else
   if truth((iniValue == 1)) then
    DesertFairyMotion2(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
   end
  end
 end)
 TShot=asTask(function()
  local speed,way,way_angle,graphic,wt,st_span,timer,beforeX,beforeY,st,t
  speed=at(arr(2.25,2.75,3.25,4),Difficult)
  way=at(arr(7,9,15,21),Difficult)
  way_angle=at(arr((180 / way),(180 / way),(180 / way),(180 / way)),Difficult)
  graphic=BGB_RICE_S_YELLOW
  wt=at(arr(18,13,7,5),Difficult)
  st_span=at(arr(1,1,1,2),Difficult)
  timer=(iniWait + at(arr(0,0,0,0),Difficult))
  if truth((iniValue2 == 1)) then
   graphic=BGB_RICE_S_RED
  end
  beforeX=ObjMove_GetX(objEnemy)
  beforeY=ObjMove_GetY(objEnemy)
  st=0
  t=0
  while truth((truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) and truth((st < way)))) do
   if truth((truth(CheckDispIN(objEnemy,0)) and truth(((t % wt) == 0)))) then
    local angle,tmp,sx,sy,ss,sa,g
    angle=atan2((ObjMove_GetY(objEnemy) - beforeY),(ObjMove_GetX(objEnemy) - beforeX))
    tmp=(t / timer)
    sx=ObjMove_GetX(objEnemy)
    sy=ObjMove_GetY(objEnemy)
    ss=speed
    sa=(GetAngleToPlayer(objEnemy) + ((((st - (((way - 1)) / 2))) * way_angle) * iniMuki))
    g=graphic
    if truth((st_span > 1)) then
     ss=ss * ((1 - (((st % st_span)) / st_span)))
    end
    CreateShotWay_E01(sx,sy,ss,sa,g,0,1,1,0,E01_SQUARE)
    st=st + 1
   end
   beforeX=ObjMove_GetX(objEnemy)
   beforeY=ObjMove_GetY(objEnemy)
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 iniMuki=at(arr(1,(-1)),(iniX < iniToX))
 e_type=(iniValue % 2)
 eSize=ENEMY_S
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy(iniX,iniY,12,eSize)
 DrawFairy(objEnemy,emnImage,FAIRY_SMALL)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF02=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniToX,iniValue,iniWait)
 local TAct,TMove,TShot,timer,e_type,eSize,eColor,emnImage,objEnemy
 TAct=asTask(function()
  R05_GainDamageRate(objEnemy,0,(iniWait / 2))
  TShot()
  TMove()
 end)
 TMove=asTask(function()
  if truth((iniValue == 0)) then
   DesertFairyMotion(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
  else
   if truth((iniValue == 1)) then
    DesertFairyMotion2(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
   end
  end
 end)
 TShot=asTask(function()
  local speed,way,graphic,wt,ct,st,t
  speed=at(arr(2,2.25,2.75,3),Difficult)
  way=at(arr(4,5,7,8),Difficult)
  graphic=BGW_BALL_BS_YELLOW
  wt=at(arr(80,80,80,80),Difficult)
  ct=at(arr(2,2,3,3),Difficult)
  st=0
  t=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
   if truth((truth(CheckDispIN(objEnemy,0)) and truth(((t % wt) == 0)))) then
    local sx,sy,ss,sa
    sx=ObjMove_GetX(objEnemy)
    sy=ObjMove_GetY(objEnemy)
    ss=(speed * ((1 - (st * 0.3))))
    sa=GetAngleToPlayer(objEnemy)
    CreateShotSquare_E01(sx,sy,ss,sa,graphic,0,way,0,E01_SQUARE)
    CallSound(sndShot2)
    st=st + 1
   end
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 2)
 eSize=ENEMY_L
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy(iniX,iniY,125,eSize)
 SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_5),arr(MY_ITEM_TIME_1,7))
 DrawFairy(objEnemy,emnImage,FAIRY_LARGE)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF03=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniToX,iniValue,iniWait)
 local TAct,TMove,TShot,timer,e_type,eSize,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TShot()
  TMove()
 end)
 TMove=asTask(function()
  R05_GainDamageRate(objEnemy,0,(iniWait / 2))
  if truth((iniValue == 0)) then
   DesertFairyMotion(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
  else
   if truth((iniValue == 1)) then
    DesertFairyMotion2(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
   end
  end
 end)
 TShot=asTask(function()
  local speed,way,graphic,wt,ct,st,t
  speed=at(arr(1.75,2,2.5,2.75),Difficult)
  way=at(arr(4,5,7,8),Difficult)
  graphic=BGW_BALL_BS_YELLOW
  wt=at(arr(80,80,80,80),Difficult)
  ct=at(arr(1,1,1,2),Difficult)
  st=0
  t=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
   if truth((truth(CheckDispIN(objEnemy,0)) and truth(((t % wt) == 0)))) then
    local sx,sy,ss,sa
    sx=ObjMove_GetX(objEnemy)
    sy=ObjMove_GetY(objEnemy)
    ss=speed
    sa=GetAngleToPlayer(objEnemy)
    CreateShotSquare_E01(sx,sy,ss,sa,graphic,0,way,0,E01_SQUARE)
    CallSound(sndShot2)
    st=st + 1
   end
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 2)
 eSize=ENEMY_M
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy(iniX,iniY,75,eSize)
 DrawFairy(objEnemy,emnImage,FAIRY_MIDDLE)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF04=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniValue2,iniMuki,iniWait)
 local TAct,Waiting,TMove,TShot,TShot2,timer,e_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  Waiting()
  R05_GainDamageRate(objEnemy,60,300)
  TMove()
 end)
 Waiting=function()
  local bx,by,objImg
  bx=((iniX * 0.5) + (CenX * 0.5))
  by=((iniY * 0.5) + (MinY * 0.5))
  objImg=GetEnemyImageID(objEnemy)
  ObjMove_SetPosition(objEnemy,iniX,(by - 128))
  MoveToSlowdown(objEnemy,bx,by,120)
  SetEnemyVisible(objEnemy,false)
  ObjRender_SetColor(objImg,0,0,0)
  Obj_SetRenderPriorityI(objImg,21)
  ObjRender_SetScaleXYZ(objImg,0.5,0.5,0.5)
  for t=0,(60)-1 do
   local tmp
   tmp=GetCurve_d((((t + 1)) / 60))
   ObjRender_SetAlpha(objImg,(tmp * 64))
   wait(1)
  end
  while truth((truth(CanShotBullet(objEnemy)) and truth((not truth(GetAreaCommonData(CAREA_STAGE,"STG5R_CHP3",0)))))) do
   wait(1)
  end
  waitObj(objEnemy,iniWait)
 end
 TMove=asTask(function()
  local objImg
  objImg=GetEnemyImageID(objEnemy)
  if truth((iniMuki ~= 0)) then
   MoveTo(objEnemy,(ObjMove_GetX(objEnemy) + (GetStgFrameWidth * iniMuki)),ObjMove_GetY(objEnemy),180)
  else
   MoveTo(objEnemy,ObjMove_GetX(objEnemy),(ObjMove_GetY(objEnemy) - (GetStgFrameHeight / 3)),180)
  end
  waitObj(objEnemy,180)
  ObjRender_SetScaleXYZ(objImg,1,1,1)
  ObjRender_SetAlpha(objImg,255)
  ObjRender_SetColor(objImg,255,255,255)
  Obj_SetRenderPriorityI(objImg,priorityZako)
  if truth((iniMuki ~= 0)) then
   ObjMove_SetY(objEnemy,iniY)
  else
   ObjMove_SetX(objEnemy,iniX)
  end
  MoveToSlowdown(objEnemy,iniX,iniY,135)
  SetEnemyVisible(objEnemy,true)
  waitObj(objEnemy,135)
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  TCheckDispINOut(objEnemy,32)
  TShot()
  Enemy_SetPatternA2(objEnemy,0,0,iniAngle,((iniSpeed / 60) / 16),0,(iniSpeed / 16))
  waitObj(objEnemy,phaseEx(14))
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  Enemy_SetPatternA2(objEnemy,0,NO_CHANGE,NO_CHANGE,(((-iniSpeed) / 30) / 16),0,0)
  waitObj(objEnemy,30)
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  Enemy_SetPatternA2(objEnemy,0,NO_CHANGE,GetAngleToPlayer(objEnemy),(iniSpeed / 120),0,iniSpeed)
  TShot2(GetAngleToPlayer(objEnemy))
  CallSound(sndLaser2)
 end)
 TShot=asTask(function()
  local fwt
  fwt=15
  waitObj(objEnemy,fwt)
  do local _switch=e_type
  if _switch==0 or _switch==1 then
   local speed,way,way_angle,graphic,speed2,way2,graphic2,shot_span,wt,timer,shot_delay,shot_st,muki,st,t
   speed=at(arr(1.66,2,2.15,2.5),Difficult)
   way=at(arr(1,1,2,3),Difficult)
   way_angle=at(arr(45,45,45,45),Difficult)
   graphic=BGW_MISSILE_RED
   speed2=at(arr(3,3,4,4),Difficult)
   way2=at(arr(4,4,6,6),Difficult)
   graphic2=BGW_SCALE_RED
   shot_span=at(arr(4,2,2,2),Difficult)
   wt=phaseEx(1)
   timer=(240 - fwt)
   if truth((e_type == 1)) then
    timer=(520 - fwt)
   end
   shot_delay=0
   shot_st=(iniValue2 % shot_span)
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
    if truth(((((t + shot_delay)) % wt) == 0)) then
     if truth((truth((e_type == 1)) or truth(((st % shot_span) == shot_st)))) then
      local tmp,sx,sy,ba
      tmp=(t / timer)
      sx=ObjMove_GetX(objEnemy)
      sy=ObjMove_GetY(objEnemy)
      ba=(90 + rand((-30),30))
      for i=0,(way)-1 do
       local ss,sa
       ss=(speed * ((1 - (absolute((i - (((way - 1)) / 2))) * 0.4))))
       sa=(ba + (((i - (((way - 1)) / 2))) * way_angle))
       CreateShot_E01(sx,sy,ss,sa,graphic,15,E01_ARROW)
      end
      CallSound(sndShot3)
     end
     if truth((truth((e_type == 1)) and truth(((st % shot_span) == shot_st)))) then
      local sx,sy
      sx=ObjMove_GetX(objEnemy)
      sy=ObjMove_GetY(objEnemy)
      CreateShotHalfSquare_E01(sx,sy,speed2,270,graphic2,0,way2,0,E01_ARROW)
      CallSound(sndShot2)
     end
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  elseif _switch==2 then
   local speed,way,graphic,ct,max_ct,speed_dec,wt,shot_delay,muki,st,t
   speed=at(arr(2.5,2.5,2.5,2.5),Difficult)
   way=at(arr(8,10,14,16),Difficult)
   graphic=BGW_CHRYSTAL_S_RED
   ct=at(arr(4,4,4,4),Difficult)
   max_ct=at(arr(2,3,3,3),Difficult)
   speed_dec=at(arr(0.25,0.25,0.25,0.2),Difficult)
   wt=phaseEx(4)
   shot_delay=trunc((wt * absolute(((0.25 * ((CenX - ObjMove_GetX(objEnemy)))) / ((GetClipWidth / 2))))))
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
    if truth(((((t + shot_delay)) % wt) == 0)) then
     local tmp,sx,sy,sa,count
     tmp=(t / timer)
     sx=ObjMove_GetX(objEnemy)
     sy=ObjMove_GetY(objEnemy)
     sa=45
     count=max(1,trunc(((max_ct / ((ct - 1))) * st)))
     for i=0,(count)-1 do
      local ss,sw
      ss=(speed * ((1 - (i * speed_dec))))
      sw=(way - (i * 2))
      CreateShotSquare_E01(sx,sy,ss,sa,graphic,0,sw,0,E01_SQUARE)
     end
     CallSound(sndShot2)
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  end end
 end)
 TShot2=asTask(function(angle)
  local max_r,objL,bpos,mpos,rangle,t
  max_r=at(arr(32,42,64),e_type)
  objL=arr()
  for i=0,(8)-1 do
   objL=concat(objL,arr(My_CreateStraightLaserA1(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),0,0,4,(60 * 99),BGW_BEAM_YELLOW,0,false)))
  end
  bpos=arr((cos(angle) * 0.85),(sin(angle) * 0.85))
  mpos=arr(((-cos(angle)) / 3),((-sin(angle)) / 3))
  rangle=angle
  t=0
  while truth((not truth(Obj_IsDeleted(objEnemy)))) do
   local tmp,tmp2,pos,r
   tmp=GetCurve_d(min(1,(((t + 1)) / 30)))
   tmp2=GetCurve_d(min(1,(((t + 1)) / 180)))
   pos=arr()
   for i=0,(4)-1 do
    local cpos
    cpos=Rotate2D_XY((cos((rangle + (i * 90))) / 2),sin((rangle + (i * 90))),angle)
    pos=concat(pos,arr((at(mpos,0) + at(cpos,0)),(at(mpos,1) + at(cpos,1))))
   end
   r=(max_r * tmp)
   for i=0,(4)-1 do
    local p1,p2,l,a
    p1=bpos
    p2=slice(pos,(i * 2),((i * 2) + 2))
    l=((((((at(p1,1) - at(p2,1))) ^ 2) + (((at(p1,0) - at(p2,0))) ^ 2))) ^ 0.5)
    a=atan2((at(p2,1) - at(p1,1)),(at(p2,0) - at(p1,0)))
    ObjMove_SetPosition(at(objL,i),(ObjMove_GetX(objEnemy) + (at(p1,0) * r)),(ObjMove_GetY(objEnemy) + (at(p1,1) * r)))
    ObjLaser_SetLength(at(objL,i),(r * l))
    ObjStLaser_SetAngle(at(objL,i),a)
   end
   for i=0,(4)-1 do
    local p1,p2,l,a
    p1=slice(pos,(i * 2),((i * 2) + 2))
    p2=slice(pos,(((((i + 1)) % 4)) * 2),((((((i + 1)) % 4)) * 2) + 2))
    l=((((((at(p1,1) - at(p2,1))) ^ 2) + (((at(p1,0) - at(p2,0))) ^ 2))) ^ 0.5)
    a=atan2((at(p2,1) - at(p1,1)),(at(p2,0) - at(p1,0)))
    ObjMove_SetPosition(at(objL,(i + 4)),(ObjMove_GetX(objEnemy) + (at(p1,0) * r)),(ObjMove_GetY(objEnemy) + (at(p1,1) * r)))
    ObjLaser_SetLength(at(objL,(i + 4)),(r * l))
    ObjStLaser_SetAngle(at(objL,(i + 4)),a)
   end
   t=t + 1
   rangle=rangle + (tmp2 * 6)
   wait(1)
  end
  for i=0,(length(objL))-1 do
   Obj_Delete(at(objL,i))
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 3)
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(50,100,300),e_type)
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy(iniX,iniY,eLife,eSize)
 do local _switch=e_type
 if _switch==0 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_3),arr(MY_ITEM_TIME_1,5))
 elseif _switch==1 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_3),arr(MY_ITEM_TIME_1,7))
 elseif _switch==2 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_5),arr(MY_ITEM_TIME_1,10))
 end end
 if truth((eSize == ENEMY_L)) then
  SetEffectResist(objEnemy,0.5)
 end
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF04b=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniValue2,iniMuki,iniWait)
 local TAct,TMove,TShot,timer,e_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TMove()
 end)
 TMove=asTask(function()
  if truth((iniMuki ~= 0)) then
   ObjMove_SetX(objEnemy,(iniX + ((GetClipWidth / 4) * iniMuki)))
   ObjMove_SetY(objEnemy,(iniY - (GetClipWidth / 2)))
  else
   ObjMove_SetX(objEnemy,iniX)
   ObjMove_SetY(objEnemy,(iniY - (GetClipWidth / 2)))
  end
  MoveToSlowdown(objEnemy,iniX,iniY,120)
  SetEnemyVisible(objEnemy,true)
  R05_GainDamageRate(objEnemy,0,120)
  waitObj(objEnemy,(120 + iniWait))
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  Enemy_SetPatternA2(objEnemy,0,NO_CHANGE,iniAngle,(iniSpeed / 60),0,iniSpeed)
  Enemy_SetPatternA2(objEnemy,240,NO_CHANGE,iniAngle,(iniSpeed / 45),0,(iniSpeed * 4))
  TCheckDispINOut(objEnemy,32)
  TShot()
  waitObj(objEnemy,240)
 end)
 TShot=asTask(function()
  local fwt
  fwt=0
  waitObj(objEnemy,fwt)
  do local _switch=e_type
  if _switch==0 then
   local speed,way,way_angle,graphic,wt,timer,shot_delay,muki,st,t
   speed=at(arr(2,2,2.5,2.75),Difficult)
   way=at(arr(1,1,3,5),Difficult)
   way_angle=at(arr(15,15,15,15),Difficult)
   graphic=BGW_MISSILE_RED
   wt=at(arr(118,118,118,118),Difficult)
   timer=(340 - fwt)
   shot_delay=(iniValue2 * 5)
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
    if truth(((((t - shot_delay)) % wt) == 0)) then
     local to_x,to_y,tmp,sx,sy,ss,ba
     to_x=(CenX + (((GetPlayerX - CenX)) * 2))
     to_y=(CenY + (((GetPlayerY - CenY)) * 2))
     if truth((Difficult == D_EASY)) then
      to_x=GetPlayerX
      to_y=GetPlayerY
     end
     tmp=(t / timer)
     sx=ObjMove_GetX(objEnemy)
     sy=ObjMove_GetY(objEnemy)
     ss=speed
     ba=atan2((to_y - sy),(to_x - sx))
     for i=0,(way)-1 do
      local ss,sa
      ss=(speed * ((1 - (absolute((i - (((way - 1)) / 2))) * 0.2))))
      sa=(ba + (((i - (((way - 1)) / 2))) * way_angle))
      CreateShot_E01(sx,sy,ss,sa,graphic,15,E01_ARROW)
     end
     CallSound(sndShot3)
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  elseif _switch==1 or _switch==2 then
   local speed,way,way2,count_max,speed_dec,graphic,wt,ct,shot_delay,muki,st,t
   speed=at(arr(2.5,2.5,2.5,2.5),Difficult)
   way=at(arr(6,6,6,6),Difficult)
   way2=at(arr(4,5,6,7),Difficult)
   count_max=at(arr(2,3,3,3),Difficult)
   speed_dec=at(arr(0.25,0.25,0.25,0.25),Difficult)
   graphic=BGW_CHRYSTAL_S_RED
   wt=at(arr(157,157,157,157),Difficult)
   ct=3
   shot_delay=0
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
    if truth(((((t + shot_delay)) % wt) == 0)) then
     local tmp,sx,sy,sa,count
     tmp=(t / timer)
     sx=ObjMove_GetX(objEnemy)
     sy=ObjMove_GetY(objEnemy)
     sa=45
     count=max(1,trunc(((((st + 1)) / ct) * count_max)))
     for i=0,(count)-1 do
      local ss,sw
      ss=(speed * ((1 - (i * speed_dec))))
      sw=(way - i)
      CreateShotSquare_E02(sx,sy,ss,sa,graphic,0,sw,way2,0,E01_NORMAL)
     end
     CallSound(sndShot2)
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  end end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 3)
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(50,100,200),e_type)
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy((-32),(-32),eLife,eSize)
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF05=asTask(function(iniX,iniY,iniSpeed,iniAngle,toPos,offsetPos,iniValue,iniShotWait,iniWait)
 local TAct,TMove,TShot,timer,e_type,m_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TShot()
  TMove()
 end)
 TMove=asTask(function()
  if truth((m_type == 0)) then
   local to_angle
   MoveToSlowdown(objEnemy,(at(toPos,0) + at(offsetPos,0)),(at(toPos,1) + at(offsetPos,1)),90)
   R05_GainDamageRate(objEnemy,0,150)
   TShot()
   waitObj(objEnemy,(90 + iniWait))
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   to_angle=atan2((GetPlayerY - at(toPos,1)),(GetPlayerX - at(toPos,0)))
   Enemy_SetPatternA2(objEnemy,0,0,to_angle,(iniSpeed / 60),0,iniSpeed)
   TCheckDispINOut(objEnemy,32)
  else
   local objImg
   MoveToSlowdown(objEnemy,(at(toPos,0) + at(offsetPos,0)),(at(toPos,1) + at(offsetPos,1)),iniWait)
   while truth((not truth(GetAreaCommonData(CAREA_STAGE,"STG5R_CHP5",0)))) do
    if truth((not truth(CanShotBullet(objEnemy)))) then
     do return  end
    end
    wait(1)
   end
   waitEx(60)
   objImg=GetEnemyImageID(objEnemy)
   for t=(30)-1,0,-1 do
    local tmp
    tmp=(((t + 1)) / 30)
    ObjRender_SetAlpha(objImg,(tmp * 255))
    wait(1)
   end
   EraseEnemy(objEnemy)
  end
 end)
 TShot=asTask(function()
  local fwt
  fwt=iniShotWait
  do local _switch=iniValue
  if _switch==0 then
  elseif _switch==1 or _switch==2 then
   local speed,way,count,graphic,wt,timer,shot_delay,muki,st,t
   waitObj(objEnemy,fwt)
   speed=at(arr(1.33,1.75,1.75,1.75),Difficult)
   way=at(arr(4,5,7,5),Difficult)
   count=at(arr(1,1,1,2),Difficult)
   graphic=BGW_CHRYSTAL_M_RED
   wt=phaseEx(2)
   timer=(210 - fwt)
   if truth((iniValue == 2)) then
    local graphic
    graphic=BGW_CHRYSTAL_M_RED
    way=trunc((way * 1.75))
    speed=speed * 0.75
   end
   shot_delay=0
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
    if truth(((((t + shot_delay)) % wt) == 0)) then
     local tmp,sx,sy,sa
     tmp=(t / timer)
     sx=ObjMove_GetX(objEnemy)
     sy=ObjMove_GetY(objEnemy)
     sa=0
     for i=0,(count)-1 do
      local ss
      ss=(speed * ((1 - (i * 0.25))))
      CreateShotSquare_E01(sx,sy,ss,sa,graphic,0,way,0,E01_NORMAL)
     end
     CallSound(sndShot2)
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  elseif _switch==3 or _switch==4 or _switch==5 then
   local speed,way,graphic,wt,timer,shot_delay,muki,st,t
   fwt=phaseEx(2)
   waitObj(objEnemy,fwt)
   speed=at(arr(1,1.25,1.25,1.25),Difficult)
   way=at(arr(3,3,5,7),Difficult)
   graphic=BGW_CHRYSTAL_S_RED
   wt=phaseEx(4)
   timer=(iniWait - fwt)
   if truth((iniValue == 5)) then
    speed=at(arr(1.25,1.5,1.5,1.5),Difficult)
    way=at(arr(3,4,7,8),Difficult)
    graphic=BGW_CHRYSTAL_M_RED
   end
   shot_delay=0
   muki=at(arr(1,(-1)),(CenX < ObjMove_GetX(objEnemy)))
   st=0
   t=0
   while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
    if truth(((((t + shot_delay)) % wt) == 0)) then
     if truth(CheckDispIN(objEnemy,0)) then
      local tmp,sx,sy,ss,sa
      tmp=(t / timer)
      sx=ObjMove_GetX(objEnemy)
      sy=ObjMove_GetY(objEnemy)
      ss=speed
      sa=0
      CreateShotSquare_E01(sx,sy,ss,sa,(graphic + at(SHOT_COLOR,(((st + 6)) % 7))),0,way,0,E01_NORMAL)
      CallSound(sndShot2)
     end
     st=st + 1
    end
    t=t + 1
    waitObj(objEnemy,1)
   end
  end end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 3)
 m_type=trunc((iniValue / 3))
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(15,75,100),e_type)
 if truth((m_type > 0)) then
  eLife=at(arr(120,240,360),e_type)
 end
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyYellow
 objEnemy=MakeEnemy(iniX,iniY,eLife,eSize)
 do local _switch=e_type
 if _switch==0 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_3),arr(MY_ITEM_TIME_1,5))
 elseif _switch==1 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_1),arr(MY_ITEM_TIME_1,5))
 elseif _switch==2 then
  SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_3),arr(MY_ITEM_TIME_1,0))
 end end
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyI01=function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,TUchikaeshi,eSize,eColor,objEnemy
 TAct=asTask(function()
  R05_GainDamageRate(objEnemy,0,60)
  TMove()
  TShot()
  WaitForKilled(objEnemy)
  if truth((CheckKillType(objEnemy) == 2)) then
   TUchikaeshi(true)
  end
  ZakoFinalize(objEnemy,eColor)
 end)
 TMove=asTask(function()
  local timer,bx,by,vx,vy
  timer=iniWait
  bx=iniX
  by=iniY
  vx=(iniSpeed * cos(iniAngle))
  vy=(iniSpeed * sin(iniAngle))
  ZakoEnterEffect_Onmyou(objEnemy,timer)
  for t=0,(timer)-1 do
   local tmp,ex,ey
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   tmp=GetCurve_d((((t + 1)) / timer))
   ex=((CenX * (((1 / 2) - (tmp / 2)))) + (bx * (((1 / 2) + (tmp / 2)))))
   ey=(((MinY * ((1 - tmp))) + (by * tmp)) + ((128 * tmp) * ((1 - tmp))))
   ObjMove_SetPosition(objEnemy,ex,ey)
   waitObj(objEnemy,1)
  end
  Enemy_SetPatternA2(objEnemy,0,0,iniAngle,(iniSpeed / 60),0,iniSpeed)
  Enemy_SetPatternA2(objEnemy,60,NO_CHANGE,NO_CHANGE,(iniSpeed / 240),0,(iniSpeed * 2))
  while truth(CanShotBullet(objEnemy)) do
   if truth((ObjMove_GetY(objEnemy) > (MaxY + 32))) then
    EraseEnemy(objEnemy)
    do break end
   end
   waitObj(objEnemy,1)
  end
 end)
 TShot=asTask(function()
  if truth((Difficult <= D_NORM)) then
   do return  end
  end
  while truth(CanShotBullet(objEnemy)) do
   if truth((ObjMove_GetY(objEnemy) >= MaxY)) then
    TUchikaeshi(false)
    do break end
   end
   waitObj(objEnemy,1)
  end
 end)
 TUchikaeshi=asTask(function(uchi_flg)
  local speed,shot_span,max_way,graphic,objL_All
  speed=3
  shot_span=12
  max_way=at(arr(0,24,24,24),Difficult)
  graphic=BGW_CROSS_SKY
  if truth((not truth(uchi_flg))) then
   speed=at(arr(1.5,1.5,1.5,2),Difficult)
   shot_span=at(arr(36,36,32,16),Difficult)
   graphic=BGW_CROSS_PURPLE
  end
  if truth((max_way <= 0)) then
   do return  end
  end
  objL_All=Obj_GetValueD(objEnemy,"LASER_ID",(-1))
  for j=0,(length(objL_All))-1 do
   local objL
   objL=at(objL_All,j)
   if truth((not truth(Obj_IsDeleted(objL)))) then
    local x,y,len,la,way,cpos,cr,new_len
    x=ObjMove_GetX(objL)
    y=ObjMove_GetY(objL)
    len=ObjLaser_GetLength(objL)
    la=ObjStLaser_GetAngle(objL)
    way=trunc((len / shot_span))
    way=min(max_way,max(3,way))
    cpos=arr((x + ((len * cos(la)) / 2)),(y + ((len * sin(la)) / 2)))
    cr=((((((GetPlayerX - at(cpos,0))) ^ 2) + (((GetPlayerY - at(cpos,1))) ^ 2))) ^ 0.5)
    new_len=min((way * shot_span),len)
    if truth((new_len > len)) then
     x=x - ((((new_len - len)) / 2) * cos(la))
     y=y - ((((new_len - len)) / 2) * sin(la))
     la=new_len
    end
    if truth(uchi_flg) then
     for i=0,(way)-1 do
      local tmp,sr,sx,sy,vx,vy,sa,ss
      tmp=0.5
      if truth((way > 1)) then
       tmp=(i / ((way - 1)))
      end
      sr=(len * tmp)
      sx=(x + (sr * cos(la)))
      sy=(y + (sr * sin(la)))
      vx=((((GetPlayerX - sx)) / cr) * speed)
      vy=((((GetPlayerY - sy)) / cr) * speed)
      sa=atan2(vy,vx)
      ss=((((vx ^ 2) + (vy ^ 2))) ^ 0.5)
      My_CreateShotA2(sx,sy,0,sa,(ss / 120),ss,graphic,15)
      CallSound(sndShot5)
     end
    else
     for i=0,(way)-1 do
      local tmp,sr,sx,sy,sa,ss
      tmp=0.5
      if truth((way > 1)) then
       tmp=(i / ((way - 1)))
      end
      sr=(len * tmp)
      sx=(x + (sr * cos(la)))
      sy=(y + (sr * sin(la)))
      sa=(270 + rand((-45),45))
      ss=speed
      My_CreateShotA2(sx,sy,0,sa,(ss / 120),ss,graphic,15)
      CallSound(sndShot5)
     end
    end
    Obj_Delete(objL)
   end
  end
 end)
 if truth(flgStopSetZako) then
  do return ((-1)) end
 end
 eSize=ENEMY_M
 eColor=EFF_BLUE
 objEnemy=MakeEnemy(iniX,iniY,66,eSize)
 SetEnemyDropItem(objEnemy,arr(MY_ITEM_TIME_1),arr(MY_ITEM_TIME_1,5))
 Obj_SetValue(objEnemy,"LASER_ID",arr())
 DrawOnmyou(objEnemy,eColor)
 TAct()
 do return (objEnemy) end
end
I01_SetLaser=asTask(function(obj1,obj2,timer,graphic,delay)
 local obj
 if truth((truth(Obj_IsDeleted(obj1)) or truth(Obj_IsDeleted(obj2)))) then
  do return  end
 end
 obj=My_CreateStraightLaserA1(ObjMove_GetX(obj1),ObjMove_GetY(obj1),0,0,12,timer,graphic,delay,true)
 Obj_SetValue(obj1,"LASER_ID",concat(Obj_GetValueD(obj1,"LASER_ID",arr()),arr(obj)))
 Obj_SetValue(obj2,"LASER_ID",concat(Obj_GetValueD(obj2,"LASER_ID",arr()),arr(obj)))
 while truth((not truth(Obj_IsDeleted(obj)))) do
  local r,a
  if truth((truth(Obj_IsDeleted(obj1)) or truth(Obj_IsDeleted(obj2)))) then
   do break end
  end
  r=max(0,(GetObjectDistance(obj1,obj2) - 32))
  a=GetGapAngle(arr(ObjMove_GetX(obj1),ObjMove_GetY(obj1)),arr(ObjMove_GetX(obj2),ObjMove_GetY(obj2)))
  ObjMove_SetPosition(obj,(ObjMove_GetX(obj1) + (16 * cos(a))),(ObjMove_GetY(obj1) + (16 * sin(a))))
  ObjStLaser_SetAngle(obj,a)
  ObjLaser_SetLength(obj,r)
  wait(1)
 end
 Obj_Delete(obj)
end)
SetEnemyD01=function(iniX,iniY,iniSpeed,iniAngle,iniToX,iniValue,iniWait)
 local TAct,TMove,DesertFairyMotion_D01,objEnemy
 TAct=asTask(function()
  TMove()
 end)
 TMove=asTask(function()
  DesertFairyMotion_D01(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,iniWait)
 end)
 DesertFairyMotion_D01=asTask(function(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
  local ex,ey,es,to_x,bx,by,ba,muki,add_ba,t
  TCheckDispINOut(objEnemy,64)
  ex=iniX
  ey=iniY
  es=iniSpeed
  to_x=iniToX
  bx=ObjMove_GetX(objEnemy)
  by=ObjMove_GetY(objEnemy)
  ba=iniAngle
  muki=at(arr(1,(-1)),(iniX < CenX))
  add_ba=(2 * muki)
  Obj_SetValue(objEnemy,"MOVE_STOP",0)
  Obj_SetValue(objEnemy,"MOVE_STOP2",0)
  Obj_SetValue(objEnemy,"MOVE_ANGLE",iniAngle)
  Obj_SetValue(objEnemy,"MOVE_R",ba)
  Obj_SetValue(objEnemy,"MOVE_OFFSET_ANGLE",ba)
  t=0
  while truth(CanShotBullet(objEnemy)) do
   if truth((truth((bx ~= ObjMove_GetX(objEnemy))) or truth((by ~= ObjMove_GetY(objEnemy))))) then
    local a
    a=atan2((ObjMove_GetY(objEnemy) - by),(ObjMove_GetX(objEnemy) - bx))
    Obj_SetValue(objEnemy,"MOVE_ANGLE",a)
    bx=ObjMove_GetX(objEnemy)
    by=ObjMove_GetY(objEnemy)
   end
   if truth((Obj_GetValueD(objEnemy,"MOVE_STOP",0) <= 0)) then
    if truth((t < timer)) then
     local tmp
     tmp=GetCurve_d((((t + 1)) / timer))
     ex=((iniX * ((1 - tmp))) + (to_x * tmp))
    else
     if truth((t < (timer * 3))) then
      local tmp
      tmp=(GetCurve_a(min(1,(((t - timer)) / ((timer * 2))))) * 4)
      ex=((iniX * tmp) + (to_x * ((1 - tmp))))
     else
      EraseEnemy(objEnemy)
      do return  end
     end
    end
    ey=ey + es
    es=min((es * 4),(es + (iniSpeed / 60)))
    ObjMove_SetPosition(objEnemy,ex,ey)
    Obj_SetValue(objEnemy,"MOVE_R",GetCurve_d(min(1,(((t + 1)) / 60))))
    t=t + 1
   end
   if truth((Obj_GetValueD(objEnemy,"MOVE_STOP2",0) <= 0)) then
    Obj_SetValue(objEnemy,"MOVE_OFFSET_ANGLE",ba)
    ba=ba + add_ba
   end
   Obj_SetValue(objEnemy,"MOVE_STOP",0)
   Obj_SetValue(objEnemy,"MOVE_STOP2",0)
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return ((-1)) end
 end
 objEnemy=MakeEnemy(iniX,iniY,1,ENEMY_FREE)
 TAct()
 do return (objEnemy) end
end
SetEnemyF06=asTask(function(objParent,iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,e_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TMove()
  TShot()
 end)
 TMove=asTask(function()
  while truth((truth(CanShotBullet(objEnemy)) and truth((not truth(Obj_IsDeleted(objParent)))))) do
   if truth(IsTimeStopObj(objEnemy)) then
    Obj_SetValue(objParent,"MOVE_STOP",(Obj_GetValueD(objEnemy,"MOVE_STOP",0) + 1))
   end
   ObjMove_SetPosition(objEnemy,ObjMove_GetX(objParent),ObjMove_GetY(objParent))
   wait(1)
  end
  EraseEnemy(objEnemy)
 end)
 TShot=asTask(function()
  local speed,way,way2,graphic,wt,ct,shot_delay,st,t
  speed=at(arr(2,2,2.75,2.75),Difficult)
  way=at(arr(6,6,6,6),Difficult)
  way2=at(arr(3,3,3,3),Difficult)
  graphic=BGW_CHRYSTAL_M_WHITE
  wt=at(arr(157,157,157,157),Difficult)
  ct=at(arr(0,0,1,2),Difficult)
  shot_delay=0
  st=0
  t=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
   if truth(((((t + shot_delay)) % wt) == 0)) then
    local sx,sy,ss,sa
    sx=ObjMove_GetX(objEnemy)
    sy=ObjMove_GetY(objEnemy)
    ss=speed
    sa=GetAngleToPlayer(objEnemy)
    CreateShotSquare_E02(sx,sy,ss,sa,graphic,0,way,way2,0,E01_NORMAL)
    CallSound(sndShot2)
    st=st + 1
   end
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 e_type=(iniValue % 3)
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(50,100,150),e_type)
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyEgypt
 objEnemy=MakeEnemy((-32),(-32),eLife,eSize)
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyI02=asTask(function(objParent,iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,eSize,eLife,eColor,ePos,objEnemy
 TAct=asTask(function()
  TMove()
  TShot()
 end)
 TMove=asTask(function()
  local objAllImg
  objAllImg=GetEnemyImageIDEx(objEnemy)
  for i=0,(length(objAllImg))-1 do
   ObjRender_SetScaleXYZ(at(objAllImg,i),0.75,0.75,0.75)
  end
  while truth((truth(CanShotBullet(objEnemy)) and truth((not truth(Obj_IsDeleted(objParent)))))) do
   local r,ra,ea,pos
   if truth(IsTimeStopObj(objEnemy)) then
    Obj_SetValue(objParent,"MOVE_STOP2",(Obj_GetValueD(objEnemy,"MOVE_STOP2",0) + 1))
   end
   r=(iniValue * Obj_GetValueD(objParent,"MOVE_R",0))
   ra=Obj_GetValueD(objParent,"MOVE_ANGLE",0)
   ea=(Obj_GetValueD(objParent,"MOVE_OFFSET_ANGLE",0) + iniAngle)
   pos=Rotate2D_XY((cos(ea) / 3),sin(ea),ra)
   ObjMove_SetPosition(objEnemy,(ObjMove_GetX(objParent) + (at(pos,0) * r)),(ObjMove_GetY(objParent) + (at(pos,1) * r)))
   ePos=pos
   if truth((cos(ea) > 0)) then
    for i=0,(length(objAllImg))-1 do
     Obj_SetRenderPriorityI(at(objAllImg,i),priorityZako)
    end
   else
    for i=0,(length(objAllImg))-1 do
     Obj_SetRenderPriorityI(at(objAllImg,i),priorityZakoBack)
    end
   end
   wait(1)
  end
  EraseEnemy(objEnemy)
 end)
 TShot=asTask(function()
  local speed,graphic,wt,shot_ct,shot_span,timer,st,t
  speed=at(arr(2.5,3,3,2),Difficult)
  graphic=BGW_SCALE_YELLOW
  wt=at(arr(1,1,1,1),Difficult)
  shot_ct=at(arr(5,5,5,5),Difficult)
  shot_span=at(arr(10,10,9,7),Difficult)
  timer=at(arr(150,210,240,240),Difficult)
  st=0
  t=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
   if truth((truth(CheckDispIN(objEnemy,0)) and truth(((t % wt) == 0)))) then
    if truth(((st % shot_span) < shot_ct)) then
     local sx,sy,ss,sa
     sx=ObjMove_GetX(objEnemy)
     sy=ObjMove_GetY(objEnemy)
     ss=(speed * (((((at(ePos,0)) ^ 2) + ((at(ePos,1)) ^ 2))) ^ 0.5))
     sa=atan2(at(ePos,1),at(ePos,0))
     CreateShot_E01(sx,sy,ss,sa,graphic,5,E01_NORMAL)
    end
    st=st + 1
   end
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 eSize=ENEMY_S
 eLife=50
 eColor=EFF_YELLOW
 ePos=arr()
 objEnemy=MakeEnemy((-32),(-32),eLife,eSize)
 DrawOnmyou(objEnemy,eColor)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF07=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniValue2,iniMuki,iniWait)
 local TAct,TMove,TShot,e_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TMove()
  TShot()
 end)
 TMove=asTask(function()
  local bx,by,br,ba,add_ba,bs,t
  bx=iniX
  by=iniY
  br=((GetClipWidth / 2) * 1.25)
  ba=iniValue2
  add_ba=1
  bs=iniSpeed
  Enemy_WaitForDispOUT(objEnemy,64,120)
  t=0
  while truth(CanShotBullet(objEnemy)) do
   local vpos,ex,ey
   if truth((t < 120)) then
    bs=bs - (iniSpeed / 120)
    add_ba=add_ba - (1 / 120)
   else
    bs=bs + (iniSpeed / 120)
    add_ba=add_ba - (0.25 / 120)
    br=br - (((GetClipWidth / 2) * 1.25) / 180)
   end
   vpos=Rotate2D_XY(((cos(ba) * br) / 8),(sin(ba) * br),iniAngle)
   ex=(bx + at(vpos,0))
   ey=(by + at(vpos,1))
   ObjMove_SetPosition(objEnemy,ex,ey)
   bx=bx + (bs * cos(iniAngle))
   by=by + (bs * sin(iniAngle))
   ba=ba + (add_ba * iniMuki)
   t=t + 1
   waitObj(objEnemy,1)
  end
 end)
 TShot=asTask(function()
  local speed,way,way_angle,graphic
  waitObj(objEnemy,120)
  speed=at(arr(1.66,2,2.25,2.5),Difficult)
  way=at(arr(1,3,3,5),Difficult)
  way_angle=at(arr(30,30,30,18),Difficult)
  graphic=BGW_CHRYSTAL_S_BLUE
  if truth(CanShotBullet(objEnemy)) then
   local sx,sy,ss,sa
   sx=ObjMove_GetX(objEnemy)
   sy=ObjMove_GetY(objEnemy)
   ss=speed
   sa=GetAngleToPlayer(objEnemy)
   CreateShotWay_E01(sx,sy,ss,sa,graphic,0,way,way_angle,0,E01_SQUARE)
   CallSound(sndShot2)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 e_type=(iniValue % 3)
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(20,50,100),e_type)
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyEgypt
 objEnemy=MakeEnemy((-32),(-32),eLife,eSize)
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyF08=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,speedY,timer,e_type,m_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TShot()
  TMove()
 end)
 TMove=asTask(function()
  Enemy_WaitForDispOUT(objEnemy,32,60)
  Enemy_SetPatternB1(objEnemy,0,iniSpeed,speedY)
 end)
 TShot=asTask(function()
  local speed,way,way2,graphic,wt,ct,shot_delay,st
  speed=at(arr(2,2,2.75,2.75),Difficult)
  way=at(arr(6,6,6,6),Difficult)
  way2=at(arr(3,3,3,3),Difficult)
  graphic=BGW_CHRYSTAL_S_WHITE
  wt=phaseEx(1)
  ct=at(arr(0,0,5,99),Difficult)
  if truth((ct <= 0)) then
   do return  end
  end
  shot_delay=0
  st=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((st < ct)))) do
   local sx,sy,vx,vy,ss,sa
   sx=ObjMove_GetX(objEnemy)
   sy=ObjMove_GetY(objEnemy)
   vx=((-iniSpeed) / 2)
   vy=(speedY + 1)
   ss=((((vy ^ 2) + (vx ^ 2))) ^ 0.5)
   sa=atan2(vy,vx)
   CreateShot_E01(sx,sy,ss,sa,graphic,15,E01_SQUARE)
   CallSound(sndShot2)
   st=st + 1
   waitObj(objEnemy,phaseEx(1))
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 speedY=0.5
 timer=iniWait
 e_type=(iniValue % 3)
 m_type=trunc((iniValue / 3))
 eSize=at(arr(ENEMY_S,ENEMY_M,ENEMY_L),e_type)
 eLife=at(arr(10,50,100),e_type)
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyEgypt
 objEnemy=MakeEnemy(iniX,iniY,eLife,eSize)
 DrawFairy(objEnemy,emnImage,at(arr(FAIRY_SMALL,FAIRY_MIDDLE,FAIRY_LARGE),e_type))
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyMBoss=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,E01Set,E02Set,E03Set,THitCheck,timer,e_type,m_type,eSize,eLife,eColor,emnImage,HIT_CHECK,objEnemy
 TAct=asTask(function()
  TMove()
 end)
 TMove=asTask(function()
  local objImg
  MoveToSlowdown(objEnemy,iniX,iniY,180)
  THitCheck()
  wait(phaseEx((8 - 2)))
  while truth(IsTimeStopObj(objEnemy)) do
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   wait(1)
  end
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  TShot(0)
  wait(phaseEx(8))
  while truth(IsTimeStopObj(objEnemy)) do
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   wait(1)
  end
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  TShot(1)
  wait(phaseEx(8))
  while truth(IsTimeStopObj(objEnemy)) do
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   wait(1)
  end
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  TShot(2)
  wait(phaseEx((8 + 2)))
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  if truth((not truth(HIT_CHECK))) then
   SetItem(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),MY_ITEM_SPELL)
  end
  SetEnemyVisible(objEnemy,false)
  objImg=GetEnemyImageID(objEnemy)
  for t=(120)-1,0,-1 do
   local tmp,tmp_c
   tmp=(((t + 1)) / 120)
   tmp_c=((tmp ^ 2) * 255)
   ObjRender_SetAlpha(objImg,((tmp ^ 0.5) * 255))
   ObjRender_SetColor(objImg,tmp_c,tmp_c,tmp_c)
   wait(1)
  end
  EraseEnemy(objEnemy)
 end)
 TShot=asTask(function(phase)
  do local _switch=phase
  if _switch==0 then
   E01Set(3,1)
   wait(phaseEx(2))
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   E01Set(3,(-1))
   wait(phaseEx(2))
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   E01Set(3,1)
   E01Set(3,(-1))
  elseif _switch==1 then
   for i=0,(4)-1 do
    if truth((not truth(CanShotBullet(objEnemy)))) then
     do return  end
    end
    E02Set(5,(((4 - i)) * 24),1)
    E02Set(5,(((4 - i)) * 24),(-1))
    wait(phaseEx(1))
   end
  elseif _switch==2 then
   E03Set(rand(0,360),32,phaseEx((1 / 8)))
  end end
 end)
 E01Set=asTask(function(way,muki)
  local count
  count=3
  for i=0,(way)-1 do
   for j=0,(count)-1 do
    local ox2,ox,oy,es
    ox2=((((j - 1)) * 36) * muki)
    ox=(((96 + (j * 36))) * muki)
    oy=(i * 48)
    es=3
    SetEnemyMB_1(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),es,90,arr(arr(ox,0),arr(ox,oy),arr(ox2,0)),0,arr((i == 0)),0)
   end
  end
 end)
 E02Set=asTask(function(way,offset_y,muki)
  for i=0,(way)-1 do
   local ox2,ox,oy,es
   ox2=((((i + 0.5)) * 36) * muki)
   ox=((i * 36) * muki)
   oy=offset_y
   es=3
   SetEnemyMB_1((ObjMove_GetX(objEnemy) + (18 * muki)),ObjMove_GetY(objEnemy),es,90,arr(arr(0,oy),arr(ox,oy),arr(ox2,0)),1,(i == 0),0)
  end
 end)
 E03Set=asTask(function(base_angle,count,wt)
  local way,muki
  way=3
  muki=at(arr(1,(-1)),(GetPlayerX < CenX))
  for i=0,(count)-1 do
   local speed
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   speed=(0.5 + ((i / count) * 6))
   for j=0,(way)-1 do
    local sa
    sa=(base_angle + ((((j + ((i / 2.236) / 2))) * 360) / way))
    SetEnemyMB_2(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),speed,sa,0,phaseEx(8))
   end
   wait(wt)
  end
 end)
 THitCheck=asTask(function()
  local tmp_life
  tmp_life=GetPlayerLife()
  while truth(CanShotBullet(objEnemy)) do
   if truth((tmp_life < GetPlayerLife())) then
    tmp_life=GetPlayerLife()
   end
   if truth((tmp_life < GetPlayerLife())) then
    HIT_CHECK=true
    do break end
   end
   wait(1)
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 3)
 m_type=trunc((iniValue / 3))
 eSize=ENEMY_L
 eLife=999999
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyEgypt
 HIT_CHECK=false
 objEnemy=MakeEnemy(iniX,(MinY - 64),eLife,eSize)
 SetEffectResist(objEnemy,0.5)
 SetTimeResist(objEnemy,1)
 DrawFairy(objEnemy,emnImage,FAIRY_LARGE_FLOWER)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyMB_1=asTask(function(iniX,iniY,iniSpeed,iniAngle,offsetPos,iniValue,iniValue2,iniWait)
 local TAct,TMove,EnterEffect,TShot,TShot2,timer,e_type,eSize,eLife,eColor,emnImage,objEnemy
 TAct=asTask(function()
  TMove()
 end)
 TMove=asTask(function()
  local pos
  pos=arr(arr((iniX + at(at(offsetPos,0),0)),(iniY + at(at(offsetPos,0),1)),phaseEx(2)),arr((iniX + at(at(offsetPos,1),0)),(iniY + at(at(offsetPos,1),1)),phaseEx(2)))
  EnterEffect((at(at(pos,0),2) * 1.25))
  for i=0,(2)-1 do
   if truth((not truth(CanShotBullet(objEnemy)))) then
    do return  end
   end
   if truth((i == 1)) then
    TShot()
   end
   MoveTo(objEnemy,at(at(pos,i),0),at(at(pos,i),1),at(at(pos,i),2))
   waitObj(objEnemy,at(at(pos,i),2))
  end
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  TCheckDispINOut(objEnemy,16)
  do local _switch=iniValue
  if _switch==0 then
   local to_a
   to_a=atan2((GetPlayerY - ((ObjMove_GetY(objEnemy) - at(at(offsetPos,2),1)))),(GetPlayerX - ((ObjMove_GetX(objEnemy) - at(at(offsetPos,2),0)))))
   Enemy_SetPatternA2(objEnemy,0,0,to_a,(iniSpeed / 120),0,iniSpeed)
   TShot2(to_a)
   CallSound(sndLaser2)
  elseif _switch==1 then
   local vy,vx,spd_rate
   vy=(GetPlayerY - ObjMove_GetY(objEnemy))
   vx=(GetPlayerX - ObjMove_GetX(objEnemy))
   if truth((truth((absolute(vy) < 64)) and truth((vy >= 0)))) then
    vy=64
   end
   if truth((truth((absolute(vy) < 64)) and truth((vy < 0)))) then
    vy=(-64)
   end
   spd_rate=(iniSpeed / vy)
   vx=vx * spd_rate
   vy=vy * spd_rate
   if truth((spd_rate < 0)) then
    vx=(-vx)
    vy=(-vy)
   end
   Enemy_SetPatternB2(objEnemy,0,0,0,(vx / 120),(vy / 120),vx,vy)
   TShot2(atan2(vy,vx))
   CallSound(sndLaser2)
  end end
 end)
 EnterEffect=asTask(function(timer)
  local objImg
  SetEnemyVisible(objEnemy,false)
  objImg=GetEnemyImageID(objEnemy)
  for t=0,(timer)-1 do
   local tmp,tmp_c,tmp_a
   tmp=(((t + 1)) / timer)
   tmp_c=((tmp ^ 2) * 255)
   tmp_a=((((tmp * 1.25) - 0.25)) * 255)
   ObjRender_SetAlpha(objImg,tmp_a)
   ObjRender_SetColor(objImg,tmp_c,tmp_c,tmp_c)
   wait(1)
  end
  SetEnemyVisible(objEnemy,true)
 end)
 TShot=asTask(function()
  local speed,count,way,graphic,to_angle
  if truth((not truth(iniValue2))) then
   do return  end
  end
  speed=at(arr(2.25,2.25,3,4),Difficult)
  count=at(arr(1,2,2,3),Difficult)
  way=at(arr(3,4,5,5),Difficult)
  graphic=BGW_CHRYSTAL_M_BLUE
  to_angle=(-9999999)
  if truth((iniValue == 1)) then
   speed=at(arr(1.75,1.75,2.5,3.5),Difficult)
   way=at(arr(3,6,7,5),Difficult)
   count=at(arr(1,1,1,2),Difficult)
   to_angle=90
  end
  if truth(CanShotBullet(objEnemy)) then
   local sx,sy,sa
   sx=ObjMove_GetX(objEnemy)
   sy=ObjMove_GetY(objEnemy)
   sa=to_angle
   if truth((to_angle < (-999999))) then
    sa=GetAngleToPlayer(objEnemy)
   end
   for i=0,(count)-1 do
    local ss
    ss=(speed * ((1 - (i * 0.33))))
    CreateShotHalfSquare_E01(sx,sy,ss,sa,graphic,0,way,0,E01_NORMAL)
   end
   CallSound(sndShot2)
  end
 end)
 TShot2=asTask(function(angle)
  local max_r,objL,bpos,mpos,rangle,t
  max_r=36
  objL=arr()
  for i=0,(8)-1 do
   objL=concat(objL,arr(My_CreateStraightLaserA1(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),0,0,4,(60 * 99),BGW_BEAM_YELLOW,0,false)))
  end
  bpos=arr((cos(angle) * 0.85),(sin(angle) * 0.85))
  mpos=arr(((-cos(angle)) / 3),((-sin(angle)) / 3))
  rangle=angle
  t=0
  while truth((not truth(Obj_IsDeleted(objEnemy)))) do
   local tmp,tmp2,pos,r
   tmp=GetCurve_d(min(1,(((t + 1)) / 30)))
   tmp2=GetCurve_d(min(1,(((t + 1)) / 180)))
   pos=arr()
   for i=0,(4)-1 do
    local cpos
    cpos=Rotate2D_XY((cos((rangle + (i * 90))) / 2),sin((rangle + (i * 90))),angle)
    pos=concat(pos,arr((at(mpos,0) + at(cpos,0)),(at(mpos,1) + at(cpos,1))))
   end
   r=(max_r * tmp)
   for i=0,(4)-1 do
    local p1,p2,l,a
    p1=bpos
    p2=slice(pos,(i * 2),((i * 2) + 2))
    l=((((((at(p1,1) - at(p2,1))) ^ 2) + (((at(p1,0) - at(p2,0))) ^ 2))) ^ 0.5)
    a=atan2((at(p2,1) - at(p1,1)),(at(p2,0) - at(p1,0)))
    ObjMove_SetPosition(at(objL,i),(ObjMove_GetX(objEnemy) + (at(p1,0) * r)),(ObjMove_GetY(objEnemy) + (at(p1,1) * r)))
    ObjLaser_SetLength(at(objL,i),(r * l))
    ObjStLaser_SetAngle(at(objL,i),a)
   end
   for i=0,(4)-1 do
    local p1,p2,l,a
    p1=slice(pos,(i * 2),((i * 2) + 2))
    p2=slice(pos,(((((i + 1)) % 4)) * 2),((((((i + 1)) % 4)) * 2) + 2))
    l=((((((at(p1,1) - at(p2,1))) ^ 2) + (((at(p1,0) - at(p2,0))) ^ 2))) ^ 0.5)
    a=atan2((at(p2,1) - at(p1,1)),(at(p2,0) - at(p1,0)))
    ObjMove_SetPosition(at(objL,(i + 4)),(ObjMove_GetX(objEnemy) + (at(p1,0) * r)),(ObjMove_GetY(objEnemy) + (at(p1,1) * r)))
    ObjLaser_SetLength(at(objL,(i + 4)),(r * l))
    ObjStLaser_SetAngle(at(objL,(i + 4)),a)
   end
   t=t + 1
   rangle=rangle + (tmp2 * 6)
   wait(1)
  end
  for i=0,(length(objL))-1 do
   Obj_Delete(at(objL,i))
  end
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 timer=iniWait
 e_type=(iniValue % 3)
 eSize=ENEMY_S
 eLife=30
 eColor=EFF_YELLOW
 emnImage=imgZakoFairyEgypt
 objEnemy=MakeEnemy(iniX,iniY,eLife,eSize)
 DrawFairy(objEnemy,emnImage,FAIRY_SMALL)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyMB_2=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,iniTimer,iniMuki,flgUchikaeshi,e_type,eSize,eColor,objEnemy
 TAct=asTask(function()
  TMove()
  TShot()
 end)
 TMove=asTask(function()
  local bx,by,t
  bx=iniX
  by=iniY
  SetEnemyVisible(objEnemy,false)
  SetHitodama2Size(objEnemy,0,255)
  Enemy_SetPatternA2(objEnemy,0,iniSpeed,iniAngle,((-iniSpeed) / 120),0,(iniSpeed / 4))
  TCheckDispINOut(objEnemy,16)
  t=0
  while truth((truth(CanShotBullet(objEnemy)) and truth((t < iniTimer)))) do
   local tmp
   tmp=GetCurve_d((((t + 1)) / iniTimer))
   SetHitodama2Size(objEnemy,tmp,255)
   t=t + 1
   waitObj(objEnemy,1)
  end
  SetEnemyVisible(objEnemy,true)
 end)
 TShot=asTask(function()
  local speed,way
  waitObj(objEnemy,iniWait)
  if truth((not truth(CanShotBullet(objEnemy)))) then
   do return  end
  end
  speed=at(arr(0.5,0.5,0.6,0.6),Difficult)
  way=at(arr(6,12,14,18),Difficult)
  CreateShotCircle_E01(ObjMove_GetX(objEnemy),ObjMove_GetY(objEnemy),speed,iniAngle,ADD_BGW_BALL_S_BLUE,15,way,0,E01_NORMAL)
  Obj_SetValue(objEnemy,"KILLED",1)
  ObjEnemy_SetLife(objEnemy,0)
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 iniTimer=60
 iniMuki=at(arr(1,(-1)),(cos(iniAngle) < 0))
 flgUchikaeshi=true
 e_type=(iniValue % 2)
 eSize=ENEMY_S
 eColor=EFF_BLUE
 objEnemy=MakeEnemy(iniX,iniY,150,eSize)
 DrawHitodama2(objEnemy,eColor)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
SetEnemyMB_3=asTask(function(iniX,iniY,iniSpeed,iniAngle,iniValue,iniWait)
 local TAct,TMove,TShot,eSize,eColor,objEnemy
 TAct=asTask(function()
  TMove()
  TShot()
 end)
 TMove=asTask(function()
  local br,ba
  br=0
  ba=iniAngle
  ZakoEnterEffect_Onmyou(objEnemy,30)
  TCheckDispINOut(objEnemy,16)
  while truth(CanShotBullet(objEnemy)) do
   local bx,by
   bx=(iniX + (br * cos(ba)))
   by=(iniY + (br * sin(ba)))
   ObjMove_SetPosition(objEnemy,bx,by)
   br=br + iniSpeed
   ba=ba + iniValue
   waitObj(objEnemy,1)
  end
 end)
 TShot=asTask(function()
 end)
 if truth(flgStopSetZako) then
  do return  end
 end
 eSize=ENEMY_M
 eColor=EFF_BLUE
 objEnemy=MakeEnemy(iniX,iniY,50,eSize)
 DrawOnmyou(objEnemy,eColor)
 TAct()
 WaitForKilled(objEnemy)
 ZakoFinalize(objEnemy,eColor)
end)
DesertFairyMotion=asTask(function(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
 local ex,ey,es,to_x,t
 TCheckDispINOut(objEnemy,32)
 ex=iniX
 ey=iniY
 es=iniSpeed
 to_x=iniToX
 t=0
 while truth(CanShotBullet(objEnemy)) do
  if truth((t < timer)) then
   local tmp
   tmp=GetCurve_d((((t + 1)) / timer))
   ex=((iniX * ((1 - tmp))) + (to_x * tmp))
  else
   if truth((t < (timer * 3))) then
    local tmp
    tmp=(GetCurve_a(min(1,(((t - timer)) / ((timer * 2))))) * 4)
    ex=((iniX * tmp) + (to_x * ((1 - tmp))))
   else
    EraseEnemy(objEnemy)
    do return  end
   end
  end
  ey=ey + es
  es=min((es * 4),(es + (iniSpeed / 60)))
  ObjMove_SetPosition(objEnemy,ex,ey)
  t=t + 1
  waitObj(objEnemy,1)
 end
end)
DesertFairyMotion2=asTask(function(objEnemy,iniX,iniY,iniSpeed,iniAngle,iniToX,timer)
 local ex,ey,es,to_x,t,ox
 TCheckDispINOut(objEnemy,32)
 ex=iniX
 ey=iniY
 es=iniSpeed
 to_x=iniToX
 t=0
 while truth((truth(CanShotBullet(objEnemy)) and truth((t < timer)))) do
  if truth((t < timer)) then
   local tmp
   tmp=GetCurve_d((((t + 1)) / timer))
   ex=((iniX * ((1 - tmp))) + (to_x * tmp))
  end
  ey=ey + es
  es=min((es * 2),(es + (iniSpeed / timer)))
  ObjMove_SetPosition(objEnemy,ex,ey)
  t=t + 1
  waitObj(objEnemy,1)
 end
 t=0
 ox=cos(iniAngle)
 while truth(CanShotBullet(objEnemy)) do
  local tmp
  tmp=GetCurve_d(min(1,(((t + 1)) / 240)))
  ex=ex + ((es * ox) * tmp)
  ey=ey + es
  if truth((t < 90)) then
   es=es - (iniSpeed / 60)
  else
   es=min((es * 4),(es + (iniSpeed / 60)))
  end
  ObjMove_SetPosition(objEnemy,ex,ey)
  t=t + 1
  waitObj(objEnemy,1)
 end
end)
SinglePhase=39.435
PhaseTotal=0
E01_NORMAL=0
E01_ARROW=1
E01_SQUARE=2
local F01,_F01,F02,F01b,F01c,F04,I01,F04b,F05,F05b,F06,F07_single,F08
F01=asTask(function(x,to_x,count,f_rev,f_type)
 for i=0,(count)-1 do
  _F01(x,to_x,(i + 1),at(arr(0,f_type),(i == 0)))
  WaitRoad(phaseEx(0.5))
 end
 if truth(f_rev) then
  for i=((count - 1))-1,0,-1 do
   _F01(x,to_x,(i + 1),0)
   WaitRoad(phaseEx(0.5))
  end
 end
end)
_F01=asTask(function(x,to_x,count,f_type)
 for i=0,(count)-1 do
  local offset,ex,ey,es,tx,timer
  offset=(((i - (((count - 1)) / 2))) * 32)
  ex=(x + (offset * 3))
  ey=(MinY - 16)
  es=0.85
  tx=(to_x + offset)
  timer=105
  if truth((f_type == 1)) then
   SetEnemyF02(ex,ey,es,90,tx,0,timer)
  else
   if truth((f_type == 2)) then
    SetEnemyF03(ex,ey,es,90,tx,0,timer)
   else
    SetEnemyF01(ex,ey,es,90,tx,0,0,timer)
   end
  end
 end
end)
F02=asTask(function(x,to_x,count)
 local muki
 muki=at(arr(1,(-1)),(x > CenX))
 for i=0,(count)-1 do
  local offset,ex,ey,es,tx,timer
  offset=((i * 3) * muki)
  ex=(x + (offset * 3))
  ey=(MinY - 16)
  es=0.4
  tx=to_x
  timer=150
  if truth((i == 0)) then
   SetEnemyF02(ex,ey,es,90,tx,0,timer)
  else
   SetEnemyF01(ex,ey,es,90,tx,0,0,timer)
  end
  muki=(-muki)
  WaitRoad(phaseEx(0.5))
 end
end)
F01b=asTask(function(x,to_x,angle,count,f_type)
 for i=0,(count)-1 do
  local ct,muki
  ct=at(arr(2,1),(i == 0))
  muki=1
  for _loop1=0,(ct)-1 do
   local offset,ex,ey,es,tx,timer,flgBig
   offset=((((i + 0.5)) * 16) * muki)
   if truth((i == 0)) then
    offset=0
   end
   ex=(x + (offset * 2))
   ey=(MinY - 16)
   es=0.66
   tx=(to_x + offset)
   timer=105
   flgBig=((i == (trunc((count - 1)) / 2)))
   if truth((truth((i == 0)) and truth((f_type == 1)))) then
    SetEnemyF02(ex,ey,es,angle,tx,1,timer)
   else
    if truth((truth((i == 0)) and truth((f_type == 2)))) then
     SetEnemyF03(ex,ey,es,angle,tx,1,timer)
    else
     SetEnemyF01(ex,ey,es,angle,tx,1,0,timer)
    end
   end
   muki=(-muki)
  end
  WaitRoad(phaseEx((1 / 4)))
 end
end)
F01c=asTask(function(x,to_x,speed,angle,count,f_type)
 for i=0,(count)-1 do
  local ct,muki
  ct=at(arr(2,1),(i == 0))
  muki=1
  for _loop2=0,(ct)-1 do
   local offset,ex,ey,es,tx,timer,flgBig
   offset=((((i + 0.5)) * 16) * muki)
   if truth((i == 0)) then
    offset=0
   end
   ex=(x + (offset * 2))
   ey=(MinY - 16)
   es=speed
   tx=(to_x + offset)
   timer=105
   flgBig=((i == (trunc((count - 1)) / 2)))
   if truth((truth((i == 0)) and truth((f_type == 1)))) then
    SetEnemyF02(ex,ey,es,angle,tx,0,timer)
   else
    if truth((truth((i == 0)) and truth((f_type == 2)))) then
     SetEnemyF03(ex,ey,es,angle,tx,0,timer)
    else
     SetEnemyF01(ex,ey,es,angle,tx,0,1,timer)
    end
   end
   muki=(-muki)
  end
  WaitRoad(phaseEx((1 / 4)))
 end
end)
F04=function(x,y,add_x,add_y,count,muki,f_type,wait_phase)
 for i=0,(count)-1 do
  local ex,ey,es,ea,wt
  ex=(x + (add_x * i))
  ey=(y + (add_y * i))
  es=4
  ea=90
  wt=phaseEx(wait_phase)
  SetEnemyF04(ex,ey,es,ea,f_type,i,muki,wt)
 end
end
I01=asTask(function(pos_set,speed,angle)
 local _I01
 _I01=asTask(function(pos_set,wide_x,offset_x,speed,angle,carea)
  for i=0,(length(pos_set))-1 do
   local beforeE,tmp,ex,ey,ea,wt,speed,delay,objE
   beforeE=GetAreaCommonData(CAREA_STAGE,carea,(-1))
   tmp=(((at(at(pos_set,i),0) * wide_x) + (((1 - wide_x)) / 2)) + offset_x)
   ex=(MinX + (((MaxX - MinX)) * tmp))
   ey=(MinY + 16)
   ea=(angle - ((((tmp - 0.5)) * 2) * 24))
   wt=at(at(pos_set,i),2)
   speed=2
   delay=105
   objE=SetEnemyI01(ex,ey,speed,ea,i,delay)
   SetAreaCommonData(CAREA_STAGE,carea,objE)
   I01_SetLaser(beforeE,objE,(60 * 99),BGW_BEAM_BLUE,delay)
   WaitRoad(phaseEx(wt))
  end
 end)
 _I01(pos_set,0.6,(-0.15),speed,angle,"STG5R_CHP4")
 _I01(pos_set,0.6,0.15,speed,angle,"STG5R_CHP4_2")
end)
F04b=function(x,y,add_x,add_y,count,i_index,muki,f_type,wt)
 for i=0,(count)-1 do
  local ex,ey,es,ea
  ex=(x + (add_x * i))
  ey=(y + (add_y * i))
  es=0.5
  ea=90
  SetEnemyF04b(ex,ey,es,ea,f_type,(i + i_index),muki,wt)
 end
end
F05=asTask(function(x,y,to_x,to_y,count,wide,shot_delay,delay,e_type)
 local speed,angle
 speed=2
 angle=90
 SetEnemyF05(x,y,speed,angle,arr(to_x,to_y),arr(0,0),e_type,shot_delay,delay)
 for i=0,(count)-1 do
  local ox,oy
  ox=(((min(i,((count - i) - 1)) * wide) / 32) * 24)
  oy=(((i - (((count - 1)) / 2))) * wide)
  SetEnemyF05(x,y,speed,angle,arr(to_x,to_y),arr(ox,oy),0,shot_delay,delay)
  if truth((ox > 0)) then
   ox=(-ox)
   SetEnemyF05(x,y,speed,angle,arr(to_x,to_y),arr(ox,oy),0,shot_delay,delay)
  end
 end
end)
F05b=asTask(function(x,y,to_x,to_y,count,delay,e_type,e_range)
 local speed,angle
 speed=2
 angle=90
 for i=0,(count)-1 do
  local ox,oy
  ox=(min(i,((count - i) - 1)) * e_range)
  oy=(((((i - (((count - 1)) / 2))) * e_range) / 46) * 40)
  SetEnemyF05((x + ox),(y + oy),speed,angle,arr(to_x,to_y),arr(ox,oy),e_type,0,delay)
  if truth((ox > 0)) then
   ox=(-ox)
   SetEnemyF05((x + ox),(y + oy),speed,angle,arr(to_x,to_y),arr(ox,oy),e_type,0,delay)
  end
 end
end)
F06=asTask(function(x,to_x,count,f_type)
 local ex,ey,es,er,timer,objParent
 ex=x
 ey=(MinY - 32)
 es=0.33
 er=54
 timer=150
 objParent=SetEnemyD01(ex,ey,es,90,to_x,0,timer)
 SetEnemyF06(objParent,ex,ey,es,90,f_type,timer)
 for i=0,(count)-1 do
  SetEnemyI02(objParent,ex,ey,es,((i * 360) / count),er,timer)
 end
end)
F07_single=function(ea,angle,muki,e_type)
 local ex,ey,es
 ex=(CenX - (((GetClipHeight / 2) * 1.5) * cos(ea)))
 ey=(CenY - (((GetClipHeight / 2) * 1.5) * sin(ea)))
 es=3
 SetEnemyF07(ex,ey,es,ea,e_type,angle,muki,0)
end
F08=asTask(function(muki)
 local baseX,baseY,st
 baseX=(-32)
 baseY=(MinY - 64)
 st=0
 while truth((baseY < MaxY)) do
  local wt
  wt=phaseEx(1)
  if truth(1) then
   local ex,ey,vx
   ex=((MinX + (GetClipWidth / 2)) + (((baseX - (GetClipWidth / 2))) * muki))
   ey=baseY
   vx=(1.5 * muki)
   SetEnemyF08(ex,ey,vx,0,0,0)
  end
  st=st + 1
  baseY=baseY + (wt * 0.5)
  wait(wt)
 end
end)
local GetDrawingPosition,R05_DL,R05_SetDrawingLaser,DrawLaser,SetDrawingWall
GetDrawingPosition=function(index)
 do local _switch=index
 if _switch=="a" then
  do return (arr(arr((-0.87500),(-0.81250),0.31869,(-11.30993)),arr((-0.56250),(-0.87500),0.17678,(-45.00000)),arr((-0.43750),(-1.00000),0.18750,0.00000),arr((-0.25000),(-1.00000),0.27951,63.43495),arr((-0.12500),(-0.75000),0.39528,71.56505),arr(0.00000,(-0.37500),0.45069,33.69007),arr(0.37500,(-0.12500),0.55902,63.43495),arr(0.62500,0.37500,0.55902,63.43495),arr(0.87500,0.87500,0.70711,(-135.00000)),arr(0.37500,0.37500,0.80039,(-141.34019)),arr((-0.25000),(-0.12500),0.27951,(-153.43495)),arr((-0.50000),(-0.25000),0.50000,(-90.00000)),arr((-0.50000),(-0.75000),0.38017,(-170.53768)),arr((-0.37500),(-0.18750),1.12500,90.00000),arr((-0.37500),0.06250,0.88829,50.71059),arr(0.18750,0.75000,0.50000,(-90.00000)),arr(0.18750,0.43750,0.70711,45.00000),arr(0.68750,0.93750,0.19764,(-18.43495)),arr((-0.06250),0.43750,0.50389,82.87498),arr((-0.81250),0.93750,1.18750,0.00000),arr(0.00000,(-0.37500),0.31869,(-168.69007)),arr((-0.31250),(-0.43750),0.25769,104.03624))) end
 elseif _switch=="i" then
  do return (arr(arr((-0.06250),(-0.31250),0.76291,55.00798),arr((-0.37500),(-0.31250),0.72887,59.03624))) end
 elseif _switch=="e" then
  do return (arr(arr(0.18750,0.93750,1.50000,(-90.00000)),arr(0.18750,(-0.56250),0.25769,(-104.03624)),arr(0.12500,(-0.81250),0.26517,(-135.00000)),arr((-0.06250),(-1.00000),1.38773,97.76517),arr((-0.25000),0.37500,0.57622,40.60129))) end
 elseif _switch=="u" then
  do return (arr(arr((-0.62500),0.93750,1.00000,0.00000),arr((-0.62500),(-0.81250),0.13975,(-26.56505)),arr((-0.50000),(-0.87500),0.17678,(-45.00000)),arr((-0.37500),(-1.00000),0.18750,0.00000),arr((-0.18750),(-1.00000),0.22535,56.30993),arr((-0.06250),(-0.81250),0.25769,75.96376),arr(0.00000,(-0.56250),0.44194,45.00000),arr(0.31250,(-0.25000),0.45069,56.30993),arr(0.56250,0.12500,0.17678,45.00000),arr(0.68750,0.25000,0.39528,161.56505),arr(0.31250,0.37500,0.31869,(-168.69007)),arr(0.00000,0.31250,0.45069,(-123.69007)),arr((-0.25000),(-0.06250),0.57622,(-102.52881)),arr((-0.37500),(-0.62500),0.13975,(-116.56505)),arr((-0.43750),(-0.75000),0.19764,(-161.56505)),arr((-0.12500),(-0.50000),0.19764,108.43495),arr((-0.18750),(-0.31250),0.40020,51.34019),arr(0.06250,0.00000,0.13975,(-63.43495)),arr(0.12500,(-0.12500),0.19764,(-108.43495)),arr(0.00000,0.31250,0.25000,90.00000),arr(0.00000,0.56250,0.39528,108.43495),arr(0.18750,0.37500,0.25769,75.96376),arr(0.25000,0.62500,0.33657,111.80141))) end
 elseif _switch=="o" then
  do return (arr(arr(0.75000,1.00000,0.36443,(-120.96376)),arr(0.56250,0.68750,0.50389,(-97.12502)),arr(0.50000,0.18750,0.75000,(-90.00000)),arr(0.50000,(-0.56250),0.19764,(-108.43495)),arr(0.43750,(-0.75000),0.17678,(-135.00000)),arr(0.31250,(-0.87500),0.25769,(-165.96376)),arr(0.06250,(-0.93750),0.25769,165.96376),arr((-0.18750),(-0.87500),0.22535,146.30993),arr((-0.37500),(-0.75000),0.25769,104.03624),arr((-0.43750),(-0.50000),0.75000,90.00000),arr((-0.43750),0.25000,0.17678,135.00000),arr((-0.56250),0.37500,0.19764,108.43495),arr((-0.62500),0.56250,0.25769,75.96376),arr((-0.56250),0.81250,0.13975,26.56505),arr((-0.43750),0.87500,0.13975,(-26.56505)),arr((-0.31250),0.81250,0.19764,(-71.56505)),arr((-0.25000),0.62500,0.25769,(-104.03624)),arr((-0.31250),0.37500,0.17678,(-135.00000)),arr((-0.87500),0.06250,0.56250,0.00000),arr((-0.31250),0.06250,0.08839,(-45.00000)),arr((-0.25000),0.00000,0.18750,0.00000),arr((-0.06250),0.00000,0.08839,45.00000),arr(0.00000,0.06250,0.08839,135.00000),arr((-0.06250),0.12500,0.18750,180.00000),arr((-0.25000),0.12500,0.08839,(-135.00000)))) end
 elseif _switch=="k" then
  do return (arr(arr((-1.00000),(-0.31250),1.81250,0.00000),arr(0.81250,(-0.31250),0.26517,45.00000),arr(1.00000,(-0.12500),0.18750,90.00000),arr(1.00000,0.06250,0.13975,153.43495),arr(0.87500,0.12500,0.47599,(-113.19859)),arr(0.68750,(-0.31250),0.36443,120.96376),arr(0.50000,0.00000,0.36443,149.03624),arr(0.18750,0.18750,0.75000,180.00000),arr((-0.56250),0.18750,0.31250,(-143.13010)),arr((-0.81250),0.00000,0.36443,(-120.96376)))) end
 elseif _switch=="s" then
  do return (arr(arr(0.18750,1.00000,1.81250,(-90.00000)),arr(0.18750,(-0.81250),0.13975,(-116.56505)),arr(0.12500,(-0.93750),0.13975,(-153.43495)),arr(0.00000,(-1.00000),0.13975,153.43495),arr((-0.12500),(-0.93750),0.13975,116.56505),arr((-0.18750),(-0.81250),1.00000,90.00000))) end
 elseif _switch=="t" then
  do return (arr(arr(0.50000,0.25000,1.00000,180.00000),arr((-0.50000),0.25000,0.18750,(-90.00000)),arr((-0.50000),0.06250,0.22535,(-56.30993)),arr((-0.37500),(-0.12500),0.22535,(-33.69007)),arr((-0.18750),(-0.25000),0.19764,(-18.43495)),arr(0.00000,(-0.31250),0.19764,18.43495),arr(0.18750,(-0.25000),0.22535,33.69007),arr(0.37500,(-0.12500),0.22535,56.30993),arr(0.50000,0.06250,0.18750,90.00000))) end
 elseif _switch=="n" then
  do return (arr(arr((-0.93750),0.06250,0.26517,(-45.00000)),arr((-0.75000),(-0.12500),0.26517,45.00000),arr((-0.56250),0.06250,0.26517,(-45.00000)),arr((-0.37500),(-0.12500),0.26517,45.00000),arr((-0.18750),0.06250,0.26517,(-45.00000)),arr(0.00000,(-0.12500),0.26517,45.00000),arr(0.18750,0.06250,0.26517,(-45.00000)),arr(0.37500,(-0.12500),0.26517,45.00000),arr(0.56250,0.06250,0.26517,(-45.00000)),arr(0.75000,(-0.12500),0.26517,45.00000))) end
 elseif _switch=="h" then
  do return (arr(arr(0.00000,(-0.12500),0.56250,90.00000),arr(0.00000,0.43750,0.56250,0.00000),arr(0.56250,0.43750,0.87500,(-90.00000)),arr(0.56250,(-0.43750),1.12500,180.00000),arr((-0.56250),(-0.43750),0.87500,90.00000))) end
 elseif _switch=="m" then
  do return (arr(arr((-0.56250),(-1.00000),0.17678,135.00000),arr((-0.68750),(-0.87500),0.37500,90.00000),arr((-0.68750),(-0.50000),0.62500,53.13010),arr((-0.31250),0.00000,0.85009,53.97263),arr(0.18750,0.68750,0.31869,(-78.69007)),arr(0.25000,0.37500,0.50389,60.25512),arr(0.50000,0.81250,0.22535,33.69007),arr(0.68750,0.93750,0.25769,14.03624),arr(0.93750,1.00000,0.31250,(-90.00000)),arr(0.93750,0.68750,1.30054,(-125.21759)),arr(0.18750,(-0.37500),0.40020,(-141.34019)),arr((-0.12500),(-0.62500),0.25000,(-90.00000)),arr((-0.12500),(-0.87500),0.17678,(-135.00000)),arr((-0.25000),(-1.00000),0.31250,180.00000),arr((-0.56250),(-0.81250),0.27951,63.43495),arr((-0.43750),(-0.56250),0.31250,(-53.13010)),arr((-0.06250),(-0.43750),0.18750,180.00000),arr((-0.25000),(-0.43750),0.13975,116.56505),arr((-0.31250),(-0.31250),0.22535,56.30993),arr((-0.18750),(-0.12500),1.07529,35.53768),arr((-0.31250),0.00000,0.87723,94.08562),arr((-0.06250),0.37500,0.50000,90.00000),arr((-0.06250),0.87500,0.81250,180.00000))) end
 elseif _switch=="r" then
  do return (arr(arr((-1.00000),0.00000,0.61555,(-23.96249)),arr((-0.43750),(-0.25000),0.44194,(-8.13010)),arr(0.00000,(-0.31250),0.38017,9.46232),arr(0.37500,(-0.25000),0.67315,21.80141),arr(1.00000,0.00000,0.65252,163.30076),arr(0.37500,0.18750,0.38017,170.53768),arr(0.00000,0.25000,0.44194,(-171.86990)),arr((-0.43750),0.18750,0.59293,(-161.56505)))) end
 elseif _switch=="g" then
  do return (arr(arr(0.00000,(-0.18750),0.47599,113.19859),arr((-0.18750),0.25000,0.13975,26.56505),arr((-0.06250),0.31250,0.12500,0.00000),arr(0.06250,0.31250,0.13975,(-26.56505)),arr(0.18750,0.25000,0.47599,(-113.19859)),arr((-0.50000),(-0.43750),1.00000,0.00000),arr((-0.37500),(-0.43750),0.76035,99.46232),arr((-0.50000),0.31250,0.33657,21.80141),arr((-0.18750),0.43750,0.37500,0.00000),arr(0.18750,0.43750,0.33657,(-21.80141)),arr(0.50000,0.31250,0.76035,(-99.46232)))) end
 elseif _switch=="j" then
  do return (arr(arr((-0.93750),(-0.87500),0.17678,(-45.00000)),arr((-0.81250),(-1.00000),0.18750,0.00000),arr((-0.62500),(-1.00000),0.22535,56.30993),arr((-0.50000),(-0.81250),0.25000,90.00000),arr((-0.50000),(-0.56250),0.56596,(-6.34019)),arr(0.06250,(-0.62500),0.50389,7.12502),arr(0.56250,(-0.56250),0.31250,36.86990),arr(0.81250,(-0.37500),0.38017,80.53768),arr(0.87500,0.00000,0.56596,96.34019),arr(0.81250,0.56250,0.44194,81.86990),arr(0.87500,1.00000,0.53400,(-110.55605)),arr(0.68750,0.50000,0.56250,(-90.00000)),arr(0.68750,(-0.06250),0.25769,(-104.03624)),arr(0.62500,(-0.31250),0.27951,(-153.43495)),arr(0.37500,(-0.43750),0.50000,180.00000),arr((-0.12500),(-0.43750),0.44194,171.86990),arr((-0.56250),(-0.37500),0.17678,(-135.00000)),arr((-0.68750),(-0.50000),0.25000,(-90.00000)),arr((-0.68750),(-0.75000),0.12500,180.00000),arr((-0.81250),(-0.75000),0.17678,(-135.00000)))) end
 elseif _switch=="z" then
  do return (arr(arr((-1.00000),0.00000,0.75000,0.00000),arr((-0.25000),0.00000,0.17678,(-45.00000)),arr((-0.12500),(-0.12500),0.25000,0.00000),arr(0.12500,(-0.12500),0.17678,45.00000),arr(0.25000,0.00000,0.75000,0.00000),arr(0.25000,0.00000,0.17678,135.00000),arr(0.12500,0.12500,0.25000,180.00000),arr((-0.12500),0.12500,0.17678,(-135.00000)),arr(0.00000,(-0.12500),0.25000,90.00000))) end
 elseif _switch=="d" then
  do return (arr(arr(0.93750,(-0.12500),0.31250,90.00000),arr(0.93750,0.18750,0.50000,180.00000),arr(0.43750,0.18750,0.31869,168.69007),arr(0.12500,0.25000,0.81250,180.00000),arr((-0.68750),0.25000,0.25769,(-165.96376)),arr((-0.93750),0.18750,0.13975,(-116.56505)),arr((-1.00000),0.06250,0.17678,(-45.00000)),arr((-0.87500),(-0.06250),0.93750,0.00000),arr(0.93750,(-0.12500),0.43750,180.00000),arr(0.50000,(-0.12500),0.39528,(-161.56505)),arr(0.12500,(-0.25000),0.56250,180.00000),arr((-0.43750),(-0.25000),0.13975,153.43495),arr((-0.56250),(-0.18750),0.12500,90.00000))) end
 elseif _switch=="b" then
  do return (arr(arr(0.56250,(-0.93750),1.81250,90.00000),arr(0.56250,0.87500,1.06250,180.00000),arr((-0.50000),0.87500,0.06250,(-90.00000)),arr((-0.50000),0.81250,0.38017,(-9.46232)),arr((-0.12500),0.75000,0.36443,(-30.96376)),arr(0.18750,0.56250,0.22535,(-56.30993)),arr(0.31250,0.37500,1.31250,(-90.00000)),arr(0.31250,(-0.93750),0.25000,0.00000))) end
 elseif _switch=="p" then
  do return (arr(arr((-0.31250),(-0.43750),0.62500,0.00000),arr(0.31250,(-0.43750),0.81250,90.00000),arr(0.31250,0.37500,0.62500,180.00000),arr((-0.31250),0.37500,0.81250,(-90.00000)))) end
 elseif _switch=="f" then
  do return (arr(arr(0.93750,0.25000,1.37500,180.00000),arr((-0.43750),0.25000,0.13975,(-153.43495)),arr((-0.56250),0.18750,0.13975,(-116.56505)),arr((-0.62500),0.06250,0.25000,180.00000),arr((-0.87500),0.06250,0.13975,(-153.43495)),arr((-1.00000),0.00000,0.13975,(-63.43495)),arr((-0.93750),(-0.12500),0.19764,(-18.43495)),arr((-0.75000),(-0.18750),0.19764,18.43495),arr((-0.56250),(-0.12500),0.22535,56.30993),arr((-0.43750),0.06250,0.87723,4.08562),arr(0.43750,0.12500,0.22535,33.69007),arr((-0.75000),(-0.18750),0.22535,(-146.30993)),arr((-0.75000),(-0.18750),0.22535,(-33.69007)))) end
 elseif true then
  do return (arr()) end
 end end
end
R05_DL=asTask(function(x,y,vx,draw_id,size)
 local vy,angle,speed
 vy=0.5
 angle=atan2(vy,vx)
 speed=((((vx ^ 2) + (vy ^ 2))) ^ 0.5)
 R05_SetDrawingLaser(x,y,speed,angle,BGW_BEAM_BLUE,0,8,draw_id,size)
end)
R05_SetDrawingLaser=asTask(function(x,y,speed,angle,graphic,delay,l_wid,draw_id,size)
 local objBase,objLasers,pos
 objBase=CreateShotA1(x,y,speed,angle,graphic,0)
 SetShotDisabled(objBase)
 ObjShot_SetAutoDelete(objBase,false)
 Obj_SetVisible(objBase,false)
 objLasers=arr()
 pos=GetDrawingPosition(draw_id)
 for i=0,(length(pos))-1 do
  objLasers=concat(objLasers,DrawLaser(objBase,l_wid,(60 * 999),graphic,delay,at(pos,i),size))
 end
 while truth((not truth(Obj_IsDeleted(objBase)))) do
  if truth((truth((ObjMove_GetY(objBase) > MinY)) and truth((not truth(CheckDispIN(objBase,(size * 1.5))))))) then
   do break end
  end
  wait(1)
 end
 Obj_Delete(objBase)
 for i=0,(length(objLasers))-1 do
  Obj_Delete(at(objLasers,i))
 end
end)
DrawLaser=function(parent,l_wid,timer,graphic,delay,pos,size)
 local laser_a,ol,ox,oy,len,sx,sy,obj,obj2
 laser_a=at(pos,3)
 ol=(l_wid / 4)
 ox=((ol / 2) * cos(laser_a))
 oy=((ol / 2) * sin(laser_a))
 len=(at(pos,2) * size)
 sx=(ObjMove_GetX(parent) + (at(pos,0) * size))
 sy=(ObjMove_GetY(parent) + (at(pos,1) * size))
 obj=My_CreateSimpleLaserA1((sx - ox),(sy - oy),laser_a,(len + ol),l_wid,timer,graphic,delay)
 ObjMove_AddPatternA1(obj,0,ObjMove_GetSpeed(parent),ObjMove_GetAngle(parent))
 ObjShot_SetAutoDelete(obj,false)
 obj2=My_CreateSimpleLaserA1((sx - (ox * 2)),(sy - (oy * 2)),laser_a,(len + (ol * 2)),(l_wid * 2),timer,graphic,delay)
 ObjMove_AddPatternA1(obj2,0,ObjMove_GetSpeed(parent),ObjMove_GetAngle(parent))
 ObjRender_SetColor(obj2,0,0,255)
 ObjShot_SetIntersectionEnable(obj2,false)
 ObjShot_SetAutoDelete(obj2,false)
 do return (arr(obj,obj2)) end
end
SetDrawingWall=asTask(function(items,muki)
 local size_rate,vy,vx,size,baseX,baseY,next_item,next_width
 size_rate=at(arr(0.8,0.9,1,1),Difficult)
 vy=0.5
 vx=1
 size=64
 baseX=(GetClipWidth - (size / 2))
 baseY=((MinY - size) + 1)
 next_item=0
 next_width=((ator(at(at(items,next_item),3)) * size) * 2)
 while truth((baseY < MaxY)) do
  if truth((baseX > (-size))) then
   local it,sx,sy
   it=at(at(items,next_item),0)
   sx=(((MinX + (GetClipWidth / 2)) + (((baseX - (GetClipWidth / 2))) * muki)) + ((ator(at(at(items,next_item),1)) * muki) * size))
   sy=(baseY + (ator(at(at(items,next_item),2)) * size))
   if truth((not truth(flgStopSetZako))) then
    R05_DL(sx,sy,(vx * muki),it,(size * size_rate))
   end
   baseX=baseX - next_width
   next_item=(((next_item + 1)) % length(items))
   next_width=((ator(at(at(items,next_item),3)) * size) * 2)
  end
  baseX=baseX + vx
  baseY=baseY + vy
  wait(1)
 end
end)
local CHAPTER_1,CHAPTER_2,CHAPTER_3,CHAPTER_3_Pre,CHAPTER_4,CHAPTER_5,CHAPTER_6,CHAPTER_7,CHAPTER_8
CHAPTER_1=function()
 local _CHAPTER_1
 _CHAPTER_1=asTask(function()
  DisplayStage(STAGE_ID,0)
  WaitRoad(phaseEx(8))
  ChapterStart(STAGE_ID,0,CHAPTER_ROAD)
  F02(MinX,(CenX - 64),8)
  F02(MaxX,(CenX + 64),8)
  WaitRoad(phaseEx((8 - 1)))
  F01(MaxX,(CenX - 32),3,true,0)
  WaitRoad(phaseEx(2))
  F01(MinX,(CenX + 32),3,true,0)
  WaitRoad(phaseEx(2.5))
  F01(CenX,CenX,1,true,2)
  WaitRoad(phaseEx(0.5))
  F01((MaxX + 128),(CenX + 64),3,true,0)
  F01((MinX - 128),(CenX - 64),3,true,0)
  WaitRoad(phaseEx(3))
  F01((CenX - 128),(CenX + 96),3,true,2)
  WaitRoad(phaseEx(2))
  F01((MaxX - 64),(CenX - 128),4,true,0)
 end)
 if truth((FLG_TEST_CHP > 1)) then
  do return  end
 end
 _CHAPTER_1()
 for _loop1=0,(((8 * 4) - 1))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_2=function()
 local _CHAPTER_2
 _CHAPTER_2=asTask(function()
  ChapterStart(STAGE_ID,1,CHAPTER_ROAD)
  F01b(MinX,(CenX + 64),(90 - 75),5,2)
  WaitRoad(phaseEx(1))
  F01b(MaxX,(CenX - 64),(90 + 75),5,2)
  WaitRoad(phaseEx(5))
  F01b(CenX,CenX,90,5,1)
  WaitRoad(phaseEx(3))
  F01((MaxX + 128),(CenX + 128),3,true,0)
  F01((MinX - 128),(CenX - 128),3,true,0)
  WaitRoad(phaseEx(3))
  F01b(MaxX,(CenX - 64),(90 + 75),5,2)
  WaitRoad(phaseEx(1))
  F01b(MinX,(CenX + 64),(90 - 75),5,2)
  WaitRoad(phaseEx(3))
  F01(MaxX,(CenX - 96),3,true,0)
  WaitRoad(phaseEx(2))
  F01(MinX,(CenX + 96),3,true,0)
  WaitRoad(phaseEx(2))
  F01b(MinX,(CenX + 64),(90 - 90),5,1)
  F01b(MaxX,(CenX - 64),(90 + 90),5,1)
  WaitRoad(phaseEx(4))
  F01(CenX,CenX,4,true,0)
 end)
 if truth((FLG_TEST_CHP > 2)) then
  do return  end
 end
 _CHAPTER_2()
 for _loop2=0,((8 * 2))-1 do
  WaitRoad(phase(1))
 end
 CHAPTER_3_Pre()
 for _loop3=0,(((8 * 2) - 6))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_3=function()
 local _CHAPTER_3
 _CHAPTER_3=asTask(function()
  SetAreaCommonData(CAREA_STAGE,"STG5R_CHP3",1)
  WaitRoad(phaseEx(5))
  ChapterStart(STAGE_ID,2,CHAPTER_ROAD)
 end)
 if truth((FLG_TEST_CHP > 3)) then
  do return  end
 end
 _CHAPTER_3()
 for _loop4=0,(((8 * 3) + 6))-1 do
  WaitRoad(phase(1))
 end
 NextStageScene()
 for _loop5=0,((8 * 1))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_3_Pre=asTask(function()
 local wait_phase
 wait_phase=0
 for i=(5)-1,1,-1 do
  F04(((CenX + 32) + (i * 4)),((MinY + 48) + (i * 14)),42,14,4,1,0,wait_phase)
  F04(((CenX - 32) - (i * 4)),((MinY + 48) + (i * 14)),(-42),14,4,(-1),0,wait_phase)
  wait_phase=wait_phase + 2
  WaitRoad(phaseEx(1))
 end
 for i=(1)-1,0,-1 do
  F04(((CenX + 32) + (i * 4)),((MinY + 48) + (i * 14)),42,14,3,1,1,wait_phase)
  F04(((CenX - 32) - (i * 4)),((MinY + 48) + (i * 14)),(-42),14,3,(-1),1,wait_phase)
  wait_phase=wait_phase + 2
  WaitRoad(phaseEx(1))
 end
 F04(CenX,(MinY + 24),0,0,1,0,2,wait_phase)
end)
CHAPTER_4=function()
 local _CHAPTER_4a,_CHAPTER_4b
 _CHAPTER_4a=asTask(function()
  F01(MaxX,(CenX - 32),3,true,0)
  WaitRoad(phaseEx(2))
  F01(MinX,(CenX + 32),3,true,0)
  WaitRoad(phaseEx(2))
  F01b(MinX,(CenX + 64),(90 - 75),5,2)
  WaitRoad(phaseEx(1))
  F01b(MaxX,(CenX - 64),(90 + 75),5,2)
  WaitRoad(phaseEx(5))
  F01(CenX,CenX,4,true,0)
  WaitRoad(phaseEx(2))
  F01((MaxX + 128),(CenX + 128),3,true,0)
  F01((MinX - 128),(CenX - 128),3,true,0)
  WaitRoad(phaseEx(2))
  F01b(CenX,CenX,90,5,1)
  WaitRoad(phaseEx(4))
  F01(MinX,(CenX - 64),3,true,0)
  WaitRoad(phaseEx(2))
  F01(MaxX,(CenX + 64),3,true,0)
  WaitRoad(phaseEx(2))
  F01(MinX,(CenX - 64),3,true,0)
  WaitRoad(phaseEx(2))
  F01b(MinX,(CenX + 64),(90 - 90),5,2)
  F01b(MaxX,(CenX - 64),(90 + 90),5,2)
  WaitRoad(phaseEx(2))
  F01b(CenX,CenX,90,5,1)
  WaitRoad(phaseEx(4))
 end)
 _CHAPTER_4b=asTask(function()
  I01(arr(arr((1 / 14),(MinY + 64),0.5),arr((2 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((7 / 14),(MinY + 64),0.5),arr((10 / 14),(MinY + 64),1),arr((11 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((13 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5),arr((13 / 14),(MinY + 64),0.5),arr((17 / 14),(MinY + 64),0.5),arr((13 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5),arr((7 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((2 / 14),(MinY + 64),1),arr((4 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((10 / 14),(MinY + 64),0.5),arr((7 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((2 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((1 / 15),(MinY + 64),0.75),arr((2 / 15),(MinY + 64),(1 / 8)),arr((1 / 15),(MinY + 64),(1 / 8)),arr(((-3) / 15),(MinY + 64),1)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((1 / 14),(MinY + 64),0.5),arr((2 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((7 / 14),(MinY + 64),0.5),arr((10 / 14),(MinY + 64),1),arr((11 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((13 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5),arr((13 / 14),(MinY + 64),0.5),arr((17 / 14),(MinY + 64),0.5),arr((13 / 14),(MinY + 64),0.5),arr((12 / 14),(MinY + 64),0.5),arr((7 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((2 / 14),(MinY + 64),1),arr((4 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((4 / 14),(MinY + 64),0.5),arr((6 / 14),(MinY + 64),0.5),arr((2 / 14),(MinY + 64),0.5),arr((1 / 14),(MinY + 64),0.5)),1,90)
  WaitRoad(phaseEx(4))
  I01(arr(arr((1 / 15),(MinY + 64),0.75),arr((2 / 15),(MinY + 64),(1 / 8)),arr((1 / 15),(MinY + 64),(1 / 8)),arr(((-3) / 15),(MinY + 64),1)),1,90)
 end)
 if truth((FLG_TEST_CHP > 4)) then
  do return  end
 end
 _CHAPTER_4a()
 for _loop6=0,(((8 * 4) - 2))-1 do
  WaitRoad(phase(1))
 end
 _CHAPTER_4b()
 for _loop7=0,((((8 * 4) * 1) + 2))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_5=function()
 local _CHAPTER_5
 _CHAPTER_5=asTask(function()
  local F01_Fever
  F01_Fever=asTask(function()
   for i=0,(12)-1 do
    local ox,os
    ox=(64 + (rand((-1),1) * 32))
    os=(0.75 - ((i / 12) * 0.5))
    F01c(((CenX + ox) + 256),(CenX + ox),os,90,2,0)
    F01c(((CenX - ox) - 256),(CenX - ox),os,90,2,0)
    WaitRoad(phaseEx(0.5))
   end
  end)
  ChapterStart(STAGE_ID,4,CHAPTER_ROAD)
  for i=(4)-1,1,-1 do
   if truth(((i % 2) == 0)) then
    F04b(((CenX - 84) - (42 * 2)),(((MinY + 32) + (i * 16)) - (14 * 2)),42,14,3,0,(-1),0,0)
    F04b((CenX - 42),((MinY + 32) + (i * 16)),42,0,3,3,0,0,0)
    F04b((CenX + 84),((MinY + 32) + (i * 16)),42,(-14),3,6,1,0,0)
   else
    F04b(((CenX + 84) + (42 * 2)),(((MinY + 32) + (i * 16)) - (14 * 2)),(-42),14,3,0,1,0,0)
    F04b(((CenX - 42) + (42 * 2)),((MinY + 32) + (i * 16)),(-42),0,3,3,0,0,0)
    F04b((CenX - 84),((MinY + 32) + (i * 16)),(-42),(-14),3,6,(-1),0,0)
   end
   WaitRoad(phaseEx(2))
  end
  F04b(CenX,(MinY + 32),0,0,1,0,0,2,0)
  WaitRoad(phaseEx((2 + 8)))
  for i=0,(3)-1 do
   F05((MinX - 64),(CenY - (i * 64)),((CenX - 160) + (i * 32)),(CenY - (i * 72)),3,36,phaseEx((3 - (i * 0.5))),phaseEx((2 + 2)),1)
   WaitRoad(phaseEx(0.5))
  end
  WaitRoad(phaseEx(0.5))
  for i=0,(3)-1 do
   F05((MaxX + 64),(CenY - (i * 64)),((CenX + 160) - (i * 32)),(CenY - (i * 72)),3,36,phaseEx((3 - (i * 0.5))),phaseEx(2),1)
   WaitRoad(phaseEx(0.5))
  end
  WaitRoad(phaseEx(0.5))
  WaitRoad(phaseEx(1))
  F05(CenX,(MinY - 96),CenX,(MinY + 108),3,48,phaseEx(0),phaseEx(1),2)
  WaitRoad(phaseEx(3))
  F01_Fever()
  WaitRoad(phaseEx(5))
  F05b(CenX,(CenY - 512),CenX,CenY,9,phaseEx((8 * 4)),4,46)
  F05b(CenX,(CenY - 512),CenX,CenY,5,phaseEx((8 * 4)),5,54)
  while truth((not truth(GetAreaCommonData(CAREA_STAGE,"STG5R_CHP5",0)))) do
   wait(1)
  end
  ResetPlayerInvincibility(180)
  waitEx(60)
  SetItemCollect(120)
  waitEx(60)
  DeleteShotAll(TYPE_ALL,TYPE_FADE)
 end)
 if truth((FLG_TEST_CHP > 5)) then
  do return  end
 end
 NextStageScene()
 _CHAPTER_5()
 for _loop8=0,(((8 * 4) * 2))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_6=function()
 local _CHAPTER_6
 _CHAPTER_6=asTask(function()
  ChapterStart(STAGE_ID,5,CHAPTER_ROAD)
  F06(CenX,(CenX + 96),3,2)
  WaitRoad(phaseEx(2))
  F06(CenX,(CenX - 96),3,2)
  WaitRoad(phaseEx(5))
  F06((MinX + 128),(CenX + 64),3,2)
  WaitRoad(phaseEx(2))
  F06((MaxX - 128),(CenX - 64),3,2)
  WaitRoad(phaseEx(2))
  F06((MinX + 64),(CenX - 32),3,2)
  WaitRoad(phaseEx(2))
  F06((MaxX - 64),(CenX + 32),3,2)
  WaitRoad(phaseEx(3))
  for i=0,(32)-1 do
   F07_single(105,(((-i) * 137.5) / 2),(-1),0)
   WaitRoad(phaseEx((2 / 32)))
  end
  WaitRoad(phaseEx(3))
  for i=0,(32)-1 do
   F07_single(60,((i * 137.5) / 2),1,0)
   WaitRoad(phaseEx((2 / 32)))
  end
  WaitRoad(phaseEx(2))
  for i=0,(32)-1 do
   F07_single(150,(i * 137.5),(-1),0)
   WaitRoad(phaseEx((2 / 32)))
  end
 end)
 if truth((FLG_TEST_CHP > 6)) then
  do return  end
 end
 _CHAPTER_6()
 for _loop9=0,(((8 * 4) - 2))-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_7=function()
 local _CHAPTER_7a
 _CHAPTER_7a=asTask(function()
  SetDrawingWall(arr(arr("i","0","-0.8","0"),arr("n","0","0","0"),arr("d","0","0.6","1.2"),arr("o","0","0","1"),arr("z","0","-0.6","0"),arr("i","0","0.4","1"),arr("n","0","0","1.2")),(-1))
  F08(1)
  WaitRoad(phaseEx(4))
  SetDrawingWall(arr(arr("k","0","0","0.9"),arr("a","0","0","0.5"),arr("i","0","0","0.6"),arr("s","0","0","0.5"),arr("e","0","0","0.9"),arr("n","0","-0.3","0"),arr("d","0","0.4","1"),arr("o","0","0","1.1")),1)
  WaitRoad(phaseEx(4))
  F08((-1))
  WaitRoad(phaseEx(4))
  SetDrawingWall(arr(arr("s","0.1","0","0.8"),arr("i","0","0.75","0"),arr("z","0","0","0"),arr("i","0","-0.75","1"),arr("m","0","0","0.6"),arr("i","0","-0.35","0.6")),(-1))
  WaitRoad(phaseEx(4))
  F08(1)
  WaitRoad(phaseEx(4))
  SetDrawingWall(arr(arr("b","0","0","0.9"),arr("o","0","0","0.9"),arr("s","0","0","0.3"),arr("s","0","0","0.45"),arr("i","0","0.5","0.55"),arr("s","0","0","0.65"),arr("t","0","-0.5","0"),arr("h","0","0.5","0.9"),arr("o","0","0","1"),arr("t","0","-0.5","0"),arr("h","0","0.5","0.9")),1)
  WaitRoad(phaseEx(4))
  F08((-1))
  WaitRoad(phaseEx(4))
  SetDrawingWall(arr(arr("m","0","0","1"),arr("i","0","0.5","0"),arr("r","0","-0.5","1"),arr("u","0","0","1"),arr("k","0","0.5","1"),arr("a","0","0","1"),arr("n","0","-0.5","0"),arr("i","0","0.5","1")),(-1))
  WaitRoad(phaseEx(4))
  F08(1)
  WaitRoad(phaseEx(4))
  SetDrawingWall(arr(arr("s","0","0","0.5"),arr("e","0","0","0.5"),arr("t","-0.15","-0.5","0"),arr("i","-0.15","0.5","0.7"),arr("s","0","0","0.6"),arr("g","0","-0.35","0.7"),arr("o","0","0","1"),arr("d","-0.1","0.5","1")),1)
 end)
 if truth((FLG_TEST_CHP > 7)) then
  do return  end
 end
 _CHAPTER_7a()
 for _loop10=0,(52)-1 do
  WaitRoad(phase(1))
 end
end
CHAPTER_8=function()
 local _CHAPTER_8
 _CHAPTER_8=asTask(function()
  ChapterStart(STAGE_ID,7,CHAPTER_ROAD)
  SetEnemyMBoss(CenX,(MinY + 96),1,270,0,0)
 end)
 if truth((FLG_TEST_CHP > 8)) then
  do return  end
 end
 _CHAPTER_8()
 for _loop11=0,(((8 * 4) + 2))-1 do
  WaitRoad(phase(1))
 end
end
HSoB5.chapters={CHAPTER_1,CHAPTER_2,CHAPTER_3,CHAPTER_4,CHAPTER_5,CHAPTER_6,CHAPTER_7,CHAPTER_8}
HSoB5.resetPhase=function()PhaseTotal=0 end
