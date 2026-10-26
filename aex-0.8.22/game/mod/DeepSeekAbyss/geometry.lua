-- Fixed geometry for the four-phase playable interpretation (AEX coordinates).
local G={phase_frames=900,total_frames=3600}
local rad=math.pi/180
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
function G.wrap(a) return (a+180)%360-180 end
function G.sonar(wave)
    local mid=-90+wave*3.2
    local fork=18+10*math.sin(wave*21*rad)
    return mid-fork,mid+fork,13
end
function G.sonar_open(angle,wave)
    local a,b,half=G.sonar(wave)
    return math.abs(G.wrap(angle-a))<half or math.abs(G.wrap(angle-b))<half
end
function G.rect(layer,t)
    local u=clamp(t/899,0,1)
    local w=(184-20*layer)-(80-6*layer)*u
    local h=(210-18*layer)-(66-4*layer)*u
    return {l=-w,r=w,b=-26-h,t=-26+h,cx=0,cy=-26,w=w,h=h}
end
function G.bounce(x,y,dx,dy,r)
    local nx,ny=x+dx,y+dy
    local count=0
    if nx<r.l then nx=r.l+(r.l-nx);dx=math.abs(dx);count=count+1
    elseif nx>r.r then nx=r.r-(nx-r.r);dx=-math.abs(dx);count=count+1 end
    if ny<r.b then ny=r.b+(r.b-ny);dy=math.abs(dy);count=count+1
    elseif ny>r.t then ny=r.t-(ny-r.t);dy=-math.abs(dy);count=count+1 end
    return clamp(nx,r.l,r.r),clamp(ny,r.b,r.t),dx,dy,count
end
function G.edge(r,edge,u)
    if edge==1 then return r.l+(r.r-r.l)*u,r.b
    elseif edge==2 then return r.r,r.b+(r.t-r.b)*u
    elseif edge==3 then return r.r-(r.r-r.l)*u,r.t
    else return r.l,r.t-(r.t-r.b)*u end
end
-- Power Resonance-inspired echo cycle: contract for 320f, then release for 80f.
G.echo_period=400
G.echo_capture=320
function G.echo_rect(t)
    local u=clamp((t%G.echo_period)/G.echo_capture,0,1)
    local w=164-74*u
    local b=-212+48*u
    local top=156-64*u
    return {l=-w,r=w,b=b,t=top,cx=0,cy=(b+top)/2,w=w,h=(top-b)/2}
end
function G.echo_angle(cycle,wave,index)
    local offset=((cycle*173+wave*97+41)%101)/100*6-3
    return -90+offset+(index-8.5)*10
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
    assert(released.w==90 and released.b==-164 and released.t==92,'release boundary changed')
    for wave=0,6 do assert(math.abs(G.echo_angle(0,wave,17)-G.echo_angle(0,wave,0)-170)<0.001,'echo arc geometry') end
end
function G.pose(t)
    local u=clamp((t-120)/660,0,1)
    return 300-720*u,-55+18*math.sin(math.pi*u)
end
function G.seam(u) return -60+0.10*u+7*math.sin(u/70) end
G.seam_half=19
function G.in_whale(u,v)
    local body=((u+12)/158)^2+(v/146)^2<=1
    local tail=u>=116 and u<=218 and math.abs(v)>=0.44*(u-116) and math.abs(v)<=0.86*(u-116)+12
    return body or tail
end
function G.whale_points()
    local points={}
    for u=-170,218,10 do
        for v=-150,150,10 do
            if G.in_whale(u,v) and math.abs(v-G.seam(u))>=G.seam_half then
                points[#points+1]={u=u,v=v}
            end
        end
    end
    return points
end
function G.selftest()
    G.echo_test()
    for layer=1,3 do
        for t=0,899,13 do
            local r=G.rect(layer,t)
            assert(r.l<r.r and r.b<r.t,'empty context rectangle')
            local x,y,dx,dy,n=G.bounce(r.r-1,r.t-1,3,4,r)
            assert(n==2 and dx<0 and dy<0 and x<=r.r and y<=r.t,'corner reflection')
            x,y,dx,dy,n=G.bounce(r.l+1,r.b+1,-3,-4,r)
            assert(n==2 and dx>0 and dy>0 and x>=r.l and y>=r.b,'opposite reflection')
        end
    end
    for wave=0,18 do
        local a,b=G.sonar(wave)
        assert(G.sonar_open(a,wave) and G.sonar_open(b,wave),'sonar gaps missing')
    end
    local points=G.whale_points()
    assert(#points>500 and #points<1000,'whale density budget')
    for _,p in ipairs(points) do assert(math.abs(p.v-G.seam(p.u))>=G.seam_half,'whale point in belly seam') end
    -- Belly path traverses the reachable screen and exits left; collision margin is >15 px.
    local x,y=G.pose(450)
    assert(math.abs(x)<100 and y+G.seam(0)>-200 and y+G.seam(0)<0,'unreachable belly')
    x=G.pose(780); assert(x+218< -192,'whale tail did not exit screen')
    return #points
end
return G
