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
-- TH13 st02bs BossCard1_at2 F0..F3, source Y-down to LuaSTG Y-up.
G.echo_start=150
function G.echo_rect(t)
    local u=clamp((t%G.echo_period)/G.echo_capture,0,1)
    local w=120+(64-120)*u
    local top=224-(-20+40*u)
    local bottom=224-(180-40*u)
    return {l=-w,r=w,b=bottom,t=top,cx=0,cy=(bottom+top)/2,w=w,h=(top-bottom)/2}
end
function G.echo_angle(cycle,wave,index)
    local offset=((cycle*173+wave*97+41)%101)/100*6-3
    return -90+offset+(index-(G.echo_count-1)/2)*(170/(G.echo_count-1))
end
return G
