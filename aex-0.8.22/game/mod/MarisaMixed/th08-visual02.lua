-- Original TH08 visual data only. This module does not change projectile motion,
-- attack schedules, beam collision, or any inherited combat parameter.
TH08Visual02={};local K=TH08Visual02
local spin={[12]=-0.05235988,[13]=0.05235988,[14]=-0.03141593,[15]=0.03141593}
function K.star(typ,color,age)
 if not spin[typ]then return end
 local small=typ<=13;local count=small and 16 or 8
 local c=math.max(0,math.min(count-1,math.floor(color)))
 return tostring((small and 246 or 262)+c),spin[typ]*180/math.pi*age
end
function K.spark(age)
 local t=math.max(0,age);local rows={}
 local initial={0.1,0.05,0.03,0.02};local final={3,2.5,2,1.5};local red={255,224,192,128}
 local a=96
 if t>=90 and t<120 then a=96+(255-96)*(t-90)/30 elseif t>=120 then a=255 end
 if t>=310 then a=255*math.max(0,1-(t-310)/60)end
 for i=1,4 do
  local k=math.max(0,math.min(1,(t-60)/60));k=1-(1-k)^2
  rows[i]={x=295*math.min(1,t/60)^2,sx=2.3*math.min(1,t/60)^2,sy=initial[i]+(final[i]-initial[i])*k,
   a=a,r=255,g=255+(red[i]-255)*math.min(1,t/60),b=255+(red[i]-255)*math.min(1,t/60)}
 end
 return rows
end
function K.renderStar(o)
 local key,angle=K.star(o.sourceType,o.sourceColor,o.age)
 if not key then return false end
 local row=TH08Art02[key];SetImageState(row.image,'',Color(255,255,255,255))
 Render(row.image,o.x,o.y,angle,o.hscale or 1,o.vscale or 1);return true
end
function K.renderSpark(o)
 local row=TH08Art02.spark
 for _,v in ipairs(K.spark(o.timer))do
  SetImageState(row.image,'mul+add',Color(v.a,v.r,v.g,v.b))
  Render(row.image,o.x+v.x*cos(o.rot),o.y+v.x*sin(o.rot),o.rot,v.sx,v.sy)
 end
end
