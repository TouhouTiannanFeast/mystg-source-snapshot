local G={}
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
function G.bounce(x,y,dx,dy,r)
    local nx,ny=x+dx,y+dy
    local count=0
    if nx<r.l then nx=r.l+(r.l-nx);dx=math.abs(dx);count=count+1
    elseif nx>r.r then nx=r.r-(nx-r.r);dx=-math.abs(dx);count=count+1 end
    if ny<r.b then ny=r.b+(r.b-ny);dy=math.abs(dy);count=count+1
    elseif ny>r.t then ny=r.t-(ny-r.t);dy=-math.abs(dy);count=count+1 end
    return clamp(nx,r.l,r.r),clamp(ny,r.b,r.t),dx,dy,count
end
G.echo_period=400
G.echo_capture=320
G.echo_count=25
function G.echo_rect(t)
    local u=clamp((t%G.echo_period)/G.echo_capture,0,1)
    local w=164+(67.5-164)*u
    local h=184+(96-184)*u
    local cy=-28-8*u
    local b,top=cy-h,cy+h
    return {l=-w,r=w,b=b,t=top,cx=0,cy=(b+top)/2,w=w,h=(top-b)/2}
end
function G.echo_angle(cycle,wave,index)
    local offset=((cycle*173+wave*97+41)%101)/100*6-3
    return -90+offset+(index-(G.echo_count-1)/2)*(170/(G.echo_count-1))
end
function G.echo_test()
    for cycle=0,2 do
        local x,y,dx,dy=0,120,2.5,-2.5
        for t=0,319 do
            local r=G.echo_rect(cycle*400+t)
            x,y,dx,dy=G.bounce(x,y,dx,dy,r)
            assert(x>=r.l and x<=r.r and y>=r.b and y<=r.t,'echo escaped moving field')
        end
    end
    local first,last=G.echo_rect(0),G.echo_rect(319)
    assert(last.w<first.w and last.b>first.b and last.t<first.t,'echo did not contract')
    local released=G.echo_rect(399)
    assert(released.w==67.5 and released.b==-132 and released.t==60,'release boundary changed')
    for wave=0,6 do assert(math.abs(G.echo_angle(0,wave,G.echo_count-1)-G.echo_angle(0,wave,0)-170)<0.001,'echo arc geometry') end
end

G.move_speed=0.65
function G.translate(r,x,y)
 return {l=r.l+x,r=r.r+x,b=r.b+y,t=r.t+y,cx=r.cx+x,cy=r.cy+y,w=r.w,h=r.h}
end
function G.carrier(px,py,first)
 local r=G.echo_rect(0)
 if first then return {x=-r.cx,y=-r.cy,vx=0,vy=G.move_speed,stopped=false} end
 local r=G.echo_rect(0);local x,y=r.cx-px,r.cy-py
 local d=math.sqrt(x*x+y*y);if d<0.001 then x,y,d=0,1,1 end
 return {x=0,y=0,vx=x/d*G.move_speed,vy=y/d*G.move_speed,stopped=false}
end
function G.advance(c,t)
 if t%G.echo_period>=G.echo_capture then return 0,0 end
 local r=G.translate(G.echo_rect(t),c.x,c.y);local k=1
 if c.vx>0 then k=math.min(k,(192-r.r)/c.vx) elseif c.vx<0 then k=math.min(k,(-192-r.l)/c.vx) end
 if c.vy>0 then k=math.min(k,(224-r.t)/c.vy) elseif c.vy<0 then k=math.min(k,(-224-r.b)/c.vy) end
 k=clamp(k,0,1);local dx,dy=c.vx*k,c.vy*k
 c.x,c.y=c.x+dx,c.y+dy
 c.stopped=k<1 -- Contact limits this frame only; contraction reopens space.
 return dx,dy
end
return G
