local R={period=210,mothers=3,children=3,proximity=105,warning=30,homing=36,child_life=78}
function R.turn(angle,target,limit)
    local delta=(target-angle+180)%360-180
    return angle+math.max(-limit,math.min(limit,delta))
end
function R.trigger(age,x,y,px,py)
    return age>=45 and ((x-px)^2+(y-py)^2<=R.proximity^2 or age>=150)
end
return R
