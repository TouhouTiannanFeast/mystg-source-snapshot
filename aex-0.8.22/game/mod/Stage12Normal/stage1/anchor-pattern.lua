local M={interval=4,fade_frames=30,launch_wait=120,edges={l=-176,r=176,b=-192,t=192}}
function M.profile(original)
 return {original=original,speed_scale=original and 1 or 2/3,density_scale=original and 1 or 1/3,trail_speed_scale=original and 1 or 1/2,return_visible=original}
end
function M.keep(i,p) return p.original or i%3==0 end
function M.speed(age,p) return 7*math.min(age/80,1)^4*p.speed_scale end
function M.hit(x,y) local e=M.edges;return x<=e.l or x>=e.r or y<=e.b or y>=e.t end
function M.trail(angle,age,p)
 local out={};local spread=age/4*0.19635*180/math.pi
 for stream=1,2 do for layer=0,1 do for side=0,1 do
  out[#out+1]={angle=angle+180+(side==0 and -1 or 1)*spread/2,
   speed=(0.8-(0.8-0.2)*layer/2)*p.trail_speed_scale,
   accel=(stream==1 and 0.05 or 0.013333334)*p.trail_speed_scale}
 end end end
 return out
end
function M.medium_speed(initial,accel,age)
 return initial+math.max(0,math.min(age-59,60))*accel
end
function M.impact_speed(initial,age,p)
 return initial+(0.06*p.speed_scale-initial)*math.min(age+1,60)/60
end
function M.move_angle(x,source_y,px,rad,mod3)
 local a
 if x< -70 then a=rad/3
 elseif x>70 then a=rad/3+math.pi
 else
  a=rad/4
  if (x<px and mod3==0) or (x>=px and mod3~=0) then a=a+math.pi end
 end
 while a>math.pi do a=a-2*math.pi end;while a< -math.pi do a=a+2*math.pi end
 if source_y<96 then a=math.abs(a) elseif source_y>160 then a=-math.abs(a) end
 if math.abs(a+math.pi/2)<=0.05 then a=-math.pi/2+(a<=-math.pi/2 and -0.05 or 0.05)
 elseif math.abs(a-math.pi/2)<=0.05 then a=math.pi/2+(a<math.pi/2 and -0.05 or 0.05) end
 return -a*180/math.pi
end
function M.outside(x,y,w,h)
 return x+w/2<=-192 or x-w/2>=192 or y-h/2>=288 or y+h/2<=-224
end
return M
